local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local naughty = require("naughty")
local widget2 = require("awful.widget")
local wibox = require("awful.wibox")
local vicious = require("vicious")
local tag = require("awful.tag")
local util = require("awful.util")
local shifty = require("shifty")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("drawer.netInfo")

local data = {}

function update()

end

local function createDrawer() 
  local f = io.popen('ifconfig | grep -e "inet addr:[0-9.]*" -o |  grep -e "[0-9.]*" -o')
  local text2 = "<b><u>IP Addresses:</u></b>\n"
  text2 = text2 .. "<i><b>  v4: </b>" .. f:read() .. "</i>"
  f:close()
  f = io.popen('ifconfig | grep -e "inet6 addr: [0-9.A-Fa-f;:]*" -o | cut -f3 -d " "')
  text2 =  text2 .. "\n<i><b>  v6: </b>" .. f:read() .. "</i>\n\n"
  f:close()
  f = io.open('/tmp/localNetLookup','r')
  text2 = text2 .. "<b><u>Local Network:</u></b>\n"
  text2 = text2 .. f:read("*all")
  f:close()
  f = io.open('/tmp/connectedHost','r')
  text2 = text2 .. "<b><u>Open Connections:</u></b>\n"
  text2 = text2 .. f:read("*all")
  f:close()

  local mainText = capi.widget({type = "textbox"})
  mainText.text = text2
	      
  local uploadImg = capi.widget({ type = "imagebox"})
  uploadImg.image = capi.image(util.getdir("config") .. "/Icon/arrowUp.png")
  uploadImg.resize = false
  
  local downloadImg = capi.widget({ type = "imagebox"})
  downloadImg.image = capi.image(util.getdir("config") .. "/Icon/arrowDown.png")
  downloadImg.resize = false
  
  local netUsageUp = capi.widget({ type = "textbox" })
  netUsageUp.text = "<b>Up: </b>"
  
  local netSpacer1 = capi.widget({ type = "textbox" })
  netSpacer1.text = " "
  netSpacer1.width = 10
  
  local netUsageDown = capi.widget({ type = "textbox" })
  netUsageDown.text = "<b>Down: </b>"
  
  
  local netSpacer3 = capi.widget({ type = "textbox" })
  netSpacer3.text = "  "
  
  local netSpacer2 = capi.widget({ type = "textbox" })
  netSpacer2.text = " "
  netSpacer2.width = 10

  local netUpGraph = widget2.graph()
  netUpGraph:set_width(60)
  netUpGraph:set_height(25)
  netUpGraph:set_scale(true)
  netUpGraph:set_background_color(beautiful.bg_normal)
  netUpGraph:set_border_color(beautiful.fg_normal)
  netUpGraph:set_color(beautiful.fg_normal)
  vicious.register(netUpGraph, vicious.widgets.net, '${eth0 up_kb}',1)
  
  local netDownGraph = widget2.graph()
  netDownGraph:set_width(60)
  netDownGraph:set_height(25)
  netDownGraph:set_scale(true)
  netDownGraph:set_background_color(beautiful.bg_normal)
  netDownGraph:set_border_color(beautiful.fg_normal)
  netDownGraph:set_color(beautiful.fg_normal)
  vicious.register(netDownGraph, vicious.widgets.net, '${eth0 down_kb}',1)
  
  data.wibox.widgets = {
	mainText,
	{
	  downloadImg,
	  netUsageDown,
	  netDownGraph,
	  netSpacer2,
	  uploadImg,
	  netUsageUp,
	  netUpGraph,
	  layout = widget2.layout.horizontal.leftright
	},
	
	layout = widget2.layout.vertical.topbottom
  }
  
  --netWorkWibox.box.height = netWorkWibox.box.height + 25
  
  return mainText:extents().height + 25
end

function new(screen, args)
  local netWorkWibox
  local netInfo = {}
  
  data.wibox = wibox({ position = "free", screen = capi.screen.count() })
  data.wibox.ontop = true
  data.wibox.visible = false
  local height = createDrawer() 
  data.wibox:geometry({ width = 240, height = height, x = capi.screen[capi.screen.count()].geometry.width - 240, y = 24})

  downlogo       = capi.widget({ type = "imagebox", align = "right" })
  downlogo.image = capi.image(util.getdir("config") .. "/Icon/arrowDown.png")

  downlogo:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  downlogo:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)

  netDownWidget = capi.widget({
      type = 'textbox',
      name = 'netwidget',
      align = "right"
  })

  netDownWidget.width = 55

  vicious.register(netDownWidget, vicious.widgets.net, '${eth0 down_kb}KBs',1) --Interval, ?, decimal

  netDownWidget:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  netDownWidget:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)

  uplogo       = capi.widget({ type = "imagebox", align = "right" })
  uplogo.image = capi.image(util.getdir("config") .. "/Icon/arrowUp.png")

  uplogo:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  uplogo:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)

  netUpWidget = capi.widget({
      type = 'textbox',
      name = 'netwidget',
      align = "right"
  })
  netUpWidget.width = 55

  vicious.register(netUpWidget, vicious.widgets.net, '${eth0 up_kb}KBs',1)

  netUpWidget:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  netUpWidget:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)
  
  return {down_logo = downlogo, down_text = netDownWidget, up_logo = uplogo, up_text = netUpWidget}
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
