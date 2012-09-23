-- Includes
require( "awful"        )
require( "beautiful"    )
require( "naughty"      )
require( "shifty"       )
require( "extern"       )
require( "panel"        )
require( "monkeyPatch"  )
require( "config"       )
require( "widgets"      )
require( "drawer"       )
require( "utils"        )
require( "customMenu"   )
require( "customButton" )
require( "titlebar"     )
require( "ultiLayout"   )

-- table.insert = function(t,i,v)
--     if v and i then
--         t[i] = v
--     else
--         t[#t+1] = i
--     end
-- end

function exec() --Wrap in a function for better startup profiling
-- Cache result for probe used more than once
local vicious = require("extern.vicious")
vicious.cache( vicious.widgets.net )
vicious.cache( vicious.widgets.fs  )
vicious.cache( vicious.widgets.dio )
vicious.cache( vicious.widgets.cpu )
vicious.cache( vicious.widgets.mem )
vicious.cache( vicious.widgets.dio )

-- Some widget for every screens
wiboxTop        = {}; promptbox = {}; notifibox = {}; layoutmenu = {}; wiboxBot = {}
mytaglist       = {}; movetagL  = {}; movetagR  = {}; mytasklist = {}; delTag   = {}

-- Default applications
terminal        = { cmd = "urxvtc" , class = "urxvt"   }
editor          = { cmd = "kwrite" , class = "Kwrite"  }
ide             = { cmd = "kate"   , class = "Kate"    }
webbrowser      = { cmd = "firefox", class = "Firefox" }
mediaplayer     = { cmd = "vlc"    , class = "VLC"     }
filemanager     = { cmd = "dolphin", class = "Dolphin" }

-- Main awesome key
modkey          = "Mod4"

-- Various configuration options
config.disableAutoSave()
config.data().showTitleBar  = false
config.data().themeName     = "darkBlue"
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

-- Shifty config
shifty.config.defaults = {
  layout       = awful.layout.suit.tile ,
  ncol         = 1                      ,
  mwfact       = 0.60                   ,
  floatBars    = true                   ,
}
shifty.config.float_bars = true

-- Load the theme
config.load()
config.data().themePath = awful.util.getdir("config") .. "/theme/" .. config.data().themeName .. "/"
config.data().iconPath  = config.data().themePath       .. "Icon/"
beautiful.init(config.data().themePath                .. "/theme.lua")
-- Shifty rules
dofile(awful.util.getdir("config") .. "/baseRule.lua")
shifty.init()

-- Create the panels
for s = 1, screen.count() do
  wiboxTop[s] = awful.wibox({ position = "top"   , screen = s, height = 16 })
  wiboxBot[s] = awful.wibox({ position = "bottom", screen = s, height = 16 })
  utils.theme.set_wibox_background_gradient(wiboxTop[s],beautiful.bg_normal_grad)
  utils.theme.set_wibox_background_gradient(wiboxBot[s],beautiful.bg_normal_grad)
end

-- Assign the modkey
shifty.modkey          = modkey

-- Start the URXVT integration library watchdog
--urxvtIntegration                                ( nil                                )

-- Start the desktop layout manager
desktopGrid            = widgets.layout.desktopLayout({padBottom=20,padTop=35,padDef=8})

-- Create the application menu
appMenu        = customMenu.application           ( nil                                )

-- Create the place menu TODO use the KDE list instead of the hardcoded one
placesMenu             = customMenu.places        ( appMenu:extents().width            )

-- Call the laucher wibox
launcher               = customMenu.launcher      ( appMenu:extents().width + placesMenu:extents().width+8)

-- Create the laucher dock
lauchDock              = widgets.dock             ( nil                                )

-- Create the "Show Desktop" icon
desktopPix             = customButton.showDesktop ( nil                                )

-- Create the clock
clock                  = drawer.dateinfo          ( nil                                )
clock.bg               = beautiful.bg_alternate

-- Create the volume box
soundWidget            = drawer.soundInfo         ( wiboxTop3, clock:extents().width   )

-- Create the net manager
netinfo                = drawer.netInfo           ( clock:extents().width + 60         )

-- Create the memory manager
meminfo                = drawer.memInfo           ( clock:extents().width + 210        )

-- Create the cpu manager
cpuinfo                = drawer.cpuInfo           ( clock:extents().width + 210 + 130  )

-- Create the keyboard layout switcher, feel free to add your contry and push it to master
keyboardSwitcherWidget = widgets.keyboardSwitcher ( nil                                )

-- Create a systray
mysystray              = widget                   ( { type = "systray", bg = beautiful.fg_normal } )
mysystray.bg           = beautiful.fg_normal

-- Create systray end arrow
taskarrow              = utils.theme.get_beg_arrow_widget()

-- Create systray end arrow
sysarrow               = utils.theme.get_beg_arrow_widget(nil,nil,nil,"left")
sysarrow3              = utils.theme.get_beg_arrow_widget(beautiful.bg_alternate,beautiful.fg_normal,nil,"left")
sysarrow2              = utils.theme.get_beg_arrow_widget(nil,beautiful.bg_alternate,nil,"left")

-- Create systray end arrow
menuarrow              = utils.theme.new_arrow_widget()

-- Create the logout menu
logoutmenu             = customMenu.logout()

-- Create the music panel
--musicBar = panel.musicBar()

-- Create the hardware alarm panel
--hardwarePanel = panel.hardware()

-- Create the addTag icon (depend on shifty rule)
addTag = customButton.addTag                      ( nil,{taglist = shifty.config.tags} )

--TagList buttons
mytaglist.buttons = awful.util.table.join(
  awful.button({        }, 1, function (tag) awful.tag.viewonly(tag)               end ),
  awful.button({ modkey }, 1, awful.client.movetotag                                   ),
  awful.button({        }, 2, function (tag) shifty.rename(tag)                    end ),
  awful.button({        }, 3, function (tag) customMenu.tagOption.getMenu():toggle(tag) end ),
  awful.button({ modkey }, 3, awful.client.toggletag                                   ),
  awful.button({        }, 4, awful.tag.viewnext                                       ),
  awful.button({        }, 5, awful.tag.viewprev                                       )
)

--Tasklist button
mytasklist.buttons = awful.util.table.join(
  awful.button({        }, 1, 
    function (c)
      if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
      end
      client.focus = c
      c:raise()
    end),
  awful.button({        }, 3, 
    function ( )
      if instance then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ width=450 })
      end
    end),
  awful.button({        }, 4, 
    function ( )
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.button({        }, 5, 
    function ( )
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end)
)

-- Mouse buttons on the desktop
root.buttons(awful.util.table.join(
  awful.button({        }, 1, 
  function () 
    if instance then
      instance:hide()
      instance = nil
    end
    main_menu:hide()
  end),
  awful.button({        }, 2, 
  function () 
    if instance then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ width=450 })
    end 
  end),
  awful.button({        }, 3, function () main_menu:toggle() end ),
  awful.button({        }, 4, awful.tag.viewnext                 ),
  awful.button({        }, 5, awful.tag.viewprev                 )
))

--Some spacers with dirrent text
spacer3 = widgets.spacer({text = "| "}); spacer2 = widgets.spacer({text = "  |"}); spacer4 = widgets.spacer({text = "|"})
spacer5 = widgets.spacer({text = "",width=5})
spacer2.bg,spacer5.bg,spacer4.bg = beautiful.bg_alternate,beautiful.bg_alternate,beautiful.bg_alternate

-- The widget array with different possible screens configuration
for s = 1, screen.count() do
  -- Create a promptbox for each screen
  promptbox[s]  = awful.widget.prompt   (                                                 )
  
  -- Create the layout menu for this screen
  layoutmenu[s] = customMenu.layoutmenu ( s,layouts_all                                   )
  
  -- Create a taglist widget
  mytaglist[s]  = widgets.taglist       ( s, widgets.taglist.label.all, mytaglist.buttons )
  
  -- Create the arrow after the last taglist button
  local arrow  = utils.theme.new_arrow_widget(beautiful.bg_alternate,beautiful.bg_normal,3)

  -- Create the delTag button
  delTag[s]     = customButton.delTag   ( s                                               )
  
  -- Create the notification box
  notifibox[s]  = naughty               (                                                 )
  
  -- Create a tasklist widget
  mytasklist[s] = widgets.tasklist(function(c) return widgets.tasklist.label.currenttags(c, s) end, mytasklist.buttons)
  
  -- Create the button to move a tag the next screen
  movetagL[s]   = customButton.tagmover(s,{ direction = "left",  icon = config.data().iconPath .. "tags/screen_left.png"  })
  movetagR[s]   = customButton.tagmover(s,{ direction = "right", icon = config.data().iconPath .. "tags/screen_right.png" })
  
  -- Top wibox widgets
  wiboxTop[s].widgets = { 
      {
      --    WIDGET                                                                                   FALLBACK
          mytaglist  [s]                                                                              or nil,
          addTag                                                                                      or nil,
          delTag     [s]                                                                              or nil,
          movetagL   [s]                                                                              or nil,
          movetagR   [s]                                                                              or nil,
          layoutmenu [s]                                                                              or nil,
          arrow                                                                                       or nil,
          layout = awful.widget.layout.horizontal.leftright                                           -------
      },
      --                             RULES                      EXIST            WIDGET              FALLBACK
      ( s == config.data().scr.sec or screen.count() == 1                  ) and logoutmenu             or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and sysarrow3              or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and clock                  or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and kgetwidget             or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and kgetpixmap             or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and soundWidget ) and soundWidget.wid        or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and soundWidget ) and soundWidget.pix        or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and spacer4                or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and netinfo     ) and netinfo.up_text        or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and netinfo     ) and netinfo.up_logo        or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and netinfo     ) and netinfo.down_text      or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and netinfo     ) and netinfo.down_logo      or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and spacer2                or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and meminfo     ) and meminfo.bar            or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and meminfo     ) and meminfo.text           or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and meminfo     ) and meminfo.logo           or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and spacer2                or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and cpuinfo     ) and cpuinfo.graph          or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and cpuinfo     ) and cpuinfo.text           or nil,
      ((s == config.data().scr.sec or screen.count() == 1) and cpuinfo     ) and cpuinfo.logo           or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and spacer5                or nil,
      ( s == config.data().scr.sec or screen.count() == 1                  ) and sysarrow2              or nil,
      layout = awful.widget.layout.horizontal.rightleft,                                              ------
      {                                                                                               ------
        notifibox[s]                                                                                  or nil,
        layout = awful.widget.layout.horizontal.flex                                                  ------
      },                                                                                              ------
  }
  
  -- Bottom wibox widgets
  wiboxBot[s].widgets = {
    --           RULES                                                         WIDGET                FALLBACK
    ( s == config.data().scr.pri                                           ) and appMenu                or nil,
    ( s == config.data().scr.pri                                           ) and menuarrow              or nil,
    ( s == config.data().scr.pri                                           ) and placesMenu             or nil,
    ( s == config.data().scr.pri                                           ) and menuarrow              or nil,
    ( s == config.data().scr.pri                                           ) and launcher               or nil,
    ( s == config.data().scr.pri                                           ) and menuarrow              or nil,
    ( s == config.data().scr.pri                                           ) and desktopPix             or nil,
    promptbox[s]                                                                                        or nil,
    ( s == config.data().scr.pri                                           ) and taskarrow              or nil,
    {                                                                                                   ------
      (s == config.data().scr.pri                                          ) and keyboardSwitcherWidget or nil,
      ( s == config.data().scr.pri                                         ) and sysarrow               or nil,
      (s == config.data().scr.pri                                          ) and mysystray              or nil,
      layout = awful.widget.layout.horizontal.rightleft,                                                ------
    },                                                                                                  ------
    layout = awful.widget.layout.horizontal.leftright,                                                  ------
    mytasklist[s]                                                                                       or nil,
  }  
end

-- Add the drives list on the desktop
if config.data().deviceOnDesk == true then
  widgets.devices()
end
if config.data().desktopIcon == true then
--     for i=1,20 do
--         widgets.desktopIcon()
--     end
end


shifty.taglist = mytaglist

-- Load the desktop "conky" widget
widgets.desktopMonitor(screen.count() == 1 and 1 or 2)

-- Load the keybindings
dofile(awful.util.getdir("config") .. "/keyBinding.lua")

-- Hooks
client.add_signal("manage", function (c, startup)
    if c.name == "Software Update" then c:kill() end --I hate that Firefox popup, die!!!
    -- Add a titlebar to floating clients
    if awful.client.floating.get(c) == true or config.data().showTitleBar == true  then
      if (not c.class == "^XMMS$" or not c.class == "Xine") then
	awful.titlebar.add(c, { modkey = modkey })
      end
    else
      awful.titlebar.remove(c)
    end

    -- Enable focus on mouse over
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) 
  if (c.class == webbrowser.class or c.class == ide.class or c.class == editor.class or c.class == mediaplayer.class) then
    c.border_color = "#0A1535"
  else
    c.border_color = beautiful.border_focus 
  end
end)

client.add_signal("unfocus", function(c) 
  if (c.class == webbrowser.class or c.class == ide.class or c.class == editor.class or c.class == mediaplayer.class) then
    c.border_color = "#0A1535"
  else
    c.border_color = beautiful.border_normal 
  end
end)

for s = 1, screen.count() do
  awful.tag.attached_add_signal(s, "property::selected", function () utils.tools.addTitleBar(s) end)
  awful.tag.attached_add_signal(s, "property::layout"  , function () utils.tools.addTitleBar(s) end)
end

-- shifty.init()

--Start application when a tag is first used, better than using shifty.init
local isPlayingMovie         = false
local musicBarVisibility     = false

for s = 1, screen.count() do
  awful.tag.attached_add_signal(s, "property::selected", function(tag)
  if awful.tag.selected(s) == tag then --Prevent infinite loop, but a little buggy
    if isPlayingMovie == true then
      if musicBarVisibility == false then
        volumepixmap.visible = true
        volumewidget.visible = true
        wiboxTop3.visible    = false
      end
      enableAmarokCtrl(true)
    end
      isPlayingMovie = false

      -- Run or raise options
      if tag.name     == "Files"    then
        utils.tools.run_or_raise(filemanager.cmd, { class = filemanager.class })
      elseif tag.name == "Internet" then
        utils.tools.run_or_raise(webbrowser.cmd,  { class = webbrowser.class  })
      elseif tag.name == "Develop"  then
        utils.tools.run_or_raise(ide.cmd,         { class = ide.class         })
      elseif tag.name == "Movie"    then
        enableAmarokCtrl(false)
        musicBarVisibility   = wiboxTop3.visible
        volumepixmap.visible = false
        volumewidget.visible = false
        wiboxTop3.visible    = true
        isPlayingMovie       = true
      end
    end
  end)
end

widgets.layout.desktopLayout.draw()
config.save()
config.enableAutoSave()
end
-- Startup profiling
-- utils.profile.start()
-- debug.sethook(utils.profile.trace, "crl", 1)
exec()
-- debug.sethook()
-- utils.profile.stop(_G)