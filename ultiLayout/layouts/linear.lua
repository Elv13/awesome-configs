local ipairs       = ipairs
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
   local edges   = {}
   
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
   
   local function get_cg_idx(child)
       for k,v in ipairs(cg:childs()) do
           if v == child then
               return k
           end
       end
       return nil
   end
   
   function data:show_splitters(show,horizontal,vertical)
       if orientation == "horizontal" then
            local asplitter = splitter(cg,{y=cg.y,x=cg.x+cg.width/2,index=1,direction="bottom"})
            local asplitter = splitter(cg,{y=cg.y+cg.height-48,x=cg.x+cg.width/2,direction="top"})
       else
            local asplitter = splitter(cg,{y=cg.y+cg.height/2,x=cg.x,index=1,direction="right"})
            local asplitter = splitter(cg,{y=cg.y+cg.height/2,x=cg.x+cg.width-48,direction="left"})
       end
       for k,v in ipairs(cg:childs()) do
           v:show_splitters(show,horizontal,vertical)
       end
   end
   
    function data:gen_edge(edge_list)
        local prev = nil
        for k,v in ipairs(cg:childs()) do
            if prev  then
                if not edges[prev] or not edges[prev][v] then
                    local anEdge = edge({})
                    anEdge:add_signal("distance_change::request",function(_v, delta)
                        if _v.cg1.parent == cg and _v.cg2.parent == cg and orientation == _v.orientation then
                            local cg1_ratio_k, cg2_ratio_k = get_cg_idx(_v.cg1),get_cg_idx(_v.cg2)
                            local diff = (sum_ratio()/cg[(orientation == "horizontal") and "height" or "width"])*delta
                            data.ratio[cg1_ratio_k] = data.ratio[cg1_ratio_k] + diff
                            data.ratio[cg2_ratio_k] = data.ratio[cg2_ratio_k] - diff
                            self:update()
                        end
                    end)
                    anEdge.cg1     = prev
                    anEdge.cg2     = v
                    edges[prev]    = edges[prev] or {}
                    edges[prev][v] = anEdge
                end
                local anEdge = edges[prev][v]
                table.insert(edge_list,edges[prev][v])
            end
            v:gen_edge(edge_list)
            prev = v
        end
        return edge_list
    end
    
    local function gen_margin(lenght,count)
        return (lenght/count) - (lenght-(beautiful.border_width2*(count-1)))/count
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
   end
    
   function data:add_child(child_cg)
        data.ratio[#cg:childs()+1] = child_cg.default_percent and (child_cg.default_percent*sum_ratio()) or get_average()
        --child_cg:add_signal("cg::swapped",swap)
        return child_cg
   end
   
   return data
end

common.add_new_layout( "horizontal", function(cg) return new(cg,"horizontal" ) end)
common.add_new_layout( "vertical"  , function(cg) return new(cg,"vertical"   ) end)