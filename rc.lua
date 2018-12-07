-- Use capi.timer on 3.5.* and gears.timer on git master
if not timer then
  timer = require("gears.timer")
end

assert(mouse.coords() ~= nil)
local utils  = require( "utils"       )

--Uncomment both block to profile startup
-- utils.profile.start()
-- debug.sethook(utils.profile.trace, "crl", 1)

-- Gears
local gears  = require( "gears"       )
local cairo  = require( "lgi"         ).cairo
local color  = require( "gears.color" )
local glib   = require( "lgi"         ).GLib
local config = require( "forgotten"   )

-- Awful
local awful      = require( "awful"       )
if type(timer) == "function" then
  timer = require("gears.timer")
end

awful.rules      = require( "awful.rules" )
local wibox      = require( "wibox"       )
local tyrannical = require( "tyrannical"  )
require("awful.autofocus")
require("spawn_snid")

-- Shortcuts
require( "tyrannical.shortcut" )
require( "repetitive"          )
local shorter = require( "shorter" )

-- Theme handling library
local beautiful = require( "beautiful" )
local blind     = require( "blind"     )

-- Widgets
local chopped      = require( "chopped"                    )
local menubar      = require( "menubar"                    )
local customButton = require( "customButton"               )
local customMenu   = require( "customMenu"                 )
local drawer       = require( "drawer"                     )
local widgets      = require( "widgets"                    )
local radical      = require( "radical"                    )
local rad_task     = require( "radical.impl.tasklist"      )
local rad_taglist  = require( "radical.impl.taglist"       )
local collision    = require( "collision"                  )
local alttab       = require( "radical.impl.alttab"        )
local rad_client   = require( "radical.impl.common.client" )
local rad_tag      = require( "radical.impl.common.tag"    )

-- Data sources
local naughty       = require( "naughty"                  )
local notifications = require( "extern.notifications"     )
local vicious       = require( "extern.vicious"           )
-- local wirefu     = require( "wirefu.demo.notification" )

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}
vicious.cache( vicious.widgets.net )
vicious.cache( vicious.widgets.fs  )
vicious.cache( vicious.widgets.dio )
vicious.cache( vicious.widgets.cpu )
vicious.cache( vicious.widgets.mem )
vicious.cache( vicious.widgets.dio )

-- Various configuration options
config.showTitleBar  = false
config.themeName     = "arrow"
config.noNotifyPopup = true
config.useListPrefix = true
config.deviceOnDesk  = true
config.desktopIcon   = true
config.advTermTB     = true
config.scr           = {
    pri         = 1,
    sec         = 3,
    music       = 4,
    irc         = 2,
    media       = 5,
}


-- Load the theme
config.load()
config.themePath = awful.util.getdir("config") .. "/blind/" .. config.themeName .. "/"
-- beautiful.init(config.themePath                .. "/themeZilla.lua")
-- beautiful.init(config.themePath                .. "/themeIndustry.lua")
-- beautiful.init(config.themePath                .. "/themeHolo.lua")
-- beautiful.init(config.themePath                .. "/themePro.lua") --Unmaintained
-- beautiful.init(config.themePath                .. "/themeProGrey.lua") --Unmaintained
-- beautiful.init(config.themePath                .. "/theme.lua")
 beautiful.init(config.themePath                .. "/themeSciFi.lua")
-- beautiful.init(config.themePath                .. "/themeSciFiGrad.lua")
-- beautiful.init(config.themePath                .. "/themeMidnight1982.lua")
-- beautiful.init(config.themePath                .. "/themeCyberPunk.lua")
-- beautiful.init(config.themePath                .. "/themeWin9x.lua")
config.iconPath      = config.themePath .. "/Icon/"


-- This is used later as the default terminal and editor to run.
local titlebars_enabled = beautiful.titlebar_enabled == nil and true or beautiful.titlebar_enabled
terminal                = "urxvtc --background-expr 'align 1, 0, pad keep { load \""..os.getenv ( "HOME" ).."/config_files/term_logo.png\"}'"
editor                  = os.getenv("EDITOR") or "nano"
editor_cmd              = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

local dynamite = require("dynamite")

awful.layout.layouts = {
    awful.layout.suit.tile            ,
    awful.layout.suit.max             ,
    awful.layout.suit.floating        ,
    awful.layout.suit.tile.left       ,
    awful.layout.suit.tile.bottom     ,
    awful.layout.suit.tile.top        ,
    awful.layout.suit.fair            ,
    awful.layout.suit.fair.horizontal ,
    awful.layout.suit.spiral          ,
    awful.layout.suit.spiral.dwindle  ,
    awful.layout.suit.max.fullscreen  ,
    awful.layout.suit.corner.nw       ,
    awful.layout.suit.corner.ne       ,
    awful.layout.suit.corner.sw       ,
    awful.layout.suit.corner.se       ,
    awful.layout.suit.magnifier       ,
--     awful.layout.suit.treesome        ,
}

-- Add Collision shortcuts
collision()

-- movetagL,movetagR = {}, {}

dofile(awful.util.getdir("config") .. "/baseRule.lua")

-- Create the clock
local clock                  = drawer.dateInfo          ( nil                                )
-- clock.bg                     = beautiful.bar_bg_alternate or beautiful.bg_alternate

-- Create the volume box
local soundWidget            = drawer.soundInfo         ( 300                                )

-- Create the net manager
local netinfo                = drawer.netInfo           ( 300                                )

-- Create the memory manager
local meminfo                = drawer.memInfo           ( 300                                )

-- Create the cpu manager
local cpuinfo                = drawer.cpuInfo           ( 600                                )

-- Create the laucher dock
local lauchDock              = widgets.dock             ( nil , {position="left",default_cats={"Tools","Development","Network","Player"}})

-- Create battery
local bat                    =  wibox.widget.base.make_widget_declarative {
    {
        {
            widgets.battery(),
            left       = 9,
            right      = 7,
            top        = 2,
            bottom     = 2,
            draw_empty = false,
            widget     = wibox.container.margin,
        },
        bg                 = beautiful.systray_bg or beautiful.bg_alternate or beautiful.bg_normal,
        shape_border_color = beautiful.systray_shape_border_color,
        shape_border_width = beautiful.systray_shape_border_width or 0,
        shape              = gears.shape.rounded_bar,
        widget             = wibox.container.background
    },
    left       = 0,
    right      = 0,
    top        = 1,
    bottom     = 1,
    draw_empty = false,
    widget     = wibox.container.margin,
}

-- Create notifications history
local notif = wibox.widget.base.make_widget_declarative {
    {
        {
            notifications{fg=beautiful.fg_normal},
            left       = 7,
            right      = 7,
            top        = 1,
            bottom     = 1,
            draw_empty = false,
            widget     = wibox.container.margin,
        },
        bg                 = beautiful.systray_bg or beautiful.bg_alternate or beautiful.bg_normal,
        shape_border_color = beautiful.systray_shape_border_color,
        shape_border_width = beautiful.systray_shape_border_width or 0,
        shape              = gears.shape.rounded_bar,
        widget             = wibox.container.background
    },
    left       = 0,
    right      = 0,
    top        = 1,
    bottom     = 1,
    draw_empty = false,
    widget     = wibox.container.margin,
}

-- Create keyboard layout manager
local keyboard = wibox.widget.base.make_widget_declarative {
    {
        {
            widgets.keyboard(),
            left       = 7,
            right      = 7,
            top        = 1,
            bottom     = 1,
            draw_empty = false,
            widget     = wibox.container.margin,
        },
        bg                 = beautiful.systray_bg or beautiful.bg_alternate or beautiful.bg_normal,
        shape_border_color = beautiful.systray_shape_border_color,
        shape_border_width = beautiful.systray_shape_border_width or 0,
        shape              = gears.shape.rounded_bar,
        widget             = wibox.container.background
    },
    left       = 0,
    right      = 0,
    top        = 1,
    bottom     = 1,
    draw_empty = false,
    widget = wibox.container.margin,
}

-- Create some separators
local endArrow               = chopped.get_separator {
    weight      = chopped.weight.FULL                       ,
    direction   = chopped.direction.RIGHT                   ,
    sep_color   = nil                                       ,
    left_color  = beautiful.separator_color or beautiful.icon_grad                       ,
    right_color = nil                                       ,
}

local endArrow_alt2          = chopped.get_separator {
    weight      = chopped.weight.THIN                       ,
    direction   = chopped.direction.RIGHT                   ,
    sep_color   = beautiful.separator_color or beautiful.icon_grad or beautiful.fg_normal,
    left_color  = beautiful.bar_bg_alternate or beautiful.bg_alternate                    ,
    right_color = nil                                       ,
}

local endArrowR             = chopped.get_separator {
    weight      = chopped.weight.THIN                       ,
    direction   = chopped.direction.LEFT                    ,
    sep_color   = beautiful.separator_color or beautiful.icon_grad or beautiful.fg_normal,
    left_color  = nil                                       ,
    right_color = beautiful.bar_bg_alternate or beautiful.bg_alternate                    ,
}

local arr_last_tag_w       = chopped.get_separator {
    weight      = chopped.weight.THIN                       ,
    direction   = chopped.direction.RIGHT                   ,
    sep_color   = beautiful.separator_color or beautiful.icon_grad or beautiful.fg_normal,
    left_color  = nil                                       ,
    right_color = beautiful.bar_bg_alternate or beautiful.bg_alternate                    ,
    margin      = -beautiful.default_height/2
}

local endArrow2           = chopped.get_separator {
    weight      = chopped.weight.FULL                       ,
    direction   = chopped.direction.LEFT                    ,
    sep_color   = nil                                       ,
    left_color  = nil                                       ,
    right_color = beautiful.separator_color or beautiful.icon_grad or beautiful.fg_normal,
}

local spacer_img          = chopped.get_separator {
    weight      = chopped.weight.THIN                       ,
    direction   = chopped.direction.LEFT                    ,
    sep_color   = beautiful.separator_color or beautiful.icon_grad or beautiful.fg_normal,
    left_color  = nil                                       ,
    right_color = nil                                       ,
}

local sep_end_menu        = chopped.get_separator {
    weight      = chopped.weight.FULL                       ,
    direction   = chopped.direction.RIGHT                   ,
    sep_color   = nil                                       ,
    left_color  = nil                                       ,
    right_color = beautiful.separator_color or beautiful.icon_grad or beautiful.fg_normal,
    margin      = -beautiful.default_height/2
}

local spacer5 = widgets.spacer({text = " ",width=5})
local spacer2 = widgets.spacer({text = "" ,width=2})
-- Imitate the Gnome 2 menubar
local bar_menu,bar_menu_w = radical.bar{
    item_style           = beautiful.bottom_menu_item_style or radical.item.style.arrow_prefix,
    fg                   = beautiful.fg_normal,
    fg_focus             = beautiful.menu_fg_normal,
    bg                   = beautiful.bottom_menu_bg,
    disable_submenu_icon = true,
    style                = beautiful.bottom_menu_style,
    spacing              = beautiful.bottom_menu_spacing,
    default_item_margins = beautiful.bottom_menu_default_item_margins,
    default_margins      = beautiful.bottom_menu_default_margins,
    item_border_color    = beautiful.bottom_menu_item_border_color,
    item_border_width    = beautiful.bottom_menu_item_border_width,
    border_width         = beautiful.bottom_menu_border_width,
    border_color         = beautiful.bottom_menu_border_color,
    icon_transformation  = beautiful.bottom_menu_icon_transformation--[[ or function(icon,data,item)
        return gears.color.apply_mask(icon,beautiful.button_bg_normal or beautiful.bg_normal)
    end]],
}
bar_menu:add_colors_namespace("bottom_menu")

local app_menu = nil
local it = bar_menu:add_item {
    text     = beautiful.apps_title or "Apps",
    icon     = beautiful.awesome_icon,
    tooltip  = "Application menu",
    bg_used  = beautiful.bar_bg_buttons or beautiful.menu_bg_normal,
    spacing  = 8,
    sub_menu = function()
        if not app_menu then
            app_menu = customMenu.appmenu (
            { -- Main menu
                filter      = true,
                show_filter = true,
                max_items   = 20,
                style       = beautiful.button_menu_style or radical.style.classic,
                item_style  = beautiful.button_menu_menu_item_style or radical.item.style.classic
            }
           ,{ -- Sub menus
                max_items   = 20,
                style       = beautiful.button_menu_style or radical.style.classic,
                item_style  = beautiful.button_menu_menu_item_style or radical.item.style.classic
            })
        end
        return app_menu
    end
}
it.state[radical.base.item_flags.USED] = true
it = bar_menu:add_item {
    text     = "Places",
    icon     = config.iconPath .. "tags_invert/home.png",
    tooltip  = "Folder shortcuts",
    sub_menu = customMenu.places.get_menu,
    style    = beautiful.button_menu_style,
    bg_used  = beautiful.bar_bg_buttons or beautiful.menu_bg_normal,
}
it.state[radical.base.item_flags.USED] = true
it = bar_menu:add_item {text="Launch",
    icon     = config.iconPath .. "gearA.png",
    tooltip  = "Execute a command",
    style    = beautiful.button_menu_style,
    sub_menu = customMenu.launcher.get_menu,
    bg_used  = beautiful.bar_bg_buttons or beautiful.menu_bg_normal,
}
it.state[radical.base.item_flags.USED] = true

it = bar_menu:add_item {tooltip="Show desktop",icon = config.iconPath .. "tags_invert/desk.png", button1=function()awful.tag.viewnone()end}

rad_taglist.taglist_watch_name_changes = true

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


alttab.default_icon   = config.iconPath .. "tags_invert /other.png"
alttab.titlebar_path  = config.themePath.. "Icon/titlebar/"

-- Create a wibox for each screen and add it
      mypromptbox = {}
local wibox_top   = {}
local wibox_bot   = {}
local mytaglist   = {}

local wibox_args = {
    ontop        = false,
    screen       = s,
    height       = beautiful.wibar_height or beautiful.default_height ,
    bg           = beautiful.wibar_bg or beautiful.bar_bg_normal or beautiful.bg_normal,
    fg           = beautiful.wibar_fg,
}

awful.screen.connect_for_each_screen(function(s)
--         print("S", s.dpi)
--         s.dpi = 110
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create the wibox

    if beautiful.bar_show_top ~= false then
        wibox_top[s] = awful.wibar(setmetatable({ position = "top"    , screen = s},{__index=wibox_args}))
        wibox_top[s]:set_bgimage(beautiful.wibar_bgimage)
    end

    if beautiful.bar_show_bottom ~= false then
        wibox_bot[s] = awful.wibar(setmetatable({ position = "bottom" , screen = s},{__index=wibox_args}))
        wibox_bot[s]:set_bgimage(beautiful.wibar_bgimage)
    end


    -- Create the tag control menu
    local tag_control,tag_control_w = radical.bar{
        item_style           = beautiful.toolbox_item_style or radical.item.style.rounded,
        item_layout          = radical.item.layout.icon,
        item_border_width    = beautiful.toolbox_item_border_width,
        icon_transformation  = beautiful.toolbox_icon_transformation,
        icon_per_state       = beautiful.toolbox_icon_per_state,
        style                = beautiful.toolbox_style,
        default_item_margins = beautiful.toolbox_default_item_margins or {
            LEFT   = 0,
            RIGHT  = 0,
            TOP    = 0,
            BOTTOM = 0,
        },
        default_margins      = beautiful.toolbox_default_margins or {
            TOP    = 0,
            BOTTOM = 0,
            RIGHT  = 5,
            LEFT   = 5,
        },
        spacing = beautiful.toolbox_spacing,
    }
    tag_control:add_colors_namespace("toolbox")

    local function parallelogram_shape(cr, width, height)
        cr:rectangle(0, height/3, width, height/3)
    end

    local h =beautiful.wibar_height or beautiful.default_height

    local screen_left_icon = gears.surface.load_from_shape(
        h, h, 
        gears.shape.transform(gears.shape.arrow) : rotate_at(h/2,h/2, math.pi*1.5),
        beautiful.fg_normal, "#00000000"
    )

    local screen_right_icon = gears.surface.load_from_shape(
        h, h, 
        gears.shape.transform(gears.shape.arrow) : rotate_at(h/2,h/2, math.pi*0.5),
        beautiful.fg_normal, "#00000000"
    )

    local screen_minus_icon = gears.surface.load_from_shape(
        h, h, 
        parallelogram_shape,
        beautiful.fg_normal, "#00000000"
    )

    local screen_cross_icon = gears.surface.load_from_shape(
        h, h, 
        gears.shape.cross,
        beautiful.fg_normal, "#00000000"
    )

    if screen.count() > 1 then
        tag_control:add_item {icon = screen_left_icon            , tooltip = "Move tag to the previous screen" }.state[radical.base.item_flags.USED] = true
        tag_control:add_item {icon = screen_right_icon           , tooltip = "Move tag to the next screen"}.state[radical.base.item_flags.USED] = true
    end
    tag_control:add_item {icon = screen_cross_icon           , tooltip = "Add a new tag", button1=function()
            awful.tag.viewonly(awful.tag.add("NewTag",{screen= (mouse.screen) }))
        end}.state[radical.base.item_flags.USED] = true
    tag_control:add_item {icon = screen_minus_icon           , tooltip = "Delete the current tag", button1=function()
            awful.tag.delete(client.focus and client.focus.screen.selected_tag or mouse.screen.selected_tag )
        end}.state[radical.base.item_flags.USED] = true

    customButton.lockTag(s, tag_control)

    rad_tag.layout_item(tag_control,{screen=s,tooltip="Change layout"}).state[radical.base.item_flags.USED] = true

    -- Top Wibox
    wibox_top[s]:setup {
        { --Left
            rad_taglist(s)._internal.margin, --Taglist
            { -- Tag control buttons
                {
                    {
                        arr_last_tag_w,
                        tag_control_w,
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.container.margin(nil,1,4,0,0)
                },
                layout = wibox.container.background(nil,beautiful.bar_bg_alternate or beautiful.bg_alternate)
            }, --Buttons
            endArrow_alt2           , --Separator
            layout = wibox.layout.fixed.horizontal
        },
        nil, --Center
        (s.index == config.scr.pri or s.index == config.scr.sec) and { -- Right, first screen only
            endArrowR,
            { -- The background
                beautiful.bar_show_info ~= false and { -- The widgets
                    spacer5    ,
                    cpuinfo    ,
                    spacer_img ,
                    meminfo    ,
                    spacer_img ,
                    netinfo    ,
                    spacer_img ,
                    soundWidget,
                    spacer_img ,
                    clock      ,
                    layout = wibox.layout.fixed.horizontal
                } or {
                    clock      ,
                    layout = wibox.layout.fixed.horizontal
                },
                layout = wibox.container.background(nil,beautiful.bar_bg_alternate or beautiful.bg_alternate)
            },
            layout = wibox.layout.fixed.horizontal
        } or nil,
        layout = wibox.layout.align.horizontal
    }

    if beautiful.bar_show_bottom ~= false then
        -- Bottom Wibox
        wibox_bot[s]:setup {
            { --Left
                bar_menu_w     ,
    --                 sep_end_menu   ,
                {
                    mypromptbox[s] ,
                    fg     = beautiful.prompt_fg or beautiful.systray_icon_fg,
                    bg     = beautiful.bg_systray_alt or beautiful.bg_systray or beautiful.icon_grad,
                    layout = wibox.container.background
                },
                layout = wibox.layout.fixed.horizontal,
            },
            rad_task(s).widget or nil, --Center
            {
                endArrow2                                ,
                { -- Right
                    {
                        {
                            spacer5                          ,
                            keyboard                         ,
                            spacer2                          ,
                            notif                            ,
                            spacer2                          ,
                            bat                              ,
                            spacer2                          ,
                            s.index == 1 and wibox.widget.systray() or nil,
                            layout = wibox.layout.fixed.horizontal
                            --clock      , --TODO add a beautiful option for clock position
                        },
                    top    = beautiful.systray_margins_top    or 0,
                    bottom = beautiful.systray_margins_bottom or 0,
                    left   = beautiful.systray_margins_left   or 0,
                    right  = beautiful.systray_margins_right  or 0,
                    widget = wibox.container.margin
                    },
                    bgimage = beautiful.bgimage_systray_alt,
                    bg      = beautiful.bg_systray_alt or beautiful.bg_systray or beautiful.icon_grad or beautiful.fg_normal,
                    widget  = wibox.container.background
                },
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.align.horizontal
        }
    end
end)

-- Add keyboard shortcuts
dofile(awful.util.getdir("config") .. "/shortcuts.lua")

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "Conky" },
      properties = { border_width = 0,
                     border_color = beautiful.border_normal,} },
    { rule = { name = "[OS][pa][ev][en] File" },
      properties = { fullscreen = true} },
}
-- }}}


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    --Fix some wierd reload bugs
    if c.size_hints.user_size and startup then
        c:geometry({width = c.size_hints.user_size.width,height = c.size_hints.user_size.height, x = c:geometry().x})
    end
    if c.size_hints.max_height and c.size_hints.max_height < screen[c.screen].geometry.height/2 then
        awful.client.setslave(c)
    end
    if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end

    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        widgets.titlebar(c)
    end
end)

client.connect_signal("focus", function(c)
    local tb = c:titlebar_top()
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.taglist_bg_image_selected
    end
--     if not c.class == "URxvt" then
        c.border_color = beautiful.border_focus
--     end
end)
client.connect_signal("unfocus", function(c)
    local tb = c:titlebar_top()
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.tasklist_bg_image_selected or beautiful.taglist_bg_image_used
    end
--     if not c.class == "URxvt" then
        c.border_color = beautiful.border_normal
--     end
end)


naughty.disconnect_signal("request::display", naughty.default_notification_handler)

naughty.connect_signal("request::display", function(n)
    local w = naughty.widget.box {
        notification    = n,
        shape           = gears.shape.rounded_bar,
        border_width    = 2,
        placement       = awful.placement.top,
        offset          = 20,
        widget_template = {
            {
                {
                    naughty.widget.icon {notification = n},
                    {
                        naughty.widget.title   {notification = n},
                        naughty.widget.message {notification = n},
                        layout = wibox.layout.fixed.vertical
                    },
                    fill_space = true,
                    layout     = wibox.layout.fixed.horizontal
                },
                naughty.widget.actionlist {notification = n},
                spacing_widget = {
                    forced_height = 10,
                    span_ratio    = 0.9,
                    color = "#ff0000",
                    widget        = wibox.widget.separator
                },
                spacing = 10,
                layout  = wibox.layout.fixed.vertical
            },
            left    = 20,
            right   = 20,
            top     = 5,
            widget  = wibox.container.margin
        },
    }

    w:buttons(gears.table.join(
        awful.button({ }, 1, function () n:destroy() end)
    ))
end)

-- When setting a client as "slave", use the first available slot instead of the last
awful.client._setslave = awful.client.setslave
function awful.client.setslave(c)
    local t = c.screen.selected_tag
    local nmaster = t.master_count or 1
    local cls = awful.client.tiled(c.screen) or client.get(c.screen)
    local index = awful.util.table.hasitem(cls,c)
    if index and index <= nmaster and #cls > nmaster then
        c:swap(cls[nmaster+1])
    else
        awful.client._setslave(c)
    end
end

-- require("radical.impl.tasklist.extensions").add("Running time",function(client)
--     local w = wibox.widget.base.make_widget()
--     w.fit = function(_,context, w, h)
--         return radical.widgets.underlay.fit("foo",{bg="#ff0000"}),h
--     end
--     w.draw = function(self, context, cr, width, height)
--         cr:set_source_surface(radical.widgets.underlay.draw("foo",{bg=beautiful.fg_normal,height=beautiful.default_height}))
--         cr:paint()
--     end
--     return w
-- end)
-- 
-- require("radical.impl.tasklist.extensions").add("Machine",function(client)
--     local w = wibox.widget.base.make_widget()
--     w.fit = function(_,context, w, h)
--         return radical.widgets.underlay.fit(client.machine,{bg="#ff0000"}),h
--     end
--     w.draw = function(self, context, cr, width, height)
--         cr:set_source_surface(radical.widgets.underlay.draw(client.machine,{bg=beautiful.fg_normal,height=beautiful.default_height}))
--         cr:paint()
--     end
--     return w
-- end)
-- require("radical.impl.taglist.extensions").add("Count",function(client)
--     local w = wibox.widget.base.make_widget()
--     w.fit = function(_,context, w, h)
--         return radical.widgets.underlay.fit("12",{bg="#ff0000"}),h
--     end
--     w.draw = function(self, context, cr, width, height)
--         cr:set_source_surface(radical.widgets.underlay.draw("12",{bg=beautiful.fg_normal,height=beautiful.default_height}))
--         cr:paint()
--     end
--     return w
-- end)

--     awful.popup {
--         widget = {
--             {
--                 {
--                     text   = "foobar",
--                     widget = wibox.widget.textbox
--                 },
--                 {
--                     {
--                         text   = "foobar",
--                         widget = wibox.widget.textbox
--                     },
--                     bg     = "#ff00ff",
--                     clip   = true,
--                     shape  = gears.shape.rounded_bar,
--                     widget = wibox.container.background
--                 },
--                 {
--                     value         = 0.5,
--                     forced_height = 30,
--                     forced_width  = 100,
--                     widget        = wibox.widget.progressbar
--                 },
--                 layout = wibox.layout.fixed.vertical,
--             },
--             margins = 10,
--             widget  = wibox.container.margin
--         },
--         border_color = "#00ff00",
--         border_width = 5,
--         placement    = awful.placement.top_left,
--         shape        = gears.shape.octogon,
--         visible      = true,
--     }

shorter.register_section("TYRANNICAL",{
    foo = "bar",
    bar = "foo"
})

shorter.register_section_text("REPETITIVE","gdfgdfgdfg dsfhg jsdghjsdf gdsfhj gdhj gjgj gjdf ghdjfh gjgdjgdjhg d dhjfg dhfjg dhfj gdhfgj sdhj fg")

