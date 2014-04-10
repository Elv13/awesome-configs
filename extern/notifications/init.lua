local wibox      = require("wibox")
local beautiful  = require("beautiful")
local radical    = require("radical")
local awful      = require("awful")
local naughty    = require("naughty")
local cairo      = require("lgi").cairo
local color      = require("gears.color")
local pango      = require("lgi").Pango
local pangocairo = require("lgi").PangoCairo

local module = {}

module.items = {}
module.count = 0
module.config = {}
module.widget = nil

-- Format notifications
local function update_notifications(data)
    -- allow to ignore notifications: naughty.notify({ text="foo", ignore=true })
    if data.ignore then return end
    -- avoid false negatives
    if not module.widget or not type(data.text) == "string" then return end
    -- start counter
    local count = 1
    -- time format
    local time = os.date("%H:%M:%S")
    -- background color
    local bg = "#FF0000"
    -- set icon
    local icon = data.icon or beautiful.awesome_icon
    -- set text
    local text = data.text or "N/A"
    -- cleanup 
    local text = string.gsub(text, "\n", " ")  -- remove line breaks
    local text = string.gsub(text, "%s+", " ") -- remove whitespace
    local text = string.gsub(text, "%b<>", "") -- remove everything in brackets
    local text = string.format("%.80s", text)  -- truncate

    -- merge title
    if data.title then 
        text = string.format("<b>%.20s</b> %s", data.title, text)
    end

    -- Don't add dublicate items
    for _,v in ipairs(module.items) do
        if text == v.text then
            v.count, count = v.count+1, v.count+1
        end
    end

    -- Presets
    if data.preset then
        if data.preset.bg then bg = data.preset.bg end
    end

    if count == 1 then
        local item = { 
            text = text, icon = icon, 
            count = count, time = time, 
            bg = bg 
        }
        table.insert(module.items, item)
        module.count = module.count+1
    end
    
    -- Update widget
    module.widget:emit_signal("widget::updated")
end

-- Reset notifications count/widget
function module.reset()
    module.items = {}
    module.count = 0 -- Reset count
    module.widget:emit_signal("widget::updated") -- Update widget
    if module.menu and module.menu.visible then
        module.menu.visible = false
    end
end

local function getY()
    if module.conf.direction == "top_left" or module.conf.direction == "top_right" then
        return beautiful.menu_height or 30
    elseif module.conf.direction == "bottom_left" or module.conf.direction == "bottom_right" then
        local a = screen[1].geometry.height - (beautiful.default_height or 30)
        if #module.items > module.conf.max_items then
            return a - (module.conf.max_items * (beautiful.menu_height or 30)) - 40 -- 20 per scrollbar.
        else
            return a - #module.items * (beautiful.menu_height or 30)
        end
    elseif module.conf.direction == "center"  then
        -- TODO: Add center direction
        return beautiful.menu_height or 30
    end
end
local function getX()
    if module.conf.direction == "bottom_right" or module.conf.direction == "top_right" then
        return screen[1].geometry.width
    elseif module.conf.direction == "bottom_left" or module.conf.direction == "top_left" then
        return 0
    elseif module.conf.direction == "center" then
        -- TODO: Add center direction
        return 0
    end
end

function module.main()
    if module.menu and module.menu.visible then module.menu.visible = false return end
    if module.items and #module.items > 0 then
        module.menu = radical.context({
            filer = false,
            enable_keyboard = false,
            style = radical.style.classic,
            --item_style = radical.item.style.classic,
            max_items = module.conf.max_items,
            item_height = 40,
            item_layout = radical.item.layout.notification,
            x = getX(), y = getY()
        })
        for k,v in ipairs(module.items) do
            module.menu:add_item({
                button1 = function()
                    table.remove(module.items, k)
                    module.count = module.count - 1
                    module.widget:emit_signal("widget::updated") -- Update widget
                    module.menu.visible = false
                    module.main() -- display the menu again
                end,
                text=v.text, icon=v.icon, underlay = v.count,
                tooltip = v.time, bg = v.bg
            })
        end
        module.menu.visible = true
    end
end

-- Callback used to modify notifications
naughty.config.notify_callback = function(data)
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
        desc:set_size((height-2-module.padding*2) * pango.SCALE)
        pl:set_font_description(desc)
    end
end
local function fit(self,w,height)
    init_pl(height)
    if pl and module.count > 0 then
        pl.markup = "<b>"..module.count.."</b>"
        local text_ext = pl:get_pixel_extents()
        return 3*(height/4)+3*module.padding+(text_ext.width or 0),height
    end
    return 0,height
end
local function draw(self, w, cr, width, height)
    local tri_width = 3*(height/4)
    cr:set_source(color(module.conf.icon_bg))
    cr:paint()
    cr:set_source(color(module.conf.icon_fg))
    cr:move_to(module.padding + tri_width/2,module.padding)
    cr:line_to(module.padding+tri_width,height-module.padding)
    cr:line_to(module.padding,height-module.padding)
    cr:line_to(module.padding + tri_width/2,module.padding)
    cr:close_path()
    cr:set_line_width(4)
    cr:set_line_join(1)
    cr:set_antialias(cairo.ANTIALIAS_SUBPIXEL)
    cr:stroke_preserve()
    cr:fill()
    cr:set_source(color(module.conf.icon_color))
    pl.text = "!"
    local text_ext = pl:get_pixel_extents()
    cr:move_to(4 + tri_width/2-text_ext.width/2 - height/10,module.padding-text_ext.height/4+1)
    cr:show_layout(pl)

    pl:set_font_description(beautiful.get_font(font))
    pl.markup = "<b>"..module.count.."</b>"
    cr:move_to(tri_width+2*module.padding,module.padding-text_ext.height/4+1)--,-text_ext.height/2)
    cr:set_source(color(module.conf.count_fg))
    cr:show_layout(pl)
end

-- Return widget
local function new(args)
    local args = args or {}
    module.conf = {}
    module.conf.max_items = args.max_items or 10
    module.conf.direction = args.direction or "top_right"
    module.conf.icon_bg = args.icon_bg or beautiful.icon_grad or "#00000000"
    module.conf.icon_fg = args.icon_fg or beautiful.bg_alternate or beautiful.fg_normal
    module.conf.icon_color = args.icon_color or beautiful.icon_grad or beautiful.bg_normal
    module.conf.count_fg = args.count_fg or beautiful.bg_alternate or beautiful.fg_normal
    module.padding = args.pading or 3

    module.widget = wibox.widget.base.make_widget()
    module.widget.draw = draw
    module.widget.fit = fit
    module.widget:set_tooltip("Notifications")
    module.widget:buttons(awful.util.table.join(awful.button({ }, 1, module.main), awful.button({ }, 3, module.reset)))

    return module.widget
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })