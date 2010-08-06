require("awful")
require("beautiful")
require("naughty")
require("shifty")
require("vicious")
require("layoutmenu")
require("tagmover")
require("customMenu.recent")
require("customMenu.application")
require("customMenu.places")
require("keyboardSwitcher")
require("customButton.launcher")
require("customButton.showDesktop")
require("customButton.addTag")
require("customButton.delTag")
require("soundInfo")
require("dateInfo")
require("memInfo")
require("cpuInfo")
require("netInfo")

dofile(awful.util.getdir("config") .. "/functions.lua")
dofile(awful.util.getdir("config") .. "/desktop.lua")

-- Cache result for probe used more than once
vicious.cache(vicious.widgets.net)
vicious.cache(vicious.widgets.fs)
vicious.cache(vicious.widgets.dio)
vicious.cache(vicious.widgets.cpu)

beautiful.init(awful.util.getdir("config") .. "/default/theme.lua")
terminal = 'urxvt  -tr +sb -tint gray -fade 50 +bl +si -cr red -pr green -iconic -bg black -fg white -fn "xft:DejaVu Sans Mono:pixelsize=13"'
-- terminal = 'aterm -tr +sb -tint gray -fade 50 +bl -tinttype true +si -cr red -pr green'
editor = os.getenv("EDITOR") or "kwrite" or "nano"
editor_cmd = 'kwrite'
modkey = "Mod4"

dofile(awful.util.getdir("config") .. "/baseRule.lua")

-- Shifty config
shifty.config.defaults = {
  layout = awful.layout.suit.tile,
  ncol = 1,
  mwfact = 0.60,
  floatBars=true,
}

shifty.modkey = modkey

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
mytextclock = dateinfo()

-- Create the memory manager
meminfo = memInfo(screen.count())

-- Create the cpu manager
cpuinfo = cpuInfo()

-- Create the net manager
netinfo = netInfo()

-- Create the volume box
soundWidget = soundInfo()

-- Create the keyboard layout switcher, feel free to add your contry and push it to master
keyboardSwitcherWidget = keyboardSwitcher()

-- Create the addTag icon
addTag = customButton.addTag()

-- Create a systray
mysystray = widget({ type = "systray" })

-- Some widget for every screens
mywibox = {}
mypromptbox = {}
mylayoutmenu = {}
mytaglist = {}
movetagL= {}
movetagR= {}
mytasklist = {}
delTag = {}

--Hacking and buggy, a rewrite is in my TODO list
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, function (tag) awful.tag.viewonly(tag) end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 2, function (tag) shifty.rename(tag) end),
                    awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
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

spacer77 = widget({ type = "textbox" })
spacer77.text = "| "

spacer76 = widget({ type = "textbox", align = "left" })
spacer76.text = "| "

spacer3 = widget({ type = "textbox", align = "right" })
spacer3.text = "| "

spacer2 = widget({ type = "textbox", align = "right" })
spacer2.text = "  |"

spacer1 = widget({ type = "textbox", align = "right" })
spacer1.text = "  |"

spacer4 = widget({ type = "textbox", align = "right" })
spacer4.text = "|"

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
  mylayoutmenu[s] = layoutmenu(s,layouts_all)
  
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(function(c) return awful.widget.tasklist.label.currenttags(c, s) end, mytasklist.buttons)
  -- Create the top
  mywibox[s] = awful.wibox({ position = "top", screen = s })
  
  -- Create the delTag button
  delTag[s] = customButton.delTag(s)
  
  -- Create the button to move a tag the next screen
  movetagL[s] = tagmover(s,{ direction = "left", icon = awful.util.getdir("config") .. "/Icon/tags/screen_left.png" })
  movetagR[s] = tagmover(s,{ direction = "right", icon = awful.util.getdir("config") .. "/Icon/tags/screen_right.png" })
  
  if s == screen.count() then
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
			  spacer1,
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
    mywibox2.widgets = {  applicationMenu["menu"],
			  applicationMenu["text"],
			  placesMenu["menu"],
			  placesMenu["text"],
			  recentMenu["menu"],
			  recentMenu["text"],
			  desktopPix,
			  launcherPix,
			  mypromptbox[s],
			  spacer76,
			  {
			    movetagL[s],
			    movetagR[s],
			    keyboardSwitcherWidget,
			    spacer77,
			    mytasklist[s],
			    s == 1 and mysystray or nil,
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}  
  elseif s == 1 then
    mywibox2.widgets = {  applicationMenu["menu"],
			  applicationMenu["text"],
			  placesMenu["menu"],
			  placesMenu["text"],
			  recentMenu["menu"],
			  recentMenu["text"],
			  desktopPix,
			  launcherPix,
			  mypromptbox[s],
			  spacer76,
			  {
			    movetagL[s],
			    movetagR[s],
			    spacer77,
			    mytasklist[s],
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}  
  elseif screen.count() == s then
    mywibox2.widgets = {
			  mypromptbox[s],
			  spacer76,
			  {  mysystray,
			    keyboardSwitcherWidget,
			    movetagL[s],
			    movetagR[s],
			    spacer77,
			    mytasklist[s],
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}
    else
    mywibox2.widgets = {
			  mypromptbox[s],
			  spacer76,
			  {
			    movetagL[s],
			    movetagR[s],
			    mylayoutbox[s],
			    spacer77,
			    mytasklist[s],
			    layout = awful.widget.layout.horizontal.rightleft,
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			}
    end
end

local isPlayingMovie = false
local musicBarVisibility = false

dofile(awful.util.getdir("config") .. "/hardware.lua")

shifty.taglist = mytaglist

loadMonitor(screen.count() * screen[1].geometry.width - 415) --BUG support only identical screens

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
  if (c.class == "Firefox" or c.class == "Kate4" or c.class == "Kwrite" or c.class == "VLC") then
    c.border_color = "#0A1535"
  else
    c.border_color = beautiful.border_focus 
  end
end)

client.add_signal("unfocus", function(c) 
  if (c.class == "Firefox" or c.class == "Kate4" or c.class == "Kwrite" or c.class == "VLC") then
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
	run_or_raise("dolphin", { class = "Dolphin" })
      elseif tag.name == "Internet" then
	run_or_raise("firefox", { class = "Firefox" })
      elseif tag.name == "Develop" then
	run_or_raise("kate", { class = "Kate" })
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