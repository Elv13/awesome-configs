local setmetatable = setmetatable
local table = table
local io = io
local print = print
local string = string
local button = require("awful.button")
local wibox = require("awful.wibox")
local beautiful = require("beautiful")
local util = require("awful.util")
local config = require("config")
local vicious = require("extern.vicious")
local desktopGrid = require("widgets.layout.desktopLayout")
local capi = { image = image,
               widget = widget}
local widget = require("awful.widget")

module("widgets.devices")

local data = {}
local devices = {}

function update()

end

function new(screen, args) 
  add_device("/dev/root,/home/lepagee")
  local deviceList = io.popen("/bin/mount | grep -E \"/dev/(root|sd[a-z])\" | awk '{print $1\",\"$3}'")
  if deviceList then
    while true do
        local line = deviceList:read("*line")
        if line == nil then break end
        add_device(line, "hdd")
    end 
  end
end

function add_device(args)
  --args2 = args:split(",")
  local devType
  local pos = string.find(args,",") or 1
  local mountPoint = string.sub(args,pos+1) --args2[2] or ""
  local deviceNode = string.sub(args,1,pos-1) --args2[1] or ""
  
  if string.sub(deviceNode,0,2) == "//" then
    devType = "net"
  elseif string.sub(mountPoint,1,5) == "/home" then
    devType = "home"
  else
    devType = "hdd"
  end
  
  
  local mywibox19 = wibox({ position = "free", screen = s})
  
  mywibox19:add_signal("mouse::enter", function() mywibox19.bg = beautiful.fg_normal.."25" end)
  mywibox19:add_signal("mouse::leave", function() mywibox19.bg = "#00000000" end)
  
  --awful.wibox.rounded_corners(mywibox19,1)
  
  local relY = 50 + 100 * (#devices)
  
  mywibox19:geometry({ width = 230, height = 52, x =10, y = 99})
  desktopGrid.addWidget(mywibox19,{screen = 1, onclick = function() util.spawn("dolphin "..mountPoint) end})
  --mywibox19.free = true
  --awful.wibox.set_free(mywibox19,true)
  
  mywibox19.bg = "#ff000000"
  
  local iconTest = capi.widget({ type = "imagebox"})
  
  if devType == "hdd" then
    iconTest.image = capi.image(config.data().iconPath .. "hdd.png")
  elseif devType == "net" then
    iconTest.image = capi.image(config.data().iconPath .. "hddn.png")
  elseif devType == "home" then
    iconTest.image = capi.image(config.data().iconPath .. "home.png")
  end
  
  
  local iconTest1 = capi.widget({ type = "imagebox"})
  iconTest1.image = capi.image(config.data().iconPath .. "tags/eject.png")
  
  iconTest1:add_signal("mouse::enter", function ()
    iconTest1.image = capi.image(config.data().iconPath .. "tags/eject_over.png")
  end)

  iconTest1:add_signal("mouse::leave", function ()
    iconTest1.image = capi.image(config.data().iconPath .. "tags/eject.png")
  end)
  
  local volSpacer = capi.widget({ type = "textbox" })
  volSpacer.text = "   "
  
  local volName = capi.widget({ type = "textbox" })
  volName.text = mountPoint
  vicious.register(volName, vicious.widgets.fs,mountPoint..' (${'..mountPoint..' size_gb} GB)')
  
  local volName2 = capi.widget({ type = "textbox" })
  volName2.text = "<b>Cap:</b> 100gb"
  
  ----vicious.register(volName2, vicious.widgets.fs, "<b>Cap:</b> ${".. mountPoint.." size}gb", 599, true)
  
  local volName3 = capi.widget({ type = "textbox" })
  volName3.text = "<b>Used:</b> 83gb (76%)"
  vicious.register(volName3, vicious.widgets.fs,'<b>Used:</b> ${'..mountPoint..' used_gb}GB (${'..mountPoint..' used_p}%)')
  
  ----vicious.register(volName3, vicious.widgets.fs, "<b>Used:</b> ${".. mountPoint .." used}gb", 599, true)
  
  local volName4 = capi.widget({ type = "textbox" })
  volName4.text = "<b>Avail:</b> 17gb (14%)"
  vicious.register(volName4, vicious.widgets.fs,'<b>Avail:</b> ${'..mountPoint..' avail_gb}GB (${'..mountPoint..' avail_p}%)')
  
  ----vicious.register(volName4, vicious.widgets.fs, "<b>Avail:</b> ${".. mountPoint .." avail}gb", 599, true)
  
  local volUsage = widget.graph()
  volUsage:set_width(130)
  volUsage:set_height(10)
  volUsage:set_scale(true)
  volUsage:set_background_color(beautiful.bg_normal)
  volUsage:set_border_color(beautiful.fg_normal)
  volUsage:set_color(beautiful.fg_normal)
  
  local deviceName = string.sub(deviceNode,6,-2) or "sda"
--   vicious.register(volUsage, vicious.widgets.dio, "${total_kb}", 1, "sdc/sdc1")
 vicious.register(volUsage, vicious.widgets.dio, "${".. deviceName .." total_kb}")
  
  volfill = widget.progressbar()
  volfill:set_vertical(true)
  volfill:set_width(10)
  volfill:set_height(50)
  if (widget.progressbar.set_offset ~= nil) then
    volfill:set_offset(1)
  end
  volfill:set_background_color(beautiful.bg_normal)
  volfill:set_border_color(beautiful.fg_normal)
  volfill:set_color(beautiful.fg_normal)
  volfill:set_value(50)
  
  vicious.register(volfill, vicious.widgets.fs,'${'..mountPoint..' used_p}')
  
  mywibox19.widgets = {
    iconTest,
    volfill,
    volSpacer,
    layout = widget.layout.horizontal.leftright,
    {
      iconTest1,
      layout = widget.layout.horizontal.rightleft,
    },
    {
      volName,
      volName3,
      volName4,
      volUsage,
      layout = widget.layout.vertical.flex
    },
  }
  
  table.insert(devices, mywibox19)
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
