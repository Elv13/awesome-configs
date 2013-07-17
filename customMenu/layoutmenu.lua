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
local tooltip2   = require( "widgets.tooltip2" )
local themeutils = require( "blind.common.drawing"    )
local radical    = require("radical")

local module = {}

local function update(w, screen)
    local layout = layout.getname(layout.get(screen))
    if layout and beautiful["layout_" ..layout.."_s"] then
        w:set_image(themeutils.apply_color_mask(beautiful["layout_" ..layout.."_s"]))
    else
        w:set_image()
    end
end

local centered = nil

local function populate(menu,layouts)
    local cur = layout.get(tag.getscreen(tag.selected()))
    for i, layout_real in ipairs(layouts) do
        local layout2 = layout.getname(layout_real)
        if layout2 and beautiful["layout_" ..layout2] then
            menu:add_item({icon=beautiful["layout_" ..layout2],button1 = function(_,mod)
                if mod then
                    menu[mod[1] == "Shift" and "previous_item" or "next_item"].selected = true
                end
                layout.set(layouts[menu.current_index] or layouts[1],tag.selected())
            end, selected = (layout_real == cur)})
        end
    end
end

module.centered_menu = function(layouts,backward)
    if not centered then
        centered = radical.box({filter=false,item_style=radical.item_style.rounded,item_height=45,column=6,layout=radical.layout.grid})
        populate(centered,layouts)
        centered:add_key_hook({}, " ", "press", function(_,mod) centered._current_item.button1(_,mod) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "release", function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "release", function(menu) end)
        centered:add_key_hook({}, "Mod4", "release", function(menu) centered.visible = false end)
    end
    centered.visible = true
end

local function new(screen, layouts)
    local screen = screen or 1
    local w = wibox.widget.imagebox()
    tooltip2(w,"Change Layout",{})
    w.bg = beautiful.bg_alternate
    update(w, screen)
    local menu = nil

    local function btn(geo)
        if not menu then
            menu = radical.context({filter=false,item_style=radical.item_style.rounded,item_height=30,column=3,layout=radical.layout.grid,arrow_type=radical.base.arrow_type.CENTERED})
            populate(menu,layouts)
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
