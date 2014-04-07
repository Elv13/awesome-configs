local setmetatable = setmetatable
local ipairs = ipairs
local table = table
local print = print
local button     = require("awful.button")
local layout     = require("awful.layout")
local tag        = require("awful.tag")
local util       = require("awful.util")
local beautiful  = require("beautiful")
local wibox      = require("wibox")
local tooltip2   = require( "radical.tooltip" )
local themeutils = require( "blind.common.drawing"    )
local radical    = require("radical")
local color = require("gears.color")
local tag_menu = require( "radical.impl.common.tag" )

local capi = {client = client,mouse=mouse}

local module = {}

local function update(w, screen)
    local layout = layout.getname(layout.get(screen))
    if layout and beautiful["layout_" ..layout.."_s"] then
        w:set_image(color.apply_mask(beautiful["layout_" ..layout.."_s"]))
    else
        w:set_image()
    end
end

local centered = nil

module.centered_menu = function(layouts,backward)
    local screen = capi.client.focus and capi.client.focus.screen or capi.mouse.screen
    if not centered then
        centered = radical.box({filter=false,item_style=radical.item.style.rounded,item_height=45,column=6,layout=radical.layout.grid,screen=screen})
        tag_menu.layouts(centered,layouts)
        centered:add_key_hook({}, " ", "press", function(_,mod) centered._current_item.button1(_,mod) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "release", function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "release", function(menu) end)
        centered:add_key_hook({}, "Mod4", "release", function(menu) centered.visible = false end)
    end
    centered.screen = screen
    centered.visible = true
    centered._current_item.button1(centered,backward and {"Shift"} or {})
end

local function new(screen, layouts)
    local screen = screen or capi.client.focus and capi.client.focus.screen or 1
    local w = wibox.widget.imagebox()
    w:set_tooltip("Change Layout")
    w.bg = beautiful.bg_alternate
    update(w, screen)
    local menu = nil

    local function btn(geo)
        if not menu then
            menu = radical.context({filter=false,item_style=radical.item.style.rounded,item_height=30,column=3,layout=radical.layout.grid,arrow_type=radical.base.arrow_type.CENTERED})
            tag_menu.layouts(menu,layouts)
        end
        menu.parent_geometry = geo
        menu.visible = true
    end

    w:buttons( util.table.join(
      button({ }, 1, btn),
      button({ }, 3, btn),
      button({ }, 4, function()
        layout.inc(layouts, 1)
      end),
      button({ }, 5, function()
        layout.inc(layouts, -1)
      end)
    ))

    local function update_on_tag_selection(new_tag)
        return update(w, new_tag.screen)
    end

    tag.attached_connect_signal(screen, "property::selected", update_on_tag_selection)
    tag.attached_connect_signal(screen, "property::layout", update_on_tag_selection)

    return w
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
