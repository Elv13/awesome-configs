local ipairs       = ipairs
local common       = require( "ultiLayout.common"           )
local edge         = require( "ultiLayout.edge"             )
local splitter     = require( "ultiLayout.widgets.splitter" )
local print = print

module("ultiLayout.layouts.linear")

local function new(cg,ori)
    local data = { ratio = {} }
    cg.decorations:add_decoration(splitter(cg,{direction=(ori == "horizontal") and "bottom" or "right", index=1}),{class="splitter",position="top",align="beginning",ontop=true})
    cg.decorations:add_decoration(splitter(cg,{direction=(ori == "horizontal") and "top"    or "left" ,        }),{class="splitter",position="top",align="beginning",ontop=true})
   
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
       return (#cg:childs() > 0) and (sum_ratio(only_visible) / #((only_visible == true) and cg:visible_childs() or cg:childs())) or 1
   end
   
   local function size(ratio,w_or_h,orientation)
       return ( ori == orientation ) and cg.workarea[w_or_h] or ((ratio or get_average(true)) / sum_ratio(true))*cg.workarea[w_or_h]
   end
   
   function data:update()
       local relX,relY = cg.workarea.x,cg.workarea.y
       for k,v in ipairs(cg:childs()) do
           if v.visible ~= false and (#v:childs() > 0 or v:has_client() == true) then --TODO visible childs
                v:geometry({width = size(data.ratio[k],"width","horizontal"), height = size(data.ratio[k],"height","vertical"), x = relX, y = relY })
                relY,relX = relY + (( ori == "horizontal" ) and v.height or 0),relX + (( ori == "vertical"   ) and v.width  or 0)
           end
       end
   end
    
   function data:add_child(child_cg,index)
        local index,anEdge = index or  #cg:childs()+1,edge({cg=child_cg,orientation=ori})
        data.ratio[#cg:childs()+1] = child_cg.default_percent or get_average()
        anEdge:add_signal("distance_change::request",function(_e, delta)
            print("HERE",cg,child_cg.parent)
            local diff,idx = (sum_ratio()/child_cg.parent[(ori == "horizontal") and "height" or "width"])*delta,child_cg.parent:cg_to_idx(child_cg)
            data.ratio[idx-1],data.ratio[idx] = data.ratio[ idx-1 ] + diff,data.ratio[ idx   ] - diff
            child_cg.parent:repaint()
        end)
        child_cg.decorations:add_decoration(anEdge,{class="edge",position=((ori == "vertical") and "left" or "top"),align="ajust",index=1,update_callback= function() anEdge:update() end})
        return child_cg
   end
   return data
end

common.add_new_layout( "horizontal", function(cg) return new(cg,"horizontal" ) end)
common.add_new_layout( "vertical"  , function(cg) return new(cg,"vertical"   ) end)