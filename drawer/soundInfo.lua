local setmetatable = setmetatable
local tonumber = tonumber
local table = table
local io = io
local button = require("awful.button")
local vicious = require("vicious")
local wibox = require("awful.wibox")
local widget2 = require("awful.widget")
local config = require("config")
local beautiful = require("beautiful")
local util = require("awful.util")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse}

module("drawer.soundInfo")

local data = {}
local alsaInfo = {}
local mywibox3 = nil
local widgetTable = {}

function update()

end

local function amixer_volume(format)
   local f = io.popen('amixer sget Master | tail -n1 |cut -f 6 -d " " | grep -o -e "[0-9]*"')
   local l = f:read()
   f:close()
   if l+0 == 0 then
    if volumepixmap == not nil then
      volumepixmap.image = capi.image(config.data.iconPath .. "volm.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = capi.image(config.data.iconPath .. "volm.png")
    end
   elseif l+0 < 15 then
   if volumepixmap == not nil then
      volumepixmap.image = capi.image(config.data.iconPath .. "vol1.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = capi.image(config.data.iconPath .. "vol1.png")
    end
   elseif l+0 < 35 then
   if volumepixmap == not nil then
      volumepixmap.image = capi.image(config.data.iconPath .. "vol2.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = capi.image(config.data.iconPath .. "vol2.png")
    end
   else
    if volumepixmap == not nil then
      volumepixmap.image = capi.image(config.data.iconPath .. "vol3.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = capi.image(config.data.iconPath .. "vol3.png")
    end
   end
   return {l}
end

function amixer_volume_int(format)
   local f = io.popen('amixer sget Master | tail -n1 |cut -f 6 -d " " | grep -o -e "[0-9]*"')
   local l = f:read()
   f:close()
   local toReturn
   if l == "" then
    toReturn = 0
   else
    toReturn = tonumber(l)
   end
   return {toReturn}
end

function soundInfo() 
  local f = io.popen('amixer | grep "Simple mixer control" | cut -f 2 -d "\'" | sort -u')
  
  local soundHeader = capi.widget({type = "textbox"})
  soundHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>CHANALS</tt></b></span> "
  soundHeader.bg = beautiful.fg_normal
  soundHeader.width = 240
  table.insert(widgetTable, soundHeader)
  
  local counter = 0
  while true do
    local aChannal = f:read("*line")
    if aChannal == nil then
      break
    end
    
    local f2= io.popen('amixer sget '.. aChannal ..' | tail -n1 |cut -f 6 -d " " | grep -o -e "[0-9]*" 2> /dev/null')
    local aVolume = (tonumber(f2:read("*line")) or 0) / 100
    f2:close()
    
    channal = capi.widget({type = "textbox"})
    channal.text = aChannal
    channal.width = 107
        
    mute = capi.widget({ type = "imagebox", align = "left" })
    mute.image = capi.image(config.data.iconPath .. "volm.png")
    mute.width = 25
    mute.bg = "#0F2051"
    mute.border_width = 1
    mute.border_color = beautiful.bg_normal
    
    plus = capi.widget({ type = "imagebox", align = "left" })
    plus.image = capi.image(config.data.iconPath .. "tags/cross2.png")

    volume = widget2.progressbar()
    volume:set_width(40)
    volume:set_height(20)
    volume:set_background_color(beautiful.bg_normal)
    volume:set_border_color(beautiful.fg_normal)
    volume:set_color(beautiful.fg_normal)
    volume:set_value(aVolume or 0)
    if (widget2.progressbar.set_offset ~= nil) then
      volume:set_offset(1)
    end
    --volume:set_margin({top=6,bottom=6})
    
    minus = capi.widget({ type = "imagebox", align = "left" })
    minus.image = capi.image(config.data.iconPath .. "tags/minus2.png")
    counter = counter +1
    table.insert(widgetTable, {mute, channal, plus, volume, minus, layout = widget2.layout.horizontal.leftright})
  end
  f:close()

  widgetTable["layout"] = widget2.layout.vertical.flex
            
  data.wibox.widgets = widgetTable
  data.wibox:geometry({height = counter*19 + 19})
end
  
function new(mywibox3)

  data.wibox = wibox({ position = "free", screen = s})
  data.wibox.ontop = true
  data.wibox.visible = false
  data.wibox:geometry({y = 20, x = capi.screen[capi.mouse.screen].geometry.width - 240 + capi.screen[capi.mouse.screen].geometry.x, width = 240, height = 300})
  soundInfo() 
  volumewidget = capi.widget({
      type = 'textbox',
      name = 'volumewidget',
      align='right'
  })

  --volumewidget.mouse_enter = function () soundInfo() end

  volumewidget:buttons( util.table.join(button({ }, 1, function ()
      data.wibox.visible = true
  end)))
  
  --volumewidget.mouse_leave = function () naughty.destroy(alsaInfo[3]) end

  volumewidget:buttons( util.table.join(
     button({ }, 1, function()
          data.wibox.visible = not data.wibox.visible
	  mywibox3.visible = not mywibox3.visible
	  musicBarVisibility = true
	  volumepixmap.visible = not volumepixmap.visible 
	  volumewidget.visible = not volumewidget.visible 
      end),
      button({ }, 4, function()
	  util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
      end),
      button({ }, 5, function()
	  util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
      end)
  ))


  volumepixmap       = capi.widget({ type = "imagebox", align = "right" })
  volumepixmap.image = capi.image(config.data.iconPath .. "vol.png")
  volumepixmap:buttons( util.table.join(
      button({ }, 1, function()
          data.wibox.visible = not data.wibox.visible
	  --mywibox3.visible = not mywibox3.visible
	  volumepixmap.visible = not volumepixmap.visible 
	  volumewidget.visible = not volumewidget.visible 
      end),
      button({ }, 4, function()
	  util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
      end),
      button({ }, 5, function()
	  util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
      end)
  ))

  
  volumepixmap:buttons( util.table.join(button({ }, 1, function ()
      data.wibox.visible = true
  end)))


  vicious.register(volumewidget, amixer_volume_int, '$1%  | ')
  return {pix = volumepixmap, wid = volumewidget}
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
