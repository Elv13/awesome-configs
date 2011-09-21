-- Includes
require( "awful"        )
require( "beautiful"    )
require( "naughty"      )
require( "shifty"       )
require( "vicious"      )
require( "panel"        )
require( "monkeyPatch"  )
require( "config"       )
require( "widgets"      )
require( "drawer"       )
require( "utils"        )
require( "customMenu"   )
require( "customButton" )

-- Cache result for probe used more than once
vicious.cache( vicious.widgets.net )
vicious.cache( vicious.widgets.fs  )
vicious.cache( vicious.widgets.dio )
vicious.cache( vicious.widgets.cpu )

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
config.data = {                                                                                      --
  showTitleBar  = true                                                                                ,
  themeName     = "darkBlue"                                                                          ,
  noNotifyPopup = true                                                                                , --TODO
  useListPrefix = true                                                                                ,
  deviceOnDesk  = true                                                                                , 
  desktopIcon   = true                                                                                , 
  advTermTB     = true                                                                                , 
  scriptPath    = awful.util.getdir("config") .. "/Scripts/"                                          ,
  listPrefix    = {'①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳'} ,
  scr           = {                                                                                  --
    pri         = 1                                                                                   ,
    sec         = 2                                                                                   ,
    music       = 3                                                                                   ,
    media       = 4                                                                                   ,
    irc         = 5                                                                                   ,
  }                                                                                                   ,
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
config.data.themePath = awful.util.getdir("config") .. "/theme/" .. config.data.themeName .. "/"
config.data.iconPath  = config.data.themePath       .. "/Icon/"
beautiful.init(config.data.themePath                .. "/theme.lua")
  
-- Create the panels
for s = 1, screen.count() do
  wiboxTop[s] = awful.wibox({ position = "top"   , screen = s, height = 16 })
  wiboxBot[s] = awful.wibox({ position = "bottom", screen = s, height = 16 })
end

-- Assign the modkey
shifty.modkey          = modkey

-- Start the URXVT integration library watchdog
--urxvtIntegration                                ( nil                                )

-- Start the desktop layout manager
desktopGrid            = widgets.layout.desktopLayout({padBottom=20,padTop=35,padDef=8})

-- Create the application menu
applicationMenu        = customMenu.application   ( nil                                )

-- Create the place menu TODO use the KDE list instead of the hardcoded one
placesMenu             = customMenu.places        ( nil                                )

-- Create the recent menu
-- recentMenu          = customMenu.recent        ( nil                                )

-- Call the laucher wibox
launcher               = customMenu.launcher      ( nil                                )

-- Create the laucher dock
lauchDock              = widgets.dock             ( nil                                )

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
keyboardSwitcherWidget = widgets.keyboardSwitcher ( nil                                )

-- Create a systray
mysystray              = widget                   ( { type = "systray"               } )

-- Create the tag right click menu [[In develpment]]
tagMenu                = customMenu.tagOption     ( nil                                )

-- Create the mod4 + middle click menu on a client
clientMenu             = customMenu.clientMenu    ( nil                                )

-- Create the music panel
--musicBar = panel.musicBar()

-- Create the hardware alarm panel
hardwarePanel = panel.hardware()

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

-- The widget array with different possible screens configuration
for s = 1, screen.count() do
  -- Create a promptbox for each screen
  promptbox[s]  = awful.widget.prompt   (                                                 )
  
  -- Create the layout menu for this screen
  layoutmenu[s] = customMenu.layoutmenu ( s,layouts_all                                   )
  
  -- Create a taglist widget
  mytaglist[s]  = widgets.taglist       ( s, widgets.taglist.label.all, mytaglist.buttons )

  -- Create the delTag button
  delTag[s]     = customButton.delTag   ( s                                               )
  
  -- Create the notification box
  notifibox[s]  = naughty               (                                                 )
  
  -- Create a tasklist widget
  mytasklist[s] = widgets.tasklist(function(c) return widgets.tasklist.label.currenttags(c, s) end, mytasklist.buttons)
  
  -- Create the button to move a tag the next screen
  movetagL[s]   = customButton.tagmover(s,{ direction = "left",  icon = config.data.iconPath .. "tags/screen_left.png"  })
  movetagR[s]   = customButton.tagmover(s,{ direction = "right", icon = config.data.iconPath .. "tags/screen_right.png" })
  
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
          layout = awful.widget.layout.horizontal.leftright                                           -------
      },
      --                             RULES                      EXIST            WIDGET              FALLBACK
      ( s == config.data.scr.sec or screen.count() == 1                  ) and mytextclock            or nil,
      ( s == config.data.scr.sec or screen.count() == 1                  ) and kgetwidget             or nil,
      ( s == config.data.scr.sec or screen.count() == 1                  ) and kgetpixmap             or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and soundWidget ) and soundWidget.wid        or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and soundWidget ) and soundWidget.pix        or nil,
      ( s == config.data.scr.sec or screen.count() == 1                  ) and spacer4                or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and netinfo     ) and netinfo.up_text        or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and netinfo     ) and netinfo.up_logo        or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and netinfo     ) and netinfo.down_text      or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and netinfo     ) and netinfo.down_logo      or nil,
      ( s == config.data.scr.sec or screen.count() == 1                  ) and spacer2                or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and meminfo     ) and meminfo.bar            or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and meminfo     ) and meminfo.text           or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and meminfo     ) and meminfo.logo           or nil,
      ( s == config.data.scr.sec or screen.count() == 1                  ) and spacer2                or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and cpuinto     ) and cpuinfo.graph          or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and cpuinfo     ) and cpuinfo.text           or nil,
      ((s == config.data.scr.sec or screen.count() == 1) and cpuinfo     ) and cpuinfo.logo           or nil,
      ( s == config.data.scr.sec or screen.count() == 1                  ) and spacer3                or nil,
      layout = awful.widget.layout.horizontal.rightleft,                                              ------
      {                                                                                               ------
        notifibox[s]                                                                                  or nil,
        layout = awful.widget.layout.horizontal.flex                                                  ------
      },                                                                                              ------
  }
  
  -- Bottom wibox widgets
  wiboxBot[s].widgets = {
    --           RULES                                                         WIDGET                FALLBACK
    ( s == config.data.scr.pri                                           ) and applicationMenu        or nil,
    ( s == config.data.scr.pri                                           ) and placesMenu             or nil,
    ( s == config.data.scr.pri                                           ) and recentMenu             or nil,
    ( s == config.data.scr.pri                                           ) and launcher               or nil,
    ( s == config.data.scr.pri                                           ) and desktopPix             or nil,
    promptbox[s]                                                                                      or nil,
    spacer3                                                                                           or nil,
    {                                                                                                 ------
      (s == config.data.scr.pri                                          ) and keyboardSwitcherWidget or nil,
      spacer3                                                                                         or nil,
      (s == config.data.scr.pri                                          ) and mysystray              or nil,
      layout = awful.widget.layout.horizontal.rightleft,                                              ------
    },                                                                                                ------
    layout = awful.widget.layout.horizontal.leftright,                                                ------
    mytasklist[s]                                                                                     or nil,
  }  
end

-- Titlebar widgets
widgets.titlebar.add_signal("create",function(widgets,titlebar)
    local menuTb = widget({type="textbox"})
    menuTb.text  = "[MENU]"

    widgets.wibox.widgets = {                                      --
        {                                                          --
          widgets.icon                                              ,
          menuTb                                                    ,
          layout = awful.widget.layout.horizontal.leftright         ,
        }                                                           ,
        widgets.buttons.close.widget                                ,
        widgets.buttons.ontop.widget                                , 
        widgets.buttons.maximized.widget                            ,
        widgets.buttons.sticky.widget                               ,
        widgets.buttons.floating.widget                             ,
        layout = awful.widget.layout.horizontal.rightleft           ,
        widgets.tabbar                                              ,
    }
          
    local client = nil
    titlebar:add_signal('client_changed', function (c)
        client = c
    end)
    
    menuTb:buttons( awful.util.table.join(
    awful.button({ }, 1, function()
        if client ~= nil then
            customMenu.clientMenu.menu().settings.x = client:geometry().x
            customMenu.clientMenu.menu().settings.y = client:geometry().y+16
            customMenu.clientMenu.toggle(client)
        end
    end)))
end)

-- Add the drives list on the desktop
if config.data.deviceOnDesk == true then
  widgets.devices()
end
if config.data.desktopIcon == true then
    for i=1,20 do
        widgets.desktopIcon()
    end
end


shifty.taglist = mytaglist

-- Load the desktop "conky" widget
widgets.desktopMonitor(screen.count() == 1 and 1 or 2)

-- Load the keybindings
dofile(awful.util.getdir("config") .. "/keyBinding.lua")

-- Hooks
client.add_signal("manage", function (c, startup)
    -- Add a titlebar to floating clients
    if awful.client.floating.get(c) == true or config.data.showTitleBar == true  then
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