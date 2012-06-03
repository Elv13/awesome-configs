local ipairs       = ipairs
local pairs        = pairs
local print        = print
local wibox        = require( "awful.wibox"       )
local common       = require( "ultiLayout.common" )
local beautiful    = require( "beautiful"         )
local titlebar     = require( "ultiLayout.widgets.titlebar"  )
local splitter     = require( "ultiLayout.widgets.splitter" )

module("ultiLayout.layouts.stack")

function new(cg,have_tiltebar)
    if not cg then return end
   local data      = {}
   local tb        = nil
   local asplitter = splitter.create_splitter_bar(cg)
   cg.swapable     = true
   
   function data:update()
        local margin = (cg.width-(2*(beautiful.client_margin or 0)) < 0 or cg.height-(2*(beautiful.client_margin or 0)) < 0) and 0 or beautiful.client_margin or 0
        local margin_top = (tb) and tb.wibox.height or 0
        for k,v in ipairs(cg:childs()) do
            v:geometry({width  = cg.width-(margin*2), height = cg.height-margin_top-(margin*2), x = cg.x+(margin/2), y = cg.y+margin_top+(margin/2)})
            v:repaint()
        end
        --if tb then tb:update() end
        asplitter:update()
   end
   
    function data:set_active(sub_cg)
        for k,v in pairs(cg:childs()) do
            v.visible = v == sub_cg
        end
        if tb then tb:select_tab(sub_cg) end
    end

    function data:add_child(child_cg)
        if not tb and have_tiltebar == true then
            tb = titlebar(cg)
            cg.decorations:add_decoration(tb.wibox,{class="titlebar",position="top",align="ajust",update_callback= function() tb:update() end})
            common.register_wibox(tb.wibox,cg,function(new_cg) cg:attach(new_cg) end)
        end
        if tb then tb:add_tab(child_cg) end
        data:set_active(sub_cg)
        return child_cg
    end
   
    return data
end

common.add_new_layout("stack",function(cg,...) return new(cg,true ,...) end)
common.add_new_layout("max"  ,function(cg,...) return new(cg,false,...) end)