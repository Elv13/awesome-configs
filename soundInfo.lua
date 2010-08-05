local setmetatable = setmetatable
local tonumber = tonumber
local ipairs = ipairs
local table = table
local io = io
local util = require("awful.util")
local button = require("awful.button")
local vicious = require("vicious")
local tag = require("awful.tag")
local util = require("awful.util")
local naughty = require("naughty")
--local shifty = require("shifty")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       		tag = tag}

module("soundInfo")

local data = {}
local alsaInfo = {}

function update()

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
  local f = io.popen('/home/lepagee/Scripts/alsaInfo.sh')
  local text2 = f:read("*all")
  f:close()
  alsaInfo = { month, year, 
	      naughty.notify({
		  text = text2,
		  timeout = 0, hover_timeout = 0.5,
		  width = 140, screen = capi.mouse.screen
	      })
	    }
end
  
function new(screen, args)


  volumewidget = capi.widget({
      type = 'textbox',
      name = 'volumewidget',
      align='right'
  })

  --volumewidget.mouse_enter = function () soundInfo() end

  volumewidget:add_signal("mouse::enter", function ()
      soundInfo()
  end)

  volumewidget:add_signal("mouse::leave", function ()
    naughty.destroy(alsaInfo[3])
  end)

  --volumewidget.mouse_leave = function () naughty.destroy(alsaInfo[3]) end

  volumewidget:buttons( util.table.join(
     button({ }, 1, function()
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
  volumepixmap.image = capi.image("/home/lepagee/Icon/vol.png")
  volumepixmap:buttons( util.table.join(
      button({ }, 1, function()
	  mywibox3.visible = not mywibox3.visible
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

  -- volumepixmap.mouse_enter = function () soundInfo() end
  -- volumepixmap.mouse_leave = function () naughty.destroy(alsaInfo[3]) end

  volumepixmap:add_signal("mouse::enter", function ()
      soundInfo()
  end)

  volumepixmap:add_signal("mouse::leave", function ()
    naughty.destroy(alsaInfo[3])
  end)


  vicious.register(volumewidget, amixer_volume_int, '$1%  | ')
  return {pix = volumepixmap, wid = volumewidget}
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
