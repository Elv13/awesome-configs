local ipairs       = ipairs
local pairs        = pairs
local print        = print
local table        = table
local common       = require( "ultiLayout.common" )
local edge         = require( "ultiLayout.edge" )
local splitter     = require( "ultiLayout.widgets.splitter" )
local beautiful    = require( "beautiful" )

module("ultiLayout.layouts.linear")

local function cg_to_idx(list,cg)
    for k,v in ipairs(list) do
        if v == cg then return k end
    end
    return nil
end

local function new(cg,orientation)
   local data     = { ratio = {} }
   local edges    = {}
   local splitter1,splitter2
   
    if orientation == "horizontal" then
        splitter1 = splitter(cg,{y=function() return cg.y end              ,x=function() return cg.x+cg.width/2 end, index=1 ,direction="bottom"})
        splitter2 = splitter(cg,{y=function() return cg.y+cg.height-48 end ,x=function() return cg.x+cg.width/2 end          ,direction="top"   })
    else
        splitter1 = splitter(cg,{y=function() return cg.y+cg.height/2 end  ,x=function() return cg.x end           , index=1 ,direction="right" })
        splitter2 = splitter(cg,{y=function() return cg.y+cg.height/2 end  ,x=function() return cg.x+cg.width-48 end         ,direction="left"  })
    end
   
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
   
   local function ratio_to_percent(ratio)
       return (ratio or get_average(true)) / sum_ratio(true)
   end
   
    local function gen_margin(lenght,count)
        return (lenght/count) - (lenght-(beautiful.border_width2*(count-1)))/count
    end
    
    local function update_decorator()
       for k,v in pairs(edges) do for k2,v2 in pairs(v or {}) do
           v2:update()
       end end
       splitter1:update()
       splitter2:update()
    end
   
   function data:update()
       local relX,relY,margin = cg.x,cg.y,gen_margin(cg[orientation == "horizontal" and "width" or "height"],#cg:childs())
       for k,v in ipairs(cg:childs()) do
           if v.visible ~= false and (#v:childs() > 0 or v:has_client() == true) then --TODO visible childs
                local width  = ( orientation == "horizontal" ) and cg.width or ratio_to_percent(data.ratio[k])*cg.width
                local height = ( orientation == "vertical"   ) and cg.height or ratio_to_percent(data.ratio[k])*cg.height
                local pad_h,pad_v = ( orientation == "vertical"   ) and 0 or margin,( orientation == "vertical"   ) and margin or 0
                v:geometry({width = width-pad_v, height = height-pad_h, x = relX, y = relY })
                v:repaint()
                relY     = relY + (( orientation == "horizontal" ) and v.height+beautiful.border_width2 or 0)
                relX     = relX + (( orientation == "vertical"   ) and v.width+beautiful.border_width2  or 0)
           end
       end
       update_decorator()
   end
    
   function data:add_child(child_cg,index)
        local current_count = #cg:childs()
        local index  = index or current_count + 1
        data.ratio[current_count+1] = child_cg.default_percent and (child_cg.default_percent*sum_ratio()) or get_average()
        --child_cg:add_signal("cg::swapped",swap)
        if current_count > 0 and current_count+1 == index then--TODO implement other cases
            local anEdge = edge({cg1=cg:childs()[current_count],cg2=child_cg})
            anEdge:add_signal("distance_change::request",function(_e, delta)
                if _e.cg1.parent == cg and _e.cg2.parent == cg and orientation == _e.orientation then --TODO dead code?
                    local diff = (sum_ratio()/cg[(orientation == "horizontal") and "height" or "width"])*delta
                    data.ratio[ current_count   ] = data.ratio[ current_count   ] + diff
                    data.ratio[ current_count+1 ] = data.ratio[ current_count+1 ] - diff
                    self:update()
                end
            end)
            edges[cg:childs()[current_count]]    = edges[cg:childs()[current_count]] or {}
            edges[cg:childs()[current_count]][child_cg] = anEdge
        end
        return child_cg
   end
   cg:add_signal("visibility::changed",update_decorator)
   return data
end

common.add_new_layout( "horizontal", function(cg) return new(cg,"horizontal" ) end)
common.add_new_layout( "vertical"  , function(cg) return new(cg,"vertical"   ) end)