require("awful")
require("beautiful")
require("naughty")
require("shifty")
require("vicious")
require("customMenu.layoutmenu")
require("customMenu.recent")
require("customMenu.application")
require("customMenu.places")
require("customMenu.tagOption")
require("customMenu.clientMenu")
require("customButton.launcher")
require("customButton.showDesktop")
require("customButton.addTag")
require("customButton.delTag")
require("customButton.tagmover")
require("drawer.soundInfo")
require("drawer.dateInfo")
require("drawer.memInfo")
require("drawer.cpuInfo")
require("drawer.netInfo")
require("widget.spacer")
require("widget.keyboardSwitcher")
require("mouseManager")
require("urxvtIntegration")
require("tasklist2")
require("clientSwitcher")

-- Cache result for probe used more than once
vicious.cache(vicious.widgets.net)
vicious.cache(vicious.widgets.fs)
vicious.cache(vicious.widgets.dio)
vicious.cache(vicious.widgets.cpu)

beautiful.init(awful.util.getdir("config") .. "/default/theme.lua")

-- Some widget for every screens
mywibox = {}
mypromptbox = {}
mylayoutmenu = {}
mytaglist = {}
movetagL= {}
movetagR= {}
mytasklist = {}
delTag = {}

--Create the wiboxes
for s = 1, screen.count() do
  mywibox[s] = awful.wibox({ position = "top", screen = s })
end

dofile(awful.util.getdir("config") .. "/functions.lua")
dofile(awful.util.getdir("config") .. "/desktop.lua")
--dofile(awful.util.getdir("config") .. "/hardware.lua")
--dofile(awful.util.getdir("config") .. "/musicBar.lua")

terminal = 'urxvt -tint gray -fade 50 +bl +si -cr red -pr green -iconic -fn "xft:DejaVu Sans Mono:pixelsize=13" -pe tabbed'
-- terminal = 'aterm -tr +sb -tint gray -fade 50 +bl -tinttype true +si -cr red -pr green'
editor = {cmd = "kwrite", class = "Kwrite"}
editor_cmd = 'kwrite'
webbrowser = {cmd = "firefox", class = "Firefox"}
ide = {cmd = "kate", class = "Kate"}
mediaplayer = {cmd = "vlc", class = "VLC"}
filemanager = {cmd = "dolphin", class = "Dolphin"}
xcompmgr_path = "/home/kde-devel/kde/src/xcompmgr2/"

modkey = "Mod4"

-- Shifty config
shifty.config.defaults = {
  layout = awful.layout.suit.tile,
  ncol = 1,
  mwfact = 0.60,
  floatBars=true,
}

-- Assign the modkey
shifty.modkey = modkey

-- Start the URXVT integration library watchdog
--urxvtIntegration()

-- Create the application menu
applicationMenu = customMenu.application()

-- Create the place menu TODO use the KDE list instead of the hardcoded one
placesMenu = customMenu.places()

-- Create the recent menu
recentMenu = customMenu.recent()

-- Call the laucher wibox
launcherPix = customButton.launcher()

-- Create the "Show Desktop" icon
desktopPix = customButton.showDesktop()

-- Create the clock
mytextclock = drawer.dateinfo()

-- Create the memory manager
meminfo = drawer.memInfo(screen.count())

-- Create the cpu manager
cpuinfo = drawer.cpuInfo()

-- Create the net manager
netinfo = drawer.netInfo()

-- Create the volume box
soundWidget = drawer.soundInfo(mywibox3)

-- Create the keyboard layout switcher, feel free to add your contry and push it to master
keyboardSwitcherWidget = widget.keyboardSwitcher()


-- Create a systray
mysystray = widget({ type = "systray" })

-- Create the tag right click menu [[In develpment]]
tagMenu = customMenu.tagOption(nil)

-- Create the mod4 + middle click menu on a client
clientMenu = customMenu.clientMenu(nil)

-- Shifty rules
dofile(awful.util.getdir("config") .. "/baseRule.lua")

-- Create the addTag icon (depend on shifty rule)
addTag = customButton.addTag(nil,{taglist = shifty.config.tags})

--TagList buttons
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, function (tag) awful.tag.viewonly(tag) end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 2, function (tag) shifty.rename(tag) end),
                    awful.button({ }, 3, function (tag) tagMenu:toggle(tag)--[[tag.selected = not tag.selected]] end),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )


--Tasklist button
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=450 })
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

spacer3 = widget.spacer({text = "| "})

spacer2 = widget.spacer({text = "  |"})

spacer4 = widget.spacer({text = "|"})

--Add icons on the desktop. They have to be the size of those bellow to work fine, but it's not nice, so I don't use it anymore
-- setupRectLauncher(1, {awful.util.getdir("config") .. "/Icon/rectangles90/run.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/update_server3.png"}) 
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/backup_virtual_machine.png"})
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/backup_dev_files.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/fetch_pictures.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/xkill.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/mount_iso_image.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/mount_img_image.png"})
--loadRectLauncher(2)
    

-- The widget array with different possible screens configuration TODO create some kind of screen widget rule system, this long array suck
for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
			    
  -- Create the layout menu for this screen
  mylayoutmenu[s] = customMenu.layoutmenu(s,layouts_all)
  
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = tasklist2(function(c) return tasklist2.label.currenttags(c, s) end, mytasklist.buttons)
  -- Create the top
  --mywibox[s] = awful.wibox({ position = "top", screen = s })
  
  -- Create the delTag button
  delTag[s] = customButton.delTag(s)
  
  -- Create the button to move a tag the next screen
  movetagL[s] = customButton.tagmover(s,{ direction = "left", icon = awful.util.getdir("config") .. "/Icon/tags/screen_left.png" })
  movetagR[s] = customButton.tagmover(s,{ direction = "right", icon = awful.util.getdir("config") .. "/Icon/tags/screen_right.png" })
  
  if s == 2 --[[screen.count()]] then
    mywibox[s].widgets = { 
			  {
			      mytaglist[s],
			      addTag,
			      delTag[s],
			      movetagL[s],
			      movetagR[s],
			      mylayoutmenu[s],
			      layout = awful.widget.layout.horizontal.leftright
			  },
			  mytextclock,
			  kgetwidget,
			  kgetpixmap,
			  soundWidget["wid"],
			  soundWidget["pix"],
			  spacer4,
			  netinfo["up_text"],
			  netinfo["up_logo"],
			  netinfo["down_text"],
			  netinfo["down_logo"],
			  spacer2,
			  meminfo["bar"],
			  meminfo["text"],
			  meminfo["logo"],
			  spacer2,
			  cpuinfo["graph"],
			  cpuinfo["text"],
			  cpuinfo["logo"],
			  spacer3,
			  layout = awful.widget.layout.horizontal.rightleft
			}
    else
    mywibox[s].widgets = {
			    mytaglist[s],
			    addTag,
			    delTag[s],
			    movetagL[s],
			    movetagR[s],
			    mylayoutmenu[s],
			    layout = awful.widget.layout.horizontal.leftright
			  }
    end

  -- Create the device list on the desktop
  if s == 1 then --Don't ask, otherwise it bug, I don't know why I can't put that out of this loop
    add_device("/dev/root,/home/lepagee")
    local deviceList = io.popen("mount | grep -e'^[/]' | awk '{print substr($1,6,3)\"/\"substr($1,6,4)\",\"$3}' | tail -n 4")
    while true do
	local line = deviceList:read("*line")
	if line == nil then break end
	add_device(line, "hdd")
    end 
  end

  mywibox2 = awful.wibox({ position = "bottom", screen = s })
  
  if screen.count() == 1 then
    mywibox2.widgets = {  applicationMenu,
			  placesMenu,
			  recentMenu,
			  desktopPix,
			  launcherPix,
			  mypromptbox[s],
			  spacer3,
			  {
			    movetagL[s],
			    movetagR[s],
			    keyboardSwitcherWidget,
			    spacer3,
			    mytasklist[s],
			    s == 1 and mysystray or nil,
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}  
  elseif s == 1 then
    mywibox2.widgets = {  applicationMenu,
			  placesMenu,
			  recentMenu,
			  desktopPix,
			  launcherPix,
			  mypromptbox[s],
			  spacer3,
			  {
			    movetagL[s],
			    movetagR[s],
			    spacer3,
			    mytasklist[s],
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}  
  elseif screen.count() == s then
    mywibox2.widgets = {
			  mypromptbox[s],
			  spacer3,
			  {  
			    movetagL[s],
			    movetagR[s],
			    spacer3,
			    mytasklist[s],
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}
    elseif s ==2 then
      mywibox2.widgets = {
                          mypromptbox[s],
                          spacer3,
                          { mysystray,
                            keyboardSwitcherWidget,
                            movetagL[s],
                            movetagR[s],
                            --mylayoutbox[s],
                            spacer3,
                            mytasklist[s],
                            layout = awful.widget.layout.horizontal.rightleft,
                          },
                          layout = awful.widget.layout.horizontal.leftright,
                        }
    else
      
    mywibox2.widgets = {
			  mypromptbox[s],
			  spacer3,
			  {
			    movetagL[s],
			    movetagR[s],
			    --mylayoutbox[s],
			    spacer3,
			    mytasklist[s],
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}
    end
end

local isPlayingMovie = false
local musicBarVisibility = false

shifty.taglist = mytaglist

local monitorPos = 0
for s = 1, screen.count() do
  monitorPos = monitorPos + screen[s].geometry.width
end
loadMonitor(2)

root.buttons(awful.util.table.join(
    awful.button({ }, 1, function () 
      if instance then
	  instance:hide()
	  instance = nil
      end
      main_menu:hide()
    end),
    awful.button({ }, 2, function () 
			    if instance then
				instance:hide()
				instance = nil
			    else
				instance = awful.menu.clients({ width=450 })
			    end end),
    awful.button({ }, 3, function () main_menu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

dofile(awful.util.getdir("config") .. "/keyBinding.lua")


client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })
    if awful.client.floating.get(c) == true then
      if (not c.class == "^XMMS$" or not c.class == "Xine") then
	awful.titlebar.add(c, { modkey = modkey })
      end
    else
      awful.titlebar.remove(c)
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
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
  if (c.class == webbrowser.class or c.class == "luakit" or c.class == ide.class or c.class == editor.class or c.class == mediaplayer.class) then
    c.border_color = "#0A1535"
  else
    c.border_color = beautiful.border_focus 
  end
end)

client.add_signal("unfocus", function(c) 
  if (c.class == webbrowser.class or c.class == "luakit" or c.class == ide.class or c.class == editor.class or c.class == mediaplayer.class) then
    c.border_color = "#0A1535"
  else
    c.border_color = beautiful.border_normal 
  end
end)

for s = 1, screen.count() do
  awful.tag.attached_add_signal(s, "property::selected", function () addTitleBar(s) end)
  awful.tag.attached_add_signal(s, "property::layout", function () addTitleBar(s) end)
end

shifty.init()
mywibox[1].visible = false
mywibox[1].visible = true

mywibox2.visible = false
mywibox2.visible = true

--Start application when a tag is first used, better than using shifty.init
for s = 1, screen.count() do
  awful.tag.attached_add_signal(s, "property::selected", function(tag)
    if awful.tag.selected(s) == tag then --Prevent infinite loop, but a little buggy
    if isPlayingMovie == true then
      if musicBarVisibility == false then
	  volumepixmap.visible = true
	  volumewidget.visible = true
	  mywibox3.visible = false
      end
      enableAmarokCtrl(true)
    end
      isPlayingMovie = false
      if tag.name == "Files" then
	run_or_raise(filemanager.cmd, { class = filemanager.class })
      elseif tag.name == "Internet" then
	run_or_raise(webbrowser.cmd, { class = webbrowser.class })
      elseif tag.name == "Develop" then
	run_or_raise(ide.cmd, { class = ide.class })
    elseif tag.name == "Movie" then
      enableAmarokCtrl(false)
      musicBarVisibility = mywibox3.visible
      volumepixmap.visible = false
      volumewidget.visible = false
      mywibox3.visible = true
      isPlayingMovie = true
      end
    end
  end)
end

io.popen("killall xcompmgr")
awful.util.spawn(xcompmgr_path .."xcompmgr -fFC -I 0.05")
