local ipairs       = ipairs
local pairs        = pairs
local print        = print
local common       = require( "ultiLayout.common" )
local edge         = require( "ultiLayout.edge" )
local splitter     = require( "ultiLayout.widgets.splitter" )

module("ultiLayout.layouts.linear")

local function new(cg,orientation)
   local data     = { ratio = {} }
   local splitter1,splitter2
   
   --local function pos_or_size(p_or_x,side) return (p_or_x == "pos") and cg[side]/2 or cg[side]-48 end
    if orientation == "horizontal" then
        splitter1 = splitter(cg,{y=function() return cg.y end              ,x=function() return cg.x+cg.width/2 end, index=1 ,direction="bottom"})
        splitter2 = splitter(cg,{y=function() return cg.y+cg.height-48 end ,x=function() return cg.x+cg.width/2 end          ,direction="top"   })
    else
        splitter1 = splitter(cg,{y=function() return cg.y+cg.height/2 end  ,x=function() return cg.x end           , index=1 ,direction="right" })
        splitter2 = splitter(cg,{y=function() return cg.y+cg.height/2 end  ,x=function() return cg.x+cg.width-48 end         ,direction="left"  })
    end
    cg.decorations:add_decoration(splitter1,{class="splitter",position="top",align="beginning",ontop=true,update_callback= function() splitter1:update() end})
    cg.decorations:add_decoration(splitter2,{class="splitter",position="top",align="beginning",ontop=true,update_callback= function() splitter2:update() end})
   
   local function sum_ratio(only_visible)
        local sumratio = 0
        for k,v in ipairs(cg:childs()) do
            if (only_visible == true and v.visible ~= false and (#v:childs() > 0 or v:has_client() == true)) or only_visible ~= true then --TODO visible childs
                sumratio = sumratio + (data.ratio[k] or 1)
            end
        end
        return sumratio
   end
   
   local function get_average(only_visible)
       if #cg:childs() == 0 then return 1 end
       return (sum_ratio(only_visible) / #((only_visible == true) and cg:visible_childs() or cg:childs())) or 1
   end
   
   local function size(ratio,w_or_h,ori)
       return ( orientation == ori ) and cg.workarea[w_or_h] or ((ratio or get_average(true)) / sum_ratio(true))*cg.workarea[w_or_h]
   end
   
   function data:update()
       local relX,relY = cg.workarea.x,cg.workarea.y
       for k,v in ipairs(cg:childs()) do
           if v.visible ~= false and (#v:childs() > 0 or v:has_client() == true) then --TODO visible childs
                v:geometry({width = size(data.ratio[k],"width","horizontal"), height = size(data.ratio[k],"height","vertical"), x = relX, y = relY })
                v:repaint()
                relY = relY + (( orientation == "horizontal" ) and v.height or 0)
                relX = relX + (( orientation == "vertical"   ) and v.width  or 0)
           end
       end
   end
    
   function data:add_child(child_cg,index)
        local current_count = #cg:childs()
        local index  = index or current_count + 1
        data.ratio[current_count+1] = child_cg.default_percent and (child_cg.default_percent*sum_ratio()) or get_average()
            local anEdge = edge({cg1=cg:childs()[current_count] or nil,cg2=child_cg,orientation=orientation})
            anEdge:add_signal("distance_change::request",function(_e, delta)
                if _e.cg2 then
                    local diff = (sum_ratio()/cg[(orientation == "horizontal") and "height" or "width"])*delta
                    local idx2 = cg:cg_to_idx(_e.cg2)
                    data.ratio[ idx2-1 ] = data.ratio[ idx2-1 ] + diff
                    data.ratio[ idx2 ] = data.ratio[ idx2 ] - diff
                    self:update()
                end
            end)
            child_cg.decorations:add_decoration(anEdge,{class="edge",position=((orientation == "vertical") and "left" or "top"),align="ajust",update_callback= function() anEdge:update() end})
        return child_cg
   end
   return data
end

common.add_new_layout( "horizontal", function(cg) return new(cg,"horizontal" ) end)
common.add_new_layout( "vertical"  , function(cg) return new(cg,"vertical"   ) end)