-- Standard awesome library
-- require("crashed")
local gears = require("gears")
local cairo     = require( "lgi"              ).cairo
local color     = require( "gears.color"      )
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local customButton = require("customButton")
local customMenu = require("customMenu")
local config = require("forgotten")
-- config.load()
-- print(config.idfgdfgdfgdfgdfgdf.dfgdfg.dfgdfg)
-- exit(3)
local drawer = require("drawer")
local widgets = require("widgets")
-- local shifty = require("shifty")
local utils = require("utils")
local vicious = require("extern.vicious")
local menu4 = require( "radical.context"          )
local radical = require("radical")
local rad_task = require("radical.impl.tasklist")
local rad_tag = require("radical.impl.taglist")
local tyrannical = require("tyrannical")
local tyr_launcher = require("tyrannical.extra.launcher")
local indicator = require("customIndicator")
local blind = require("blind")
local alttab = require("radical.impl.alttab")
local notifications = require("extern.notifications")
local glib = require("lgi").GLib
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
beautiful.init(config.themePath                .. "/themeSciFi.lua")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init(awful.util.getdir("config").."/blind/arrow/themeSciFi.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
-- Table of layouts to cover with awful.layout.inc, order matters.

local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
--     awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
local layouts_all =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
--     awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

movetagL,movetagR = {}, {}

dofile(awful.util.getdir("config") .. "/baseRule.lua")


-- Create the application menu
local appMenu                = customMenu.application   ( nil                                )

-- Create the place menu TODO use the KDE list instead of the hardcoded one
local placesMenu             = customMenu.places        ( 100                                )

-- Call the laucher wibox
local launcher               = customMenu.launcher      ( 200                                )

-- Create the "Show Desktop" icon
local desktopPix             = customButton.showDesktop ( nil                                )

-- Create the clock
local clock                  = drawer.dateInfo          ( nil                                )
clock.bg                     = beautiful.bg_alternate

-- Create the volume box
local soundWidget            = drawer.soundInfo         ( 300                                )

-- Create the net manager
local netinfo                = drawer.netInfo           ( 300                                )

-- Create the memory manager
local meminfo                = drawer.memInfo           ( 300                                )

-- Create the cpu manager
local cpuinfo                = drawer.cpuInfo           ( 300                                )

-- Create the laucher dock
local lauchDock              = widgets.dock             ( nil                                )

-- Create the laucher dock
local endArrow               = blind.common.drawing.get_beg_arrow_wdg2({bg_color=beautiful.icon_grad })
-- Create the laucher dock
local endArrow_alt           = blind.common.drawing.get_beg_arrow_wdg2({bg_color=beautiful.bg_alternate})
local endArrow_alt2i         = cairo.ImageSurface(cairo.Format.ARGB32, beautiful.default_height/2+2, beautiful.default_height)
local cr = cairo.Context(endArrow_alt2i)
cr:set_source_surface(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.bg_alternate}))
cr:paint()
cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
cr:set_line_width(1.5)
cr:move_to(0,-2)
cr:line_to(beautiful.default_height/2,beautiful.default_height/2)
cr:line_to(0,beautiful.default_height+2)
cr:stroke()
local endArrow_alt2 = wibox.widget.imagebox()
endArrow_alt2:set_image(endArrow_alt2i)

-- Create battery
local bat = widgets.battery()

-- Create notifications history
local notif = notifications()

-- Create keyboard layout manager
local keyboard = widgets.keyboard()

-- End arrow
local endArrowR = wibox.widget.imagebox()

local endArrowR2i         = cairo.ImageSurface(cairo.Format.ARGB32, beautiful.default_height/2+2, beautiful.default_height)
local cr = cairo.Context(endArrowR2i)
cr:set_source_surface(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.bg_alternate ,direction="left"}),2,0)
cr:paint()
cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
cr:set_line_width(1.5)
cr:move_to(beautiful.default_height/2+2,-2)
cr:line_to(2,beautiful.default_height/2)
cr:line_to(beautiful.default_height/2+2,beautiful.default_height+2)
cr:stroke()

endArrowR:set_image(endArrowR2i)
local endArrowR2 = wibox.widget.imagebox()
endArrowR2:set_image(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.bg_alternate ,direction="left"}),2,0)

-- Create the addTag icon (depend on shifty rule)
local addTag                 = customButton.addTag                      ( nil )

-- Create the addTag icon (depend on shifty rule)
local lockTag                 = {}

-- Create the keyboard layout switcher, feel free to add your contry and push it to master
local keyboardSwitcherWidget = widgets.keyboardSwitcher ( nil                                )

-- Load the desktop "conky" widget
-- widgets.desktopMonitor(screen.count() == 1 and 1 or 2)

--Some spacers with dirrent text
spacer5 = widgets.spacer({text = " ",width=5})
local spacer_img = blind.common.drawing.separator_widget()

local arr_last_tag = blind.common.drawing.get_end_arrow2({ bg_color=beautiful.bg_alternate })
local cr = cairo.Context(arr_last_tag)
cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
cr:set_line_width(1.5)
cr:move_to(0,-2)
cr:line_to(beautiful.default_height/2,beautiful.default_height/2)
cr:line_to(0,beautiful.default_height+2)
cr:stroke()
local arr_last_tag_w = wibox.widget.base.make_widget()
arr_last_tag_w.fit=function(s,w,h)
    return 0,h
end
-- Use negative offset
arr_last_tag_w.draw = function(self, w, cr, width, height)
    cr:save()
    cr:reset_clip()
    cr:set_source_surface(arr_last_tag,-beautiful.default_height/2-1,0)
    cr:paint()
    cr:restore()
end

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

local prev_menu,prev_item = nil

beautiful.on_tag_hover = customMenu.taghover
beautiful.on_task_hover = function(c,geo,visible)
    if not visible and prev_menu then
        prev_menu.visible = false
        return
    end
    if not c then return end
    if not prev_menu then
        prev_menu = radical.context({layout=radical.layout.horizontal,item_width=140,item_height=140,icon_size=100,
            arrow_type=radical.base.arrow_type.CENTERED,enable_keyboard=false,item_style=radical.item.style.rounded})
        prev_item = prev_menu:add_item({text = "<b>"..c.name.."</b>",icon=c.content})
        prev_menu.wibox.opacity=0.8
    end
    if prev_item then
        prev_item.icon = c.content
        prev_item.text  = "<b>"..c.name:gsub('&','&amp;').."</b>"
        prev_menu.parent_geometry = geo
        prev_menu.visible = true
    end
end
alttab.default_icon   = config.iconPath .. "tags/other.png"
alttab.titlebar_path  = config.themePath.. "Icon/titlebar/" 

-- Create a wibox for each screen and add it
wibox_top = {}
wibox_bot = {}
mypromptbox = {}
mytaglist = {}
layoutmenu = {}
delTag   = {}


local right_layout = wibox.layout.fixed.horizontal()
local right_layout_meta = wibox.layout.fixed.horizontal()
right_layout_meta:add(endArrowR)
right_layout:add(spacer5)
right_layout:add(cpuinfo)
right_layout:add(spacer_img)
right_layout:add(meminfo)
right_layout:add(spacer_img)
right_layout:add(netinfo)
right_layout:add(spacer_img)
right_layout:add(soundWidget)
right_layout:add(spacer_img)
right_layout:add(clock)
local right_bg = wibox.widget.background()
right_bg:set_bg(beautiful.bg_alternate)
right_bg:set_widget(right_layout)
right_layout_meta:add(right_bg)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create a taglist widget

    -- Create the delTag button
    delTag[s]     = customButton.delTag   ( s                                               )
    lockTag[s]    = customButton.lockTag                      ( s )

    -- Create the button to move a tag the next screen
    movetagL[s]   = customButton.tagmover(s,{ direction = "left",  icon = config.iconPath .. "tags/screen_left.png"  })
    movetagR[s]   = customButton.tagmover(s,{ direction = "right", icon = config.iconPath .. "tags/screen_right.png" })

    -- Create the layout menu for this screen
    layoutmenu[s] = customMenu.layoutmenu ( s,layouts_all                                   )

    -- Create the wibox
    wibox_top[s] = awful.wibox({ position = "top"   , screen = s,height=beautiful.default_height , bg = beautiful.bg_wibar or beautiful.bg_normal })
    wibox_bot[s] = awful.wibox({ position = "bottom", screen = s,height=beautiful.default_height , bg = beautiful.bg_wibar or beautiful.bg_normal })

    -- Widgets that are aligned to the left
    local left_layout_top = wibox.layout.fixed.horizontal()

    local tag_bar = rad_tag(s)
    left_layout_top:add(tag_bar._internal.layout)
    local bgb = wibox.widget.background()
    local l2 = wibox.layout.fixed.horizontal()
    local mar = wibox.layout.margin()
    mar:set_left(1)
    mar:set_right(4)
    mar:set_widget(l2)
    bgb:set_widget(mar)
    bgb:set_bg(beautiful.bg_alternate)
    l2:add(arr_last_tag_w)
    l2:add(addTag     )
    l2:add(delTag  [s])
    l2:add(lockTag [s])
    l2:add(movetagL  [s])
    l2:add(movetagR  [s])
--     left_layout_top:add(movetagL[s])
--     left_layout_top:add(movetagR[s])
    l2:add(layoutmenu[s])
    left_layout_top:add(bgb)
    left_layout_top:add(endArrow_alt2)

    local layout_top = wibox.layout.align.horizontal()

    -- Widgets that are aligned to the right
    if s == config.scr.pri or s == config.scr.sec then
        layout_top:set_right(right_layout_meta)
    end

    -- Now bring it all together (with the tasklist in the middle)
    layout_top:set_left(left_layout_top)

    wibox_top[s]:set_widget(layout_top)

    local left_layout_bot = wibox.layout.fixed.horizontal()
    left_layout_bot:add(appMenu)
    left_layout_bot:add(placesMenu)
    left_layout_bot:add(launcher)
    left_layout_bot:add(desktopPix)

    local runbg = wibox.widget.background()
    runbg:set_widget(mypromptbox[s])
    runbg:set_bg(beautiful.icon_grad or beautiful.fg_normal)
    runbg:set_fg(beautiful.bg_normal)
    left_layout_bot:add(runbg)
    left_layout_bot:add(endArrow)


--     left_layout_bot:add(bar._internal.layout)

    local layout_bot = wibox.layout.align.horizontal()
    layout_bot:set_left(left_layout_bot)

    local bar = rad_task(s or 1)
    layout_bot:set_middle(bar._internal.layout)
    wibox_bot[s]:set_widget(layout_bot)

    local endArrow2 = wibox.widget.imagebox()
    endArrow2:set_image(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.icon_grad,direction="left"}))

    local bg_bot_right = wibox.widget.background()
    bg_bot_right:set_bg(beautiful.icon_grad or beautiful.fg_normal)
    local left_layout_right_bot = wibox.layout.fixed.horizontal()
    left_layout_right_bot:add(endArrow2)

    left_layout_right_bot:add(keyboardSwitcherWidget)
    
--     local bat = awful.widget.progressbar()
--     vicious.register(volumewidget2, vicious.widgets.mem, '$1', 1, 'mem')
-- --   vicious.register(bat, vicious.widgets.bat, '$2', 1, 'BAT0')
--     bat:set_value(0.50)
    left_layout_right_bot:add(keyboard)
    left_layout_right_bot:add(notif)
    left_layout_right_bot:add(bat)
    if s == 1 then
        left_layout_right_bot:add(wibox.widget.systray())
    end
    bg_bot_right:set_widget(left_layout_right_bot)
    layout_bot:set_right(bg_bot_right)

end
-- }}}

-- Add the drives list on the desktop
if config.deviceOnDesk == true then
--   widgets.devices()
end
if config.desktopIcon == true then
--     for i=1,20 do
--         widgets.desktopIcon()
--     end
end

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ "Control", "Mod1" }, "Left",   awful.tag.viewprev       ),
    awful.key({ "Control", "Mod1" }, "Right",  awful.tag.viewnext       ),
    awful.key({ "Mod1"            }, "space",  widgets.keyboard.quickswitchmenu),
--     awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function ()  end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
--     awful.key({ modkey,           }, "Tab",
--         function ()
--             awful.client.focus.history.previous()
--             if client.focus then
--                 client.focus:raise()
--             end
--         end),
--         
    
    awful.key({ modkey,           }, "Tab"   , function () alttab.altTab()          end ),
    awful.key({ modkey, "Shift"   }, "Tab"   , function () alttab.altTabBack()      end ),
    
    awful.key({ "Mod1",           }, "Tab"   , function () alttab.altTab({auto_release=true})          end ),
    awful.key({ "Mod1", "Shift"   }, "Tab"   , function () alttab.altTabBack({auto_release=true})      end ),

    -- Standard program
    awful.key({         "Control" }, "Escape", function () awful.util.spawn("xkill")    end ),
    awful.key({ modkey,           }, "Return", function () tyr_launcher.spawn({command=terminal})   end ),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey            }, "n"     , function() awful.tag.viewonly(awful.tag.add("NewTag",{screen= (client.focus and client.focus.screen or mouse.screen) }))    end ),
    awful.key({ modkey, "Shift"   }, "n"     , function() 
                                                  local c = client.focus
                                                  local t = awful.tag.add(c.class,{screen= (client.focus and client.focus.screen or mouse.screen) })
                                                  if c then c:tags(awful.util.table.join(c:tags(), {t})) end
                                                  awful.tag.viewonly(t)
                                               end ),
    awful.key({ modkey, "Mod1"   }, "n"     , function() 
                                                  local c = client.focus
                                                  local t = awful.tag.add(c.class,{screen= (client.focus and client.focus.screen or mouse.screen) })
                                                  if c then c:tags({t})
                                                    awful.tag.viewonly(t)
                                                  end
                                               end ),
    awful.key({modkey,"Mod1"      }, "r"  , function()
                                                  if client.focus then
                                                     local tag = awful.tag.selected(client.focus.screen)
                                                     tag.name = client.focus.class
                                                  end end),
    awful.key({ modkey            }, "d"    , function() awful.tag.delete(client.focus and awful.tag.selected(client.focus.screen) or awful.tag.selected(mouse.screen) )  end ),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () customMenu.layoutmenu.centered_menu(layouts) end),
    awful.key({ modkey, "Shift"   }, "space", function () customMenu.layoutmenu.centered_menu(layouts,true) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    -- Move focus
    awful.key({ modkey,           }, "#136",  function () indicator.focus.global_bydirection("left")  end),
    awful.key({ modkey,           }, "#220",  function () indicator.focus.global_bydirection("down")  end),
    awful.key({ modkey,           }, "#143",  function () indicator.focus.global_bydirection("right") end),
    awful.key({ modkey,           }, "#209",  function () indicator.focus.global_bydirection("up")    end),
    awful.key({ modkey,"Control"  }, "#136",  function () awful.client.swap.global_bydirection("left")  end),
    awful.key({ modkey,"Control"  }, "#220",  function () awful.client.swap.global_bydirection("down")  end),
    awful.key({ modkey,"Control"  }, "#143",  function () awful.client.swap.global_bydirection("right") end),
    awful.key({ modkey,"Control"  }, "#209",  function () awful.client.swap.global_bydirection("up")    end),
    awful.key({ modkey,           }, "Left",  function () indicator.focus.global_bydirection("left")  end),
    awful.key({ modkey,           }, "Right", function () indicator.focus.global_bydirection("down")  end),
    awful.key({ modkey,           }, "Up",    function () indicator.focus.global_bydirection("up")    end),
    awful.key({ modkey,           }, "Down",  function () indicator.focus.global_bydirection("down")  end),
    awful.key({ modkey, "Shift"   }, "Left",  function () indicator.focus.global_bydirection("left",nil,true)  end),
    awful.key({ modkey, "Shift"   }, "Right", function () indicator.focus.global_bydirection("down",nil,true)  end),
    awful.key({ modkey, "Shift"   }, "Up",    function () indicator.focus.global_bydirection("up",nil,true)    end),
    awful.key({ modkey, "Shift"   }, "Down",  function () indicator.focus.global_bydirection("down",nil,true)  end),
    awful.key({ "Control", "Mod1" }, "#143",  awful.tag.viewnext),
    awful.key({ "Control", "Mod1" }, "#136",  awful.tag.viewprev),
    --220 143 209

    --Switch screen
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({                   }, "#179"  , function () utils.mouseManager.switchTo(3)       end ),
    awful.key({                   }, "#175"  , function () utils.mouseManager.switchTo(4)       end ),
    awful.key({                   }, "#176"  , function () utils.mouseManager.switchTo(5)       end ),
    awful.key({                   }, "#178"  , function () utils.mouseManager.switchTo(1)       end ),
    awful.key({                   }, "#177"  , function () utils.mouseManager.switchTo(2)       end ),

    -- Prompt
    awful.key({ modkey, "Shift"   }, "r",
              function ()
                 awful.prompt.run({ prompt = "New tag name: " },
                                  mypromptbox[mouse.screen].widget,
                                  function(new_name)
                                     if not new_name or #new_name == 0 then
                                        return
                                     else
                                        local screen = mouse.screen
                                        local tag = awful.tag.selected(screen)
                                        if tag then
                                           tag.name = new_name
                                        end
                                     end
                                  end)
              end),
    awful.key({ modkey },            "r",     
--               function ()
--                   mypromptbox[mouse.screen]:run()
--                   awful.prompt.run({ prompt = "Run:" },
--                       mypromptbox[mouse.screen].widget,
--                       awful.util.spawn,
--                       awful.completion.shell,
--                       awful.util.getdir("cache") .. "/history")
--               end
              function ()
                  awful.prompt.run({ prompt = "Run: " },
                  mypromptbox[mouse.screen].widget,
                  function (com)
                          local result = tyr_launcher.spawn({command=com})
--                           local tmp = config.launcher[com].counter
--                           if type(tmp) ~= "number" then
--                             tmp = 0
--                           end
--                           config.launcher[com].counter = tmp + 1
--                           print("in there",tmp,config.launcher[com].counter,config.sdfsdf.sdfsdf.werwr.werasd.xcvxcsef)
                          if type(result) == "string" then
                              promptbox.widget:set_text(result)
                          end
                          return true
                  end, awful.completion.shell,
                  awful.util.getdir("cache") .. "/history")
              end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
    
    --Custom
    awful.key({ modkey,"Control" }, "p", function() 
        utils.profile.start()
        debug.sethook(utils.profile.trace, "crl", 1)
    end),
    awful.key({ modkey,"Control","Shift" }, "p", function() 
        debug.sethook()
        utils.profile.stop(_G)
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "y",      function (c) indicator.resize.display(c,true) end),
    awful.key({ modkey,           }, "m",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end)
--    awful.key({ modkey,           }, "m",
--        function (c)
--            c.maximized_horizontal = not c.maximized_horizontal
--            c.maximized_vertical   = not c.maximized_vertical
--        end)
)

-- Compute the maximum number of digit we need, limited to 9
-- keynumber = 0
-- for s = 1, screen.count() do
--    keynumber = math.min(9, math.max(#tags[s], keynumber))
-- end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
}
-- }}}

awesome.register_xproperty("_NET_STARTUP_ID","string")
-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    print("SN",c:get_xproperty("_NET_STARTUP_ID"))
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
--     client.focus = c
    --Fix some wierd reload bugs
    if c.size_hints.user_size and startup then
        c:geometry({width = c.size_hints.user_size.width,height = c.size_hints.user_size.height, x = c:geometry().x})
    end

--     if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
--     end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        local tt = {}
        local ib = wibox.widget.imagebox()
        ib:set_image(beautiful.titlebar_resize)
        ib:buttons( awful.util.table.join(
        awful.button({ }, 1, function(geometry)
            root.fake_input("button_release",1,0,0)
            indicator.resize.display(c,true)
        end)))
        left_layout:add(ib)
        local ib2 = wibox.widget.imagebox()
        ib2:set_image(beautiful.titlebar_tag)
        left_layout:add(ib2)

        local height = --[[awful.client.floating.get(c) and]] beautiful.titlebar_height or  beautiful.get_font_height() * 1.5 --[[or 5]]
        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        local labels = {"Floating","Maximize","Sticky","On Top","Close"}
        for k,v in ipairs({awful.titlebar.widget.floatingbutton(c) , awful.titlebar.widget.maximizedbutton(c), awful.titlebar.widget.stickybutton(c), 
            awful.titlebar.widget.ontopbutton(c), awful.titlebar.widget.closebutton(c)}) do
            right_layout:add(v)
            radical.tooltip(v,labels[k],{})
--             v:connect_signal("mouse::enter", function() tt[k] = tt[k] or ;tt[k]:showToolTip(true,{y=c:geometry().y+height}) end)
--             v:connect_signal("mouse::leave", function() tt[k]:showToolTip(false) end)
        end

        -- The title goes in the middle
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )
        local title = awful.titlebar.widget.titlewidget(c)
        title.data = {c = c,image=beautiful.tasklist_bg_image_selected or beautiful.taglist_bg_image_used}

        title.fit = function(self,w,h)
            local width, height = wibox.widget.textbox.fit(self, w, h);
            local rw,rh = width+ height*4, beautiful.titlebar_height or height
            self._rw1,self._rh = rw,rh
            return w,h -- take all the space
        end

        title.draw = function(self,w, cr, width, height)
            cr:save()
            cr:translate(width/2-self._rw1/2, 0)
            cr:rectangle(0, 0, self._rw1, self._rh)
            cr:clip()
            blind.arrow.task.task_widget_draw(self,w, cr, self._rw1, self._rh,{no_marker=true})
            cr:restore()
        end
--         title:buttons(buttons)

        local bgbr = wibox.widget.background()
        bgbr:set_widget(right_layout)
        bgbr:set_bg(beautiful.bg_alternate)
        local right_layout2 = wibox.layout.fixed.horizontal()
        right_layout2:add(endArrowR2)
        right_layout2:add(bgbr)

        local bgbl = wibox.widget.background()
        bgbl:set_widget(left_layout)
        bgbl:set_bg(beautiful.bg_alternate)
        local left_layout2 = wibox.layout.fixed.horizontal()
        left_layout2:add(bgbl)
        left_layout2:add(endArrow_alt)
--         left_layout2:add(awful.titlebar.widget.iconwidget(c))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout2)

        layout:set_right(right_layout2)
        layout:set_middle(title)

        local tb = awful.titlebar(c,{size=beautiful.titlebar_height or 16})
--         tb:connect_signal("property::height",function(tb)
--             print(debug.traceback())
--         end)
        tb:set_widget(layout)
        tb.title_wdg = title
        title:buttons(buttons)
        local underlays = {}
        for k,v in ipairs(c:tags()) do
            underlays[#underlays+1] = v.name
        end
        title:set_underlay(underlays,{style=radical.widgets.underlay.draw_arrow,alpha=1,color="#0C2853"})
    end
end)


client.connect_signal("tagged",function(v)
--     local tb = v:titlebar_top()
        local tb = awful.titlebar(v,{size=beautiful.titlebar_height or 16})
    if tb and tb.title_wdg then
        local underlays = {}
        for k,v in ipairs(v:tags()) do
            underlays[#underlays+1] = v.name
        end
        tb.title_wdg:set_underlay(underlays,{style=radical.widgets.underlay.draw_arrow,alpha=1,color="#0C2853"})
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
-- }}}
-- debug.sethook()
-- utils.profile.stop(_G)
-- widgets.radialSelect.radial_client_select()
--print("start")
--utils.fd_async.exec_command_async("/tmp/test.sh"):connect_signal("request::completed",function(content)
--    print("content",content)
--end)

-- utils.fd_async.download_text_async("http://www.google.com"):connect_signal("request::completed",function(content)
--     print("c2",content)
-- end)
-- print("HONORING",awesome.honor_ewmh_desktop,awesome.font_height,awesome.font)
-- awesome.honor_ewmh_desktop = false
-- client.add_signal("property::shape_bounding")
drawable.add_signal("property::shape_bounding")


-- print("test")
-- glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function() print("foo") end)
-- print("test2")


require("radical.impl.tasklist.extensions").add("Running time",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return 75,h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw("foo",{bg="#ff0000"}))
        cr:paint()
    end
    return w
end)
require("radical.impl.tasklist.extensions").add("Machine",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return 100,h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw(client.machine,{bg="#ff0000"}))
        cr:paint()
    end
    return w
end)
require("radical.impl.taglist.extensions").add("Count",function(client)
    local w = wibox.widget.base.make_widget()
    w.fit = function(_,w,h)
        return 100,h
    end
    w.draw = function(self, w, cr, width, height)
        cr:set_source_surface(radical.widgets.underlay.draw("12",{bg="#ff0000"}))
        cr:paint()
    end
    return w
end)