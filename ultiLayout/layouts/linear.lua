local ipairs       = ipairs
local pairs        = pairs
local common       = require( "ultiLayout.common" )
local edge         = require( "ultiLayout.edge" )
local splitter     = require( "ultiLayout.widgets.splitter" )

module("ultiLayout.layouts.linear")

local function new(cg,orientation)
    local data     = { ratio = {} }
    local splitter1 = splitter(cg,{direction=(orientation == "horizontal") and "bottom" or "right", index=1})
    local splitter2 = splitter(cg,{direction=(orientation == "horizontal") and "top"    or "left" ,        })
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
        local index,anEdge = index or  #cg:childs()+1,edge({cg=child_cg,orientation=orientation})
        data.ratio[#cg:childs()+1] = child_cg.default_percent and (child_cg.default_percent*sum_ratio()) or get_average()
        anEdge:add_signal("distance_change::request",function(_e, delta)
            local diff,idx2 = (sum_ratio()/cg[(orientation == "horizontal") and "height" or "width"])*delta,cg:cg_to_idx(child_cg)
            data.ratio[ idx2-1 ] = data.ratio[ idx2-1 ] + diff
            data.ratio[ idx2   ] = data.ratio[ idx2   ] - diff
            self:update()
        end)
        child_cg.decorations:add_decoration(anEdge,{class="edge",position=((orientation == "vertical") and "left" or "top"),align="ajust",update_callback= function() anEdge:update() end})
        return child_cg
   end
   return data
end

common.add_new_layout( "horizontal", function(cg) return new(cg,"horizontal" ) end)
common.add_new_layout( "vertical"  , function(cg) return new(cg,"vertical"   ) end)