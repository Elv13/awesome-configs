local wibox      = require("wibox")
local beautiful  = require("beautiful")
local radical    = require("radical")
local awful      = require("awful")
local naughty    = require("naughty")
local cairo      = require("lgi").cairo
local color      = require("gears.color")
local pango      = require("lgi").Pango
local pangocairo = require("lgi").PangoCairo
local constrainedtext = require("radical.widgets.constrainedtext")
local dump = require("gears.debug").dump

local module = {}

module.items = {}
module.count = 0
module.border_width = 3
module.config = {}
module.widget = nil
module.skip = false


-- Format notifications
local function update_notifications(data)
    --dump(data)
    -- allow to ignore notifications: naughty.notify({ text="foo", ignore=true })
    if data.ignore then return end
    -- avoid false negatives
    if not module.widget or not type(data.text) == "string" then return end
    -- Set bg/fg colors
    local fg = beautiful.menu_fg_normal or beautiful.fg_normal
    local bg = beautiful.menu_bg_normal or beautiful.bg_normal
    -- start counter
    local count = 1
    -- time format
    local time = os.date("%H:%M:%S")
    -- set icon
    local icon = data.icon or beautiful.awesome_icon
    -- set text
    local text = tostring(data.text) or "N/A"
    -- cleanup 
    local text = string.gsub(text, "\n", " ")  -- remove line breaks
    local text = string.gsub(text, "%s+", " ") -- remove whitespace
    local text = string.gsub(text, "%b<>", "") -- remove everything in brackets
    --local text = string.format("%.80s", text)  -- truncate

    -- merge title
    if data.title then 
        text = string.format("<b>%.20s</b> %s", data.title, text)
    elseif data.appname then
        text = string.format("<b>%.20s</b> %s", data.appname, text)
    end

    -- Don't add dublicate items
    for _,v in ipairs(module.items) do
        if text == v.text then v.count, count = v.count+1, v.count+1 end
    end

    -- Presets
    if data.preset then
        if data.preset.bg then bg = data.preset.bg end
        if data.preset.fg then fg = data.preset.fg end
        if data.preset.icon then icon = data.preset.icon end
    end

    if count == 1 then
        table.insert(module.items, { text = text, icon = icon, count = count, time = time, bg = bg, fg = fg })
        module.count = module.count+1
        if module.tb then
            module.tb:set_text(module.count)
        end
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
    module.skip = true
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
            filer = false, enable_keyboard = false,
            style = radical.style.classic,
            max_items = module.conf.max_items,
            x = getX(), y = getY(), width = 300
        })
        for k,v in ipairs(module.items) do
            local i = module.menu:add_item({
                button1 = function()
                    table.remove(module.items, k)
                    module.count = module.count - 1
                    module.widget:emit_signal("widget::updated") -- Update widget
                    module.menu.visible = false
                    module.main() -- display the menu again
                end,
                text = v.text, icon = v.icon, underlay = v.count,
                tooltip = v.time
            })
        end
        module.menu.visible = true
    end
end

-- Callback used to modify notifications
naughty.config.notify_callback = function(data)
    -- Update notifications widget
    update_notifications(data)

    -- Add title if not present
    if not data.title and data.appname then
        data.title = data.appname
    end

    return data
end

local function fit(self, context, w,height)
    if module.count > 0 then
        local tri_width = height
        return tri_width + module.padding + 2, height
    end


    -- By default, show nothing
    return 0,height
end
local function draw(self, context, cr, width, height)
    local tri_width = height-2 -- The border is 4 point, 2 in and 2 out

    -- Draw a triangle
    cr:set_source(color(self._color or module.conf.icon_fg))
    cr:move_to(module.padding + tri_width/2 + 1, module.padding        )
    cr:line_to(module.padding + tri_width      , height-module.padding )
    cr:line_to(module.padding               + 1, height-module.padding )
    cr:line_to(module.padding + tri_width/2 + 1, module.padding        )
    cr:close_path()

    -- Fake a border radius using a borner
    cr:set_line_width(4)
    cr:set_line_join(1)
    cr:set_antialias(cairo.ANTIALIAS_SUBPIXEL)
    cr:stroke_preserve()
    cr:fill()
    cr:set_source(color(self._color or module.conf.icon_color))

    cr:set_source(color(self._fg or module.conf.icon_fg or beautiful.fg_normal))

    -- Draw the point -3 is is leave a pixel outside, one inside + antialiasing
    cr:arc(tri_width - 1, height - 3, 1, 0, 2*math.pi)
    cr:fill()

    -- Draw the ! top bar
    cr:set_line_width(2)
    cr:rectangle(tri_width - 2, 3, 2, height - 8)
    cr:fill()
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

    local layout = wibox.layout.fixed.horizontal()
    module.widget = wibox.widget.base.make_widget()
    module.widget._color = args.fg or args.color
    module.widget.draw = draw
    module.widget.fit = fit
    module.widget:set_tooltip("Notifications")
    module.widget:buttons(awful.util.table.join(awful.button({ }, 1, module.main), awful.button({ }, 3, module.reset)))

    module.tb = constrainedtext(nil, 1, 2)
    layout:add(module.widget, module.tb)

    return layout
end

--[[
[18:30:49] <Elv1313> minde: or at least fix my hack https://github.com/Elv13/awesome-configs/blob/master/rc.lua#L927
[18:31:16] <Elv1313> I don't know why (and havn't looked much), but the shape bounding is not applied correctly
[18:43:31] <Elv1313> the idea is/was to keep a single wibox when there is a single notification and to fallback to radical.imlp.notification (your module) when there is more than 1
[18:44:16] <Elv1313> I also planned to use some dark lua magic to take control of the widget border, but someone need to see why the shape_bounding is not working
[20:13:14] <Elv1313> You can integrate that, push that to git, then I will restore the border, fix the margins and make sure it fallback to the radical notification widget when there is more than 1
--]]

-- Hack to have rounded naughty popups
local wmt = getmetatable(wibox)
local wibox_constructor = wmt.__call
-- setmetatable(wibox,{__call = function()
--     print("foobar")
-- end})

local function resize_naughty(w)

    -- Give some padding
    w:disconnect_signal("property::width", resize_naughty)
    w:disconnect_signal("property::height", resize_naughty)
    w.width = w.width + 40

    -- Create a rounded shape
    local height,width = w.height,w.width
    local shape = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
    local cr = cairo.Context(shape)
    cr:set_source_rgba(0,0,0,0)
    cr:paint()
    cr:move_to(height/2,height)
    cr:arc(height/2, height/2, height/2, math.pi/2,3*(math.pi/2))
    cr:arc(width-height, height/2, height/2,3*(math.pi/2),math.pi/2)
    cr:close_path()
    cr:set_source_rgba(1,1,1,1)
    cr:fill()
    w.shape_bounding = shape._native

    -- Do the same for the background
    local bw = module.border_width+1 -- The '1' is to offset the antialiasing loss
    local radius = bw/2
    cr:move_to(bw+height/2,height-bw/2)
    width  = width  - bw*2

    -- Fill everything (used as border)
    cr:set_source(color(beautiful.naughty_border_color or beautiful.border_color or beautiful.fg_normal))
    cr:paint()

    -- Apply the main background color
    cr:arc(bw+height/2-bw-1, height/2-1, height/2 - radius, math.pi/2,3*(math.pi/2))
    cr:arc(width-height+2*bw-1, height/2-1, height/2 - radius,3*(math.pi/2),math.pi/2)
    cr:close_path()
    cr:set_line_width(bw)
    cr:set_source(color(beautiful.naughty_bg or beautiful.bg_normal))
    cr:fill()
    w:set_bg(cairo.Pattern.create_for_surface(shape))

    -- Move to center --TODO add option for all corners, use naughty if it support them
    w.x = math.floor(screen[1].geometry.width/2-width/2)
end

-- The trick here is to replace the wibox metatable to hijack the constructor
-- ... so evil!
local fake_naughty_box = {__call=function(...)
    local w = wibox_constructor(...)
    w:connect_signal("property::width", resize_naughty)
    w:connect_signal("property::height", resize_naughty)
    return w
end}

local function force_margins(self,margin)
    self:set_left   ( 10+margin )
    self:set_right  ( 10+margin )
    self:set_top    ( margin    )
    self:set_bottom ( margin    )
end

naughty._notify = naughty.notify
naughty.notify = function(args,...)
   if not module.skip then
      local args = args or {}

      -- Prevent the mask from hinding text
      local set_margins = wibox.container.margin.set_margins
      wibox.container.margin.set_margins = force_margins

      setmetatable(wibox, fake_naughty_box)
      local ret = naughty._notify(args,...)
      setmetatable(wibox, wmt)
      wibox.container.margin.set_margins = set_margins
--       module.skip = true
      return ret
   else
       return naughty._notify(args,...)
   end
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })

