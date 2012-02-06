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

module("ultiLayout.horizontal")


local function cg_to_idx(list,cg)
    for k,v in ipairs(list) do
        if v == cg then
            return k
        end
    end
    return nil
end

function new(cg) 
   local data     = {}
   data.ratio     = {}
   local nb       = 0
   local vertex   = {}
   
   
   local function make_room(percentage) --Between 0 and 1
       local nb = #cg:childs()
       local shrinking_factor = 1 - percentage
       for k,v in ipairs(cg:childs()) do
           data.ratio[k] = (data.ratio[k] or 1)*shrinking_factor
       end
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
                aVertex.x = cg.x
                aVertex.y = v.y
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
           print(#cg:childs(),v)
           v:geometry({width  = cg.width                ,
                       height = cg.height*data.ratio[k] ,
                       x      = relX                    ,
                       y      = relY                   })
           v:repaint()
           --relX     = relX + (width*data.ratio[v])
           relY     = relY + (cg.height*data.ratio[k])
       end
       for k,v in pairs(vertex) do
           for k2,v2 in pairs(v) do
               v2.x = relX
               v2.y = relY
               v2.length = k2.width
           end
       end
   end
   
       
    local function swap(_cg,other_cg,old_parent)
        print("here")
        if _cg:get_parent() ~= cg then
            _cg:remove_signal("cg::swapped",swap)
            other_cg:add_signal("cg::swapped",swap)
        elseif _cg:get_parent() == cg and other_cg:get_parent() == cg then
            print("BEGIN")
            local cg_idx, other_cg_idx = cg_to_idx(cg:childs(),_cg),cg_to_idx(cg:childs(),other_cg)
            local buf = data.ratio[cg_idx]
            data.ratio[cg_idx] = data.ratio[other_cg_idx]
            data.ratio[other_cg_idx] = buf
            print("in swap",cg_idx,other_cg_idx)
        end
    end
        
   function data:add_child(child_cg)
       nb = nb + 1
       local percent = 1 / nb
       make_room(percent)
       --local idx = cg_to_idx(,child_cg)
       data.ratio[#cg:childs()+1] = percent
        child_cg:add_signal("cg::swapped",swap)
   end
   
   return data
end

common.add_new_layout("horizontal",new)

setmetatable(_M, { __call = function(_, ...) return new(...) end })