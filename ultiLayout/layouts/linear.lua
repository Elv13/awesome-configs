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
    cg.orientation = ori
   
   function data:sum_ratio(only_visible)
        local sumratio = 0
        for k,v in ipairs(cg:childs()) do
            if (only_visible == true and v.visible ~= false and (#v:childs() > 0 or v:has_client() == true)) or only_visible ~= true then --TODO visible childs
                sumratio = sumratio + (data.ratio[k] or 1)
            end
        end
        return sumratio
   end
   
   local function get_average(only_visible)
       return (#cg:childs() > 0) and (data:sum_ratio(only_visible) / #((only_visible == true) and cg:visible_childs() or cg:childs())) or 1
   end
   
   local function size(ratio,w_or_h,orientation)
       return ( ori == orientation ) and cg.workarea[w_or_h] or ((ratio or get_average(true)) / data:sum_ratio(true))*cg.workarea[w_or_h]
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
   
   local function resize_common(child_cg,base,w_or_h,v_or_h)
       local newBase = base
        if base and base ~= 0 and ori == v_or_h then
            if (child_cg[w_or_h] - base < 15) then
                newBase = (child_cg[w_or_h]+base <=15) and 0 or child_cg[w_or_h] -15
            else
                newBase = (cg:previousChild(child_cg)[w_or_h]+base <=15) and 0 or base
            end
            local diff,idx,length = (data:sum_ratio()/cg[w_or_h])*(newBase),cg:cg_to_idx(child_cg),cg[w_or_h]
            data.ratio[idx-1],data.ratio[idx] = data.ratio[ idx-1 ] + (diff >= length-5 and length-5 or diff),data.ratio[ idx   ] - (diff >= length-5 and length-5 or diff)
        end
        return base-newBase
   end
   
   function data:resize(child_cg,w,h)
       return resize_common(child_cg,w,"width","vertical"),resize_common(child_cg,h,"height","horizontal")
   end
    
   function data:add_child(child_cg,index)
        local index,anEdge = index or  #cg:childs()+1,edge({cg=child_cg,orientation=ori})
        data.ratio[#cg:childs()+1] = child_cg.default_percent or get_average()
        child_cg.decorations:add_decoration(anEdge,{class="edge",position=((ori == "vertical") and "left" or "top"),align="ajust",index=1,update_callback= function() anEdge:update() end})
        return child_cg
   end
   return data
end

common.add_new_layout( "horizontal", function(cg) return new(cg,"horizontal" ) end)
common.add_new_layout( "vertical"  , function(cg) return new(cg,"vertical"   ) end)