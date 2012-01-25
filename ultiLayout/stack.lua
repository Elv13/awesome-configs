local setmetatable = setmetatable
local ipairs       = ipairs
local pairs        = pairs
local print        = print
local button       = require( "awful.button"      )
local beautiful    = require( "beautiful"         )
local naughty      = require( "naughty"           )
local tag          = require( "awful.tag"         )
local util         = require( "awful.util"        )
local wibox        = require( "awful.wibox"       )
local common       = require( "ultiLayout.common" )
local titlebar     = require( "widgets.titlebar"  )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.stack")

function new(cg) 
   local data = {}
   local nb =0
   local activeCg = nil
   local tb = nil
   --cg:add_signal("client::attached",function() print("\n\n\n\n\nclient attaced\n\n\n\n\n") end)
   --cg:add_signal("client::attached", function()  print("new client\n\n\n\n\n");tb.tl:add_tab_cg(cg);asjkghfdaksjhd() end)
   
   function data:update()
       for k,v in ipairs(cg:childs()) do
           if tb and cg.width > 0 then
               tb.wibox.x       = cg.x
               tb.wibox.y       = cg.y
               tb.wibox.width   = cg.width
               tb.wibox.visible = true
           elseif tb then
               tb.wibox.visible = false
           end
           v:geometry({width  = cg.width, height = cg.height-16, x = cg.x, y = cg.y+16})
           v:repaint()
       end
   end
   
    function data:gen_vertex(vertex_list)
        if activeCg then
            activeCg:gen_vertex(vertex_list)
        end
        return vertex_list
    end
   
    function data:show_splitters(show,horizontal,vertical)
        print("Showing stack splliter",show)
    end
    
    function data:set_active(sub_cg)
        for k,v in pairs(cg:childs()) do
            if v == sub_cg then
                v.visible = true
            else
                v.visible = false
            end
        end
        activeCg = sub_cg
    end

    function data:add_child(child_cg)
        print("Stack is",self)
        --if not activeCg then
            activeCg = child_cg
        --end
        if not tb then
            tb = titlebar.create_from_cg(cg)
            tb.wibox.ontop = true
            tb.wibox.bg    = "#ff0000"
        end
        tb.tablist:add_tab_cg(child_cg)
        nb = nb + 1
        local percent = 1 / nb
    end
    
    cg:add_signal("visibility::changed",function(_cg,value)
        print('####################changing tb visibility\n\n\n\n\n',value)
       if tb then
           tb.wibox.visible = value
       end
    end)
   
    return data
end

common.add_new_layout("stack",new)

setmetatable(_M, { __call = function(_, ...) return new(...) end })