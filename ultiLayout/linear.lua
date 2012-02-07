local setmetatable = setmetatable
local ipairs       = ipairs
local pairs        = pairs
local print        = print
local table        = table
local button       = require( "awful.button"      )
local beautiful    = require( "beautiful"         )
local tag          = require( "awful.tag"         )
local util         = require( "awful.util"        )
local common       = require( "ultiLayout.common" )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.linear")


local function cg_to_idx(list,cg)
    for k,v in ipairs(list) do
        if v == cg then
            return k
        end
    end
    return nil
end

local function new(cg,orientation) 
   local data     = {}
   data.ratio     = {}
   local nb       = 0
   local vertex   = {}
   local orientation = orientation
   
   local function get_average()
       if #cg:childs() == 0 then return 1 end
       local ratio = 0
       for k,v in ipairs(cg:childs()) do
           ratio = ratio + (data.ratio[k] or 1)
       end
       return (ratio / #cg:childs()) or 1
   end
   
   local function ratio_to_percent(ratio)
       local sumratio = 0
       for k,v in ipairs(cg:childs()) do
           sumratio = sumratio + data.ratio[k]
       end
       return ratio / sumratio
   end
   
   function data:show_splitters(show,horizontal,vertical)
--        if horizontal then
--            --ultiLayout.common.add_splitter_box()
--        end
--        if vertical then
--             
--        end
       for k,v in ipairs(cg:childs()) do
           v:show_splitters(show,horizontal,vertical)
       end
   end
   
    function data:gen_vertex(vertex_list)
        local prev = nil
        local nb2   = 0
        for k,v in ipairs(cg:childs()) do
            if prev and nb2 ~= nb then
                if not vertex[prev] or not vertex[prev][v] then
                    local aVertex = common.create_vertex({x=cg.x,y=v.y,orientation="horizontal",length=cg.width})
                    aVertex.cg1     = prev
                    aVertex.cg2     = v
                    vertex[prev]    = vertex[prev] or {}
                    vertex[prev][v] = aVertex
                end
                local aVertex = vertex[prev][v]
                aVertex.length = cg.width
                if orientation == "horizontal" then
                    aVertex.x = cg.x
                    aVertex.y = v.y
                else
                    aVertex.x = v.x
                    aVertex.y = cg.y
                end
                table.insert(vertex_list,vertex[prev][v])
            end
            v:gen_vertex(vertex_list)
            prev = v
            nb2 = nb2+1
        end
        return vertex_list
    end
   
   function data:update()
       local relX   = cg.x
       local relY   = cg.y
       for k,v in ipairs(cg:childs()) do
            if orientation == "horizontal" then
                v:geometry({width  = cg.width                ,
                            height = cg.height*ratio_to_percent(data.ratio[k]) ,
                            x      = relX                    ,
                            y      = relY                   })
            else
                v:geometry({width  = cg.width*ratio_to_percent(data.ratio[k])  ,
                            height = cg.height ,
                            x      = relX                    ,
                            y      = relY                   })
            end
            v:repaint()
            if orientation == "horizontal" then
                relY     = relY + (cg.height*ratio_to_percent(data.ratio[k]))
            else
                relX     = relX + (cg.width*ratio_to_percent(data.ratio[k]))
            end
       end
       for k,v in pairs(vertex) do
           for k2,v2 in pairs(v) do
               v2.x = relX
               v2.y = relY
               if orientation == "horizontal" then
                    v2.length = k2.width
               else
                   v2.length = k2.height
               end
           end
       end
   end
   
       
    local function swap(_cg,other_cg,old_parent)
        if _cg.parent ~= cg then
            _cg:remove_signal("cg::swapped",swap)
            other_cg:add_signal("cg::swapped",swap)
        elseif _cg.parent == cg and other_cg.parent == cg then
            local cg_idx, other_cg_idx = cg_to_idx(cg:childs(),_cg),cg_to_idx(cg:childs(),other_cg)
            local buf = data.ratio[cg_idx]
            data.ratio[cg_idx] = data.ratio[other_cg_idx]
            data.ratio[other_cg_idx] = buf
        end
    end
        
   function data:add_child(child_cg)
        nb = nb + 1
        local percent = 1 / nb
        data.ratio[#cg:childs()+1] = get_average()
        child_cg:add_signal("cg::swapped",swap)
   end
   
   return data
end

common.add_new_layout("horizontal",function(cg) return new(cg,"horizontal") end)
common.add_new_layout("vertical",function(cg) return new(cg,"vertical") end)

setmetatable(_M, { __call = function(_, ...) return new(...) end })