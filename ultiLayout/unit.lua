--This is the smallest component of a layout. It handle titlebars and (optionally) some other goodies
local setmetatable = setmetatable
local print        = print
local debug        = debug
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )
local common       = require( "ultiLayout.common" )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.unit")

function new(cg,c)
  local data = {titlebar = nil, client = c,x=0,y=0,width=0,height=0}
  local function make_room(percentage) --Between 0 and 1
       --Nothing to do, refuse any attempt to do it
   end
   
   function data:update()
       c:geometry({x = cg.x, y = cg.y, width = cg.width, height = cg.height})
   end
   
    function data:gen_vertex(vertex_list)
        return vertex_list
    end
   
   function data:add_child()
       return false --Unit can't have childs
   end
   
   function data:add_client(c)
       make_room(percent)
   end
   return data
end

common.add_new_layout("unit",new)

setmetatable(_M, { __call = function(_, ...) return new(...) end })