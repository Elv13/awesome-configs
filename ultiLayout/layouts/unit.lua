--This is the smallest component of a layout. It handle titlebars and (optionally) some other goodies
local print        = print
local client       = client
local common       = require( "ultiLayout.common" )

module("ultiLayout.layouts.unit")

function new(cg,c)
    local data = {titlebar = nil, client = c,x=0,y=0,width=0,height=0}
    cg:set_client(c)
    
    function data:update()
        c.hidden = not cg.visible
        c:geometry({x = cg.x, y = cg.y, width = cg.width, height = cg.height})
    end

    function data:gen_edge(edge_list)
        return edge_list
    end

    function data:show_splitters(show,horizontal,vertical) end
    
    function data:set_active(sub_cg)
        c.focus = c
    end
   
    function data:add_child() end

    function data:add_client(c) end
   
   cg:add_signal("visibility::changed",function(_cg,value)
       c.hidden = not value
   end)
   
    c:add_signal("property::name",function()
        cg.title = c.name
    end)
    
    client.add_signal("focus",function(c2) --TODO 4.0, emit this from the client object too
        if c == c2 then
            cg.focus = true
        end
    end)
    
    client.add_signal("unfocus",function(c2) --TODO 4.0, emit this from the client object too
        if c == c2 then
            cg.focus = false
        end
    end)
   return data
end

common.add_new_layout("unit",new)