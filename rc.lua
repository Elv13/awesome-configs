require("awful")
require("beautiful")
require("naughty")
require("shifty")
require("vicious")
require("layoutmenu")
require("tagmover")
dofile(awful.util.getdir("config") .. "/functions.lua")
dofile(awful.util.getdir("config") .. "/desktop.lua")

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

shifty.config.defaults = {
  layout = awful.layout.suit.tile,
  ncol = 1,
  mwfact = 0.60,
  floatBars=true,
}

shifty.modkey = modkey

myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

				     
dofile(awful.util.getdir("config") .. "/menu.lua")   

mymainmenu2 = awful.menu.new({ items = {{ "Home", "dolphin $HOME",image(awful.util.getdir("config") .. "/Icon/tags/home.png") },
					{ "KDE-devel", "dolphin /home/kde-devel",image(awful.util.getdir("config") .. "/Icon/tags/kde.png") },
					{ "Image", "dolphin /mnt/smbsda1/My\ Pictures/",image(awful.util.getdir("config") .. "/Icon/tags/image.png") },
					{ "Video", "dolphin /mnt/smbsdb3/movie/to_burn/",image(awful.util.getdir("config") .. "/Icon/tags/video.png") },
					{ "Music", "dolphin /mnt/smbsda1/music/",image(awful.util.getdir("config") .. "/Icon/tags/media.png") },
					{ "Backup", "dolphin /mnt/smbsda1/backup/",image(awful.util.getdir("config") .. "/Icon/tags/backup.png") },
					{ "Notes", "dolphin /home/lepagee/Notes/",image(awful.util.getdir("config") .. "/Icon/tags/editor.png") },
                                      },
                            })
			    
local aFile = io.popen("/home/lepagee/Scripts/awesomeTopExec.sh")
local count = 0
local commandArray = {}
while true do
    local line = aFile:read("*line")
    if line == nil then break end
    commandArray[count] = {line,line}
    count = count + 1
end
aFile:close()
mymainmenu3 = awful.menu.new({ items = commandArray})

mylauncher2 = awful.widget.launcher({ image = image(awful.util.getdir("config") .. "/Icon/tags/home2.png"),
                                     menu = mymainmenu2 })
mylauncher2text = widget({ type = "textbox" })
mylauncher2text.text = " Places  "

			    
mylauncher3 = awful.widget.launcher({ image = image(awful.util.getdir("config") .. "/Icon/tags/star2.png"),
                           menu = mymainmenu3   })
mylauncher3text = widget({ type = "textbox" })
mylauncher3text.text = " Recent |"
				     
mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = main_menu })
mylaunchertext = widget({ type = "textbox" })
mylaunchertext.text = " Apps  "

launcherPix       = widget({ type = "imagebox", align = "left" })
launcherPix.image = image(awful.util.getdir("config") .. "/Icon/gearA2.png")

desktopPix       = widget({ type = "imagebox", align = "left" })
desktopPix.image = image(awful.util.getdir("config") .. "/Icon/tags/desk2.png")

addTag = widget({ type = "imagebox", align = "left" })
addTag.image = image(awful.util.getdir("config") .. "/Icon/tags/cross2.png")

delTag = {}
-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mylayoutmenu = {}
mytaglist = {}
movetagL= {}
movetagR= {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, function (tag) 
					    awful.tag.viewonly(tag) 
					    if isPlayingMovie == true then
					      if musicBarVisibility == false then
						volumepixmap.visible = true
						volumewidget.visible = true
						mywibox3.visible = false
					      end
					      enableAmarokCtrl(true)
					    end
					    isPlayingMovie = false
					    if tag == shifty.getpos(3) then
					      run_or_raise("dolphin", { class = "Dolphin" })
					    elseif tag == shifty.getpos(2) then
					      run_or_raise("firefox", { class = "Firefox" })
					    elseif tag == shifty.getpos(4) then
					      run_or_raise("kate", { class = "Kate" })
					    elseif tag == shifty.getpos(12) then
					      enableAmarokCtrl(false)
					      musicBarVisibility = mywibox3.visible
					      volumepixmap.visible = false
					      volumewidget.visible = false
					      mywibox3.visible = true
					      isPlayingMovie = true
					    end
					    
					    if (#tag:clients() == 0) then
					      delTag[tag.screen].visible = true
					    else
					      delTag[tag.screen].visible = false
					    end
					 end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
		    awful.button({ }, 2, function (tag) shifty.rename(tag) end),
                    awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )


		    
mytasklist = {}
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
					  
function setupKb()
  local keyboardPipe = io.open('/tmp/kbMap',"r")
  --local keyboardPipe = io.popen('sleep 1 && setxkbmap -v 10 -display :0 | grep "layout:" | grep -e "[a-zA-Z0-9_]*" -o | tail -n1');
  local text = keyboardPipe:read("*all")
  keyboardPipe:close()
  return text
end

dofile(awful.util.getdir("config") .. "/topWidget.lua")

keyboardSwitcher = widget({ type = "imagebox"})

if setupKb() ==  "us" then
  keyboardSwitcher.image = image(awful.util.getdir("config") .. "/Icon/us_flag.png")
else
  keyboardSwitcher.image = image(awful.util.getdir("config") .. "/Icon/canada_flag.png")
end

keyboardSwitcher:buttons( awful.util.table.join(
  awful.button({ }, 1, function()
      if setupKb() ==  "us" then
	keyboardSwitcher.text = "ca"
	local aFile = io.open('/tmp/kbMap',"w")
	aFile:write("ca")
	aFile:close() 
	awful.util.spawn("setxkbmap ca") 
	keyboardSwitcher.image = image(awful.util.getdir("config") .. "/Icon/canada_flag.png")
      else
	keyboardSwitcher.text = "us"
	local aFile = io.open('/tmp/kbMap',"w")
	aFile:write("us")
	aFile:close() 
	awful.util.spawn("setxkbmap us")
	keyboardSwitcher.image = image(awful.util.getdir("config") .. "/Icon/us_flag.png")
      end
  end)
))

spacer77 = widget({ type = "textbox" })
spacer77.text = "| "

spacer76 = widget({ type = "textbox", align = "left" })
spacer76.text = "| "

-- setupRectLauncher(1, {awful.util.getdir("config") .. "/Icon/rectangles90/run.png"}) 
-- setupRectLauncher(1, {awful.util.getdir("config") .. "/Icon/rectangles90/update_local_system.png"}) 
-- setupRectLauncher(1, {awful.util.getdir("config") .. "/Icon/rectangles90/clear_temp_file.png"}) 
-- setupRectLauncher(1, {awful.util.getdir("config") .. "/Icon/rectangles90/free_space.png"}) 
-- setupRectLauncher(1, {awful.util.getdir("config") .. "/Icon/rectangles90/compile_svn.png"}) 
-- setupRectLauncher(1, {awful.util.getdir("config") .. "/Icon/rectangles90/local_admin.png"}) 
-- 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/update_server3.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/update_server2.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/update_server1.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/restart_server3.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/restart_server2.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/restart_server1.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/block_all_intrusion.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/lock_network.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/prevent_ssh.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/allow_vcn.png"}) 
-- setupRectLauncher(2, {awful.util.getdir("config") .. "/Icon/rectangles90/net_admin.png"}) 
-- 
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/backup_virtual_machine.png"})
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/backup_dev_files.png"})
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/backup_database.png"})
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/restore_backup.png"})
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/backup_drive.png"})
-- setupRectLauncher(3, {awful.util.getdir("config") .. "/Icon/rectangles90/backup.png"})
-- 
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/fetch_pictures.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/xkill.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/mount_iso_image.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/mount_img_image.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/rip_cd.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/remount_read_only.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/mount_sdd1.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/mount_sdc1.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/mount_sdb1.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/eject_cd.png"})
-- setupRectLauncher(4, {awful.util.getdir("config") .. "/Icon/rectangles90/local_admin.png"})

  
loadRectLauncher(2)
    

for s = 1, screen.count() do
  
  
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
			     
    mylayoutmenu[s] = layoutmenu(s,layouts_all)
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)


    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    
    delTag[s] = widget({ type = "imagebox", align = "left" })
    delTag[s].image = image(awful.util.getdir("config") .. "/Icon/tags/minus2.png")
    delTag[s].visible = false
    
    movetagL[s] = tagmover(s,{ direction = "left", icon = awful.util.getdir("config") .. "/Icon/tags/screen_left.png" })
    
    movetagR[s] = tagmover(s,{ direction = "right", icon = awful.util.getdir("config") .. "/Icon/tags/screen_right.png" })
    
    delTag[s]:buttons( awful.util.table.join(
      awful.button({ }, 1, function()
	  shifty.del(awful.tag.selected(mouse.screen))
      end)
    ))
    
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
      mywibox2.widgets = {  mylauncher,
			    mylaunchertext,
			    mylauncher2,
			    mylauncher2text,
			    mylauncher3,
			    mylauncher3text,
			    desktopPix,
			    launcherPix,
			    mypromptbox[s],
			    spacer76,
			    {
			      movetagL[s],
			      movetagR[s],
			      keyboardSwitcher,
			      mylayoutbox[s],
			      spacer77,
			      mytasklist[s],
			      s == 1 and mysystray or nil,
			      layout = awful.widget.layout.horizontal.rightleft,
			    },
			    layout = awful.widget.layout.horizontal.leftright,
			  }  
    elseif s == 1 then
      mywibox2.widgets = {  mylauncher,
			    mylaunchertext,
			    mylauncher2,
			    mylauncher2text,
			    mylauncher3,
			    mylauncher3text,
			    desktopPix,
			    launcherPix,
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
    elseif screen.count() == s then
      mywibox2.widgets = {
			    mypromptbox[s],
			    spacer76,
			    {  mysystray,
			      keyboardSwitcher,
			      mylayoutbox[s],
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

dofile(awful.util.getdir("config") .. "/launchbar.lua")

launcherPix:buttons( awful.util.table.join(
  awful.button({ }, 1, function()
      if lauchBar.visible ==  false then
	lauchBar.visible = true
      else
	lauchBar.visible = false
      end
  end)
))

desktopPix:buttons( awful.util.table.join(
  awful.button({ }, 1, function()
      awful.tag.viewnone()
  end)
))

addTag:buttons( awful.util.table.join(
 awful.button({ }, 1, function()
     shifty.add({name = "NewTag"})
     delTag[mouse.screen].visible = true
 end)
))


shifty.taglist = mytaglist

loadMonitor(screen.count() * screen[1].geometry.width - 415) --BUG support only identical screens

-- }}}

-- {{{ Mouse bindings
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
-- }}}

dofile(awful.util.getdir("config") .. "/keyBinding.lua")

-- }}}

-- {{{ Rules

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
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
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
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
-- }}}

shifty.init()
mywibox[1].visible = false
mywibox[1].visible = true

mywibox2.visible = false
mywibox2.visible = true
