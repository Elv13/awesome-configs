-- Includes
require( "awful"                   )
require( "beautiful"               )
require( "naughty"                 )
require( "shifty"                  )
require( "vicious"                 )
require( "customMenu"              )
require( "customButton"            )
require( "drawer"                  )
require( "widget.spacer"           )
require( "widget.keyboardSwitcher" )
require( "widget.desktopMonitor"   )
require( "widget.devices"          )
require( "widget.dock"             )
require( "mouseManager"            )
require( "urxvtIntegration"        )
require( "tasklist2"               )
require( "clientSwitcher"          )
require( "tabbar"                  )
require( "taglist"                 )

-- Cache result for probe used more than once
vicious.cache( vicious.widgets.net )
vicious.cache( vicious.widgets.fs  )
vicious.cache( vicious.widgets.dio )
vicious.cache( vicious.widgets.cpu )

dofile(awful.util.getdir("config") .. "/functions.lua")
--dofile(awful.util.getdir("config") .. "/hardware.lua")
--dofile(awful.util.getdir("config") .. "/musicBar.lua")

-- Some widget for every screens
wiboxTop     = {}; promptbox = {}; notifibox = {}; layoutmenu = {}; wiboxBot = {}
mytaglist    = {}; movetagL  = {}; movetagR  = {}; mytasklist = {}; delTag   = {}

-- Default applications
terminal     = 'urxvt -tint gray -fade 50 +bl +si -cr red -pr green -iconic -fn "xft:DejaVu Sans Mono:pixelsize=13" -pe tabbed'
editor       = { cmd = "kwrite" , class = "Kwrite"  }
ide          = { cmd = "kate"   , class = "Kate"    }
webbrowser   = { cmd = "firefox", class = "Firefox" }
mediaplayer  = { cmd = "vlc"    , class = "VLC"     }
filemanager  = { cmd = "dolphin", class = "Dolphin" }

-- Main awesome key
modkey       = "Mod4"

-- Various configuration options
showTitleBar = true --TODO
themeName    = "darkBlue"
showNotPopup = true --TODO
showListPref = true --TODO
deviceOnDesk = true --TODO
desktopIcon  = false --TODO
listPref     = {'①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳'} --TODO

-- Shifty config
shifty.config.defaults = {
  layout     = awful.layout.suit.tile,
  ncol       = 1,
  mwfact     = 0.60,
  floatBars  = true,
}

-- Load the theme
beautiful.init(awful.util.getdir("config") .. "/theme/".. themeName .."/theme.lua")

-- Create the panels
for s = 1, screen.count() do
  wiboxTop[s] = awful.wibox({ position = "top"   , screen = s, height = 16 })
  wiboxBot[s] = awful.wibox({ position = "bottom", screen = s, height = 16 })
end

-- Assign the modkey
shifty.modkey          = modkey

-- Start the URXVT integration library watchdog
--urxvtIntegration                                ( nil                                )

-- Create the application menu
applicationMenu        = customMenu.application   ( nil                                )

-- Create the place menu TODO use the KDE list instead of the hardcoded one
placesMenu             = customMenu.places        ( nil                                )

-- Create the recent menu
recentMenu             = customMenu.recent        ( nil                                )

-- Call the laucher wibox
launcherPix            = customButton.launcher    ( nil                                )

-- Create the laucher dock
lauchDock              = widget.dock              ( nil                                )

-- Create the "Show Desktop" icon
desktopPix             = customButton.showDesktop ( nil                                )

-- Create the clock
mytextclock            = drawer.dateinfo          ( nil                                )

-- Create the memory manager
meminfo                = drawer.memInfo           ( screen.count()                     )

-- Create the cpu manager
cpuinfo                = drawer.cpuInfo           ( nil                                )

-- Create the net manager
netinfo                = drawer.netInfo           ( nil                                )

-- Create the volume box
soundWidget            = drawer.soundInfo         ( wiboxTop3                          )

-- Create the keyboard layout switcher, feel free to add your contry and push it to master
keyboardSwitcherWidget = widget.keyboardSwitcher  ( nil                                )

-- Create a systray
mysystray              = widget                   ( { type = "systray"               } )

-- Create the tag right click menu [[In develpment]]
tagMenu                = customMenu.tagOption     ( nil                                )

-- Create the mod4 + middle click menu on a client
clientMenu             = customMenu.clientMenu    ( nil                                )

-- Shifty rules
dofile(awful.util.getdir("config") .. "/baseRule.lua"                                  )

-- Create the addTag icon (depend on shifty rule)
addTag = customButton.addTag                      ( nil,{taglist = shifty.config.tags} )

--TagList buttons
mytaglist.buttons = awful.util.table.join(
  awful.button({        }, 1, function (tag) awful.tag.viewonly(tag)               end ),
  awful.button({ modkey }, 1, awful.client.movetotag                                   ),
  awful.button({        }, 2, function (tag) shifty.rename(tag)                    end ),
  awful.button({        }, 3, function (tag) tagMenu:toggle(tag)                   end ),
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
    function ()
      if instance then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ width=450 })
      end
    end),
  awful.button({        }, 4, 
    function ()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.button({        }, 5, 
    function ()
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
spacer3 = widget.spacer({text = "| "}); spacer2 = widget.spacer({text = "  |"}); spacer4 = widget.spacer({text = "|"})

-- The widget array with different possible screens configuration
for s = 1, screen.count() do
  -- Create a promptbox for each screen
  promptbox[s]  = awful.widget.prompt   (                                         )
			    
  -- Create the layout menu for this screen
  layoutmenu[s] = customMenu.layoutmenu ( s,layouts_all                           )
  
  -- Create a taglist widget
  mytaglist[s]  = taglist               ( s, taglist.label.all, mytaglist.buttons )

  -- Create the delTag button
  delTag[s]     = customButton.delTag   ( s                                       )
  
  -- Create the notification box
  notifibox[s]  = naughty               (                                         )
  
  -- Create a tasklist widget
  mytasklist[s] = tasklist2(function(c) return tasklist2.label.currenttags(c, s) end, mytasklist.buttons)
  
  -- Create the button to move a tag the next screen
  movetagL[s]   = customButton.tagmover(s,{ direction = "left",  icon = awful.util.getdir("config") .. "/theme/darkBlue/Icon/tags/screen_left.png"  })
  movetagR[s]   = customButton.tagmover(s,{ direction = "right", icon = awful.util.getdir("config") .. "/theme/darkBlue/Icon/tags/screen_right.png" })
  
  -- Top wibox widgets
  wiboxTop[s].widgets = { 
      {
      --    WIDGET                                                                 FALLBACK
          mytaglist[s]                                                              or nil,
          addTag                                                                    or nil,
          delTag[s]                                                                 or nil,
          movetagL[s]                                                               or nil,
          movetagR[s]                                                               or nil,
          layoutmenu[s]                                                             or nil,
          layout = awful.widget.layout.horizontal.leftright                         -------
      },
      --           RULES                                       WIDGET              FALLBACK
      ( s == 2 or screen.count() == 1                  ) and mytextclock            or nil,
      ( s == 2 or screen.count() == 1                  ) and kgetwidget             or nil,
      ( s == 2 or screen.count() == 1                  ) and kgetpixmap             or nil,
      ((s == 2 or screen.count() == 1) and soundWidget ) and soundWidget["wid"]     or nil,
      ((s == 2 or screen.count() == 1) and soundWidget ) and soundWidget["pix"]     or nil,
      ( s == 2 or screen.count() == 1                  ) and spacer4                or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and netinfo["up_text"]     or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and netinfo["up_logo"]     or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and netinfo["down_text"]   or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and netinfo["down_logo"]   or nil,
      ( s == 2 or screen.count() == 1                  ) and spacer2                or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and meminfo["bar"]         or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and meminfo["text"]        or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and meminfo["logo"]        or nil,
      ( s == 2 or screen.count() == 1                  ) and spacer2                or nil,
      ((s == 2 or screen.count() == 1) and netInto     ) and cpuinfo["graph"]       or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and cpuinfo["text"]        or nil,
      ((s == 2 or screen.count() == 1) and netInfo     ) and cpuinfo["logo"]        or nil,
      ( s == 2 or screen.count() == 1                  ) and spacer3                or nil,
      layout = awful.widget.layout.horizontal.rightleft,                            ------
      {                                                                             ------
        notifibox[s]                                                                or nil,
        layout = awful.widget.layout.horizontal.flex                                ------
      },                                                                            ------
  }
  
  -- Bottom wibox widgets
  wiboxBot[s].widgets = {
    --           RULES                                       WIDGET                FALLBACK
    ( s == 1                                           ) and applicationMenu        or nil,
    ( s == 1                                           ) and placesMenu             or nil,
    ( s == 1                                           ) and recentMenu             or nil,
    ( s == 1                                           ) and desktopPix             or nil,
    ( s == 1                                           ) and launcherPix            or nil,
    promptbox[s]                                                                    or nil,
    spacer3                                                                         or nil,
    {                                                                               ------
      (s == 1                                          ) and keyboardSwitcherWidget or nil,
      spacer3                                                                       or nil,
      (s == 1                                          ) and mysystray              or nil,
      layout = awful.widget.layout.horizontal.rightleft,                            ------
    },                                                                              ------
    layout = awful.widget.layout.horizontal.leftright,                              ------
    mytasklist[s]                                                                   or nil,
  }  
end

-- Add the drives list on the desktop
widget.devices()


shifty.taglist = mytaglist

-- Load the desktop "conky" widget
widget.desktopMonitor(screen.count() == 1 and 1 or 2)

-- Load the keybindings
dofile(awful.util.getdir("config") .. "/keyBinding.lua")

-- Hooks
client.add_signal("manage", function (c, startup)
    -- Add a titlebar --TODO DEAD CODE?
    if awful.client.floating.get(c) == true or showTitleBar == true then
      if (not c.class == "^XMMS$" or not c.class == "Xine") then
	awful.titlebar.add(c, { modkey = modkey })
      end
    else
      awful.titlebar.remove(c)
    end

    -- Enable sloppy focus
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
  awful.tag.attached_add_signal(s, "property::selected", function () addTitleBar(s) end)
  awful.tag.attached_add_signal(s, "property::layout"  , function () addTitleBar(s) end)
end

shifty.init()

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
      if tag.name == "Files" then
        run_or_raise(filemanager.cmd, { class = filemanager.class })
      elseif tag.name == "Internet" then
        run_or_raise(webbrowser.cmd,  { class = webbrowser.class  })
      elseif tag.name == "Develop" then
        run_or_raise(ide.cmd,         { class = ide.class         })
      elseif tag.name == "Movie" then
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
