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
    cg:set_client(c)
    
    function data:update()
        c:geometry({x = cg.x, y = cg.y, width = cg.width, height = cg.height})
    end

    function data:gen_vertex(vertex_list)
        return vertex_list
    end

    function data:show_splitters(show,horizontal,vertical)
        if vertical then
            common.add_splitter_box(cg.x,cg.y+(cg.height/2)-25)
            common.add_splitter_box(cg.x+cg.width-50,cg.y+(cg.height/2)-25)
        end
        if horizontal then
            common.add_splitter_box(cg.x+(cg.width/2)-25,cg.y)
            common.add_splitter_box(cg.x+(cg.width/2)-25,cg.y+cg.height-50)
        end
    end
    
    function data:set_active(sub_cg)
        c.focus = c
    end
   
    function data:add_child()
        return false --Unit can't have childs
    end

    function data:add_client(c)
        
    end
   
   cg:add_signal("visibility::changed",function(_cg,value)
       c.hidden = not value
   end)
   return data
end

common.add_new_layout("unit",new)

setmetatable(_M, { __call = function(_, ...) return new(...) end })