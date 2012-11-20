local setmetatable = setmetatable
local io           = io
local next         = next
local ipairs       = ipairs
local loadstring   = loadstring
local table        = table
local print        = print
local beautiful    = require( "beautiful"      )
local widget2      = require( "awful.widget"   )
local wibox        = require( "awful.wibox"    )
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
local graphHeader      = capi.widget({type = "textbox"  })
local ipHeader         = capi.widget({type = "textbox"  })
local localHeader      = capi.widget({type = "textbox"  })
local connHeader       = capi.widget({type = "textbox"  })
local protHeader       = capi.widget({type = "textbox"  })
local appHeader        = capi.widget({type = "textbox"  })
local ip4Info          = capi.widget({type = "textbox"  })
local ip6Info          = capi.widget({type = "textbox"  })
local localInfo        = capi.widget({type = "textbox"  })
local netUsageUp       = capi.widget({type = "textbox"  })
local downloadImg      = capi.widget({type = "imagebox" })
local uploadImg        = capi.widget({type = "imagebox" })
local netUsageDown     = capi.widget({type = "textbox"  })
local netSpacer        = capi.widget({type = "textbox"  })
local appHeader        = capi.widget({type = "textbox"  })
local downlogo         = capi.widget({type = "imagebox" })
local uplogo           = capi.widget({type = "imagebox" })
local netDownWidget    = capi.widget({type = 'textbox'  })
local netUpWidget      = capi.widget({type = 'textbox'  })
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

    ip4Info.text = ip4Value
    ip6Info.text = ip6Value

    local localValue = ""
    f = io.open('/tmp/localNetLookup','r')
    if f ~= nil then
        localValue = f:read("*all")
        f:close()
    end

    localInfo.text = localValue
end

local function reload_conn(connMenu,data)
    connMenu:clear()
    for i=0 , #(data.connectionInfo or {}) do
        if data.connectionInfo[i] then
            local protocol             = capi.widget({ type = "textbox"  })
            protocol.width             = 25
            protocol.bg                = "#0F2051"
            protocol.border_width      = 1
            protocol.border_color      = beautiful.bg_normal
            local application          = capi.widget({ type = "textbox"  })
            application.width          = 40
            application.bg             = "#0F2051"
            application.border_width   = 1
            application.border_color   = beautiful.bg_normal
            local address              = capi.widget({ type = "textbox"  })

            local w         = wibox({ position = "free" , screen = s , ontop = true, bg = beautiful.menu_bg     })
            w.visible = false
            w.widgets = {
                            application                                               ,
                            {protocol,layout = widget2.layout.horizontal.rightleftcached}   ,
                            layout = widget2.layout.horizontal.leftrightcached              ,
                            {address,layout = widget2.layout.horizontal.flexcached}         ,
                        }

            application:margin({ left = 7, right = 7 })
            application.text =        (data.connectionInfo[i]['protocol']    or "")
            address.text     = " " .. (data.connectionInfo[i]['site']        or "")

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
                protocol.text =  (data.connectionInfo[i]['application']    or "")
                protocol.bg_image = nil
            else
                protocol.text = ""
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
        local protocol3   = capi.widget({ type = "textbox"                        })
        local protoCount  = capi.widget({ type = "textbox"                        })
        protoCount.bg     = "#0F2051"
        protoCount.width  = 20
        local w           = wibox({ position = "free" , screen = s , ontop = true , bg = beautiful.menu_bg})
        w.visible         = false
        w.widgets         = {
                                protoCount                                   ,
                                protocol3                                    ,
                                layout = widget2.layout.horizontal.leftrightcached ,
                            }
        protoCount:margin({ left = 7, right = 7 })
        protoCount.text = "x"..i
        protocol3:margin({ left = 7, right = 7 })
        protocol3.text = v
        protMenu:add_wibox(w,{height = 20, width = 200})
    end
end

local function reload_appstat(appMenu,data)
    appMenu:clear()
    for v, i in next, appStat do
        local appIcon          = capi.widget({ type = "textbox"                        })
        appIcon.width          = 25
        appIcon.bg             = "#0F2051"
        appIcon.border_color   = beautiful.bg_normal
        appIcon.border_width   = 1
        local app2             = capi.widget({ type = "textbox"                        })
        testImage2             = capi.widget({ type = "imagebox"                       })
        testImage2.image       = capi.image (config.data().iconPath .. "kill.png"       )
        local w                = wibox({ position = "free" , screen = s , ontop = true , bg = beautiful.menu_bg})
        w.visible              = false
        w.widgets              = {
                                    appIcon                                                   ,
                                    {testImage2,layout = widget2.layout.horizontal.rightleftcached} ,
                                    layout = widget2.layout.horizontal.leftrightcached              ,
                                    {app2,layout = widget2.layout.horizontal.flexcached}            ,
                                 }

        app2.text = " " .. v .."("..i..")"
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

    graphHeaderW.visible = false
    ipHeaderW.visible    = false
--     localHeaderW.visible = false
    connHeaderW.visible  = false
    protHeaderW.visible  = false
    appHeaderW.visible   = false

    graphHeaderW.widgets = { graphHeader , layout = widget2.layout.horizontal.leftrightcached }
    ipHeaderW.widgets    = { ipHeader    , layout = widget2.layout.horizontal.leftrightcached }
--     localHeaderW.widgets = { localHeader , layout = widget2.layout.horizontal.leftright }
    connHeaderW.widgets  = { connHeader  , layout = widget2.layout.horizontal.leftrightcached }
    protHeaderW.widgets  = { protHeader  , layout = widget2.layout.horizontal.leftrightcached }
    appHeaderW.widgets   = { appHeader   , layout = widget2.layout.horizontal.leftrightcached }

    ipInfo.visible = false
    ipInfo.widgets = {
        {ip4Info  , layout = widget2.layout.horizontal.leftrightcached},
        {ip6Info  , layout = widget2.layout.horizontal.leftrightcached},
        layout = widget2.layout.vertical.flexcached
    }

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

    uploadImg.image    = capi.image(config.data().iconPath .. "arrowUp.png"  )
    uploadImg.resize   = false
    downloadImg.image  = capi.image(config.data().iconPath .. "arrowDown.png")
    downloadImg.resize = false
    netUsageUp.text    = "<b>Up: </b>"
    netUsageDown.text  = "<b>Down: </b>"
    netSpacer.text     = " "
    netSpacer.width    = 10

    graphUW.visible = false
    graphUW.widgets = {
        {uploadImg    , netUsageUp   , layout = widget2.layout.horizontal.leftrightcached},
        {netUpGraph   ,                layout = widget2.layout.horizontal.leftrightcached},
        layout = widget2.layout.vertical.flexcached
    }

    graphDW.visible = false
    graphDW.widgets = {
        {downloadImg  , netUsageDown , layout = widget2.layout.horizontal.leftrightcached},
        {netDownGraph ,                layout = widget2.layout.horizontal.leftrightcached},
        {netSpacer    ,                layout = widget2.layout.horizontal.leftrightcached},
        layout = widget2.layout.vertical.flexcached
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

    netDownWidget.width = 55
    netUpWidget.width   = 55
    uplogo.image        = capi.image(config.data().iconPath .. "arrowUp.png"         )
    downlogo.image      = capi.image(config.data().iconPath .. "arrowDown.png"       )
    vicious.register(netUpWidget  , vicious.widgets.net   ,  '${eth0 up_kb}KBs'   ,1 )
    vicious.register(netDownWidget, vicious.widgets.net   ,  '${eth0 down_kb}KBs' ,1 )
    local btn = util.table.join(button({ }, 1, function () show() end))
    for k,v in ipairs({downlogo,netDownWidget,uplogo,netUpWidget}) do v:buttons(btn) end

    for k,v in ipairs({downlogo,netDownWidget,uplogo,netUpWidget}) do
        v.bg = beautiful.bg_alternate
    end
    return {down_logo = downlogo      ,
            down_text = netDownWidget ,
            up_logo   = uplogo        ,
            up_text   = netUpWidget   }
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })