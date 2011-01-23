local devices = {}
local rectLauncher = {}
local rectLauncherWdg = {}

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
  
  
  local mywibox19 = awful.wibox({ position = "free", screen = s})
  
  mywibox19:add_signal("mouse::enter", function() mywibox19.bg = beautiful.fg_normal.."25" end)
  mywibox19:add_signal("mouse::leave", function() mywibox19.bg = "#00000000" end)
  
  --awful.wibox.rounded_corners(mywibox19,1)
  
  local relY = 50 + 100 * (#devices)
  
  mywibox19:geometry({ width = 230, height = 52, x =10, y = relY})
  --mywibox19.free = true
  --awful.wibox.set_free(mywibox19,true)
  
  mywibox19.bg = "#ff000000"
  
  local iconTest = widget({ type = "imagebox"})
  
  if devType == "hdd" then
    iconTest.image = image(awful.util.getdir("config") .. "/Icon/hdd.png")
  elseif devType == "net" then
    iconTest.image = image(awful.util.getdir("config") .. "/Icon/hddn.png")
  elseif devType == "home" then
    iconTest.image = image(awful.util.getdir("config") .. "/Icon/home.png")
  end
  
  iconTest:buttons( awful.util.table.join(
    awful.button({ }, 1, function()
        awful.util.spawn("dolphin "..mountPoint) 
    end)
  ))
  
  
  local iconTest1 = widget({ type = "imagebox"})
  iconTest1.image = image(awful.util.getdir("config") .. "/Icon/tags/eject.png")
  
  iconTest1:add_signal("mouse::enter", function ()
    iconTest1.image = image(awful.util.getdir("config") .. "/Icon/tags/eject_over.png")
  end)

  iconTest1:add_signal("mouse::leave", function ()
    iconTest1.image = image(awful.util.getdir("config") .. "/Icon/tags/eject.png")
  end)
  
  local volSpacer = widget({ type = "textbox" })
  volSpacer.text = "   "
  
  local volName = widget({ type = "textbox" })
  volName.text = mountPoint
  vicious.register(volName, vicious.widgets.fs,mountPoint..' (${'..mountPoint..' size_gb}GB)')
  
  local volName2 = widget({ type = "textbox" })
  volName2.text = "<b>Cap:</b> 100gb"
  
  ----vicious.register(volName2, vicious.widgets.fs, "<b>Cap:</b> ${".. mountPoint.." size}gb", 599, true)
  
  local volName3 = widget({ type = "textbox" })
  volName3.text = "<b>Used:</b> 83gb (76%)"
  vicious.register(volName3, vicious.widgets.fs,'<b>Used:</b> ${'..mountPoint..' used_gb}GB (${'..mountPoint..' used_p}%)')
  
  ----vicious.register(volName3, vicious.widgets.fs, "<b>Used:</b> ${".. mountPoint .." used}gb", 599, true)
  
  local volName4 = widget({ type = "textbox" })
  volName4.text = "<b>Avail:</b> 17gb (14%)"
  vicious.register(volName4, vicious.widgets.fs,'<b>Avail:</b> ${'..mountPoint..' avail_gb}GB (${'..mountPoint..' avail_p}%)')
  
  ----vicious.register(volName4, vicious.widgets.fs, "<b>Avail:</b> ${".. mountPoint .." avail}gb", 599, true)
  
  local volUsage = awful.widget.graph()
  volUsage:set_width(130)
  volUsage:set_height(10)
  volUsage:set_scale(true)
  volUsage:set_background_color("#000000"--[[beautiful.bg_normal]])
  volUsage:set_border_color(beautiful.fg_normal)
  volUsage:set_color(beautiful.fg_normal)
  
  local deviceName = string.sub(deviceNode,5) or "sda"
  --vicious.register(volUsage, vicious.widgets.dio, "${total_kb}", 1, "sdc/sdc1")
 -- --vicious.register(volUsage, vicious.widgets.dio, "${total_kb}", 1, deviceNode)
  
  volfill = awful.widget.progressbar()
  volfill:set_vertical(true)
  volfill:set_width(10)
  volfill:set_height(50)
  if (awful.widget.progressbar.set_offset ~= nil) then
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
    layout = awful.widget.layout.horizontal.leftright,
    {
      iconTest1,
      layout = awful.widget.layout.horizontal.rightleft,
    },
    {
      volName,
      volName3,
      volName4,
      volUsage,
      layout = awful.widget.layout.vertical.flex
    },
  }
  
  table.insert(devices, mywibox19)
end


function setupRectLauncher(column, arg) 
  
  if rectLauncherWdg[column] == nil then
    rectLauncherWdg[column] = { layout = awful.widget.layout.horizontal.leftright }
  end
  
  newLauncher = widget({ type = "imagebox"})
  newLauncher.image = image(arg[1])
  
  table.insert(rectLauncherWdg[column], newLauncher)
  
end

function loadRectLauncher(s2)
  for i, column in ipairs(rectLauncherWdg) do
    local aWibox = awful.wibox({ position = "free", screen = s})
    local relX = -25 --screen[1].geometry.x -500
    for j =1, screen.count() - s2 +2 do
      relX = relX + screen[j].geometry.width
    end
    relX = relX - 250
    local relY = screen[1].geometry.height - 25 - 400
    aWibox:geometry({ width = 250, height = 400, x =relX - (260 *(i-1)), y = relY})
    aWibox.bg = "#ff000000"
    aWibox.widgets = column
  end
end

function loadMonitor(screen2)

  local xPos = 0
  for s = 1, screen2 or screen.count() do
    if s < screen.count() then
      xPos = xPos + screen[s].geometry.width
    end
  end
  xPos = xPos - 415

  local aWibox = awful.wibox({ position = "free", screen = s})
  aWibox:geometry({ width = 400, height = 200, x = xPos, y = 40})
  --aWibox:rounded_corners(10)
  awful.wibox.rounded_corners(aWibox,10)
  aWibox.bg = "#0A1535AA"
  
  local systemWdg = widget({ type = "textbox" })
  systemWdg.text = "  <b><u>System:</u></b>"
  
  local upTime = widget({ type = "textbox" })
  upTime.text = "  uptime: 12d 23:32"
  
  vicious.register(upTime, vicious.widgets.uptime,'  uptime: $2d $3h $4m $5s',1)
  
  local load = widget({ type = "textbox" })
  load.text = ", load: 0.032, 0.453, 0.123"
  
  --vicious.register(load, vicious.widgets.load,', load: $1 $2 $3')//TODO restore
  
  local cpuUsage = widget({ type = "textbox" })
  cpuUsage.text = "  CPU usage: 30% "
  cpuUsage.width = 110
  
  vicious.register(cpuUsage, vicious.widgets.cpu,'  CPU usage: $1%')
  
  local cpuBar = awful.widget.graph()
  cpuBar:set_width(287)
  cpuBar:set_height(18)
--   cpuBar:set_max_value(100)
--   cpuBar:set_scale(false)
  cpuBar:set_background_color(beautiful.bg_normal)
  cpuBar:set_border_color(beautiful.fg_normal)
  cpuBar:set_color(beautiful.fg_normal)
  
  if (awful.widget.graph.set_offset ~= nil) then
    cpuBar:set_offset(1)
  end
  
  --vicious.register(cpuBar, vicious.widgets.cpu, '$1', 1, 'cpu')
  vicious.register(cpuBar, vicious.widgets.cpu,'$1',1)
  
  
  local sectionSpacer2 = widget({ type = "textbox" })
  sectionSpacer2.text = "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  
  local netWdg = widget({ type = "textbox" })
  netWdg.text = "  <b><u>Networking:</u></b>"
  
  local uploadImg = widget({ type = "imagebox"})
  uploadImg.image = image(awful.util.getdir("config") .. "/Icon/arrowUp.png")
  
  local downloadImg = widget({ type = "imagebox"})
  downloadImg.image = image(awful.util.getdir("config") .. "/Icon/arrowDown.png")
  
  local netUsageUp = widget({ type = "textbox" })
  netUsageUp.text = "Upload: 10kbs"
  netUsageUp.width = 190
  
  vicious.register(netUsageUp, vicious.widgets.net, 'Upload: ${eth0 up_kb}KBs',1)
  
  local netSpacer1 = widget({ type = "textbox" })
  netSpacer1.text = " "
  netSpacer1.width = 10
  
  local netUsageDown = widget({ type = "textbox" })
  netUsageDown.text = "Download: 10kbs"
  netUsageDown.width = 190
  
  vicious.register(netUsageDown, vicious.widgets.net, 'Download: ${eth0 down_kb}KBs',1)
  
  local netSpacer3 = widget({ type = "textbox" })
  netSpacer3.text = "  "
  
  local netUpGraph = awful.widget.graph()
  netUpGraph:set_width(190)
  netUpGraph:set_height(25)
  --netUpGraph:set_scale(true)
  netUpGraph:set_background_color(beautiful.bg_normal)
  netUpGraph:set_border_color(beautiful.fg_normal)
  netUpGraph:set_color(beautiful.fg_normal)
  if (awful.widget.graph.set_offset ~= nil) then
    netUpGraph:set_offset(1)
  end
  
  vicious.register(netUpGraph, vicious.widgets.net, '${eth0 up_kb}',1)
  
  local netSpacer2 = widget({ type = "textbox" })
  netSpacer2.text = " "
  netSpacer2.width = 10
  
  local netDownGraph = awful.widget.graph()
  netDownGraph:set_width(190)
  netDownGraph:set_height(25)
  netDownGraph:set_scale(true)
  netDownGraph:set_background_color(beautiful.bg_normal)
  netDownGraph:set_border_color(beautiful.fg_normal)
  netDownGraph:set_color(beautiful.fg_normal)
  if (awful.widget.graph.set_offset ~= nil) then
    netDownGraph:set_offset(1)
  end
  
  vicious.register(netDownGraph, vicious.widgets.net, '${eth0 down_kb}',1)
  
  local strangeSpacer = widget({ type = "textbox" })
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
  
  local sectionSpacer = widget({ type = "textbox" })
  sectionSpacer.text = "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
  
  local diskWdg = widget({ type = "textbox" })
  diskWdg.text = "  <b><u>Disk:</u></b>"
  
  local diskUsageUp = widget({ type = "textbox" })
  diskUsageUp.text = "I\O Read: 10kbs"
  diskUsageUp.width = 190
  
--  vicious.register(diskUsageUp, vicious.widgets.dio, "I/O Read: ${read_kb}kbs", 1, "sdb")
  
  local diskSpacer1 = widget({ type = "textbox" })
  diskSpacer1.text = " "
  diskSpacer1.width = 10
  
  local diskUsageDown = widget({ type = "textbox" })
  diskUsageDown.text = "I\O Write: 10kbs"
  diskUsageDown.width = 190
  
--  vicious.register(diskUsageDown, vicious.widgets.dio, "I/O Write: ${write_kb}kbs", 1, "sdb")
  
  local diskSpacer3 = widget({ type = "textbox" })
  diskSpacer3.text = "  "
  
  local diskUpGraph = awful.widget.graph()
  diskUpGraph:set_width(190)
  diskUpGraph:set_height(25)
  diskUpGraph:set_scale(true)
  diskUpGraph:set_background_color(beautiful.bg_normal)
  diskUpGraph:set_border_color(beautiful.fg_normal)
  diskUpGraph:set_color(beautiful.fg_normal)
  if (awful.widget.graph.set_offset ~= nil) then
    diskUpGraph:set_offset(1)
  end
  
--  vicious.register(diskUpGraph, vicious.widgets.dio, "${read_kb}", 1, "sdb")
  
  local diskSpacer2 = widget({ type = "textbox" })
  diskSpacer2.text = " "
  diskSpacer2.width = 10
  
  local diskDownGraph = awful.widget.graph()
  diskDownGraph:set_width(190)
  diskDownGraph:set_height(25)
  diskDownGraph:set_scale(true)
  diskDownGraph:set_background_color(beautiful.bg_normal)
  diskDownGraph:set_border_color(beautiful.fg_normal)
  diskDownGraph:set_color(beautiful.fg_normal)
  if (awful.widget.graph.set_offset ~= nil) then
    diskDownGraph:set_offset(1)
  end
  
--  vicious.register(diskDownGraph, vicious.widgets.dio, "${write_kb}", 1, "sdb")
  
  local bottomSpacer = widget({ type = "textbox" })
  bottomSpacer.text = " "
  bottomSpacer.width = 10
  
  aWibox.widgets = {
    systemWdg,
    {
      upTime,
      load,
      layout = awful.widget.layout.horizontal.leftright
    },
    {
      cpuUsage,
      cpuBar,
      layout = awful.widget.layout.horizontal.leftright
    },
    sectionSpacer2,
    netWdg,
    {
      diskSpacer3,
      downloadImg,
      netUsageDown,
      uploadImg,
      netUsageUp,
      layout = awful.widget.layout.horizontal.leftright
    },
    {
      netSpacer3,
      netDownGraph,
      netSpacer2,
      netUpGraph,
      layout = awful.widget.layout.horizontal.leftright
    },
    strangeSpacer,
    serverWdg,
    --gatewaySrv,
    --webSrv,
    --fileSrv,
    --mediaSrv,
    --vmSrv,
    sectionSpacer,
    diskWdg,
    {
      diskSpacer3,
      downloadImg,
      diskUsageDown,
      uploadImg,
      diskUsageUp,
      layout = awful.widget.layout.horizontal.leftright
    },
    {
      diskSpacer3,
      diskDownGraph,
      diskSpacer2,
      diskUpGraph,
      layout = awful.widget.layout.horizontal.leftright
    },
    bottomSpacer,
    layout = awful.widget.layout.vertical.flex,
  }
end
