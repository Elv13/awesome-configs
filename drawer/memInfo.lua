local setmetatable = setmetatable
local io           = io
local pairs        = pairs
local print        = print
local loadstring   = loadstring
local next         = next
local table        = table
local button       = require("awful.button")
local beautiful    = require("beautiful")
local widget2      = require("awful.widget")
local wibox        = require("awful.wibox")
local menu         = require("widgets.menu")
local vicious      = require("vicious")
local config       = require("config")
local util         = require("awful.util")

local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               mouse  = mouse  ,
	       timer  = timer  }

module("drawer.memInfo")

local data = {}

local memInfo = {}

function createDrawer() 
  widgetTable = {  }
  
  local infoHeader     = capi.widget({type = "textbox"})
  local totalRam       = capi.widget({type = "textbox"})
  local freeRam        = capi.widget({type = "textbox"})
  local usedRam        = capi.widget({type = "textbox"})
  local freeSwap       = capi.widget({type = "textbox"})
  local usedSwap       = capi.widget({type = "textbox"})
  local totalSwap      = capi.widget({type = "textbox"})
  local userHeader     = capi.widget({type = "textbox"})
  local stateHeader    = capi.widget({type = "textbox"})
  local processHeader  = capi.widget({type = "textbox"})
  
  local totalRamLabel  = capi.widget({type = "textbox"})
  local freeRamLabel   = capi.widget({type = "textbox"})
  local usedRamLabel   = capi.widget({type = "textbox"})
  local totalSwapLabel = capi.widget({type = "textbox"})
  local freeSwapLabel  = capi.widget({type = "textbox"})
  local usedSwapLabel  = capi.widget({type = "textbox"})
  
  local ramLabel       = capi.widget({type = "textbox"})
  local swapLabel      = capi.widget({type = "textbox"})
  local totalLabel     = capi.widget({type = "textbox"})
  local usedLabel      = capi.widget({type = "textbox"})
  local freeLabel      = capi.widget({type = "textbox"})
  
  infoHeader.text      = " <span color='".. beautiful.bg_normal .."'><b><tt>USAGE</tt></b></span> "
  infoHeader.bg        = beautiful.fg_normal
  infoHeader.width     = 212
  
  userHeader.text      = " <span color='".. beautiful.bg_normal .."'><b><tt>USERS</tt></b></span> "
  userHeader.bg        = beautiful.fg_normal
  userHeader.width     = 212
  
  stateHeader.text     = " <span color='".. beautiful.bg_normal .."'><b><tt>STATE</tt></b></span> "
  stateHeader.bg       = beautiful.fg_normal
  stateHeader.width    = 212
  
  processHeader.text   = " <span color='".. beautiful.bg_normal .."'><b><tt>PROCESS</tt></b></span> "
  processHeader.bg     = beautiful.fg_normal
  processHeader.width  = 212
  
  table.insert(widgetTable, stateHeader)
  table.insert(widgetTable, processHeader)
  
  util.spawn("/bin/bash -c 'while true;do "..util.getdir("config") .."/Scripts/memStatistics.sh > /tmp/memStatistics.lua && sleep 5;done'")
  util.spawn("/bin/bash -c 'while true; do "..util.getdir("config") .."/Scripts/topMem2.sh > /tmp/topMem.lua;sleep 5;done'")
  
  function refreshStat()
    local f = io.open('/tmp/memStatistics.lua','r')
    if f ~= nil then
      local text3 = f:read("*all")
      text3 = text3.." return memStat"
      f:close()
      local afunction = loadstring(text3)
      memStat = {}
      if afunction ~= nil then
        memStat = afunction()
      end
      statNotFound = nil
    else
      statNotFound = "N/A"
    end

    if memStat == nil or memStat["ram"] == nil then
      statNotFound = "N/A"
    end
    
    ramLabel.text           = "<span color='".. beautiful.bg_normal .."'>Ram</span>"
    ramLabel.width          = 55
    ramLabel.border_width   = 1
    ramLabel.bg             = beautiful.fg_normal
    ramLabel.border_color   = beautiful.bg_normal
    swapLabel.text          = "<span color='".. beautiful.bg_normal .."'>Swap</span>"
    swapLabel.width         = 55
    swapLabel.border_width  = 1
    swapLabel.bg            = beautiful.fg_normal
    swapLabel.border_color  = beautiful.bg_normal
    totalLabel.text         = "<span color='".. beautiful.bg_normal .."'>Total</span>"
    totalLabel.width        = 55
    totalLabel.border_width = 1
    totalLabel.bg           = beautiful.fg_normal
    totalLabel.border_color = beautiful.bg_normal
    usedLabel.text          = "<span color='".. beautiful.bg_normal .."'>Used</span>"
    usedLabel.width         = 55
    usedLabel.border_width  = 1
    usedLabel.bg            = beautiful.fg_normal
    usedLabel.border_color  = beautiful.bg_normal
    freeLabel.text          = "<span color='".. beautiful.bg_normal .."'>Used</span>"
    freeLabel.width         = 55
    freeLabel.border_width  = 1
    freeLabel.bg            = beautiful.fg_normal
    freeLabel.border_color  = beautiful.bg_normal
    
    totalRam.text           = statNotFound or memStat["ram"]["total"]
    totalRam.width          = 55
    totalRam.border_width   = 1
    totalRam.border_color   = beautiful.fg_normal
    
    freeRam.text            = statNotFound or memStat["ram"]["free"]
    freeRam.width           = 55
    freeRam.border_width    = 1
    freeRam.border_color    = beautiful.fg_normal
    
    usedRam.text            = statNotFound or memStat["ram"]["used"]
    usedRam.width           = 55
    usedRam.border_width    = 1
    usedRam.border_color    = beautiful.fg_normal
    
    totalSwap.text          = statNotFound or memStat["swap"]["total"]
    totalSwap.width         = 55
    totalSwap.border_width  = 1
    totalSwap.border_color  = beautiful.fg_normal
    
    freeSwap.text           = statNotFound or memStat["swap"]["free"]
    freeSwap.width          = 55
    freeSwap.border_width   = 1
    freeSwap.border_color   = beautiful.fg_normal
    
    usedSwap.text           = statNotFound or memStat["swap"]["used"]
    usedSwap.width          = 55
    usedSwap.border_width   = 1
    usedSwap.border_color   = beautiful.fg_normal
    
    return newWidgets2
  end
  
  refreshStat()
  function refreshAll() 
    local tempWdg = refreshStat()
    table.insert(tempWdg,infoHeader)
    table.insert(tempWdg,{totalLabel,totalLabel,usedLabel,freeLabel, layout = widget2.layout.horizontal.leftright})
    table.insert(tempWdg,{ramLabel,totalRam,usedRam,freeRam, layout = widget2.layout.horizontal.leftright})
    table.insert(tempWdg,{swapLabel,totalSwap,usedSwap,freeSwap, layout = widget2.layout.horizontal.leftright})
    table.insert(tempWdg,userHeader)
    tempWdg["layout"] = widget2.layout.vertical.flex
                     
    data.wibox.widgets = widgetTable4.widgets
    data.wibox:geometry({ width = 212, height = (((widgetTable4.count or 0)*22) or 0) + (#tempWdg*22) + 600, y = 20, x = capi.screen[capi.mouse.screen].geometry.width*2 -  212})
  end
  
  process = {}
  
  local mainMenu = menu()
  
  local infoHeaderW    = wibox({ position = "free", screen = s,ontop = true})
  local ramW           = wibox({ position = "free", screen = s,ontop = true})
  local userHeaderW    = wibox({ position = "free", screen = s,ontop = true})
  local stateHeaderW   = wibox({ position = "free", screen = s,ontop = true})
  local processHeaderW = wibox({ position = "free", screen = s,ontop = true})
  
  infoHeaderW.widgets = {infoHeader,layout = widget2.layout.horizontal.leftright}
  
  ramW.widgets = {
                    {totalLabel,totalLabel,usedLabel,freeLabel, layout = widget2.layout.horizontal.leftright},
                    {ramLabel,totalRam,usedRam,freeRam, layout = widget2.layout.horizontal.leftright},
                    {swapLabel,totalSwap,usedSwap,freeSwap, layout = widget2.layout.horizontal.leftright},
                    layout = widget2.layout.vertical.flex
                 }
                 
  
  userHeaderW.widgets = {userHeader,layout = widget2.layout.horizontal.leftright}
                  
   mainMenu:add_wibox(infoHeaderW,{height = 20 , width = 200})
   mainMenu:add_wibox(ramW       ,{height = 72, width = 200})
   mainMenu:add_wibox(userHeaderW,{height = 20, width = 200})
    local memStat
    local totalUser = 0
    local totalState = 0
    local f = io.open('/tmp/memStatistics2.lua','r')
    if f ~= nil then
      local text3 = f:read("*all")
      text3 = text3.." return memStat"
      f:close()
      local afunction = loadstring(text3)
      memStat = {}
      if afunction ~= nil then
        memStat = afunction()
        --print("Momory stat loaded successfully"..memStat["users"])
      end
      statNotFound = nil
    else
      print("Failed to open memStat")
      statNotFound = "N/A"
    end
   
   if memStat ~= nil and memStat["users"] then
      for v, i in next, memStat["users"] do
        local userW = wibox({ position = "free", screen = s,ontop = true})
        local anUser = capi.widget({type = "textbox"})
        anUser.text = i
        local anUserLabel = capi.widget({type = "textbox"})
        anUserLabel.text = v..":"
        anUserLabel.width = 70
        anUserLabel.bg = "#0F2051"
        userW.widgets = {anUserLabel,anUser, layout = widget2.layout.horizontal.leftright}
        totalUser = totalUser +1
        mainMenu:add_wibox(userW,{height = 20, width = 200})
      end  
   end
    
  stateHeaderW.widgets   = {stateHeader,layout = widget2.layout.horizontal.leftright}
  mainMenu:add_wibox(stateHeaderW,{height = 20 , width = 200})
   
   if memStat ~= nil and memStat["state"] ~= nil then
      for v, i in next, memStat["state"] do
        local stateW = wibox({ position = "free", screen = s,ontop = true})
        local anState = capi.widget({type = "textbox"})
        anState.text = i
        local anStateLabel = capi.widget({type = "textbox"})
        anStateLabel.text = v..":"
        anStateLabel.width = 70
        anStateLabel.bg = "#0F2051"
        stateW.widgets = {anStateLabel,anState, layout = widget2.layout.horizontal.leftright}
        totalState = totalState +1
        mainMenu:add_wibox(stateW,{height = 20, width = 200})
      end  
   end
    
  processHeaderW.widgets = {processHeader,layout = widget2.layout.horizontal.leftright}
  mainMenu:add_wibox(processHeaderW,{height = 20 , width = 200})
   
   local process
    local f = io.open('/tmp/topMem2.lua','r')
    if f ~= nil then
      text3 = f:read("*all")
      text3 = text3.." return process"
      f:close()
      afunction = loadstring(text3)
      if afunction == nil then
        return { count = o, widgets = widgetTable2}
      end
      process = afunction()
    end
      
    if process ~= nil and process[1] then
      for i = 0, #process or 0 do
        if process[i]["name"] ~= nil then
          local processW = wibox({ position = "free", screen = s,ontop = true})
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
          testImage2.image = capi.image(config.data.iconPath .. "kill.png")
          
          processW.widgets = {aMem, aProcess, {testImage2, layout = widget2.layout.horizontal.rightleft}, layout = widget2.layout.horizontal.leftright}
          mainMenu:add_wibox(processW,{height = 20, width = 200})
        end
      end
    end
  --memory.widgets = {layout = widget2.layout.horizontal.leftright}
  
  mainMenu:toggle(true)
  
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
  ramlogo.image = capi.image(config.data.iconPath .. "cpu.png")
  ramlogo:buttons( util.table.join(
    button({ }, 1, function()
      toggleSensorBar()
    end)
  ))
  
  ramlogo:add_signal("mouse::enter", function ()
      data.wibox.visible = true
      data.wibox:geometry({y = 20, x = capi.screen[capi.mouse.screen].geometry.width*2 - (ramlogo:extents().x or 212)})
  end)

  ramlogo:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)

  memwidget = capi.widget({
      type  = 'textbox',
      name  = 'memwidget',
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
  
  if widget2.progressbar.set_margin then
    membarwidget:set_margin({top=2,bottom=2})
  end
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
