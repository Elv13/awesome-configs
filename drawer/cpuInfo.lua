local setmetatable = setmetatable
local io = io
local table = table
local button = require("awful.button")
local loadstring = loadstring
local tonumber = tonumber
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local config = require("config")
local vicious = require("vicious")
local util = require("awful.util")
local wibox = require("awful.wibox")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
               timer = timer}

module("drawer.cpuInfo")

local data = {}
local coreWidgets = {}

local cpuInfo = {}

local function updateTable()
  local f = io.open('/tmp/cpuStatistic.lua','r')
  local cpuStat = {}
  if f ~= nil then
    local text3 = f:read("*all")
    text3 = text3.." return cpuInfo"
    f:close()
    local afunction = loadstring(text3)
    if afunction ~= nil then
      cpuStat = afunction() 
      infoNotFound = nil
    else
      infoNotFound = "N/A"
    end
  else
    infoNotFound = "N/A"
  end
  
  if cpuStat == nil then
    infoNotFound = "N/A"
  end
  
  if cpuStat ~= nil and cpuStat["core0"] ~= nil and coreWidgets ~= nil then  
    for i=0 , cpuStat["core"] do --TODO add some way to correct the number of core, it usually fail on load --Solved
      if i <= (coreWidgets["count"] or 1) then
        coreWidgets[i]["core"].text = " <span color='".. beautiful.bg_normal .."'>".."C"..i.."</span> "
        coreWidgets[i]["clock"].text = tonumber(cpuStat["core"..i]["speed"]) /1024 .. "Ghz"
        coreWidgets[i]["temp"].text = cpuStat["core"..i]["temp"]
        coreWidgets[i]["usage"].text = cpuStat["core"..i]["usage"]
        coreWidgets[i]["wait"].text = cpuStat["core"..i]["iowait"]
        coreWidgets[i]["idle"].text = cpuStat["core"..i]["idle"]
      end
    end
  end
end

function createDrawer() 
  local infoHeader = capi.widget({type = "textbox"})
  local cpuModel = capi.widget({type = "textbox"})
  local usageHeader = capi.widget({type = "textbox"})
  local volUsage = widget2.graph()
  local emptyCornerHeader = capi.widget({type = "textbox"})
  local clockHeader = capi.widget({type = "textbox"})
  local tempHeader = capi.widget({type = "textbox"})
  local usageHeader2 = capi.widget({type = "textbox"})
  local iowaitHeader = capi.widget({type = "textbox"})
  local idleHeader = capi.widget({type = "textbox"})

  util.spawn("/bin/bash -c 'while true; do sleep 3 &&"..util.getdir("config") .."/Scripts/cpuInfo2.sh > /tmp/cpuStatistic.lua;done'")
  local cpuStat = {}
  local f = io.open('/tmp/cpuStatistic.lua','r')
  if f ~= nil then
    local text3 = f:read("*all")
    text3 = text3.." return cpuInfo"
    f:close()
    local afunction = loadstring(text3)
    if afunction ~= nil then
      cpuStat = afunction() 
      infoNotFound = nil
    else
      infoNotFound = "N/A"
    end
  else
    infoNotFound = "N/A"
  end
  
  if cpuStat == nil then
    infoNotFound = "N/A"
  end
  
  cpuWidgetArray = {}
  
  infoHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>INFO</tt></b></span> "
  infoHeader.bg = beautiful.fg_normal
  infoHeader.width = 212
  table.insert(cpuWidgetArray, infoHeader)
  
  cpuModel.text = infoNotFound or cpuStat["model"]
  cpuModel.width = 212
  table.insert(cpuWidgetArray, {cpuModel})
  
  usageHeader2.text = " <span color='".. beautiful.bg_normal .."'><b><tt>USAGE</tt></b></span> "
  usageHeader2.bg = beautiful.fg_normal
  usageHeader2.width = 212
  table.insert(cpuWidgetArray, usageHeader2)
  
  volUsage:set_width(212)
  volUsage:set_height(30)
  volUsage:set_scale(true)
  --volUsage:set_background_color(beautiful.bg_normal)
  volUsage:set_border_color(beautiful.fg_normal)
  volUsage:set_color(beautiful.fg_normal)
  vicious.register(volUsage, vicious.widgets.cpu,'$1',1)
  table.insert(cpuWidgetArray, volUsage)
  
  --Table header
  emptyCornerHeader.text = " <span color='".. beautiful.bg_normal .."'>Core</span> "
  emptyCornerHeader.bg = beautiful.fg_normal
  emptyCornerHeader.width = 35
  emptyCornerHeader.border_width = 1
  emptyCornerHeader.border_color = beautiful.bg_normal
  clockHeader.text = " <span color='".. beautiful.bg_normal .."'>Ghz</span> "
  clockHeader.bg = beautiful.fg_normal
  clockHeader.width = 30
  clockHeader.border_width = 1
  clockHeader.border_color = beautiful.bg_normal
  tempHeader.text = " <span color='".. beautiful.bg_normal .."'>Temp</span> "
  tempHeader.bg = beautiful.fg_normal
  tempHeader.width = 40
  tempHeader.border_width = 1
  tempHeader.border_color = beautiful.bg_normal
  usageHeader.text = " <span color='".. beautiful.bg_normal .."'>Used</span> "
  usageHeader.bg = beautiful.fg_normal
  usageHeader.width = 37
  usageHeader.border_width = 1
  usageHeader.border_color = beautiful.bg_normal
  iowaitHeader.text = " <span color='".. beautiful.bg_normal .."'> I/O</span> "
  iowaitHeader.bg = beautiful.fg_normal
  iowaitHeader.width = 35
  iowaitHeader.border_width = 1
  iowaitHeader.border_color = beautiful.bg_normal
  idleHeader.text = " <span color='".. beautiful.bg_normal .."'> Idle</span> "
  idleHeader.bg = beautiful.fg_normal
  idleHeader.width = 35
  idleHeader.border_width = 1
  idleHeader.border_color = beautiful.bg_normal
  table.insert(cpuWidgetArray, {emptyCornerHeader,clockHeader,tempHeader,usageHeader,iowaitHeader,idleHeader, layout = widget2.layout.horizontal.leftright})


  local f2 = io.popen("cat /proc/cpuinfo | grep processor | tail -n1 | grep -e'[0-9]*' -o")
  local coreNb = f2:read("*all") or "0"
  f2:close() 
  coreWidgets["count"] = tonumber(coreNb)
  for i=0 , coreWidgets["count"] do
    coreWidgets[i] = {}
    local aCore = capi.widget({type = "textbox"})
    aCore.text = " <span color='".. beautiful.bg_normal .."'>".."C"..i.."</span> "
    aCore.bg = beautiful.fg_normal
    aCore.width = 35
    coreWidgets[i]["core"] = aCore
    local aCoreClock = capi.widget({type = "textbox"})
    aCoreClock.width = 30
    aCoreClock.border_width = 1
    aCoreClock.border_color = beautiful.fg_normal
    coreWidgets[i]["clock"] = aCoreClock
    local aCoreTemp = capi.widget({type = "textbox"})
    aCoreTemp.width = 40
    aCoreTemp.border_width = 1
    aCoreTemp.border_color = beautiful.fg_normal
    coreWidgets[i]["temp"] = aCoreTemp
    local aCoreUsage = capi.widget({type = "textbox"})
    aCoreUsage.width = 37
    aCoreUsage.border_width = 1
    aCoreUsage.border_color = beautiful.fg_normal
    coreWidgets[i]["usage"] = aCoreUsage
    local aCoreIoWait = capi.widget({type = "textbox"})
    aCoreIoWait.width = 35
    aCoreIoWait.border_width = 1
    aCoreIoWait.border_color = beautiful.fg_normal
    coreWidgets[i]["wait"] =  aCoreIoWait
    local aCoreIdle = capi.widget({type = "textbox"})
    aCoreIdle.width = 35
    aCoreIdle.border_width = 1
    aCoreIdle.border_color = beautiful.fg_normal
    coreWidgets[i]["idle"] = aCoreIdle
    aCore.border_width = 1
    aCore.border_color = beautiful.bg_normal
    table.insert(cpuWidgetArray, {aCore,aCoreClock,aCoreTemp,aCoreUsage,aCoreIoWait,aCoreIdle, layout = widget2.layout.horizontal.leftright})
  end
  
  
  local spacer1 = capi.widget({type = "textbox"})
  spacer1.text = ""
  table.insert(cpuWidgetArray, spacer1)
  
  local processHeader = capi.widget({type = "textbox"})
  processHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>PROCESS</tt></b></span> "
  processHeader.bg = beautiful.fg_normal
  processHeader.width = 212
  table.insert(cpuWidgetArray, processHeader)
  local process = {}
  util.spawn("/bin/bash -c '"..util.getdir("config") .."/Scripts/topCpu3.sh > /tmp/topCpu.lua'")
  f = io.open('/tmp/topCpu.lua','r')
  if f ~= nil then
    text3 = f:read("*all")
    text3 = text3.." return cpuStat"
    f:close()
    local afunction = loadstring(text3) or nil
    if afunction ~= nil then
      process = afunction()
    else
      process = nil
    end
  end

  local processCount = 0
  if process ~= nil then
    for i = 0, #process or 0 do
      if process[i] then
	local aProcess = capi.widget({type = "textbox"})
	aProcess.text = " "..process[i]["name"]
	
	local aPid = capi.widget({type = "textbox"})
	aPid.text = process[i]["pid"]
	
	local aMem = capi.widget({type = "textbox"})
	aMem.text = process[i]["percent"].."%"
	aMem.width = 53
	aMem.bg = "#0F2051"
	aMem.border_width = 1
	aMem.border_color = beautiful.bg_normal
	
	testImage2       = capi.widget({ type = "imagebox"})
	testImage2.image = capi.image(config.data.iconPath .. "kill.png")
	
	local aLine = {aMem, aProcess, {testImage2, layout = widget2.layout.horizontal.rightleft}, layout = widget2.layout.horizontal.leftright}
	table.insert(cpuWidgetArray, aLine)
	processCount = processCount +1
      end
    end
  end
  
  cpuWidgetArray["layout"] = widget2.layout.vertical.flex
  data.wibox.widgets = cpuWidgetArray
  return (processCount * 22) + ((coreWidgets["count"] or 0)*22) + 100
end

function update()

end

function new(screen, args)
  data.wibox = wibox({ position = "free", screen = capi.screen.count() })
  data.wibox.ontop = true
  data.wibox.visible = false
  local height = createDrawer() 
  data.wibox:geometry({ width = 212, height = height, x = capi.screen[capi.mouse.screen].geometry.width*2 -  212, y = 20})

  cpulogo       = capi.widget({ type = "imagebox", align = "right" })
  cpulogo.image = capi.image(config.data.iconPath .. "brain.png")
  cpulogo:buttons( util.table.join(
    button({ }, 1, function()
      toggleSensorBar()
    end)
  ))

  cpulogo:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  cpulogo:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)

  cpuwidget = capi.widget({
		type = 'textbox',
		name = 'cpuwidget',
		align = "right"
	      })
  cpuwidget.width = 27
  cpuwidget:buttons( util.table.join(
    button({ }, 1, function()
      toggleSensorBar()
    end)
  ))
  
  vicious.register(cpuwidget, vicious.widgets.cpu,'$1%')

  cpuwidget:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  cpuwidget:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)
	      
  cpugraphwidget = widget2.graph({ layout = widget2.layout.horizontal.rightleft })
  
  cpugraphwidget.height = 0.6
  cpugraphwidget.width = 45
  cpugraphwidget.grow = 'right'

  cpugraphwidget:set_width(40)
  cpugraphwidget:set_height(18)
  if (widget2.graph.set_offset ~= nil) then
    cpugraphwidget:set_offset(1)
  end
  cpugraphwidget:set_height(14)
  cpugraphwidget:set_background_color(beautiful.bg_normal)
  cpugraphwidget:set_border_color(beautiful.fg_normal)
  cpugraphwidget:set_color(beautiful.fg_normal)
  
  vicious.register(cpugraphwidget, vicious.widgets.cpu, '$1', 1)
  
  mytimer = capi.timer({ timeout = 2 })
  mytimer:add_signal("timeout", updateTable)
  mytimer:start()
  
  return {logo = cpulogo, text = cpuwidget, graph = cpugraphwidget}
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
