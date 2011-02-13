local setmetatable = setmetatable
local io = io
local next = next
local ipairs = ipairs
local loadstring = loadstring
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
	       tag = tag,
               timer = timer}

module("drawer.netInfo")

local data = {}

function update()

end

local function createDrawer() 
  
  local graphHeader = capi.widget({type = "textbox"})
  graphHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>GRAPH</tt></b></span> "
  graphHeader.bg = beautiful.fg_normal
  graphHeader.width = 240

  local ipHeader = capi.widget({type = "textbox"})
  ipHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>IP</tt></b></span> "
  ipHeader.bg = beautiful.fg_normal
  ipHeader.width = 240
  
  
  local f = io.popen('ifconfig | grep -e "inet addr:[0-9.]*" -o |  grep -e "[0-9.]*" -o')
  local ip4Value = "<i><b>  v4: </b>" .. (f:read() or "") .. "</i>"
  f:close()
  f = io.popen('ifconfig | grep -e "inet6 addr: [0-9.A-Fa-f;:]*" -o | cut -f3 -d " "')
  local ip6Value = "<i><b>  v6: </b>" .. (f:read() or "") .. "</i>\n\n"
  f:close()
  
  local ip4Info = capi.widget({type = "textbox"})
  ip4Info.text = ip4Value
  
  local ip6Info = capi.widget({type = "textbox"})
  ip6Info.text = ip6Value .. "test"
  
  local localHeader = capi.widget({type = "textbox"})
  localHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>Local Network</tt></b></span> "
  localHeader.bg = beautiful.fg_normal
  localHeader.width = 240
  
  local localValue = ""
  f = io.open('/tmp/localNetLookup','r')
  if f ~= nil then
    localValue = f:read("*all")
    f:close()
  end
  
  local localInfo = capi.widget({type = "textbox"})
  localInfo.text = localValue
  
  
  local connHeader = capi.widget({type = "textbox"})
  connHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>IP</tt></b></span> "
  connHeader.bg = beautiful.fg_normal
  connHeader.width = 240
  
  
  

  
  local text2 = ""
  f = io.open('/tmp/connectedHost','r')
  text2 = ""
  if f ~= nil then
    text2 = text2 .. f:read("*all")
    f:close()
  end
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
  netUpGraph:set_width(235)
  netUpGraph:set_height(30)
  netUpGraph:set_scale(true)
  netUpGraph:set_background_color(beautiful.bg_normal)
  netUpGraph:set_border_color(beautiful.fg_normal)
  netUpGraph:set_color(beautiful.fg_normal)
  vicious.register(netUpGraph, vicious.widgets.net, '${eth0 up_kb}',1)
  
  local netDownGraph = widget2.graph()
  netDownGraph:set_width(235)
  netDownGraph:set_height(30)
  netDownGraph:set_scale(true)
  netDownGraph:set_background_color(beautiful.bg_normal)
  netDownGraph:set_border_color(beautiful.fg_normal)
  netDownGraph:set_color(beautiful.fg_normal)
  vicious.register(netDownGraph, vicious.widgets.net, '${eth0 down_kb}',1)
  
  local widgetArray ={
   graphHeader,
   {
     downloadImg,
     netUsageDown,
     layout = widget2.layout.horizontal.leftright
   },
   netDownGraph,
   {
     uploadImg,
     netUsageUp,
     layout = widget2.layout.horizontal.leftright
   },
   netUpGraph,
	ipHeader,
	ip4Info,
        ip6Info,
	localHeader,
	localInfo,
	layout = widget2.layout.vertical.flex
  }

  local connHeader = capi.widget({type = "textbox"})
  connHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>CONNECTIONS</tt></b></span> "
  connHeader.bg = beautiful.fg_normal
  connHeader.width = 240  
  table.insert(widgetArray, connHeader)

  local connectionWidget = {}
  local protWidget = {}
  local appWidget = {}
  
  for i=0 , 10 do
    local protocol = capi.widget({type = "textbox",visible = false})
    protocol.width = 40
    protocol.bg = "#0F2051"
    protocol.border_width = 1
    protocol.border_color = beautiful.bg_normal
    local application = capi.widget({type = "textbox",visible = false})
    application.width = 25
    application.bg = "#0F2051"
    application.border_width = 1
    application.border_color = beautiful.bg_normal
    local address = capi.widget({type = "textbox",visible = false})
    
    protocol.visible = false
    application.visible = false
    address.visible = false
    
    application.text = "test"
    
    connectionWidget[i] = {application = application, protocol = protocol, address = address, layout = widget2.layout.horizontal.leftright}
    table.insert(widgetArray, {application,protocol,address, layout = widget2.layout.horizontal.leftright})--connectionWidget)
  end
  

  local protHeader = capi.widget({type = "textbox"})
  protHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>PROTOCOLS</tt></b></span> "
  protHeader.bg = beautiful.fg_normal
  protHeader.width = 240
  table.insert(widgetArray, protHeader)
  
  for i=0 , 10 do
    local protocol3 = capi.widget({type = "textbox"})
    protWidget[i] = protocol3
    table.insert(widgetArray, protocol3)
  end
  
  
  local appHeader = capi.widget({type = "textbox"})
  appHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>APPLICATIONS</tt></b></span> "
  appHeader.bg = beautiful.fg_normal
  appHeader.width = 240
  table.insert(widgetArray, appHeader)
  
  for i=0 , 10 do
    local appIcon = capi.widget({type = "textbox"})
    appIcon.width = 25
    appIcon.bg = "#0F2051"
    appIcon.border_color = beautiful.bg_normal
    appIcon.border_width = 1
    local app2 = capi.widget({type = "textbox"})
    testImage2       = capi.widget({ type = "imagebox"})
    testImage2.image = capi.image(util.getdir("config") .. "/Icon/kill.png")
    appWidget[i] = {appIcon=appIcon,app2=app2}
    table.insert(widgetArray, {{appIcon, app2, layout = widget2.layout.horizontal.leftright}, testImage2, layout = widget2.layout.horizontal.rightleft})
  end
  
  
  
  util.spawn("/bin/bash -c 'while true; do "..util.getdir("config") .."/Scripts/connectedHost2.sh > /tmp/connectedHost.lua;sleep 15;done'")
  
  mytimer = capi.timer({ timeout = 2 })
  mytimer:add_signal("timeout", function() 
    local connectionInfo ={}
    local protocolStat = {}
    local appStat = {}
    
    f = io.open('/tmp/connectedHost.lua','r')
    if f ~= nil then
      local text3 = f:read("*all")
      text3 = text3.." return connectionInfo"
      f:close()
      afunction = loadstring(text3)
      if afunction == nil then
        return { count = o, widgets = widgetTable2}
      end
      connectionInfo = afunction()
    end
    
    local count =0
    if connectionInfo ~= nil then
      for i=0 , #connectionInfo do
        if connectionInfo[i] ~= nil and i < 10 and connectionInfo[i]['protocol'] ~= nil then
          connectionWidget[i].application.text = " ["..(connectionInfo[i]['protocol'] or "").."]"
          connectionWidget[i].protocol.text = connectionInfo[i]['application'] or ""
          connectionWidget[i].address.text = " " .. (connectionInfo[i]['site'] or "")
          
          connectionWidget[i].application.visible = true
          connectionWidget[i].protocol.visible = true
          connectionWidget[i].address.visible = true


          appStat[connectionInfo[i]['application'] ] = (protocolStat[connectionInfo[i]['application'] ] or 0) + 1
          protocolStat[connectionInfo[i]['protocol'] ] = (protocolStat[connectionInfo[i]['protocol'] ] or 0) + 1
	  count = count +1
        end
	
	for i=0 , 10-count do
	  connectionWidget[10-count].application.visible = false
          connectionWidget[10-count].protocol.visible = false
          connectionWidget[10-count].address.visible = false
	end
      end  
      
      
    end
    
    count =0
    for v, i in next, protocolStat do
      protWidget[count].text = " " .. v.."("..i..")"
      protWidget[count].visible = true
      count = count +1
    end
    
    for i=0 , 10-count do
      protWidget[count].visible = false
    end
    
    count =0
    for v, i in next, appStat do
      appWidget[count].app2.text = " " .. v .."("..i..")"
      appWidget[count].app2.visible = true
      count = count +1
    end
    
    for i=0 , 10-count do
      appWidget[count].app2.visible = false
    end
  end)
  mytimer:start()
  --netWorkWibox.box.height = netWorkWibox.box.height + 25]]

  


  

  data.wibox.widgets = widgetArray  
  if connectionInfo ~= nil then
    return 800--mainText:extents().height + (#appStat *22) + (#protocolStat * 22) + ((#connectionInfo or 0)*22) + (#widgetArray or 0 * 22)+ 240 + 300
  else
    return 800--mainText:extents().height + (#appStat *22) + (#protocolStat * 22) +  (#widgetArray or 0 * 22)+ 240 + 300
  end
end

function new(screen, args)
  local netWorkWibox
  local netInfo = {}
  
  data.wibox = wibox({ position = "free", screen = capi.screen.count() })
  data.wibox.ontop = true
  data.wibox.visible = false
  local height = createDrawer() 
  data.wibox:geometry({ width = 240, height = height, x = capi.screen[capi.mouse.screen].geometry.width*2 -  240, y = 20})

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
