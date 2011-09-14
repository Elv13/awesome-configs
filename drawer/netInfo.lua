local setmetatable = setmetatable
local io           = io
local next         = next
local ipairs       = ipairs
local loadstring   = loadstring
local table        = table
local print        = print
local beautiful    = require( "beautiful"    )
local widget2      = require( "awful.widget" )
local wibox        = require( "awful.wibox"  )
local button       = require( "awful.button" )
local vicious      = require( "vicious"      )
local util         = require( "awful.util"   )
local config       = require( "config"       )
local menu         = require( "widgets.menu" )

local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               client = client ,
               mouse  = mouse  ,
               timer  = timer  }

module("drawer.netInfo")

--DATA
local data             = {}
local connectionWidget = {}
local protWidget       = {}
local appWidget        = {}
local connectionInfo   = {}
local protocolStat     = {}
local appStat          = {}

--WIBOX
local connectionInfoW  = {}
local protWidgetW      = {}
local appWidgetW       = {}
local graphHeaderW     = nil
local ipHeaderW        = nil
local localHeaderW     = nil
local connHeaderW      = nil
local protHeaderW      = nil
local ipInfo           = nil
local graphUW          = nil
local graphDW          = nil

--WIDGET
local graphHeader      = capi.widget({type = "textbox" })
local ipHeader         = capi.widget({type = "textbox" })
local localHeader      = capi.widget({type = "textbox" })
local connHeader       = capi.widget({type = "textbox" })
local protHeader       = capi.widget({type = "textbox" })
local appHeader        = capi.widget({type = "textbox" })
local ip4Info          = capi.widget({type = "textbox" })
local ip6Info          = capi.widget({type = "textbox" })
local localInfo        = capi.widget({type = "textbox" })
local netUsageUp       = capi.widget({type = "textbox" })
local downloadImg      = capi.widget({type = "imagebox"})
local uploadImg        = capi.widget({type = "imagebox"})
local netSpacer1       = capi.widget({type = "textbox" })
local netUsageDown     = capi.widget({type = "textbox" })
local netSpacer3       = capi.widget({type = "textbox" })
local netSpacer2       = capi.widget({type = "textbox" })
local appHeader        = capi.widget({type = "textbox" })
local downlogo         = capi.widget({type = "imagebox"})
local uplogo           = capi.widget({type = "imagebox"})
local netDownWidget    = capi.widget({type = 'textbox' })
local netUpWidget      = capi.widget({type = 'textbox' })
local netUpGraph       = widget2.graph()
local netDownGraph     = widget2.graph()

--VARIABLES
local totalCount    = 0
  
  --util.spawn("/bin/bash -c 'while true; do "..util.getdir("config") .."/Scripts/connectedHost2.sh > /tmp/connectedHost.lua;sleep 15;done'")
  
function update() 
    local connectionInfo
    local f = io.open('/tmp/connectedHost.lua','r')
    if f ~= nil then
        local text3 = f:read("*all")
        text3 = text3.." return connectionInfo"
        f:close(text3)
        afunction = loadstring(text3)
        if afunction == nil then
        return { count = o, widgets = widgetTable2}
        end
        connectionInfo = afunction()
    end
    
    if connectionInfo ~= nil then
        data.connectionInfo = connectionInfo
    end
    
    f = io.popen('ifconfig | grep -e "inet addr:[0-9.]*" -o |  grep -e "[0-9.]*" -o')
    local ip4Value = "<i><b>  v4: </b>" .. (f:read("*line") or "") .. "</i>"
    f:close()
    f = io.popen('ifconfig | grep -e "inet6 addr: [0-9.A-Fa-f;:]*" -o | cut -f3 -d " "')
    local ip6Value = "<i><b>  v6: </b>" .. (f:read("*line") or "") .. "</i>\n\n"
    f:close()
    
    ip4Info.text = ip4Value
    ip6Info.text = ip6Value .. "test"
    
    local localValue = ""
    f = io.open('/tmp/localNetLookup','r')
    if f ~= nil then
        localValue = f:read("*all")
        f:close()
    end
    
    localInfo.text = localValue
end

local function repaint()
    local mainMenu = menu()
    
    mainMenu:add_wibox(graphHeaderW ,{height = 20, width = 200})
    mainMenu:add_wibox(graphUW      ,{height = 40, width = 200})
    mainMenu:add_wibox(graphDW      ,{height = 50, width = 200})
    mainMenu:add_wibox(ipHeaderW    ,{height = 20, width = 200})
    mainMenu:add_wibox(ipInfo       ,{height = 20, width = 200})
    mainMenu:add_wibox(localHeaderW ,{height = 20, width = 200})
    mainMenu:add_wibox(connHeaderW  ,{height = 20, width = 200})
    
    totalCount = 0
    if data.connectionInfo ~= nil then
        for i=0 , #(data.connectionInfo or {}) do
            if i < 10 then
                connectionWidget[i].application.text = " [".. (data.connectionInfo[i]['protocol']    or "").."]"
                connectionWidget[i].protocol.text    =        (data.connectionInfo[i]['application'] or "")
                connectionWidget[i].address.text     = " " .. (data.connectionInfo[i]['site']        or "")
                totalCount = totalCount +1
            end
            appStat[data.connectionInfo[i]['application'] ]   = (protocolStat[data.connectionInfo[i]['application'] ] or 0) + 1
            protocolStat[data.connectionInfo[i]['protocol'] ] = (protocolStat[data.connectionInfo[i]['protocol'   ] ] or 0) + 1
        end
        local subTotal = (totalCount < 10) and totalCount or 10
        for i=0, subTotal-1 do
            mainMenu:add_wibox(connectionInfoW[i] ,{height = 20, width = 200})
        end
    end
    
    mainMenu:add_wibox(protHeaderW ,{height = 20, width = 200})
    
    local count =1
    for v, i in next, protocolStat do
        if count < 10 then
            protWidget[count].text = " " .. v.."("..i..")"
            mainMenu:add_wibox(protWidgetW[count],{height = 20, width = 200})
            count = count +1
        end
    end
    
    mainMenu:add_wibox(appHeaderW,{height = 20, width = 200})

    count =1
    for v, i in next, appStat do
        if count < 10 then
            appWidget[count].app2.text = " " .. v .."("..i..")"
            for k2,v2 in ipairs(capi.client.get()) do
                print(v)
                if v2.class:lower() == v:lower() or v2.name:lower():find(v:lower()) ~= nil then
                    appWidget[count].appIcon.bg_image = v2.icon
                    break 
                end
            end
            mainMenu:add_wibox(appWidgetW[count],{height = 20, width = 200})
            count = count +1
        end
    end
    
    mainMenu.settings.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x
    mainMenu.settings.y = 16
    return mainMenu
end 

function new(screen, args)
    graphHeaderW         = wibox({ position = "free" , screen = s , ontop = true})
    ipHeaderW            = wibox({ position = "free" , screen = s , ontop = true})
    localHeaderW         = wibox({ position = "free" , screen = s , ontop = true})
    connHeaderW          = wibox({ position = "free" , screen = s , ontop = true})
    protHeaderW          = wibox({ position = "free" , screen = s , ontop = true})
    appHeaderW           = wibox({ position = "free" , screen = s , ontop = true})
    graphUW              = wibox({ position = "free" , screen = s , ontop = true})
    ipInfo               = wibox({ position = "free" , screen = s , ontop = true})
    graphDW              = wibox({ position = "free" , screen = s , ontop = true})
    
    graphHeaderW.visible = false
    ipHeaderW.visible    = false
    localHeaderW.visible = false
    connHeaderW.visible  = false
    protHeaderW.visible  = false
    appHeaderW.visible   = false
    
    graphHeaderW.widgets = { graphHeader , layout = widget2.layout.horizontal.leftright }
    ipHeaderW.widgets    = { ipHeader    , layout = widget2.layout.horizontal.leftright }
    localHeaderW.widgets = { localHeader , layout = widget2.layout.horizontal.leftright }
    connHeaderW.widgets  = { connHeader  , layout = widget2.layout.horizontal.leftright }
    protHeaderW.widgets  = { protHeader  , layout = widget2.layout.horizontal.leftright }
    appHeaderW.widgets   = { appHeader   , layout = widget2.layout.horizontal.leftright }
    
    ipInfo.visible = false
    ipInfo.widgets = {
        {ip4Info  , layout = widget2.layout.horizontal.leftright},
        {ip6Info  , layout = widget2.layout.horizontal.leftright},
        layout = widget2.layout.vertical.flex
    }
    
    graphUW.visible = false
    graphUW.widgets = {
        {uploadImg    , netUsageUp   , layout = widget2.layout.horizontal.leftright},
        {netUpGraph   ,                layout = widget2.layout.horizontal.leftright},
        layout = widget2.layout.vertical.flex
    }
    
    graphDW.visible = false
    graphDW.widgets = {
        {downloadImg  , netUsageDown , layout = widget2.layout.horizontal.leftright},
        {netDownGraph ,                layout = widget2.layout.horizontal.leftright},
        {netSpacer2   ,                layout = widget2.layout.horizontal.leftright},
        layout = widget2.layout.vertical.flex
    }
    
    function formatHeader(wdg,txt)
        wdg.text= " <span color='".. beautiful.bg_normal .."'><b><tt>".. txt .."</tt></b></span> "
        wdg.bg     = beautiful.fg_normal
        wdg.width  = 240
    end
    
    formatHeader(graphHeader ,"GRAPH"         )
    formatHeader(ipHeader    ,"IP"            )
    formatHeader(localHeader ,"LOCAL NETWORK" )
    formatHeader(connHeader  ,"CONNECTIONS"   )
    formatHeader(protHeader  ,"APPLICATIONS"  )
    formatHeader(appHeader   ,"PROTOCOLS"     )
    
    uploadImg.image    = capi.image(config.data.iconPath .. "arrowUp.png")
    uploadImg.resize   = false
    downloadImg.image  = capi.image(config.data.iconPath .. "arrowDown.png")
    downloadImg.resize = false
    netUsageUp.text    = "<b>Up: </b>"
    netSpacer1.text    = " "
    netSpacer1.width   = 10
    netUsageDown.text  = "<b>Down: </b>"
    netSpacer3.text    = "  "
    netSpacer2.text    = " "
    netSpacer2.width   = 10
    
    netUpGraph:set_width             (190                )
    netUpGraph:set_height            (20                 )
    netUpGraph:set_scale             (true               )
    netUpGraph:set_background_color  (beautiful.bg_normal)
    netUpGraph:set_border_color      (beautiful.fg_normal)
    netUpGraph:set_color             (beautiful.fg_normal)
    vicious.register                 (netUpGraph, vicious.widgets.net, '${eth0 up_kb}',1)

    netDownGraph:set_width           (190                )
    netDownGraph:set_height          (20                 )
    netDownGraph:set_scale           (true               )
    netDownGraph:set_background_color(beautiful.bg_normal)
    netDownGraph:set_border_color    (beautiful.fg_normal)
    netDownGraph:set_color           (beautiful.fg_normal)
    vicious.register                 (netDownGraph, vicious.widgets.net, '${eth0 down_kb}',1)
    
    for i=0 , 10 do
        local protocol             = capi.widget({type = "textbox"})
        protocol.width             = 40
        protocol.bg                = "#0F2051"
        protocol.border_width      = 1
        protocol.border_color      = beautiful.bg_normal
        local application          = capi.widget({type = "textbox"})
        application.width          = 25
        application.bg             = "#0F2051"
        application.border_width   = 1
        application.border_color   = beautiful.bg_normal
        local address              = capi.widget({type = "textbox"})
        connectionWidget[i]        = {application = application, protocol = protocol, address = address, layout = widget2.layout.horizontal.leftright}
        connectionInfoW[i]         = wibox({ position = "free" , screen = s , ontop = true})
        connectionInfoW[i].visible = false
        connectionInfoW[i].widgets = {
                                        application,
                                        {protocol,layout = widget2.layout.horizontal.rightleft},
                                        layout = widget2.layout.horizontal.leftright, 
                                        {address,layout = widget2.layout.horizontal.flex}
                                     }
    end
    
    for i=1 , 10 do
        local appIcon          = capi.widget({type = "textbox"})
        appIcon.width          = 25
        appIcon.bg             = "#0F2051"
        appIcon.border_color   = beautiful.bg_normal
        appIcon.border_width   = 1
        local app2             = capi.widget({type = "textbox"})
        testImage2             = capi.widget({ type = "imagebox"})
        testImage2.image       = capi.image(config.data.iconPath .. "kill.png")
        appWidget[i]           = {appIcon=appIcon,app2=app2}
        appWidgetW[i]          = wibox({ position = "free" , screen = s , ontop = true})
        appWidgetW[i].visible  = false
        appWidgetW[i].widgets  = {
                                  appIcon,
                                  {testImage2,layout = widget2.layout.horizontal.rightleft},
                                  layout = widget2.layout.horizontal.leftright,
                                  {app2,layout = widget2.layout.horizontal.flex},
                                }
    end
    
    for i=1 , 10 do
        local protocol3        = capi.widget({type = "textbox"})
        protWidget[i]          = protocol3
        protWidgetW[i]         = wibox({ position = "free" , screen = s , ontop = true})
        protWidgetW[i].visible = false
        protWidgetW[i].widgets = {protocol3,layout = widget2.layout.horizontal.leftright}
    end

    function show()
        if not data.menu or data.menu.settings.visible == false then
            update() 
            data.menu = repaint()
            data.menu:toggle(true)
        else
            data.menu:toggle(false)
        end
    end

    netDownWidget.width = 55
    netUpWidget.width   = 55
    uplogo.image        = capi.image(config.data.iconPath .. "arrowUp.png"      )
    downlogo.image      = capi.image(config.data.iconPath .. "arrowDown.png"    )
    vicious.register(netUpWidget,   vicious.widgets.net, '${eth0 up_kb}KBs'   ,1)
    vicious.register(netDownWidget, vicious.widgets.net, '${eth0 down_kb}KBs' ,1) 
    
    downlogo:buttons      (util.table.join(button({ }, 1, function () show() end)))
    netDownWidget:buttons (util.table.join(button({ }, 1, function () show() end)))
    uplogo:buttons        (util.table.join(button({ }, 1, function () show() end)))
    netUpWidget:buttons   (util.table.join(button({ }, 1, function () show() end)))
    return {down_logo = downlogo, down_text = netDownWidget, up_logo = uplogo, up_text = netUpWidget}
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })