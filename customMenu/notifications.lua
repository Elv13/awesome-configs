--[[
        File:      widgets/notifications.lua
        Date:      2014-01-12
      Author:      Mindaugas <mindeunix@gmail.com> http://minde.gnubox.com
   Copyright:      Copyright (C) 2014 Free Software Foundation, Inc.
     Licence:      GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
        NOTE:      -------

button 1: radical menu su listu notifications history
button 3: reset notifications

--]]

local wibox     = require("wibox")
local beautiful = require("beautiful")
local radical   = require("radical")
local awful     = require("awful")
local naughty   = require("naughty")
local cairo     = require("lgi").cairo
local color     = require( "gears.color"              )
local pango = require("lgi").Pango
local pangocairo = require("lgi").PangoCairo

local padding = 3
local widget = nil

local module = {}
-- Maximum number of items before showing scrollbar
module.items_limit = 10
module.items_max_characters = 80
-- Table where all items will be stored.
module.items = {}

-- Update notifications icon
local function update_icon()
--     if #module.items >= 1 then
--         module.icon:set_image(beautiful.path.."/widgets/notifications.svg")
--         module.icon:set_tooltip(#module.items.." message/s") -- Fails.
--     else
--         module.icon:set_image() -- reset
--     end
    -- Hide menu
    if module.menu and module.menu.visible then 
        module.menu.visible = false
    end
end

-- Format notifications
local function update_notifications(data)
    local text,icon,count,bg,time = data.text or "N/A", data.icon or beautiful.unknown,1
    if data.title and data.title ~= "" then text = "<b>"..data.title.."</b> - "..text end
    local text = string.sub(text, 0, module.items_max_characters)
    for k,v in ipairs(module.items) do
        if text == v.text then count, v.count = count + 1, v.count + 1 end
    end
    time=os.date("%H:%M:%S")
    if data.preset and data.preset.bg then bg=data.preset.bg end -- TODO: presets
    if count == 1 then table.insert(module.items, {text=text,icon=icon,count=count,bg=bg,time=time}) end
    update_icon()
end

-- Reset notifications count/icon
function module.reset()
    module.items={}
    update_icon()
end

local function getX(i)
    local a = screen[1].geometry.height - beautiful.default_height or 16
    if i > module.items_limit then
        return a - (module.items_limit * beautiful.menu_height) - 40 -- 20 per scrollbar.
    else
        return a- i * beautiful.menu_height
    end
end

function module.main()
    if module.menu and module.menu.visible then module.menu.visible = false return end
    if module.items and #module.items > 0 then
        module.menu = radical.context({filer = false, enable_keyboard = false,
            style = radical.style.classic, item_style = radical.item_style.classic,
            direction = "bottom", max_items = module.items_limit,
            x = screen[1].geometry.width, y = getX(#module.items),
        })
        for k,v in ipairs(module.items) do
            module.menu:add_item({
                button1 = function()
                    widget._count = widget._count - 1
                    widget:emit_signal("widget::updated")
                    table.remove(module.items, k)
                    update_icon()
                    module.main() -- display the menu again
                end,
                text=v.text, icon=v.icon, underlay = v.count, tooltip = v.time
            })
        end
        module.menu.visible = true
    end
end

-- Callback used to modify notifications
naughty.config.notify_callback = function(data)
    widget._count = widget._count + 1
    widget:emit_signal("widget::updated")
    update_notifications(data)
    return data
end

local pl = nil

local function init_pl(height)
    if not pl and height > 0 then
        local pango_crx = pangocairo.font_map_get_default():create_context()
        pl = pango.Layout.new(pango_crx)
        local desc = pango.FontDescription()
        desc:set_family("Verdana")
        desc:set_weight(pango.Weight.ULTRABOLD)
        desc:set_size((height-2-padding*2) * pango.SCALE)
        pl:set_font_description(desc)
    end
end

local function fit(self,w,height)
    init_pl(height)
    if pl and self._count > 0 then
        pl.markup = "<b>"..self._count.."</b>"
        local text_ext = pl:get_pixel_extents()
        return 3*(height/4)+3*padding+(text_ext.width or 0),height
    end
    return 0,height
end

local function draw(self, w, cr, width, height)
    local padding = 3
    local tri_width = 3*(height/4)
    cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
    cr:paint()
    cr:set_source(color(beautiful.bg_alternate or beautiful.bg_normal))
    cr:move_to(padding + tri_width/2,padding)
    cr:line_to(padding+tri_width,height-padding)
    cr:line_to(padding,height-padding)
    cr:line_to(padding + tri_width/2,padding)
    cr:close_path()
    cr:set_line_width(4)
    cr:set_line_join(1)
    cr:set_antialias(cairo.ANTIALIAS_SUBPIXEL)
    cr:stroke_preserve()
    cr:fill()
    cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
    pl.text = "!"
    local text_ext = pl:get_pixel_extents()
    cr:move_to(padding + tri_width/2-text_ext.width/2 - height/16,padding-text_ext.height/4+1)
    cr:show_layout(pl)

    pl:set_font_description(beautiful.get_font(font))
    pl.markup = "<b>"..self._count.."</b>"
    cr:move_to(tri_width+2*padding,padding-text_ext.height/4+1)--,-text_ext.height/2)
    cr:set_source(color(beautiful.bg_alternate or beautiful.bg_normal))
    cr:show_layout(pl)
end

-- Return widget
local function new()
    widget = wibox.widget.base.make_widget()
    widget.draw = draw
    widget.fit = fit
    widget._count = 0
    widget:set_tooltip("Notifications")
--     widget:set_text("sfsdf")
    widget:buttons(awful.util.table.join(awful.button({ }, 1, module.main), awful.button({ }, 3, module.reset)))
    update_icon()
    return widget
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
