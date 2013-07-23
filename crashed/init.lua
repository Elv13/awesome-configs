--------------------------------------------------------------------------
-- @author Emmanuel Lepage <elv1313@gmail.com>                          --
--                                                                      --
-- Port of my old "monkeypatch" module from Awesome 3.5                 --
-- As my config is more complex than Gnome 3, some additional           --
-- Optimizations are required to make it run fast enough                --
-- LGI also need proper caching support, so I have to bypass            --
-- it everytime I can.                                                  --
--                                                                      --
-- @warning Some of these changes are not fully compatible with         --
-- the "vanilla" Awesome 3.5 libraries                                  --
--                                                                      --
--------------------------------------------------------------------------

local gears = require("gears")
local type = type
local string = string
local print = print
local cairo =require( "lgi" ).cairo
local wibox = require("wibox")


local color_cache = {}
gears.color.create_pattern = function(col)
    -- If it already is a cairo pattern, just leave it as that
    if cairo.Pattern:is_type_of(col) then
        return col
    end
    if type(col) == "string" then
        local cached = color_cache[col]
        if cached then
            return cached
        end
        local t = string.match(col, "[^:]+")
        if gears.color.types[t] then
            local pos = string.len(t)
            local arg = string.sub(col, pos + 2)
            local res = gears.color.types[t](arg)
            color_cache[col] = res
            return res
        else
            local res = gears.color.create_solid_pattern(col)
            color_cache[col] = res
            return res
        end
    elseif type(col) == "table" then
        local t = col.type
        if gears.color.types[t] then
            return gears.color.types[t](col)
        end
    end
    return gears.color.create_solid_pattern(col)
end

-- Cannot work unless the widget_at code can be untangled from draw. It would be very nice

-- local base = wibox.layout.base
-- local count = 1
-- function wibox.layout.base.draw_widget(wibox, cr, widget, x, y, width, height)
--     print("here",count)
--     if not widget.cache then
--         widget.cache = {}
--         widget:connect_signal("widget::updated",function()
--             widget.cache = {}
--         end)
--     end
--     count = count +1
--     -- Use save() / restore() so that our modifications aren't permanent
--     cr:save()
-- 
--     -- Move (0, 0) to the place where the widget should show up
--     cr:translate(x, y)
--     local cached = widget.cache[width+10000*height]
--     if cached then
--         print("use cache")
--         cr:set_source_surface(cached)
--         cr:paint()
--         cr:restore()
--         return
--     end
-- 
--     -- Make sure the widget cannot draw outside of the allowed area
--     cr:rectangle(0, 0, width, height)
--     cr:clip()
-- 
--     -- Let the widget draw itself
--     local success, msg = pcall(widget.draw, widget, wibox, cr, width, height)
--     if not success then
--         print("Error while drawing widget: " .. msg)
--     end
-- 
--     -- Register the widget for input handling
--     wibox:widget_at(widget, base.rect_to_device_geometry(cr, 0, 0, width, height))
--     
--     local img  = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)--target:create_similar(target:get_content(),width,height) 
--     local cr2 = cairo.Context(img)
--     cr2:set_source_surface(cr:get_target(),-x,-y)
--     cr2:translate(x,y)
--     cr2:paint()
--     widget.cache[width+10000*height] = img
-- 
--     cr:restore()
-- end