
-- Gears
local gears  = require( "gears"       )
local cairo  = require( "lgi"         ).cairo
local color  = require( "gears.color" )
local glib   = require( "lgi"         ).GLib
local config = require( "forgotten"   )
local utils  = require( "utils"       )
require("retrograde")

-- Awful
local awful      = require( "awful"       )
awful.rules      = require( "awful.rules" )
local wibox      = require( "wibox"       )
local tyrannical = require( "tyrannical"  )
require("awful.autofocus")

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

-- Hardware
local wacky = require("wacky")

-- utils.profile.start()
-- debug.sethook(utils.profile.trace, "crl", 1)
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
config.scriptPath    = awful.util.getdir("config") .. "/Scripts/"
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
config.iconPath  = config.themePath       .. "Icon/"
beautiful.init(config.themePath                .. "/themeZilla.lua")


-- This is used later as the default terminal and editor to run.
local titlebars_enabled = beautiful.titlebar_enabled == nil and true or beautiful.titlebar_enabled
terminal                = "urxvtc"
editor                  = os.getenv("EDITOR") or "nano"
editor_cmd              = terminal .. " -e " .. editor

-- Default modkey.
modkey = "Mod4"

local layouts =
{
    awful.layout.suit.floating        ,
    awful.layout.suit.tile            ,
    awful.layout.suit.tile.left       ,
    awful.layout.suit.tile.bottom     ,
    awful.layout.suit.tile.top        ,
    awful.layout.suit.fair            ,
    awful.layout.suit.fair.horizontal ,
    awful.layout.suit.spiral          ,
--     awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max             ,
    awful.layout.suit.max.fullscreen  ,
    awful.layout.suit.magnifier       ,
}
local layouts_all =
{
    awful.layout.suit.floating        ,
    awful.layout.suit.tile            ,
    awful.layout.suit.tile.left       ,
    awful.layout.suit.tile.bottom     ,
    awful.layout.suit.tile.top        ,
    awful.layout.suit.fair            ,
    awful.layout.suit.fair.horizontal ,
    awful.layout.suit.spiral          ,
--     awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max             ,
    awful.layout.suit.max.fullscreen  ,
    awful.layout.suit.magnifier       ,
}

-- Add Collision shortcuts
collision()

movetagL,movetagR = {}, {}

dofile(awful.util.getdir("config") .. "/baseRule.lua")

-- Create the "Show Desktop" icon
local desktopPix             = customButton.showDesktop ( nil                                )

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
local cpuinfo                = drawer.cpuInfo           ( 300                                )

-- Create the laucher dock
local lauchDock              = widgets.dock             ( nil , {position="left",default_cats={"Tools","Development","Network","Player"}})

-- Create battery
local bat                    = widgets.battery()

-- Create notifications history
local notif                  = notifications()

-- Create keyboard layout manager
local keyboard               = widgets.keyboard()

-- Create the addTag icon (depend on shifty rule)
local addTag                 = customButton.addTag                      ( nil )


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
--     item_border_color    = "#ff0000",
    border_width         = 2,
    icon_transformation  = beautiful.bottom_menu_icon_transformation or function(icon,data,item)
        return gears.color.apply_mask(icon,beautiful.button_bg_normal or beautiful.bg_normal)
    end,
}
bar_menu:add_colors_namespace("bottom_menu")

local app_menu = nil
local it = bar_menu:add_item {
    text     = "Apps",
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
                style       = radical.style.classic,
                item_style  = radical.item.style.classic
            }
           ,{ -- Sub menus
                max_items   = 20,
                style       = radical.style.classic,
                item_style  = radical.item.style.classic
            })
        end
        return app_menu
    end
}
it.state[radical.base.item_flags.USED] = true
it = bar_menu:add_item {
    text     = "Places",
    icon     = config.iconPath .. "tags/home.png",
    tooltip  = "Folder shortcuts",
    sub_menu = customMenu.places.get_menu,
    bg_used  = beautiful.bar_bg_buttons or beautiful.menu_bg_normal,
}
it.state[radical.base.item_flags.USED] = true
it = bar_menu:add_item {text="Launch",
    icon     = config.iconPath .. "gearA.png",
    tooltip  = "Execute a command",
    sub_menu = customMenu.launcher.get_menu,
    bg_used  = beautiful.bar_bg_buttons or beautiful.menu_bg_normal,
}
it.state[radical.base.item_flags.USED] = true

rad_taglist.taglist_watch_name_changes = true

-- Load the desktop "conky" widget
-- widgets.desktopMonitor(screen.count() == 1 and 1 or 2)


-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


alttab.default_icon   = config.iconPath .. "tags/other.png"
alttab.titlebar_path  = config.themePath.. "Icon/titlebar/"

-- Create a wibox for each screen and add it
      mypromptbox = {}
local wibox_top   = {}
local wibox_bot   = {}
local mytaglist   = {}
local layoutmenu  = {}
local delTag      = {}
local lockTag     = {}

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create the delTag button
    delTag[s]     = customButton.delTag   ( s                                               )
    lockTag[s]    = customButton.lockTag                      ( s )

    -- Create the button to move a tag the next screen
    movetagL[s]   = customButton.tagmover(s,{ direction = "left",  icon = config.iconPath .. "tags/screen_left.png"  })
    movetagR[s]   = customButton.tagmover(s,{ direction = "right", icon = config.iconPath .. "tags/screen_right.png" })

    -- Create the layout menu for this screen
    layoutmenu[s] = customMenu.layoutmenu ( s,layouts_all                                   )

    -- Create the wibox
    wibox_top[s] = awful.wibox({ position = "top"   , ontop=false,screen = s,height=beautiful.default_height , bg = beautiful.bar_bg_normal or beautiful.bg_normal })
    wibox_bot[s] = awful.wibox({ position = "bottom", ontop=false,screen = s,height=beautiful.default_height , bg = beautiful.bar_bg_normal or beautiful.bg_normal })

    -- Create the tag control menu
    local tag_control,tag_control_w = radical.bar{
        item_style           = beautiful.toolbox_item_style or radical.item.style.rounded,
        item_layout          = radical.item.layout.icon,
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
        }
    }
    tag_control:add_colors_namespace("toolbox")
--     tag_control:add_widgets {
--         addTag        ,
--         delTag     [s],
--         lockTag    [s],
--         movetagL   [s],
--         movetagR   [s],
--         layoutmenu [s],
--     }
    
    
    tag_control:add_items {
        {icon = config.iconPath .. "tags/screen_left.png"            , tooltip = "Move tag to the previous screen" },
        {icon = config.iconPath .. "tags/screen_right.png"           , tooltip = "Move tag to the next screen"},
        {icon = config.iconPath .. "tags/cross2.png"                 , tooltip = "Add a new tag", button1=function()
            awful.tag.viewonly(awful.tag.add("NewTag",{screen= (client.focus and client.focus.screen or mouse.screen) }))
        end},
        {icon = config.iconPath .. "tags/minus2.png"                 , tooltip = "Delete the current tag", button1=function()
            awful.tag.delete(client.focus and awful.tag.selected(client.focus.screen) or awful.tag.selected(mouse.screen) )
        end},
--         {icon = config.iconPath .. "layouts_small/spiral_d.png"      , },
    }
    rad_tag.layout_item(tag_control,{screen=s,tooltip="Change layout"})
    
    -- Top Wibox
    wibox_top[s]:set_widgets {
        { --Left
            rad_taglist(s)._internal.margin, --Taglist
            { -- Tag control buttons
                {
                    {
                        arr_last_tag_w,
                        tag_control_w,
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.margin(nil,1,4,0,0)
                },
                layout = wibox.widget.background(nil,beautiful.bar_bg_alternate or beautiful.bg_alternate)
            }, --Buttons
            endArrow_alt2           , --Separator
            layout = wibox.layout.fixed.horizontal
        },
        nil, --Center
        (s == config.scr.pri or s == config.scr.sec) and { -- Right, first screen only
            endArrowR,
            { -- The background
                { -- The widgets
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
                },
                layout = wibox.widget.background(nil,beautiful.bar_bg_alternate or beautiful.bg_alternate)
            },
            layout = wibox.layout.fixed.horizontal
        } or nil,
        layout = wibox.layout.align.horizontal
    }

    -- Bottom Wibox
    wibox_bot[s]:set_widgets {
        { --Left
            bar_menu_w     ,
            {
                mypromptbox[s] ,
                layout = wibox.widget.background(nil,beautiful.icon_grad)
            },
            sep_end_menu   ,
            desktopPix     ,
            runbg          ,
            endArrow       ,
            layout = wibox.layout.fixed.horizontal,
        },
        rad_task(s or 1)._internal.margin, --Center
        {
            endArrow2                                ,
            { -- Right
                {
                    spacer5                          ,
                    keyboard                         ,
                    notif                            ,
                    bat                              ,
                    spacer5                          ,
                    s == 1 and wibox.widget.systray(),
                },
                layout = wibox.widget.background(nil,beautiful.icon_grad or beautiful.fg_normal),
            },
        },
        layout = wibox.layout.align.horizontal
    }

end

-- Add the drives list on the desktop
-- if config.deviceOnDesk == true then
--   widgets.devices()
-- end
-- if config.desktopIcon == true then
--     for i=1,20 do
--         widgets.desktopIcon()
--     end
-- end

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


client.connect_signal("tagged",function(c)
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        local tb = awful.titlebar(c,{size=beautiful.titlebar_height or 16})
        if tb and tb.title_wdg then
            local underlays = {}
            for k,v in ipairs(c:tags()) do
                underlays[#underlays+1] = v.name
            end
            tb.title_wdg:set_underlay(underlays,{style=radical.widgets.underlay.draw_arrow,alpha=1,color="#0C2853"})
        end
    end
end)

client.connect_signal("focus", function(c)
    local tb = c:titlebar_top()
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.taglist_bg_image_selected
    end
    if not c.class == "URxvt" then
        c.border_color = beautiful.border_focus
    end
end)
client.connect_signal("unfocus", function(c)
    local tb = c:titlebar_top()
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.tasklist_bg_image_selected or beautiful.taglist_bg_image_used
    end
    if not c.class == "URxvt" then
        c.border_color = beautiful.border_normal
    end
end)

-- When setting a client as "slave", use the first available slot instead of the last
awful.client._setslave = awful.client.setslave
function awful.client.setslave(c)
    local t = awful.tag.selected(c.screen)
    local nmaster = awful.tag.getnmaster(t) or 1
    local cls = awful.client.tiled(c.screen) or client.get(c.screen)
    local index = awful.util.table.hasitem(cls,c)
    if index and index <= nmaster and #cls > nmaster then
        c:swap(cls[nmaster+1])
    else
        awful.client._setslave(c)
    end
end

require("radical.impl.tasklist.extensions").add("Running time",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return radical.widgets.underlay.fit("foo",{bg="#ff0000"}),h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw("foo",{bg=beautiful.fg_normal,height=beautiful.default_height}))
        cr:paint()
    end
    return w
end)

require("radical.impl.tasklist.extensions").add("Machine",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return radical.widgets.underlay.fit(client.machine,{bg="#ff0000"}),h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw(client.machine,{bg=beautiful.fg_normal,height=beautiful.default_height}))
        cr:paint()
    end
    return w
end)
require("radical.impl.taglist.extensions").add("Count",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return radical.widgets.underlay.fit("12",{bg="#ff0000"}),h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw("12",{bg=beautiful.fg_normal,height=beautiful.default_height}))
        cr:paint()
    end
    return w
end)

shorter.register_section("TYRANNICAL",{
    foo = "bar",
    bar = "foo"
})

shorter.register_section_text("REPETITIVE","gdfgdfgdfg dsfhg jsdghjsdf gdsfhj gdhj gjgj gjdf ghdjfh gjgdjgdjhg d dhjfg dhfjg dhfj gdhfgj sdhj fg")

-- require("wirefu.demo.notification")
