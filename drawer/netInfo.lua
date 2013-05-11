local setmetatable = setmetatable
local io           = io
local next         = next
local ipairs       = ipairs
local loadstring   = loadstring
local table        = table
local print        = print
local beautiful    = require( "beautiful"      )
local widget2      = require( "awful.widget"   )
local wibox        = require( "wibox"          )
local button       = require( "awful.button"   )
local vicious      = require( "extern.vicious" )
local util         = require( "awful.util"     )
local config       = require( "config"         )
local menu         = require( "widgets.menu"   )

local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               client = client ,
               mouse  = mouse  ,
               timer  = timer  }

module("drawer.netInfo")

--DATA
local data             = {}
local connectionInfo   = {}
local protocolStat     = {}
local appStat          = {}

--WIBOX
local graphHeaderW     = nil
local ipHeaderW        = nil
local localHeaderW     = nil
local connHeaderW      = nil
local protHeaderW      = nil
local ipInfo           = nil
local graphUW          = nil
local graphDW          = nil

--WIDGET
local graphHeader      = wibox.widget.textbox()
local ipHeader         = wibox.widget.textbox()
local localHeader      = wibox.widget.textbox()
local connHeader       = wibox.widget.textbox()
local protHeader       = wibox.widget.textbox()
local appHeader        = wibox.widget.textbox()
local ip4Info          = wibox.widget.textbox()
local ip6Info          = wibox.widget.textbox()
local localInfo        = wibox.widget.textbox()
local netUsageUp       = wibox.widget.textbox()
local downloadImg      = wibox.widget.imagebox()
local uploadImg        = wibox.widget.imagebox()
local netUsageDown     = wibox.widget.textbox()
local netSpacer        = wibox.widget.textbox()
local appHeader        = wibox.widget.textbox()
local downlogo         = wibox.widget.imagebox()
local uplogo           = wibox.widget.imagebox()
local netUpGraph       = widget2.graph(                  )
local netDownGraph     = widget2.graph(                  )

--VARIABLES

function update()
    local connectionInfo
    local f = io.open('/tmp/connectedHost.lua','r')
    if f ~= nil then
        local text3 = f:read("*all") .. " return connectionInfo"
        f:close()
        afunction   = loadstring(text3)
        if afunction == nil then
            return { count = o, widgets = widgetTable2}
        end
        connectionInfo = afunction()
    end

    if connectionInfo ~= nil then
        data.connectionInfo = connectionInfo
    end

    f = io.popen('/bin/ifconfig | grep -e "inet[a-z: ]*[0-9.]*" -o |  grep -e "[0-9.]*" -o')
    local ip4Value = "<i><b>  v4: </b>" .. (f:read("*line") or "") .. "</i>"
    f:close()
    f = io.popen('/bin/ifconfig | grep -e "inet6[a-z: ]*[0-9.A-Fa-f;:]*" -o | awk \'{print $(NF)}\'')
    local ip6Value = "<i><b>  v6: </b>" .. (f:read("*line") or "") .. "</i>\n\n"
    f:close()

    ip4Info:set_markup(ip4Value)
    ip6Info:set_markup(ip6Value)

    local localValue = ""
    f = io.open('/tmp/localNetLookup','r')
    if f ~= nil then
        localValue = f:read("*all")
        f:close()
    end

    localInfo:set_text(localValue)
end

local function reload_conn(connMenu,data)
    connMenu:clear()
    for i=0 , #(data.connectionInfo or {}) do
        if data.connectionInfo[i] then
            local protocol             = wibox.widget.textbox()
            protocol.width             = 25
            protocol.bg                = "#0F2051"
            protocol.border_width      = 1
            protocol.border_color      = beautiful.bg_normal
            local application          = wibox.widget.textbox()
            application.width          = 40
            application.bg             = "#0F2051"
            application.border_width   = 1
            application.border_color   = beautiful.bg_normal
            local address              = wibox.widget.textbox()

            local w         = wibox({ position = "free" , screen = s , ontop = true, bg = beautiful.menu_bg     })
            w.visible = false
--             w.widgets = {
--                             application                                               ,
--                             {protocol,layout = widget2.layout.horizontal.rightleftcached}   ,
--                             layout = widget2.layout.horizontal.leftrightcached              ,
--                             {address,layout = widget2.layout.horizontal.flexcached}         ,
--                         }

            local protocolH1l = wibox.layout.align.horizontal()
            protocolH1l:set_left(application)
            protocolH1l:set_middle(address)
            protocolH1l:set_right(protocol)
            w:set_widget(protocolH1l)

--             application:margin({ left = 7, right = 7 })
            application:set_text(data.connectionInfo[i]['protocol']    or "")
            address:set_text(" " .. (data.connectionInfo[i]['site']        or ""))

            local found = false
            for k2,v2 in ipairs(capi.client.get()) do
                if v2.class:lower() == data.connectionInfo[i]['application']:lower() or v2.name:lower():find(data.connectionInfo[i]['application']:lower()) ~= nil then
                    protocol.bg_image  = v2.icon
                    protocol.bg_resize = true
                    found = true
                    break
                end
            end

            if found == false then
                protocol:set_text(data.connectionInfo[i]['application']    or "")
                protocol.bg_image = nil
            else
                protocol:set_text("")
            end
            appStat[data.connectionInfo[i]['application'  ] ] = (protocolStat[data.connectionInfo[i]['application'] ] or 0) + 1
            protocolStat[data.connectionInfo[i]['protocol'] ] = (protocolStat[data.connectionInfo[i]['protocol'   ] ] or 0) + 1
            connMenu:add_wibox(w ,{height = 20, width = 200})
        end
    end
end

local function reload_protstat(protMenu,data)
    protMenu:clear()
    for v, i in next, protocolStat do
        local protocol3   = wibox.widget.textbox()
        local protoCount  = wibox.widget.textbox()
        protoCount.bg     = "#0F2051"
        protoCount.width  = 20
        local w           = wibox({ position = "free" , screen = s , ontop = true , bg = beautiful.menu_bg})
        w.visible         = false
--         w.widgets         = {
--                                 protoCount                                   ,
--                                 protocol3                                    ,
--                                 layout = widget2.layout.horizontal.leftrightcached ,
--                             }
        local statHl = wibox.layout.fixed.horizontal()
        statHl:add(protoCount)
        statHl:add(protocol3)
        w:set_widget(statHl)
--         protoCount:margin({ left = 7, right = 7 })
        protoCount:set_text("x"..i)
--         protocol3:margin({ left = 7, right = 7 })
        protocol3:set_text(v)
        protMenu:add_wibox(w,{height = 20, width = 200})
    end
end

local function reload_appstat(appMenu,data)
    appMenu:clear()
    for v, i in next, appStat do
        local appIcon          = wibox.widget.textbox()
        appIcon.width          = 25
        appIcon.bg             = "#0F2051"
        appIcon.border_color   = beautiful.bg_normal
        appIcon.border_width   = 1
        local app2             = wibox.widget.textbox()
        testImage2             = wibox.widget.imagebox()
        testImage2:set_image(config.data().iconPath .. "kill.png"       )
        local w                = wibox({ position = "free" , screen = s , ontop = true , bg = beautiful.menu_bg})
        w.visible              = false
--         w.widgets              = {
--                                     appIcon                                                   ,
--                                     {testImage2,layout = widget2.layout.horizontal.rightleftcached} ,
--                                     layout = widget2.layout.horizontal.leftrightcached              ,
--                                     {app2,layout = widget2.layout.horizontal.flexcached}            ,
--                                  }
        local appstatHl = wibox.layout.align.horizontal()
        appstatHl:set_left(appIcon)
        appstatHl:set_middle(app2)
        appstatHl:set_right(testImage2)

        app2:set_text(" " .. v .."("..i..")")
        for k2,v2 in ipairs(capi.client.get()) do
            if v2.class:lower() == v:lower() or v2.name:lower():find(v:lower()) ~= nil then
                appIcon.bg_image  = v2.icon
                appIcon.bg_resize = true
                break
            end
        end
        appMenu:add_wibox(w,{height = 20, width = 200})
    end
end

local connMenu,protMenu,appMenu

local function update2()
    reload_conn(connMenu,data)
    reload_protstat(protMenu,data)
    reload_appstat(appMenu,data)
end

local function repaint(margin)
    graphHeaderW         = wibox({ position = "free" , screen = s , ontop = true,height = 20, bg = beautiful.menu_bg})
    ipHeaderW            = wibox({ position = "free" , screen = s , ontop = true,height = 20, bg = beautiful.menu_bg})
--     localHeaderW         = wibox({ position = "free" , screen = s , ontop = true,height = 20, bg = beautiful.menu_bg})
    connHeaderW          = wibox({ position = "free" , screen = s , ontop = true,height = 20, bg = beautiful.menu_bg})
    protHeaderW          = wibox({ position = "free" , screen = s , ontop = true,height = 20, bg = beautiful.menu_bg})
    appHeaderW           = wibox({ position = "free" , screen = s , ontop = true,height = 20, bg = beautiful.menu_bg})
    ipInfo               = wibox({ position = "free" , screen = s , ontop = true,height = 30, bg = beautiful.menu_bg})
    graphUW              = wibox({ position = "free" , screen = s , ontop = true,height = 50, bg = beautiful.menu_bg})
    graphDW              = wibox({ position = "free" , screen = s , ontop = true,height = 50, bg = beautiful.menu_bg})
    
    graphHeaderW:set_bg(beautiful.fg_normal)
    ipHeaderW:set_bg(beautiful.fg_normal)
    connHeaderW:set_bg(beautiful.fg_normal)
    protHeaderW:set_bg(beautiful.fg_normal)
    appHeaderW:set_bg(beautiful.fg_normal)
    
    

    graphHeaderW.visible = false
    ipHeaderW.visible    = false
--     localHeaderW.visible = false
    connHeaderW.visible  = false
    protHeaderW.visible  = false
    appHeaderW.visible   = false

    local graphHeaderWl = wibox.layout.fixed.horizontal();graphHeaderWl:add( graphHeader )
    local ipHeaderWl    = wibox.layout.fixed.horizontal();ipHeaderWl:add   ( ipHeader    )
    local connHeaderWl  = wibox.layout.fixed.horizontal();connHeaderWl:add ( connHeader  )
    local protHeaderWl  = wibox.layout.fixed.horizontal();protHeaderWl:add ( protHeader  )
    local appHeaderWl   = wibox.layout.fixed.horizontal();appHeaderWl:add  ( appHeader   )
    
    graphHeaderW:set_widget(graphHeaderWl)
    ipHeaderW:set_widget(ipHeaderWl)
--     localHeaderW.widgets = { localHeader , layout = widget2.layout.horizontal.leftright }
    connHeaderW:set_widget(connHeaderWl)
    protHeaderW:set_widget(protHeaderWl)
    appHeaderW:set_widget(appHeaderWl)

    ipInfo.visible = false
--     ipInfo.widgets = {
--         {ip4Info  , layout = widget2.layout.horizontal.leftrightcached},
--         {ip6Info  , layout = widget2.layout.horizontal.leftrightcached},
--         layout = widget2.layout.vertical.flexcached
--     }
    local ipInfoVl  = wibox.layout.fixed.vertical()
    local ipInfoH1l = wibox.layout.fixed.horizontal()
    ipInfoH1l:add(ip4Info)
    local ipInfoH2l = wibox.layout.fixed.horizontal()
    ipInfoH2l:add(ip6Info)
    ipInfoVl:add(ipInfoH1l)
    ipInfoVl:add(ipInfoH2l)
    ipInfo:set_widget(ipInfoVl)

    local function setup_graph(g)
        g:set_width             (190                )
        g:set_height            (20                 )
        g:set_scale             (true               )
        g:set_background_color  (beautiful.bg_normal)
        g:set_border_color      (beautiful.fg_normal)
        g:set_color             (beautiful.fg_normal)
    end
    setup_graph(netUpGraph)
    vicious.register                 (netUpGraph, vicious.widgets.net  , '${eth0 up_kb}'  ,1)
    setup_graph(netDownGraph)
    vicious.register                 (netDownGraph, vicious.widgets.net, '${eth0 down_kb}',1)

    uploadImg:set_image(config.data().iconPath .. "arrowUp.png"  )
    uploadImg.resize   = false
    downloadImg:set_image(config.data().iconPath .. "arrowDown.png")
    downloadImg.resize = false
    netUsageUp:set_markup("<b>Up: </b>")
    netUsageDown:set_markup("<b>Down: </b>")
    netSpacer:set_text(" ")
    netSpacer.width    = 10

    graphUW.visible = false
--     graphUW.widgets = {
--         {uploadImg    , netUsageUp   , layout = widget2.layout.horizontal.leftrightcached},
--         {netUpGraph   ,                layout = widget2.layout.horizontal.leftrightcached},
--         layout = widget2.layout.vertical.flexcached
--     }
    local graphUWVl  = wibox.layout.fixed.vertical  ()
    local graphUWH1l = wibox.layout.fixed.horizontal()
    local graphUWH2l = wibox.layout.fixed.horizontal()
    graphUWH1l:add( uploadImg  )
    graphUWH1l:add( netUsageUp )
    graphUWH2l:add( netUpGraph )
    graphUWVl:add ( graphUWH1l )
    graphUWVl:add ( graphUWH2l )
    graphUW:set_widget(graphUWVl)

    graphDW.visible = false
--     graphDW.widgets = {
--         {downloadImg  , netUsageDown , layout = widget2.layout.horizontal.leftrightcached},
--         {netDownGraph ,                layout = widget2.layout.horizontal.leftrightcached},
--         {netSpacer    ,                layout = widget2.layout.horizontal.leftrightcached},
--         layout = widget2.layout.vertical.flexcached
--     }
    local graphDWVl  = wibox.layout.fixed.vertical  ()
    local graphDWH1l = wibox.layout.fixed.horizontal()
    local graphDWH2l = wibox.layout.fixed.horizontal()
    graphDWH1l:add( downloadImg  )
    graphDWH1l:add( netUsageDown )
    graphDWH2l:add( netDownGraph )
    graphUWVl:add ( graphDWH1l   )
    graphUWVl:add ( graphDWH2l   )
    graphUWVl:add ( netSpacer    )
    graphDW:set_widget(graphUWVl)
    

    function formatHeader(wdg,txt)
        wdg:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>".. txt .."</tt></b></span> ")
        wdg.bg     = beautiful.fg_normal
        wdg.width  = 240
    end

    formatHeader(graphHeader ,"GRAPH"         )
    formatHeader(ipHeader    ,"IP"            )
    formatHeader(localHeader ,"LOCAL NETWORK" )
    formatHeader(connHeader  ,"CONNECTIONS"   )
    formatHeader(protHeader  ,"APPLICATIONS"  )
    formatHeader(appHeader   ,"PROTOCOLS"     )

    local mainMenu = menu({arrow_x=90})
    mainMenu.settings.itemWidth = 200
    mainMenu:add_wibox(graphHeaderW ,{height = 20, width = 200})
    mainMenu:add_wibox(graphUW      ,{height = 40, width = 200})
    mainMenu:add_wibox(graphDW      ,{height = 50, width = 200})
    mainMenu:add_wibox(ipHeaderW    ,{height = 20, width = 200})
    mainMenu:add_wibox(ipInfo       ,{height = 30, width = 200})
--     mainMenu:add_wibox(localHeaderW ,{height = 20, width = 200})
    mainMenu:add_wibox(connHeaderW  ,{height = 20, width = 200})

    if data.connectionInfo ~= nil then
        connMenu = menu({width=198,maxvisible=3,has_decoration=false,has_side_deco=true})
        mainMenu:add_embeded_menu(connMenu)
    end
    mainMenu:add_wibox(appHeaderW,{height = 20, width = 200})

    protMenu = menu({width=198,maxvisible=7,has_decoration=false,has_side_deco=true})
    mainMenu:add_embeded_menu(protMenu)

    mainMenu:add_wibox(protHeaderW ,{height = 20, width = 200})

    appMenu = menu({width=198,maxvisible=7,has_decoration=false,has_side_deco=true})
    mainMenu:add_embeded_menu(appMenu)

    mainMenu.settings.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x - margin + 20
    mainMenu.settings.y = 16
    return mainMenu
end

function new(margin, args)
    graphHeaderW = nil
    ipHeaderW = nil
--     localHeaderW      
    connHeaderW = nil
    protHeaderW = nil
    appHeaderW = nil
    ipInfo = nil
    graphUW = nil
    graphDW = nil

    function show()
        if not data.menu or data.menu.settings.visible ~= true then
            update()
            if not data.menu then
                data.menu = repaint(margin)
            end
            update2()
            data.menu:toggle( true  )
        else
            data.menu:toggle( false )
        end
    end

    local netDownWidget    = wibox.widget.textbox()
    local netUpWidget      = wibox.widget.textbox()
    netDownWidget.width = 55
    netUpWidget.width   = 55
    uplogo:set_image(config.data().iconPath .. "arrowUp.png"         )
    downlogo:set_image(config.data().iconPath .. "arrowDown.png"       )
    vicious.register(netUpWidget  , vicious.widgets.net   ,  '${eth0 up_kb}KBs'   ,3 )
    vicious.register(netDownWidget, vicious.widgets.net   ,  '${eth0 down_kb}KBs' ,3 )
    local btn = util.table.join(button({ }, 1, function () show() end))
    for k,v in ipairs({downlogo,netDownWidget,uplogo,netUpWidget}) do v:buttons(btn) end

    for k,v in ipairs({downlogo,netDownWidget,uplogo,netUpWidget}) do
        v.bg = beautiful.bg_alternate
    end
    
    netDownWidget.fit = function(box, w, h)
        local w, h = wibox.widget.textbox.fit(box, w, h)
        return 55, h
    end
    
    netUpWidget.fit = function(box, w, h)
        local w, h = wibox.widget.textbox.fit(box, w, h)
        return 55, h
    end

    local l = wibox.layout.fixed.horizontal()
    l:add(downlogo)
    l:add(netDownWidget)
    l:add(uplogo)
    l:add(netUpWidget)
    return l--[[{down_logo = downlogo      ,
            down_text = netDownWidget ,
            up_logo   = uplogo        ,
            up_text   = netUpWidget   }]]
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })