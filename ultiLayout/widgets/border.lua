local capi = { root         = root         ,
               mousegrabber = mousegrabber }

local setmetatable = setmetatable
local print        = print
local button       = require( "awful.button" )
local wibox        = require( "awful.wibox"  )
local util         = require( "awful.util"   )

module("ultiLayout.widgets.border")

function update_wibox(edge)
    if edge.wibox ~= nil then
        edge.wibox.x                                                           = edge.x
        edge.wibox.y                                                           = edge.y
        edge.wibox[edge.orientation == "vertical" and "width"  or "height" ] = 3
        edge.wibox[edge.orientation == "vertical" and "height" or "width"  ] = edge.length
        edge.wibox.visible=true
    end
end

function create(edge)
    local w = wibox({position = "free"})
    w.ontop = true
    w.bg = "#ff0000"
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
        w.bg = "#00ffff"
    end)

    w:add_signal("mouse::leave", function ()
        capi.root.cursor("left_ptr")
        w.bg = "#ff00ff"
    end)
    edge.wibox = w
    return w
end