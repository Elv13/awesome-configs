mywibox3 = awful.wibox({ position = "top", screen = s, height = 20})
awful.wibox.set_position(mywibox3,"top",1)

previouspixmap       = widget({ type = "imagebox", align = "left" })
previouspixmap.image = image(awful.util.getdir("config") .. "/Icon/previous.png")

previouspixmap:add_signal("mouse::enter", function ()
    previouspixmap.image = image(awful.util.getdir("config") .. "/Icon/previous_light.png")
end)

previouspixmap:add_signal("mouse::leave", function ()
  previouspixmap.image = image(awful.util.getdir("config") .. "/Icon/previous.png")
end)

previouspixmap:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if isPlayingMovie == false then
	  awful.util.spawn('dbus-send --type=method_call --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.Prev')
      else
	awful.util.spawn('/home/lepagee/Scripts/vlcPosition.sh p')
      end
    end)
))

playpixmap       = widget({ type = "imagebox", align = "left" })
playpixmap.image = image(awful.util.getdir("config") .. "/Icon/play.png")

playpixmap:add_signal("mouse::enter", function ()
    playpixmap.image = image(awful.util.getdir("config") .. "/Icon/play_light.png")
end)

playpixmap:add_signal("mouse::leave", function ()
   playpixmap.image = image(awful.util.getdir("config") .. "/Icon/play.png")
end)

playpixmap:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if isPlayingMovie == false then
	  awful.util.spawn('dbus-send --type=method_call --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.PlayPause')
      else
	awful.util.spawn('dbus-send --session --print-reply --dest=org.mpris.vlc --type="method_call" /Player org.freedesktop.MediaPlayer.Pause')
      end
    end)
))

pausepixmap       = widget({ type = "imagebox", align = "left" })
pausepixmap.image = image(awful.util.getdir("config") .. "/Icon/pause.png")

pausepixmap:add_signal("mouse::enter", function ()
    pausepixmap.image = image(awful.util.getdir("config") .. "/Icon/pause_light.png")
end)

pausepixmap:add_signal("mouse::leave", function ()
  pausepixmap.image = image(awful.util.getdir("config") .. "/Icon/pause.png")
end)

pausepixmap:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if isPlayingMovie == false then
	  awful.util.spawn('dbus-send --type=method_call --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.PlayPause')
      else
	awful.util.spawn('dbus-send --session --print-reply --dest=org.mpris.vlc --type="method_call" /Player org.freedesktop.MediaPlayer.Pause')
      end
    end)
))

stoppixmap       = widget({ type = "imagebox", align = "left" })
stoppixmap.image = image(awful.util.getdir("config") .. "/Icon/stop.png")

stoppixmap:add_signal("mouse::enter", function ()
    stoppixmap.image = image(awful.util.getdir("config") .. "/Icon/stop_light.png")
end)

stoppixmap:add_signal("mouse::leave", function ()
  stoppixmap.image = image(awful.util.getdir("config") .. "/Icon/stop.png")
end)

stoppixmap:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if isPlayingMovie == false then
	  awful.util.spawn('dbus-send --session --print-reply --dest=org.mpris.vlc --type="method_call" /Player org.freedesktop.MediaPlayer.Stop')
      else
	awful.util.spawn('dbus-send --session --print-reply --dest=org.mpris.vlc --type="method_call" /Player org.freedesktop.MediaPlayer.Stop')
      end
    end)
))

nextpixmap       = widget({ type = "imagebox", align = "left" })
nextpixmap.image = image(awful.util.getdir("config") .. "/Icon/next.png")

nextpixmap:add_signal("mouse::enter", function ()
    nextpixmap.image = image(awful.util.getdir("config") .. "/Icon/next_light.png")
end)

nextpixmap:add_signal("mouse::leave", function ()
  nextpixmap.image = image(awful.util.getdir("config") .. "/Icon/next.png")
end)

nextpixmap:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if isPlayingMovie == false then
	  awful.util.spawn('dbus-send --type=method_call --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.Next')
      else
	awful.util.spawn('/home/lepagee/Scripts/vlcPosition.sh f')
      end
    end)
))

artistwidget = widget({
    type = 'textbox',
    name = 'volumewidget',
    align='left'
})
artistwidget.text = '<b>Artist: </b>Name | '



function check_is_running(properties)
   local clients = client.get()
   for i, c in pairs(clients) do
      if match(properties, c) then
	return true
      end
   end
   return false
end

function artist_info(format)
  if mywibox3.visible == true then
    --if check_is_running({class = "Amarok"}) then
      local f = io.popen('dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | grep artist --context=1 |  tail -n 1 | cut -f 2 -d \'"\'` #tail -n 1 | grep -e "\"[a-zA-Z0-9 ().,]*\"" -o | cut -f 2 -d \'"\'')
      local text2 = f:read()   
      f:close()
      return {"<b>Artist:</b> " .. text2 .. " | "}
      
    --else
    --  return {"Amarok is not running"}
    --end
  end
end



countwidget = widget({
    type = 'textbox',
    name = 'volumewidget',
    align='left'
})
countwidget.text = '<b>Elapsed: </b>(0:37) | '

function total_info(format)
  if mywibox3.visible == true then
    local f
    local text2
    if isPlayingMovie == false then
      f = io.popen('/home/lepagee/Scripts/amarokInfo2.sh remaining')
      text2 = f:read()
    else
      f = io.popen('/home/lepagee/Scripts/vlcInfo.sh remaining')
      text2 = f:read()
    end
    f:close()
    return {text2}
  end
end



songtilewidget = widget({
    type = 'textbox',
    name = 'volumewidget',
    align='left'
})
songtilewidget.text = '<b>Title: </b>A really long song title'

function title_info(format)
  if mywibox3.visible == true then
    local f = io.popen('/home/lepagee/Scripts/amarokInfo2.sh title')
    local text2 = f:read()
    f:close()
    return {text2}
  end
end


remainwidget = widget({
    type = 'textbox',
    name = 'remainwidget',
    align='left'
})
remainwidget.text = '    | <b>Elapsed: </b>(-3:53)'

function elapsed_info(format)
  if mywibox3.visible == true then
    local f
    local text2 
    if isPlayingMovie == false then
      f = io.popen('dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.PositionGet | tail -n 1 | awk \'{print $2/1000}\' | cut -f 1 -d "."')
      text2 = f:read()
    else
      f = io.popen('/home/lepagee/Scripts/vlcInfo.sh elapsed')
      text2 = f:read()
    end
    f:close()
    return {text2}
  end
end



progression = awful.widget.progressbar()
progression:set_width(400)
progression:set_height(20)
progression:set_background_color(beautiful.bg_normal)
progression:set_border_color(beautiful.fg_normal)
progression:set_color(beautiful.fg_normal)
progression:set_value(0.5)
progression:set_offset(1)
progression:set_margin({top=6,bottom=6})

spacer999 = widget({
    type = 'textbox',
    name = 'spacer999',
    align='right'
})
spacer999.text = "| "




vlcInfo = widget({
    type = 'textbox',
    name = 'remainwidget',
    align='left'
})
vlcInfo.text = 'The VideoLan Media Player'
vlcInfo.visible = false

function enableAmarokCtrl(boolean)
  --remainwidget.visible = boolean
  songtilewidget.visible = boolean
  --countwidget.visible = boolean
  artistwidget.visible = boolean
  vlcInfo.visible = not boolean
end

headphonecheck = true
local f99 = io.popen("amixer sget Front | grep '\\[off\\]' -o")
local l99 = f99:read()
f99:close()
if l99 == "[off]" then
  headphonecheck = false
end

function toggleHeadPhone()
  if headphonecheck == true then
    headphonecheckpix.image = image(awful.util.getdir("config") .. "/Icon/uncheck.png")
    awful.util.spawn("amixer -c0 sset Front mute >/dev/null")
    headphonecheck = false
  else
    headphonecheckpix.image = image(awful.util.getdir("config") .. "/Icon/check.png")
    awful.util.spawn("amixer -c0 sset Front unmute >/dev/null")
    headphonecheck = true
  end
end

headphonecheckpix       = widget({ type = "imagebox", align = "right" })
if headphonecheck == true then
  headphonecheckpix.image = image(awful.util.getdir("config") .. "/Icon/check.png")
else
  headphonecheckpix.image = image(awful.util.getdir("config") .. "/Icon/uncheck.png")
end

headphonecheckpix:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
        toggleHeadPhone()
    end)
))

headphone = widget({
    type = 'textbox',
    name = 'headphone',
    align='right'
})
headphone.text = "HeadPhone | "

headphone:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
        toggleHeadPhone()
    end)
))

speakercheck = true
local f98 = io.popen("amixer sget Surround | grep '\\[off\\]' -o")
local l98 = f98:read()
f98:close()
if l98 == "[off]" then
  speakercheck = false
end

function toggleSpeakers()
  if speakercheck == true then
    speakercheckpix.image = image(awful.util.getdir("config") .. "/Icon/uncheck.png")
    awful.util.spawn("amixer -c0 sset Surround mute >/dev/null")
    speakercheck = false
  else
    speakercheckpix.image = image(awful.util.getdir("config") .. "/Icon/check.png")
    awful.util.spawn("amixer -c0 sset Surround unmute >/dev/null")
    speakercheck = true
  end
end

speakercheckpix  = widget({ type = "imagebox", align = "right" })
if speakercheck == true then
  speakercheckpix.image = image(awful.util.getdir("config") .. "/Icon/check.png")
else
  speakercheckpix.image = image(awful.util.getdir("config") .. "/Icon/uncheck.png")
end

speakercheckpix:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
        toggleSpeakers()
    end)
))

speaker = widget({
    type = 'textbox',
    name = 'speaker',
    align='right'
})
speaker.text = "Speakers |"

speaker:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
        toggleSpeakers()
    end)
))


volumewidget2 = widget({
    type = 'textbox',
    name = 'volumewidget',
    align='right'
})

volumewidget2:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
        mywibox3.visible = not mywibox3.visible
	volumepixmap.visible = not volumepixmap.visible 
	volumewidget.visible = not volumewidget.visible 
    end),
    awful.button({ }, 4, function()
        awful.util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
    end),
    awful.button({ }, 5, function()
        awful.util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
    end)
))

volumebarwidget = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })

-- volumebarwidget:buttons(awful.util.table.join(
--     awful.button({ }, 1, function()
--         mywibox3.visible = not mywibox3.visible
-- 	volumepixmap.visible = not volumepixmap.visible 
-- 	volumewidget.visible = not volumewidget.visible 
--     end),
--     awful.button({ }, 4, function()
--         awful.util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
--     end),
--     awful.button({ }, 5, function()
--         awful.util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
--     end)
-- ))

volumebarwidget:set_width(40)
volumebarwidget:set_height(18)
--membarwidget:set_gap(1)
volumebarwidget:set_vertical(false)
volumebarwidget:set_background_color(beautiful.bg_normal)
volumebarwidget:set_border_color(beautiful.fg_normal)
volumebarwidget:set_color(beautiful.fg_normal)
volumebarwidget:set_gradient_colors({
  beautiful.fg_normal,
  beautiful.fg_normal,
  '#CC0000'
})
volumebarwidget:set_offset(1)
volumebarwidget:set_margin({top=3,bottom=3})

volumepixmap2       = widget({ type = "imagebox", align = "right" })
volumepixmap2.image = image(awful.util.getdir("config") .. "/Icon/vol.png")
volumepixmap2:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
        mywibox3.visible = not mywibox3.visible
	volumepixmap.visible = not volumepixmap.visible 
	volumewidget.visible = not volumewidget.visible 
    end),
    awful.button({ }, 4, function()
        awful.util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
    end),
    awful.button({ }, 5, function()
        awful.util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
    end)
))
--vicious.register(volumewidget2, amixer_volume, ' $1% ')

function percent_info(format)
  
  --progression:set_width(screen[1].geometry.width - )
--  progression:set_width((spacer999:extents()["x"])-(remainwidget:extents()["x"]+remainwidget:extents()["width"]-countwidget:extents()["width"] --faster, but not working in 3.4rc3
 --progression:set_width(--[[screen[1].geometry.width -]](previouspixmap:extents()["width"]+ pausepixmap:extents()["width"]+ playpixmap:extents()["width"]+ stoppixmap:extents()["width"]+ nextpixmap:extents()["width"]+ artistwidget:extents()["width"]+ songtilewidget:extents()["width"]+ vlcInfo:extents()["width"]+ remainwidget:extents()["width"]+ countwidget:extents()["width"]+ volumewidget2:extents()["width"]+ volumepixmap2:extents()["width"]+ speaker:extents()["width"]+ speakercheckpix:extents()["width"]+ headphone:extents()["width"]+ headphonecheckpix:extents()["width"]+ spacer999:extents()["width"]+100))
 progression:set_width(screen[1].geometry.width - (artistwidget:extents()["width"]+ songtilewidget:extents()["width"]+remainwidget:extents()["width"]+countwidget:extents()["width"]) -350)
  
  
  
  
  if mywibox3.visible == true then
    local f
    local text2
    if isPlayingMovie == false then
      f = io.popen('echo `dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | grep \'"mtime"\' --context=1 | tail -n 1 | awk \'{print $3 }\'` `dbus-send --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.PositionGet | tail -n 1 | awk \'{print $2}\'` | awk \'{print $2/$1}\'')
      text2 = f:read()
    else
      f = io.popen('/home/lepagee/Scripts/vlcInfo.sh percent')
      text2 = f:read()
    end
    f:close()
    return {tonumber(text2)*100}
  end
end
--vicious.register(progression, percent_info, '$1',1)
mytimer = timer({ timeout = 10 })
mytimer:add_signal("timeout", 	function() 
				  vicious.register(artistwidget, artist_info, '$1',10)
				  vicious.register(countwidget, total_info, ' -$1 ',10)
				  vicious.register(songtilewidget, title_info, '<b>Title:</b> $1   | ',10)
				  vicious.register(remainwidget, elapsed_info, '$1 ',10)
				  vicious.register(volumebarwidget, amixer_volume_int, '$1', 1, 'mem')
				  mytimer:stop()
				end)
mytimer:start()



    mywibox3.widgets = {  previouspixmap,
			  pausepixmap,
			  playpixmap,
			  stoppixmap,
			  nextpixmap,
			  artistwidget,
			  songtilewidget,
			  vlcInfo,
			  remainwidget,
			  progression,
			  countwidget,
			  {
			    volumewidget2,
			    volumebarwidget,
			    volumepixmap2,
			    speaker,
			    speakercheckpix,
			    headphone,
			    headphonecheckpix,
			    spacer999,
			    layout = awful.widget.layout.horizontal.rightleft
			  },
			  layout = awful.widget.layout.horizontal.leftright,
			  }
    mywibox3.screen = 1
    mywibox3.visible = false
