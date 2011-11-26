local setmetatable = setmetatable
local ipairs       = ipairs
local print        = print
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )
local common       = require( "ultiLayout.common" )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.stack")

function new(cg) 
   local data = {}
   local nb =0
   local activeCg = nil
   
   function data:update()
       for k,v in ipairs(cg:childs()) do
           v:geometry({width  = cg.width, height = cg.height, x = cg.x, y = cg.y})
           v:repaint()
       end
   end
   
    function data:gen_vertex(vertex_list)
        if activeCg then
            activeCg:get_vertex(vertex_list)
        end
        return vertex_list
    end
   
   function data:add_child(child_cg)
       if not activeCg then
           activeCg = child_cg
       end
       nb = nb + 1
       local percent = 1 / nb
       data.ratio[child_cg] = percent
   end
   return data
end

common.add_new_layout("stack",new)

setmetatable(_M, { __call = function(_, ...) return new(...) end })