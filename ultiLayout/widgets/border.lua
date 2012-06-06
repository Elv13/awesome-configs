local capi = { root         = root         ,
               mousegrabber = mousegrabber }

local setmetatable = setmetatable
local print        = print
local type = type
local button       = require( "awful.button" )
local wibox        = require( "awful.wibox"  )
local util         = require( "awful.util"   )
local beautiful    = require( "beautiful"    )

module("ultiLayout.widgets.border")

function update_wibox(edge)
    edge.wibox[(edge.orientation == "horizontal") and "height" or "width"] = 3
end

function create(edge)
    local w = wibox({position = "free"})
    w.visible = (edge.cg1 ~= nil and edge.cg2 ~= nil)
    w.bg = beautiful.border_normal
    w:buttons(util.table.join(
        button({ }, 1 ,function (tab)
            capi.mousegrabber.run(function(mouse)
                if mouse.buttons[1] == false then
                    return false
                end
                local x_or_y = edge.orientation == "horizontal" and "y" or "x"
                edge:emit_signal("distance_change::request",mouse[x_or_y] - edge[x_or_y])
                return true
            end,edge.orientation == "horizontal" and "sb_v_double_arrow" or "sb_h_double_arrow")
    end)))
    
    w:add_signal("mouse::enter", function ()
        capi.root.cursor((edge.orientation == "vertical") and "sb_h_double_arrow" or "sb_v_double_arrow")
        w.bg = beautiful.border_focus
    end)
    
    w[(edge.orientation == "horizontal") and "height" or "width"] = 3
    
    w:add_signal("mouse::leave", function ()
        capi.root.cursor("left_ptr")
        w.bg = beautiful.border_normal
    end)
    edge.wibox = w
    return w
end