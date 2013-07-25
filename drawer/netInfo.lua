local setmetatable = setmetatable
local io           = io
local next         = next
local ipairs       = ipairs
local loadstring   = loadstring
local table        = table
local print        = print
local beautiful    = require( "beautiful"                )
local widget2      = require( "awful.widget"             )
local wibox        = require( "wibox"                    )
local button       = require( "awful.button"             )
local vicious      = require( "extern.vicious"           )
local util         = require( "awful.util"               )
local config       = require( "forgotten"                )
local menu         = require( "radical.context"          )
local themeutils   = require( "blind.common.drawing"     )
local radtab       = require( "radical.widgets.table"    )
local embed        = require( "radical.embed"            )
local radical      = require( "radical"                  )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo

local capi = { widget = widget , client = client ,
               mouse  = mouse  , timer  = timer  }

local module = {}

--DATA
local data, connectionInfo, protocolStat, appStat = {},{},{},{}

--WIDGET
local ip4Info          , ip6Info          , localInfo        , netUsageUp
local downloadImg      , uploadImg        , netUsageDown     , appHeader
local downlogo         , uplogo           , netUpGraph       , netDownGraph

local function update()
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
    local ip4Value = "\n<i><b>  v4: </b>" .. (f:read("*line") or "") .. "</i>"
    f:close()
    f = io.popen('/bin/ifconfig | grep -e "inet6[a-z: ]*[0-9.A-Fa-f;:]*" -o | awk \'{print $(NF)}\'')
    local ip6Value = "<i><b>  v6: </b>" .. (f:read("*line") or "") .. "</i>\n\n\n."
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
            local application          = wibox.widget.textbox()
            application.fit = function()
                return 48,connMenu.item_height
            end
            application.draw = function(self,w, cr, width, height)
                cr:save()
                cr:set_source(color(connMenu.bg_alternate))
                cr:rectangle(height/2,0,width-height/2,height)
                cr:fill()
                cr:set_source_surface(themeutils.get_beg_arrow2({bg_color=connMenu.bg_alternate,direction="left"}),0,0)
                cr:paint()
                cr:restore()
                wibox.widget.textbox.draw(self,w, cr, width, height)
            end
            application:set_text(data.connectionInfo[i]['protocol'].." "    or "")
            application:set_align("right")

            local icon = nil
            for k2,v2 in ipairs(capi.client.get()) do
                if v2.class:lower() == data.connectionInfo[i]['application']:lower() or v2.name:lower():find(data.connectionInfo[i]['application']:lower()) ~= nil then
                    icon  = v2.icon
                    break
                end
            end
            print("adding",data.connectionInfo[i]['application'  ],appStat[data.connectionInfo[i]['application'  ] ] )
            appStat[data.connectionInfo[i]['application'  ] ] = (appStat[data.connectionInfo[i]['application'  ] ]or 0) + 1
            protocolStat[data.connectionInfo[i]['protocol'] ] = (protocolStat[data.connectionInfo[i]['protocol'   ] ] or 0) + 1
            print("now",appStat[data.connectionInfo[i]['application'  ] ])
            connMenu:add_item({text=(data.connectionInfo[i]['site'] or ""),icon=icon,suffix_widget=application})
        end
    end
end

local function reload_protstat(protMenu,data)
    protMenu:clear()
    for v, i in next, protocolStat do
        local protocol3   = wibox.widget.textbox()
        local protoCount  = wibox.widget.textbox()
        local statHl = wibox.layout.fixed.horizontal()
        statHl:add(protoCount)
        statHl:add(protocol3)
        protoCount:set_text("x"..i)
        protocol3:set_text(v)
        protMenu:add_widget(statHl,{height = 20, width = 200})
    end
end

local function reload_appstat(appMenu,data)
    appMenu:clear()
    for v, i in next, appStat do
        testImage2             = wibox.widget.imagebox()
        testImage2:set_image(config.iconPath .. "kill.png"       )
        local icon =nil
        for k2,v2 in ipairs(capi.client.get()) do
            if v2.class:lower() == v:lower() or v2.name:lower():find(v:lower()) ~= nil then
                icon  = v2.icon
                break
            end
        end
        print("this",i)
        appMenu:add_item({text=v,suffix_widget=testImage2,icon=icon,underlay = beautiful.draw_underlay(i)})
    end
end

local connMenu,protMenu,appMenu

local function update2()
    reload_conn(connMenu,data)
    reload_protstat(protMenu,data)
    reload_appstat(appMenu,data)
end

local function repaint(margin)

    local ipInfoVl  = wibox.layout.fixed.vertical()
    local ipInfoH1l = wibox.layout.fixed.horizontal()
    ipInfoH1l:add(ip4Info)
    local ipInfoH2l = wibox.layout.fixed.horizontal()
    ipInfoH2l:add(ip6Info)
    ipInfoVl:add(ipInfoH1l)
    ipInfoVl:add(ipInfoH2l)

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

    uploadImg:set_image(config.iconPath .. "arrowUp.png"  )
    uploadImg.fit = function(...) return 20,20 end
    downloadImg:set_image(config.iconPath .. "arrowDown.png")
    downloadImg.fit = function(...) return 20,20 end
    netUsageUp:set_markup("<b>Up: </b>")
    netUsageDown:set_markup("<b>Down: </b>")

    local graphUWH1l = wibox.layout.fixed.horizontal()
    graphUWH1l:add( uploadImg  )
    graphUWH1l:add( netUsageUp )

    local graphDWH1l = wibox.layout.fixed.horizontal()
    graphDWH1l:add( downloadImg  )
    graphDWH1l:add( netUsageDown )

    local mainMenu = menu({width=200,arrow_type=radical.base.arrow_type.CENTERED})
    mainMenu:add_widget(radical.widgets.header(mainMenu,"GRAPH"),{height = 20 , width = 200})
    mainMenu:add_widget(graphUWH1l      ,{height = 20, width = 200})
    mainMenu:add_widget(netUpGraph      ,{height = 30, width = 200})
    mainMenu:add_widget(graphDWH1l      ,{height = 20, width = 200})
    mainMenu:add_widget(netDownGraph      ,{height = 30, width = 200})
    mainMenu:add_widget(radical.widgets.header(mainMenu,"IP"),{height = 20 , width = 200})
    mainMenu:add_widget(ipInfoVl       ,{height = 40, width = 200})

    local imb = wibox.widget.imagebox()
    imb:set_image(beautiful.path .. "Icon/reload.png")
    mainMenu:add_widget(radical.widgets.header(mainMenu,"CONNECTIONS",{suffix_widget=imb}),{height = 20 , width = 200})

    if data.connectionInfo ~= nil then
        connMenu = embed({width=198,max_items=5,has_decoration=false,has_side_deco=true})
        mainMenu:add_embeded_menu(connMenu)
    end
    mainMenu:add_widget(radical.widgets.header(mainMenu,"PROTOCOLS",{suffix_widget=imb}),{height = 20 , width = 200})

    protMenu = embed({width=198,max_items=5,has_decoration=false,has_side_deco=true})
    mainMenu:add_embeded_menu(protMenu)

    mainMenu:add_widget(radical.widgets.header(mainMenu,"APPLICATIONS",{suffix_widget=imb}),{height = 20 , width = 200})

    appMenu = embed({width=198,max_items=3,has_decoration=false,has_side_deco=true})
    mainMenu:add_embeded_menu(appMenu)
    return mainMenu
end

local function new(margin, args)
    ip4Info          = wibox.widget.textbox()
    ip6Info          = wibox.widget.textbox()
    localInfo        = wibox.widget.textbox()
    netUsageUp       = wibox.widget.textbox()
    netUsageDown     = wibox.widget.textbox()
    appHeader        = wibox.widget.textbox()
    downloadImg      = wibox.widget.imagebox()
    uploadImg        = wibox.widget.imagebox()
    downlogo         = wibox.widget.imagebox()
    uplogo           = wibox.widget.imagebox()
    netUpGraph       = widget2.graph(                  )
    netDownGraph     = widget2.graph(                  )
    local function show()
        if not data.menu or data.menu.visible ~= true then
            update()
            if not data.menu then
                data.menu = repaint(margin)
            end
            update2()
            data.menu.visible = true
        else
            data.menu.visible = false
        end
    end

    local netDownWidget    = wibox.widget.textbox()
    local netUpWidget      = wibox.widget.textbox()
    uplogo:set_image(themeutils.apply_color_mask(config.iconPath .. "arrowUp.png"         ))
    downlogo:set_image(themeutils.apply_color_mask(config.iconPath .. "arrowDown.png"       ))
    vicious.register(netUpWidget  , vicious.widgets.net   ,  '${eth0 up_kb}KBs'   ,3 )
    vicious.register(netDownWidget, vicious.widgets.net   ,  '${eth0 down_kb}KBs' ,3 )
    local btn = util.table.join(button({ }, 1, function (geo) show();data.menu.parent_geometry=geo end))

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
    l:buttons(btn)
    return l
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })