local capi = { root         = root         ,
               mousegrabber = mousegrabber }

local setmetatable = setmetatable
local print        = print
local button       = require( "awful.button" )
local wibox        = require( "awful.wibox"  )
local util         = require( "awful.util"   )
local beautiful    = require( "beautiful"    )

module("ultiLayout.widgets.border")

function update_wibox(edge)
    if edge.wibox ~= nil then
        edge.wibox.visible = edge.cg2.visible --.parent.visible
        if edge.wibox.visible == false then return end
        edge.wibox.x                                                           = edge.x-(beautiful.border_width2*((edge.orientation == "vertical") and 1 or 0))
        edge.wibox.y                                                           = edge.y-(beautiful.border_width2*((edge.orientation == "vertical") and 0 or 1))
        edge.wibox[edge.orientation == "vertical" and "width"  or "height" ] = beautiful.border_width2
        edge.wibox[edge.orientation == "vertical" and "height" or "width"  ] = (edge.length > 0) and edge.length or 1
        edge.wibox.visible=true
    end
end

function create(edge)
    local w = wibox({position = "free"})
    w.bg = beautiful.border_normal
    w:buttons(util.table.join(
        button({ }, 1 ,function (tab)
            capi.mousegrabber.run(function(mouse)
                if mouse.buttons[1] == false then
                    return false
                end
                local x_or_y = edge.orientation == "horizontal" and "y" or "x"
                edge:emit_signal("distance_change::request",mouse[x_or_y] - edge[x_or_y])
                update_wibox(edge)
                return true
            end,"fleur")
    end)))
    
    w:add_signal("mouse::enter", function ()
        capi.root.cursor((edge.orientation == "vertical") and "sb_h_double_arrow" or "sb_v_double_arrow")
        w.bg = beautiful.border_focus
    end)

    w:add_signal("mouse::leave", function ()
        capi.root.cursor("left_ptr")
        w.bg = beautiful.border_normal
    end)
    edge.wibox = w
    return w
end