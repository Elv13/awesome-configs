local setmetatable = setmetatable
local table = table
local io = io
local os  = os
local type = type
local print = print
local string = string
local button = require("awful.button")
local wibox = require("wibox")
local beautiful = require("beautiful")
local util = require("awful.util")
local config = require("forgotten")
local vicious = require("extern.vicious")
local surface = require("gears.surface")
local desktopGrid = require("widgets.layout.desktopLayout")
local capi = { image = image,
               widget = widget}
local widget = require("awful.widget")

local module={}

local data = {}
local devices = {}
local ej,ejo,hddicn,hddnicn,homeicn

local function new(screen, args) 
  add_device("/dev/root,"..os.getenv("HOME"))
  local deviceList = io.popen("/bin/mount | grep -E \"/dev/(root|sd[a-z])\" | awk '{print $1\",\"$3}'")
  if deviceList then
    local line = deviceList:read("*line")
    while line do
        add_device(line, "hdd")
        line = deviceList:read("*line")
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
  mywibox19:set_bg("#00000000")
  mywibox19.visible = true

--   wibox.rounded_corners(mywibox19,1)

  local relY = 50 + 100 * (#devices)

  mywibox19:geometry({ width = 230, height = 52, x =10, y = 99})
  desktopGrid.addWidget(mywibox19,{type="wibox",screen = 1, onclick = function() util.spawn("dolphin "..mountPoint) end})
  --mywibox19.free = true
  --awful.wibox.set_free(mywibox19,true)

  mywibox19.bg = "#ff000000"

  local iconTest = wibox.widget.imagebox()

  if devType == "hdd" then
    if not hddnicn then
        hddicn = surface.load(config.iconPath .. "hdd.png")
    end
    iconTest:set_image(hddicn)
  elseif devType == "net" then
    if not hddnicn then
        hddnicn = surface.load(config.iconPath .. "hddn.png")
    end
    iconTest.image = hddnicn
  elseif devType == "home" then
    if not homeicn then
        homeicn = surface.load(config.iconPath .. "home.png")
    end
    iconTest.image = homeicn
  end


  local iconTest1 = wibox.widget.imagebox()
  if not ej then
      ej = surface.load(config.iconPath .. "tags/eject.png")
  end

  iconTest1.image = ej

  iconTest1:add_signal("mouse::enter", function ()
    if not ejo then
        ejo = surface.load(config.iconPath .. "tags/eject_over.png")
    end
    iconTest1.image = ejo
  end)

  iconTest1:add_signal("mouse::leave", function ()
    iconTest1.image = ej
  end)

  local volSpacer = wibox.widget.textbox()
  volSpacer:set_text("   ")

  local volName = wibox.widget.textbox()
  volName:set_text(mountPoint)
  vicious.register(volName, vicious.widgets.fs,mountPoint..' (${'..mountPoint..' size_gb} GB)',3600)

  local volName3 = wibox.widget.textbox()
  volName3:set_markup("<b>Used:</b> 83gb (76%)")
  vicious.register(volName3, vicious.widgets.fs,'<b>Used:</b> ${'..mountPoint..' used_gb}GB (${'..mountPoint..' used_p}%)',900)

  ----vicious.register(volName3, vicious.widgets.fs, "<b>Used:</b> ${".. mountPoint .." used}gb", 599, true)

  local volName4 = wibox.widget.textbox()
  volName4:set_markup("<b>Avail:</b> 17gb (14%)")
  vicious.register(volName4, vicious.widgets.fs,'<b>Avail:</b> ${'..mountPoint..' avail_gb}GB (${'..mountPoint..' avail_p}%)',900)

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
 vicious.register(volUsage, vicious.widgets.dio, "${".. deviceName .." total_kb}",900)

  volfill = widget.progressbar({})
  volfill:set_vertical(true)
  volfill:set_width(10)
  volfill:set_height(50)
--   volfill:set_bg_image(surface.load(config.iconPath .. "bg/progressbar.png"))
  if (widget.progressbar.set_offset ~= nil) then
    volfill:set_offset(1)
  end
  volfill:set_background_color(beautiful.bg_normal)
  volfill:set_border_color(beautiful.fg_normal)
  volfill:set_color(beautiful.fg_normal)
  volfill:set_value(50)

  vicious.register(volfill, vicious.widgets.fs,'${'..mountPoint..' used_p}',900)

--   mywibox19.widgets = {
--     iconTest,
--     volfill.widget,
--     volSpacer,
--     layout = widget.layout.horizontal.leftrightcached,
--     {
--       iconTest1,
--       layout = widget.layout.horizontal.rightleftcached,
--     },
--     {
--       volName,
--       volName3,
--       volName4,
--       volUsage.widget,
--       layout = widget.layout.vertical.flexcached
--     },
--   }
  local l_align = wibox.layout.align.horizontal()
  local l,l3 = wibox.layout.fixed.horizontal(),wibox.layout.flex.vertical()
  l:add(iconTest)
  l:add(volfill)
  l:add(volSpacer)
  l3:add(volName)
  l3:add(volName3)
  l3:add(volName4)
  l3:add(volUsage)
  l_align:set_left(l)
  l_align:set_right(iconTest1)
  l_align:set_middle(l3)
  mywibox19:set_widget(l_align)
  mywibox19:connect_signal("mouse::enter", function() mywibox19.bg = beautiful.fg_normal.."25" end)
  mywibox19:connect_signal("mouse::leave", function() mywibox19.bg = "#00000000";iconTest1.image = ej end)
  devices[#devices+1] = mywibox19
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
