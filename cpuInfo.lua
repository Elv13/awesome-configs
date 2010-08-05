local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local print = print
local button = require("awful.button")
local loadstring = loadstring
local tonumber = tonumber
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local naughty = require("naughty")
local vicious = require("vicious")
local tag = require("awful.tag")
local util = require("awful.util")
local wibox = require("awful.wibox")
local shifty = require("shifty")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("cpuInfo")

local data = {}

local cpuInfo = {}
function createDrawer() 

  local f = io.open('/tmp/cpuStatistic.lua','r')
  local text3 = f:read("*all")
  text3 = text3.." return cpuInfo"
  f:close()
  local afunction = loadstring(text3)
  local cpuStat = afunction()
  
  
  local f = io.open('/tmp/cpuStatus.txt','r')
  local text2 = f:read("*all")
  f:close()
    local mainText = capi.widget({type = "textbox"})
  mainText.text = text2
  
  cpuWidgetArray = { --[[mainText]] }
  
  local infoHeader = capi.widget({type = "textbox"})
  infoHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>INFO</tt></b></span> "
  infoHeader.bg = beautiful.fg_normal
  infoHeader.width = 212
  table.insert(cpuWidgetArray, infoHeader)
  
  local cpuModel = capi.widget({type = "textbox"})
  cpuModel.text = cpuStat["model"]
  cpuModel.width = 212
  table.insert(cpuWidgetArray, {cpuModel})
  
  local usageHeader = capi.widget({type = "textbox"})
  usageHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>USAGE</tt></b></span> "
  usageHeader.bg = beautiful.fg_normal
  usageHeader.width = 212
  table.insert(cpuWidgetArray, usageHeader)
  
  local volUsage = widget2.graph()
  volUsage:set_width(212)
  volUsage:set_height(30)
  volUsage:set_scale(true)
  --volUsage:set_background_color(beautiful.bg_normal)
  volUsage:set_border_color(beautiful.fg_normal)
  volUsage:set_color(beautiful.fg_normal)
  vicious.register(volUsage, vicious.widgets.cpu,'$1',1)
  table.insert(cpuWidgetArray, volUsage)
  
  --Table header
  local emptyCornerHeader = capi.widget({type = "textbox"})
  emptyCornerHeader.text = " <span color='".. beautiful.bg_normal .."'>Core</span> "
  emptyCornerHeader.bg = beautiful.fg_normal
  emptyCornerHeader.width = 35
  emptyCornerHeader.border_width = 1
  emptyCornerHeader.border_color = beautiful.bg_normal
  local clockHeader = capi.widget({type = "textbox"})
  clockHeader.text = " <span color='".. beautiful.bg_normal .."'>Ghz</span> "
  clockHeader.bg = beautiful.fg_normal
  clockHeader.width = 30
  clockHeader.border_width = 1
  clockHeader.border_color = beautiful.bg_normal
  local tempHeader = capi.widget({type = "textbox"})
  tempHeader.text = " <span color='".. beautiful.bg_normal .."'>Temp</span> "
  tempHeader.bg = beautiful.fg_normal
  tempHeader.width = 40
  tempHeader.border_width = 1
  tempHeader.border_color = beautiful.bg_normal
  local usageHeader = capi.widget({type = "textbox"})
  usageHeader.text = " <span color='".. beautiful.bg_normal .."'>Used</span> "
  usageHeader.bg = beautiful.fg_normal
  usageHeader.width = 37
  usageHeader.border_width = 1
  usageHeader.border_color = beautiful.bg_normal
  local iowaitHeader = capi.widget({type = "textbox"})
  iowaitHeader.text = " <span color='".. beautiful.bg_normal .."'> I/O</span> "
  iowaitHeader.bg = beautiful.fg_normal
  iowaitHeader.width = 35
  iowaitHeader.border_width = 1
  iowaitHeader.border_color = beautiful.bg_normal
  local idleHeader = capi.widget({type = "textbox"})
  idleHeader.text = " <span color='".. beautiful.bg_normal .."'> Idle</span> "
  idleHeader.bg = beautiful.fg_normal
  idleHeader.width = 35
  idleHeader.border_width = 1
  idleHeader.border_color = beautiful.bg_normal
  table.insert(cpuWidgetArray, {emptyCornerHeader,clockHeader,tempHeader,usageHeader,iowaitHeader,idleHeader, layout = widget2.layout.horizontal.leftright})
  
  for i=0 ,cpuStat["core"] do
    local aCore = capi.widget({type = "textbox"})
    aCore.text = " <span color='".. beautiful.bg_normal .."'>".."C"..i.."</span> "
    aCore.bg = beautiful.fg_normal
    aCore.width = 35
    local aCoreClock = capi.widget({type = "textbox"})
    aCoreClock.text = tonumber(cpuStat["core"..i]["speed"]) /1024 .. "Ghz"
    aCoreClock.width = 30
    aCoreClock.border_width = 1
    aCoreClock.border_color = beautiful.fg_normal
    local aCoreTemp = capi.widget({type = "textbox"})
    aCoreTemp.text = cpuStat["core"..i]["temp"]
    aCoreTemp.width = 40
    aCoreTemp.border_width = 1
    aCoreTemp.border_color = beautiful.fg_normal
    local aCoreUsage = capi.widget({type = "textbox"})
    aCoreUsage.text = cpuStat["core"..i]["usage"]
    aCoreUsage.width = 37
    aCoreUsage.border_width = 1
    aCoreUsage.border_color = beautiful.fg_normal
    local aCoreIoWait = capi.widget({type = "textbox"})
    aCoreIoWait.text = cpuStat["core"..i]["iowait"]
    aCoreIoWait.width = 35
    aCoreIoWait.border_width = 1
    aCoreIoWait.border_color = beautiful.fg_normal
    local aCoreIdle = capi.widget({type = "textbox"})
    aCoreIdle.text = cpuStat["core"..i]["idle"]
    aCoreIdle.width = 35
    aCoreIdle.border_width = 1
    aCoreIdle.border_color = beautiful.fg_normal
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
  
  f = io.open('/tmp/topCpu.lua','r')
  text3 = f:read("*all")
  text3 = text3.." return cpuStat"
  f:close()
  print(text3)
  local afunction = loadstring(text3)
  process = afunction()
  
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
      testImage2.image = capi.image("/home/lepagee/Icon/kill.png")
       
      local aLine = {aMem, aProcess, {testImage2, layout = widget2.layout.horizontal.rightleft}, layout = widget2.layout.horizontal.leftright}
      table.insert(cpuWidgetArray, aLine)
      end
    end
  end
  
  cpuWidgetArray["layout"] = widget2.layout.vertical.flex
  data.wibox.widgets = cpuWidgetArray
  return 410
end

function update()

end

function new(screen, args)
  data.wibox = wibox({ position = "free", screen = capi.screen.count() })
  data.wibox.ontop = true
  data.wibox.visible = false
  local height = createDrawer() 
  data.wibox:geometry({ width = 212, height = height, x = capi.screen[capi.screen.count()].geometry.width*2 -  212, y = 20})

  cpulogo       = capi.widget({ type = "imagebox", align = "right" })
  cpulogo.image = capi.image("/home/lepagee/Icon/brain.png")
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
  cpugraphwidget:set_offset(1)
  cpugraphwidget:set_height(14)
  cpugraphwidget:set_background_color(beautiful.bg_normal)
  cpugraphwidget:set_border_color(beautiful.fg_normal)
  cpugraphwidget:set_color(beautiful.fg_normal)
  
  vicious.register(cpugraphwidget, vicious.widgets.cpu, '$1', 1)
  
  return {logo = cpulogo, text = cpuwidget, graph = cpugraphwidget}
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
