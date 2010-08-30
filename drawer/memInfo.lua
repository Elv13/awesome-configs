local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local dofile = dofile
local loadstring = loadstring
local loadfile = loadfile
local print = print
local next = next	
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local wibox = require("awful.wibox")
local naughty = require("naughty")
local vicious = require("vicious")
local tag = require("awful.tag")
local util = require("awful.util")
local shifty = require("shifty")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag,
	       timer = timer}

module("drawer.memInfo")

local data = {}

local memInfo = {}
function createDrawer() 
  widgetTable = {  }

  util.spawn("/bin/bash -c '"..util.getdir("config") .."/Scripts/memStatistics.sh > /tmp/memStatistics.lua'")
  
  local f = io.open('/tmp/memStatistics.lua','r')
  if f ~= nil then
    local text3 = f:read("*all")
    text3 = text3.." return memStat"
    f:close()
    local afunction = loadstring(text3)
    memStat = afunction()
    statNotFound = nil
  else
    statNotFound = "N/A"
  end

  if memStat["ram"] == nil then
    statNotFound = "N/A"
  end
  
  local infoHeader = capi.widget({type = "textbox"})
  infoHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>USAGE</tt></b></span> "
  infoHeader.bg = beautiful.fg_normal
  infoHeader.width = 212
  table.insert(widgetTable, infoHeader)
  
  local totalRam = capi.widget({type = "textbox"})
  totalRam.text = statNotFound or memStat["ram"]["total"] 
  local totalRamLabel = capi.widget({type = "textbox"})
  totalRamLabel.text = "Total Ram:"
  totalRamLabel.width = 70
  table.insert(widgetTable, {totalRamLabel,totalRam, layout = widget2.layout.horizontal.leftright})
  
  local freeRam = capi.widget({type = "textbox"})
  freeRam.text = statNotFound or memStat["ram"]["free"]
  local freeRamLabel = capi.widget({type = "textbox"})
  freeRamLabel.text = "Free Ram:"
  freeRamLabel.width = 70
  table.insert(widgetTable, {freeRamLabel,freeRam, layout = widget2.layout.horizontal.leftright})
  
  local usedRam = capi.widget({type = "textbox"})
  usedRam.text = statNotFound or memStat["ram"]["used"]
  local usedRamLabel = capi.widget({type = "textbox"})
  usedRamLabel.text = "Used Ram:"
  usedRamLabel.width = 70
  table.insert(widgetTable, {usedRamLabel,usedRam, layout = widget2.layout.horizontal.leftright})
  
  local totalSwap = capi.widget({type = "textbox"})
  totalSwap.text = statNotFound or memStat["swap"]["total"]
  local totalSwapLabel = capi.widget({type = "textbox"})
  totalSwapLabel.text = "Total Swap:"
  totalSwapLabel.width = 70
  table.insert(widgetTable, {totalSwapLabel,totalSwap, layout = widget2.layout.horizontal.leftright})
  
  local freeSwap = capi.widget({type = "textbox"})
  freeSwap.text = statNotFound or memStat["swap"]["free"]
  local freeSwapLabel = capi.widget({type = "textbox"})
  freeSwapLabel.text = "Free Swap:"
  freeSwapLabel.width = 70
  table.insert(widgetTable, {freeSwapLabel,freeSwap, layout = widget2.layout.horizontal.leftright})
  
  local usedSwap = capi.widget({type = "textbox"})
  usedSwap.text = statNotFound or memStat["swap"]["used"]
  local usedSwapLabel = capi.widget({type = "textbox"})
  usedSwapLabel.text = "Used Swap:"
  usedSwapLabel.width = 70
  table.insert(widgetTable, {usedSwapLabel,usedSwap, layout = widget2.layout.horizontal.leftright})
  
  local userHeader = capi.widget({type = "textbox"})
  userHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>USERS</tt></b></span> "
  userHeader.bg = beautiful.fg_normal
  userHeader.width = 212
  table.insert(widgetTable, userHeader)
  
  local totalUser = 0
  if memStat ~= nil then
    for v, i in next, memStat["users"] do
      local anUser = capi.widget({type = "textbox"})
      anUser.text = i
      local anUserLabel = capi.widget({type = "textbox"})
      anUserLabel.text = v..":"
      anUserLabel.width = 70
      table.insert(widgetTable, {anUserLabel,anUser, layout = widget2.layout.horizontal.leftright})
      totalUser = totalUser +1
    end  
  end
  
  local stateHeader = capi.widget({type = "textbox"})
  stateHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>STATE</tt></b></span> "
  stateHeader.bg = beautiful.fg_normal
  stateHeader.width = 212
  table.insert(widgetTable, stateHeader)
  
  
  local totalState = 0
  if memStat ~= nil then
    for v, i in next, memStat["state"] do
      local anState = capi.widget({type = "textbox"})
      anState.text = i
      local anStateLabel = capi.widget({type = "textbox"})
      anStateLabel.text = v..":"
      anStateLabel.width = 70
      table.insert(widgetTable, {anStateLabel,anState, layout = widget2.layout.horizontal.leftright})
      totalState = totalState +1
    end  
  end

  util.spawn("/bin/bash -c 'while true; do "..util.getdir("config") .."/Scripts/topMem2.sh > /tmp/topMem.lua ; sleep 5 ; done'")


  local processHeader = capi.widget({type = "textbox"})
  processHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>PROCESS</tt></b></span> "
  processHeader.bg = beautiful.fg_normal
  processHeader.width = 212
  table.insert(widgetTable, processHeader)
  
  widgetTable["layout"] = widget2.layout.vertical.flex
 
  tableWithTop = widgetTable
  
  function generateTop(widgetTable2) 
      f = io.open('/tmp/topMem.lua','r')
        if f ~= nil then
        text3 = f:read("*all")
        text3 = text3.." return process"
        f:close()
        afunction = loadstring(text3)
        process = afunction()
      end
      
      if process ~= nil and process[1] then
      for i = 0, #process or 0 do
	  local aProcess = capi.widget({type = "textbox"})
	  aProcess.text = " "..process[i]["name"] or "N/A"
	  
	  local aPid = capi.widget({type = "textbox"})
	  aPid.text = process[i]["pid"]
	  
	  local aMem = capi.widget({type = "textbox"})
	  aMem.text = process[i]["mem"]
	  aMem.width = 53
	  aMem.bg = "#0F2051"
	  aMem.border_width = 1
	  aMem.border_color = beautiful.bg_normal
	  
	  testImage2       = capi.widget({ type = "imagebox"})
	  testImage2.image = capi.image(util.getdir("config") .. "/Icon/kill.png")
	  
	  local aLine = {aMem, aProcess, {testImage2, layout = widget2.layout.horizontal.rightleft}, layout = widget2.layout.horizontal.leftright}
	  table.insert(widgetTable2, aLine)
	end
    else
      return {widgets = widgetTable2, count = 0}
      end
      
      return { widgets = widgetTable2, count  = (#process or 0)}
  end
  
  local widgetTable3 = generateTop(widgetTable)
  widgetTable3.widgets["layout"] = widget2.layout.vertical.flex
  data.wibox.widgets = widgetTable3.widgets
  data.wibox:geometry({ width = 212, height = ((widgetTable3.count*22) or 0) + (8*22) + (totalUser *22) + (totalState*22), y = 20, x = capi.screen[capi.screen.count()].geometry.width*2 -  212})
  
  
  process = {}
  --mytimer = capi.timer({ timeout = 5 })
  --mytimer:add_signal("timeout", function() generateTop() end)

  
  return 
end

function update()

end

function new(s, args)
  data.wibox = wibox({ position = "free", screen = s})
  data.wibox.ontop = true
  data.wibox.visible = false
  local height = createDrawer() 

  ramlogo       = capi.widget({ type = "imagebox", align = "right" })
  ramlogo.image = capi.image(util.getdir("config") .. "/Icon/cpu.png")
  ramlogo:buttons( util.table.join(
    button({ }, 1, function()
      toggleSensorBar()
    end)
  ))
  
  ramlogo:add_signal("mouse::enter", function ()
      data.wibox.visible = true
      data.wibox:geometry({y = 20, x = capi.screen[capi.screen.count()].geometry.width*2 - (ramlogo:extents().x or 212)})
  end)

  ramlogo:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)

  memwidget = capi.widget({
      type = 'textbox',
      name = 'memwidget',
      align = "right"
  })
  memwidget:buttons( util.table.join(
    button({ }, 1, function()
      toggleSensorBar()
    end)
  ))


  vicious.register(memwidget, vicious.widgets.mem, '$1%')
  
  memwidget:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  memwidget:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)
  
  membarwidget = widget2.progressbar({ layout = widget2.layout.horizontal.rightleft })
  membarwidget:set_width(40)
  membarwidget:set_height(18)
  if (widget2.progressbar.set_offset ~= nil) then
    membarwidget:set_offset(1)
  end
  membarwidget:set_margin({top=2,bottom=2})
  membarwidget:set_vertical(false)
  membarwidget:set_background_color(beautiful.bg_normal)
  membarwidget:set_border_color(beautiful.fg_normal)
  membarwidget:set_color(beautiful.fg_normal)
  membarwidget:set_gradient_colors({
    beautiful.fg_normal,
    beautiful.fg_normal,
    '#CC0000'
  })

  vicious.register(membarwidget, vicious.widgets.mem, '$1', 1, 'mem')
  
  return { logo = ramlogo, text = memwidget, bar = membarwidget}
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
