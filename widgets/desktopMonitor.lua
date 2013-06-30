local setmetatable = setmetatable
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local tag = require("awful.tag")
local util = require("awful.util")
local config = require("forgotten")
local vicious = require("extern.vicious")
local desktopGrid = require("widgets.layout.desktopLayout")
local capi = { image = image,
               widget = widget,
               screen = screen}
local widget = require("awful.widget")

local module={}

local function new(screen2, args) 
  
  local xPos = 0
  for s = 1, screen2 or capi.screen.count() do
    if s <= capi.screen.count() then
      xPos = xPos + capi.screen[s].geometry.width
    end
  end
  xPos = xPos - 415

  local aWibox = wibox({ position = "free", screen = s, bg = beautiful.menu_bg or beautiful.bg_normal.."AA"})
  aWibox.visible = true
  aWibox:geometry({ width = 400, height = 200, x = xPos, y = 40})
  desktopGrid.addCornerWidget(aWibox,config.scr.sec or config.scr.pri,nil,{type = "wibox"})
  --aWibox:rounded_corners(10)
--   wibox.rounded_corners(aWibox,10)
  
  local systemWdg = wibox.widget.textbox()
  systemWdg.text = "  <b><u>System:</u></b>"
  
  local upTime = wibox.widget.textbox()
  upTime.text = "  uptime: 12d 23:32"
  
  vicious.register(upTime, vicious.widgets.uptime,'  uptime: $2d $3h $4m $5s',1)
  
  local load = wibox.widget.textbox()
  load.text = ", load: 0.032, 0.453, 0.123"
  
  --vicious.register(load, vicious.widgets.load,', load: $1 $2 $3')//TODO restore
  
  local cpuUsage = wibox.widget.textbox()
  cpuUsage.text = "  CPU usage: 30% "
  cpuUsage.width = 110
  
  vicious.register(cpuUsage, vicious.widgets.cpu,'  CPU usage: $1%')
  
  local cpuBar = widget.graph()
  cpuBar:set_width(287)
  cpuBar:set_height(18)
--   cpuBar:set_max_value(100)
--   cpuBar:set_scale(false)
  cpuBar:set_background_color(beautiful.bg_normal)
  cpuBar:set_border_color(beautiful.fg_normal)
  cpuBar:set_color(beautiful.fg_normal)
  
  if (widget.graph.set_offset ~= nil) then
    cpuBar:set_offset(1)
  end
  
  --vicious.register(cpuBar, vicious.widgets.cpu, '$1', 1, 'cpu')
  vicious.register(cpuBar, vicious.widgets.cpu,'$1',1)
  
  
  local sectionSpacer2 = wibox.widget.textbox()
  sectionSpacer2.text = "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  
  local netWdg = wibox.widget.textbox()
  netWdg:set_markup("  <b><u>Networking:</u></b>")
  
  local uploadImg = wibox.widget.imagebox()
  uploadImg:set_image(config.iconPath .. "arrowUp.png")
  
  local downloadImg = wibox.widget.imagebox()
  downloadImg:set_image(config.iconPath .. "arrowDown.png")
  
  local netUsageUp = wibox.widget.textbox()
  netUsageUp.text = "Upload: 10kbs"
  netUsageUp.width = 190
  
  vicious.register(netUsageUp, vicious.widgets.net, 'Upload: ${eth0 up_kb}KBs',1)
  
  local netSpacer1 = wibox.widget.textbox()
  netSpacer1.text = " "
  netSpacer1.width = 10
  
  local netUsageDown = wibox.widget.textbox()
  netUsageDown.text = "Download: 10kbs"
  netUsageDown.width = 190
  
  vicious.register(netUsageDown, vicious.widgets.net, 'Download: ${eth0 down_kb}KBs',1)
  
  local netSpacer3 = wibox.widget.textbox()
  netSpacer3.text = "  "
  
  local netUpGraph = widget.graph()
  netUpGraph:set_width(190)
  netUpGraph:set_height(25)
  --netUpGraph:set_scale(true)
  netUpGraph:set_background_color(beautiful.bg_normal)
  netUpGraph:set_border_color(beautiful.fg_normal)
  netUpGraph:set_color(beautiful.fg_normal)
  if (widget.graph.set_offset ~= nil) then
    netUpGraph:set_offset(1)
  end
  
  vicious.register(netUpGraph, vicious.widgets.net, '${eth0 up_kb}',1)
  
  local netSpacer2 = wibox.widget.textbox()
  netSpacer2.text = " "
  netSpacer2.width = 10
  
  local netDownGraph = widget.graph()
  netDownGraph:set_width(190)
  netDownGraph:set_height(25)
  netDownGraph:set_scale(true)
  netDownGraph:set_background_color(beautiful.bg_normal)
  netDownGraph:set_border_color(beautiful.fg_normal)
  netDownGraph:set_color(beautiful.fg_normal)
  if (widget.graph.set_offset ~= nil) then
    netDownGraph:set_offset(1)
  end
  
  vicious.register(netDownGraph, vicious.widgets.net, '${eth0 down_kb}',1)
  
  local strangeSpacer = wibox.widget.textbox()
  strangeSpacer.text = " "
  --Fake
--   
--   local serverWdg = widget({ type = "textbox" })
--   serverWdg.text = "  <b>Server:</b>"
--   
--   local gatewaySrv = widget({ type = "textbox" })
--   gatewaySrv.text = "    <u>Gateway:</u> up <i>(uptime: 12d 20h 24m, ip: 192.168.2.1</i>)"
--   
--   local webSrv = widget({ type = "textbox" })
--   webSrv.text = "    <u>LAMP server:</u> up <i>(uptime: 12d 20h 24m, ip: 192.168.2.1</i>)"
--   
--   local fileSrv = widget({ type = "textbox" })
--   fileSrv.text = "    <u>File server:</u> up <i>(uptime: 12d 20h 24m, ip: 192.168.2.1</i>)"
--   
--   local mediaSrv = widget({ type = "textbox" })
--   mediaSrv.text = "    <u>Media server:</u> up <i>(uptime: 12d 20h 24m, ip: 192.168.2.1</i>)"
--   
--   local vmSrv = widget({ type = "textbox" })
--   vmSrv.text = "    <u>VM server:</u> up <i>(uptime: 12d 20h 24m, ip: 192.168.2.1</i>)"
  
  local sectionSpacer = wibox.widget.textbox()
  sectionSpacer.text = "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  
  local diskWdg = wibox.widget.textbox()
  diskWdg.text = "  <b><u>Disk:</u></b>"
  
  local diskUsageUp = wibox.widget.textbox()
  diskUsageUp.text = "I\O Read: 10kbs"
  diskUsageUp.width = 190
  
 vicious.register(diskUsageUp, vicious.widgets.dio, "I/O Read: ${sda read_kb}kbs", 3, "sdb")
  
  local diskSpacer1 = wibox.widget.textbox()
  diskSpacer1.text = " "
  diskSpacer1.width = 10
  
  local diskUsageDown = wibox.widget.textbox()
  diskUsageDown.text = "I\O Write: 10kbs"
  diskUsageDown.width = 190
  
 vicious.register(diskUsageDown, vicious.widgets.dio, "I/O Write: ${sda write_kb}kbs", 3, "sdb")
  
  local diskSpacer3 = wibox.widget.textbox()
  diskSpacer3.text = "  "
  
  local diskUpGraph = widget.graph()
  diskUpGraph:set_width(190)
  diskUpGraph:set_height(25)
  diskUpGraph:set_scale(true)
  diskUpGraph:set_background_color(beautiful.bg_normal)
  diskUpGraph:set_border_color(beautiful.fg_normal)
  diskUpGraph:set_color(beautiful.fg_normal)
  if (widget.graph.set_offset ~= nil) then
    diskUpGraph:set_offset(1)
  end
  
 vicious.register(diskUpGraph, vicious.widgets.dio, "${sda read_kb}", 3, "sdb")
  
  local diskSpacer2 = wibox.widget.textbox()
  diskSpacer2.text = " "
  diskSpacer2.width = 10
  
  local diskDownGraph = widget.graph()
  diskDownGraph:set_width(190)
  diskDownGraph:set_height(25)
  diskDownGraph:set_scale(true)
  diskDownGraph:set_background_color(beautiful.bg_normal)
  diskDownGraph:set_border_color(beautiful.fg_normal)
  diskDownGraph:set_color(beautiful.fg_normal)
  if (widget.graph.set_offset ~= nil) then
    diskDownGraph:set_offset(1)
  end
  
 vicious.register(diskDownGraph, vicious.widgets.dio, "${sda write_kb}", 3, "sdb")
  
  local bottomSpacer = wibox.widget.textbox()
  bottomSpacer.text = " "
  bottomSpacer.width = 10
  
--   aWibox.widgets = {
--     systemWdg,
--     {
--       upTime,
--       load,
--       layout = widget.layout.horizontal.leftrightcached
--     },
--     {
--       cpuUsage,
--       cpuBar.widget,
--       layout = widget.layout.horizontal.leftrightcached
--     },
--     sectionSpacer2,
--     netWdg,
--     {
--       diskSpacer3,
--       downloadImg,
--       netUsageDown,
--       uploadImg,
--       netUsageUp,
--       layout = widget.layout.horizontal.leftrightcached
--     },
--     {
--       netSpacer3,
--       netDownGraph.widget,
--       netSpacer2,
--       netUpGraph.widget,
--       layout = widget.layout.horizontal.leftrightcached
--     },
--     strangeSpacer,
--     serverWdg,
--     --gatewaySrv,
--     --webSrv,
--     --fileSrv,
--     --mediaSrv,
--     --vmSrv,
--     sectionSpacer,
--     diskWdg,
--     {
--       diskSpacer3,
--       downloadImg,
--       diskUsageDown,
--       uploadImg,
--       diskUsageUp,
--       layout = widget.layout.horizontal.leftrightcached
--     },
--     {
--       diskSpacer3,
--       diskDownGraph.widget,
--       diskSpacer2,
--       diskUpGraph.widget,
--       layout = widget.layout.horizontal.leftrightcached
--     },
--     bottomSpacer,
--     layout = widget.layout.vertical.flexcached,
--   }
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
