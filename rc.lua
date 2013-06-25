-- Standard awesome library
local gears = require("gears")
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
local config = require("config")
local drawer = require("drawer")
local widgets = require("widgets")
-- local shifty = require("shifty")
local utils = require("utils")
local vicious = require("extern.vicious")
local menu4 = require( "radical.context"          )
local tyrannical = require("tyrannical")
local tyr_launcher = require("tyrannical.extra.launcher")
local indicator = require("customIndicator")
local blind = require("blind")
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
config.disableAutoSave()
config.data().showTitleBar  = false
config.data().themeName     = "arrow"
config.data().noNotifyPopup = true
config.data().useListPrefix = true
config.data().deviceOnDesk  = true
config.data().desktopIcon   = true
config.data().advTermTB     = true
config.data().scriptPath    = awful.util.getdir("config") .. "/Scripts/"
config.data().listPrefix    = {'①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳'}
config.data().scr           = {
    pri         = 1,
    sec         = 2,
    music       = 3,
    media       = 4,
    irc         = 5,
}

-- Load the theme
config.load()
config.data().themePath = awful.util.getdir("config") .. "/blind/" .. config.data().themeName .. "/"
config.data().iconPath  = config.data().themePath       .. "Icon/"
beautiful.init(config.data().themePath                .. "/theme.lua")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config").."/blind/arrow/theme.lua")

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
    awful.layout.suit.spiral.dwindle,
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
    awful.layout.suit.spiral.dwindle,
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
local clock                  = drawer.dateinfo          ( nil                                )
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
local endArrow               = blind.common.drawing.get_beg_arrow_wdg2()
-- Create the laucher dock
local endArrow_alt           = blind.common.drawing.get_beg_arrow_wdg2({bg_color=beautiful.bg_alternate})

-- End arrow
local endArrowR = wibox.widget.imagebox()
endArrowR:set_image(blind.common.drawing.get_beg_arrow2({bg_color=beautiful.bg_alternate ,direction="left"}))

-- Create the addTag icon (depend on shifty rule)
local addTag                 = customButton.addTag                      ( nil )

-- Create the keyboard layout switcher, feel free to add your contry and push it to master
local keyboardSwitcherWidget = widgets.keyboardSwitcher ( nil                                )

-- Load the desktop "conky" widget
-- widgets.desktopMonitor(screen.count() == 1 and 1 or 2)

--Some spacers with dirrent text
spacer3 = widgets.spacer({text = "| "}); spacer2 = widgets.spacer({text = "  |"}); spacer4 = widgets.spacer({text = "|"})
spacer5 = widgets.spacer({text = " ",width=5})
local spacer_img = wibox.widget.imagebox()
spacer_img:set_image(config.data().iconPath.."bg_arrow.png")

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


-- Create a wibox for each screen and add it
wibox_top = {}
wibox_bot = {}
mypromptbox = {}
mytaglist = {}
layoutmenu = {}
delTag   = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 2, awful.tag.viewtoggle),
                    awful.button({ }, 3, function(q,w,e,r)
--                         local menu = customMenu.tagOption.getMenu()
                        customMenu.taghover.tag = q
                        local menu = customMenu.taghover.getMenu()
                        menu.visible = true
                    end),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                    awful.button({ }, 3, function(c)
                        customMenu.clientMenu.client = c
                        local menu = customMenu.clientMenu.menu()
                        menu.visible = true
                    end),
                     awful.button({ }, 2, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the delTag button
    delTag[s]     = customButton.delTag   ( s                                               )

    -- Create the button to move a tag the next screen
    movetagL[s]   = customButton.tagmover(s,{ direction = "left",  icon = config.data().iconPath .. "tags/screen_left.png"  })
    movetagR[s]   = customButton.tagmover(s,{ direction = "right", icon = config.data().iconPath .. "tags/screen_right.png" })

    -- Create the layout menu for this screen
    layoutmenu[s] = customMenu.layoutmenu ( s,layouts_all                                   )

    -- Create the wibox
    wibox_top[s] = awful.wibox({ position = "top"   , screen = s,height=beautiful.default_height })
    wibox_bot[s] = awful.wibox({ position = "bottom", screen = s,height=beautiful.default_height })

    -- Widgets that are aligned to the left
    local left_layout_top = wibox.layout.fixed.horizontal()
    left_layout_top:add(mytaglist[s])
    local bgb = wibox.widget.background()
    local l2 = wibox.layout.fixed.horizontal()
    bgb:set_widget(l2)
    bgb:set_bg(beautiful.bg_alternate)
    l2:add(addTag     )
    l2:add(delTag  [s])
    l2:add(movetagL  [s])
    l2:add(movetagR  [s])
--     left_layout_top:add(movetagL[s])
--     left_layout_top:add(movetagR[s])
    l2:add(layoutmenu[s])
    left_layout_top:add(bgb)
    left_layout_top:add(endArrow_alt)

    -- Widgets that are aligned to the right
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

    -- Now bring it all together (with the tasklist in the middle)
    local layout_top = wibox.layout.align.horizontal()
    right_layout_meta:add(right_bg)
    layout_top:set_left(left_layout_top)
    layout_top:set_right(right_layout_meta)

    wibox_top[s]:set_widget(layout_top)

    local left_layout_bot = wibox.layout.fixed.horizontal()
    left_layout_bot:add(appMenu)
    left_layout_bot:add(placesMenu)
    left_layout_bot:add(launcher)
    left_layout_bot:add(desktopPix)

    local runbg = wibox.widget.background()
    runbg:set_widget(mypromptbox[s])
    runbg:set_bg(beautiful.fg_normal)
    runbg:set_fg(beautiful.bg_normal)
    left_layout_bot:add(runbg)
    left_layout_bot:add(endArrow)
    local layout_bot = wibox.layout.align.horizontal()
    layout_bot:set_left(left_layout_bot)
    layout_bot:set_middle(mytasklist[s])
    wibox_bot[s]:set_widget(layout_bot)

    local endArrow2 = wibox.widget.imagebox()
    endArrow2:set_image(blind.common.drawing.get_beg_arrow2({direction="left"}))

    local left_layout_right_bot = wibox.layout.fixed.horizontal()
    if s == 1 then
        local sysbg = wibox.widget.background()
        sysbg:set_bg(beautiful.fg_normal)
        sysbg:set_widget(wibox.widget.systray())
        left_layout_right_bot:add(sysbg) 
    end
    left_layout_right_bot:add(endArrow2)

    left_layout_right_bot:add(keyboardSwitcherWidget)
    layout_bot:set_right(left_layout_right_bot)

end
-- }}}

-- Add the drives list on the desktop
if config.data().deviceOnDesk == true then
--   widgets.devices()
end
if config.data().desktopIcon == true then
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
    awful.key({ modkey, "Shift"   }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey, "Shift"   }, "Right",  awful.tag.viewnext       ),
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
    
    awful.key({ modkey,           }, "Tab"   , function () utils.keyFunctions.altTab()          end ),
    awful.key({ modkey, "Shift"   }, "Tab"   , function () utils.keyFunctions.altTabBack()      end ),
    
    awful.key({ "Mod1",           }, "Tab"   , function () utils.keyFunctions.altTab({auto_release=true})          end ),
    awful.key({ "Mod1", "Shift"   }, "Tab"   , function () utils.keyFunctions.altTabBack({auto_release=true})      end ),

    -- Standard program
    awful.key({         "Control" }, "Escape", function () awful.util.spawn("xkill")    end ),
    awful.key({ modkey,           }, "Return", function () tyr_launcher.spawn({command=terminal})   end ),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

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
    awful.key({ modkey, "Shift"   }, "#143",  awful.tag.viewnext),
    awful.key({ modkey, "Shift"   }, "#136",  awful.tag.viewprev),
    --220 143 209

    --Switch screen
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({                   }, "#177"  , function () utils.mouseManager.switchTo(3)       end ),
    awful.key({                   }, "#152"  , function () utils.mouseManager.switchTo(4)       end ),
    awful.key({                   }, "#190"  , function () utils.mouseManager.switchTo(5)       end ),
    awful.key({                   }, "#208"  , function () utils.mouseManager.switchTo(1)       end ),
    awful.key({                   }, "#129"  , function () utils.mouseManager.switchTo(2)       end ),

    -- Prompt
    awful.key({ modkey },            "r",     
              function ()
                  mypromptbox[mouse.screen]:run()
                  awful.prompt.run({ prompt = mypromptbox[mouse.screen].prompt },
                      mypromptbox[mouse.screen].widget,
                      function (com)
                          local result = tyr_launcher.spawn({command=com})
                          if type(result) == "string" then
                              promptbox.widget:set_text(result)
                          end
                      end,
                      awful.completion.shell,
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
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
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

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focusssdaf
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
            widgets.tooltip2(v,labels[k],{})
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
--         title.fit = function(box, w, h)
--             local width, height = wibox.widget.textbox.fit(box, w, h);
--             return w, beautiful.titlebar_height or height
--         end
        title.fit = function(box, w, h)
            local width, height = wibox.widget.textbox.fit(box, w, h);
            return width+ 50, beautiful.titlebar_height or height
        end
        title.data = {c = c,image=beautiful.taglist_bg_image_used}
        title.draw = function(self,w, cr, width, height) blind.arrow.task.task_widget_draw(self,w, cr, width, height,{no_marker=true}) end
--         title:buttons(buttons)

        local bgbr = wibox.widget.background()
        bgbr:set_widget(right_layout)
        bgbr:set_bg(beautiful.bg_alternate)
        local right_layout2 = wibox.layout.fixed.horizontal()
        right_layout2:add(endArrowR)
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

        local tb = awful.titlebar(c,{size=height})
        tb:set_widget(layout)
        tb.title_wdg = title
        title:buttons(buttons)
    end
end)


client.connect_signal("focus", function(c) 
    local tb = awful.titlebar(c)
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.taglist_bg_image_selected
    end
    if not c.class == "URxvt" then
        c.border_color = beautiful.border_focus
    end
end)
client.connect_signal("unfocus", function(c) 
    local tb = awful.titlebar(c)
    if tb and tb.title_wdg then
        tb.title_wdg.data.image = beautiful.taglist_bg_image_used
    end
    if not c.class == "URxvt" then
        c.border_color = beautiful.border_normal
    end
end)
-- }}}
-- debug.sethook()
-- utils.profile.stop(_G)
-- widgets.radialSelect.radial_client_select()

-- awesome.connect_signal("spawn::initiated", function(id,id2) print("\n\ninitiated",id,id2,"") ;for k,v in pairs(id) do print (k,v) end ;print("end\n\n") end)
-- awesome.connect_signal("spawn::canceled", function(id) print("\n\ncanceled",id) ;for k,v in pairs(id) do print (k,v) end  ;print("end\n\n") end)
-- awesome.connect_signal("spawn::completed", function(id,id2) print("\n\ncompleted",id);for k,v in pairs(id) do print (k,v) end  ;print("end\n\n")  end)
-- awesome.connect_signal("spawn::timeout", function(id) print("\n\ntimeout",id);for k,v in pairs(id) do print (k,v) end ;print("end\n\n")  end)
-- awesome.connect_signal("spawn::change", function(id) print("\n\nchange",id);for k,v in pairs(id) do print (k,v) end ;print("end\n\n")  end)