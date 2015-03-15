local setmetatable = setmetatable
local io           = io
local next         = next
local ipairs       = ipairs
local loadstring   = loadstring
local table        = table
local print        = print
local math         = math
local beautiful    = require( "beautiful"                )
local widget2      = require( "awful.widget"             )
local wibox        = require( "wibox"                    )
local button       = require( "awful.button"             )
local vicious      = require("extern.vicious")
local util         = require( "awful.util"               )
local config       = require( "forgotten"                )
local menu         = require( "radical.context"          )
local themeutils   = require( "blind.common.drawing"     )
local embed        = require( "radical.embed"            )
local radical      = require( "radical"                  )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo
local allinone     = require( "widgets.allinone"         )
local fd_async = require("utils.fd_async")

local capi = { widget = widget , client = client}

local module = {}

--DATA
local protocolStat, appStat = {},{}
local data={connectionInfo={},ip={}}
local connLookup={ ["site"]=1,["pid"]=2,["application"]=3,["protocol"]=4}

--WIDGET
local ip4Info          , ipExtInfo          , localInfo        , netUsageUp
local netUsageDown     , appHeader        , netUpGraph       , netDownGraph
local ip4lbl           , ip6lbl           , mainMenu

--MENUS
local connMenu,protMenu,appMenu
local connNum = -1

local function update()
    --Load connectionInfo data (ASYNC)
    fd_async.exec.command(util.getdir("config")..'/drawer/Scripts/connectedHost3.sh'):connect_signal("new::line",function(content)
            --Check if first line
            if connNum == -1 then
                --Get connections number (First line)
                connNum=tonumber(content) or 0
                --print("INFO@netInfo: ",connNum," connection(s) found")
            elseif connNum == 0 then
                --All line read, Repaint all!
                connMenu:clear()
                for i=0 , #(data.connectionInfo or {}) do
                    if data.connectionInfo[i] then
                        -- Reset application connection count
                        if data.connectionInfo[i][connLookup['application']] ~= nil then
                            appStat[data.connectionInfo[i][connLookup['application']] ] = 0
                        end

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
                        application:set_markup("<b>"..data.connectionInfo[i][connLookup['protocol']].." </b>")
                        application:set_align("right")

                        local icon = nil
                        for k2,v2 in ipairs(capi.client.get()) do
                            if v2.class:lower() == data.connectionInfo[i][connLookup['application']]:lower() or v2.name:lower():find(data.connectionInfo[i][connLookup['application']]:lower()) ~= nil then
                                icon  = v2.icon
                                break
                            end
                        end
                        appStat[data.connectionInfo[i][connLookup['application'  ]] ] = (appStat[data.connectionInfo[i][connLookup['application' ] ] ]or 0) + 1
                        protocolStat[data.connectionInfo[i][connLookup['protocol']] ] = (protocolStat[data.connectionInfo[i][connLookup['protocol' ]  ] ] or 0) + 1
                        connMenu:add_item({text=(data.connectionInfo[i][connLookup['site']] or ""),icon=icon,suffix_widget=application})
                    end
                end

                --Repaint protocol stat graph
                protMenu:set_data(protocolStat)

                --Repaint application stat
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
                    appMenu:add_item({text=v,suffix_widget=testImage2,icon=icon,underlay = i})
                end
            else
                -- Load line into data
                if content == nil then print ("This shouldn't happen...")
                else      data.connectionInfo[connNum]=content:split(",")
                end
            end

            -- Decrease connection left number
            connNum=connNum-1
        end)


    --Get local ipv4
    local f = io.popen("ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'")
    data.ip['local4'] = f:read("*line") or "N/A"
    f:close()
    ip4Info:set_markup("<i>"..data.ip['local4'] .. "</i>")

    --Get wan ip from OpenDns
    fd_async.exec.command("dig +short myip.opendns.com @resolver1.opendns.com") : connect_signal("request::completed", function(content)
            data.ip['net'] =content or "N/A"
            ipExtInfo:set_markup("<i>"..data.ip['net'] .. "</i>")
        end)

end

local function repaint(margin)

    local ipInfoVl  = wibox.layout.fixed.vertical()
    local ipInfoH1l = wibox.layout.fixed.horizontal()
    ipInfoH1l:add(ip4lbl)
    ipInfoH1l:add(ip4Info)
    local ipInfoH2l = wibox.layout.fixed.horizontal()
    ipInfoH2l:add(ip6lbl)
    ipInfoH2l:add(ipExtInfo)
    ipInfoVl:add(ipInfoH1l)
    ipInfoVl:add(ipInfoH2l)

    local ipm = wibox.layout.margin()
    ipm:set_widget(ipInfoVl)
    ipm:set_top(5)
    ipm:set_bottom(5)

    local function setup_graph(g)
        g:set_width             (190                )
        g:set_height            (30                 )
        g:set_scale             (true               )
        g:set_background_color(beautiful.menu_bg_normal or beautiful.bg_normal)
        g:set_border_color      (beautiful.fg_normal)
        g:set_color             (beautiful.menu_bg_header or beautiful.fg_normal)
    end
    setup_graph(netUpGraph)
    --vicious.register(netUpGraph, vicious.widgets.net,  ,1)
    setup_graph(netDownGraph)
    --vicious.register(netDownGraph, vicious.widgets.net, ,1)

    local mar = wibox.layout.margin()
    local lay = wibox.layout.fixed.vertical()
    lay:add(netUpGraph)
    lay:add(netDownGraph)
    mar:set_margins(3)
    mar:set_bottom(10)
    mar:set_widget(lay)

    mainMenu = menu({width=200,arrow_type=radical.base.arrow_type.CENTERED})
    mainMenu:add_widget(radical.widgets.header(mainMenu,"GRAPH"),{height = 20 , width = 200})
    mainMenu:add_widget(mar ,{height = 73, width = 200})
    mainMenu:add_widget(radical.widgets.header(mainMenu,"IP"),{height = 20 , width = 200})
    mainMenu:add_widget(ipm       ,{height = 50, width = 200})

    local imb = wibox.widget.imagebox()
    imb:set_image(beautiful.path .. "Icon/reload.png")
    imb:buttons(button({ }, 1, function (geo) update() end))
    mainMenu:add_widget(radical.widgets.header(mainMenu,"CONNECTIONS",{suffix_widget=imb}),{height = 20 , width = 200})

    if data.connectionInfo ~= nil then
        connMenu = embed({width=198,max_items=5,has_decoration=false,has_side_deco=true})
        mainMenu:add_embeded_menu(connMenu)
    end
    mainMenu:add_widget(radical.widgets.header(mainMenu,"PROTOCOLS"),{height = 20 , width = 200})

    protMenu = radical.widgets.piechart()
    mainMenu:add_widget(protMenu,{height = 100 , width = 100})
    protMenu:set_data(protocolStat)

    mainMenu:add_widget(radical.widgets.header(mainMenu,"APPLICATIONS"),{height = 20 , width = 200})

    appMenu = embed({width=198,max_items=3,has_decoration=false,has_side_deco=true})
    mainMenu:add_embeded_menu(appMenu)
    return mainMenu
end

local upsur,downsur
local function down_graph_draw(self,w, cr, width, height)
    if mainMenu and mainMenu.visible then
        if not downsur then
            downsur = color.apply_mask(config.iconPath .. "arrowDown.png"         )
        end
        cr:save()
        cr:rotate(math.pi)
        cr:translate(-width,-height)
        widget2.graph.draw(self,w, cr, width, height)
        cr:restore()
        cr:move_to(18,height/2+3)
        cr:set_source(color(beautiful.fg_normal))
        cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
        cr:set_font_size(10)
        cr:show_text("Download")
        cr:set_source_surface(downsur,3,height/4)
        cr:paint()
    end
end

local function up_graph_draw(self,w, cr, width, height)
    if mainMenu and mainMenu.visible then
        if not upsur then
            upsur = color.apply_mask(config.iconPath .. "arrowUp.png"         )
        end
        cr:save()
        cr:scale(-1,1)
        cr:translate(-width,0)
        widget2.graph.draw(self,w, cr, width, height)
        cr:restore()
        cr:move_to(18,height/2+3)
        cr:set_source(color(beautiful.fg_normal))
        cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
        cr:set_font_size(10)
        cr:show_text("Upload")
        cr:set_source_surface(upsur,3,height/4)
        cr:paint()
    end
end

local function ip_label_draw(self,w, cr, width, height)
    if mainMenu and mainMenu.visible then
        cr:save()
        cr:set_source(color(beautiful.bg_alternate))
        cr:rectangle(0,1,width-height/2,height-2)
        cr:fill()
        cr:set_source_surface(themeutils.get_beg_arrow2({bg_color=beautiful.bg_alternate}),width-height/2,2)
        cr:paint()
        cr:restore()
        --     cr:set_source(color(beautiful.fg_normal))
        wibox.widget.textbox.draw(self,w, cr, width, height)
    end
end

local function ip_label_fit(...)
    --     local w,h = wibox.widget.textbox(...)
    return 60,20
end

-- This code will create a pseudo/fake average over the last 15 samples and output a value
local function set_value(self,value)
    local value = value or 0
    self._time = (self._time*14 + (value or 0))/15
    local percent = value/self._time
    if percent > 1 then
        percent = 1
    end
    self:set_text(value*1000)
    self:set_percent(percent)
end

local function new(margin, args)
    ip4Info          = wibox.widget.textbox()
    ipExtInfo          = wibox.widget.textbox()
    ip4lbl           = wibox.widget.textbox()
    ip6lbl           = wibox.widget.textbox()
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

    netDownGraph.draw = down_graph_draw
    netUpGraph.draw   = up_graph_draw
    ip4lbl:set_markup("<b>IP LAN:</b>")
    ip6lbl:set_markup("<b>IP WAN:</b>")
    ip4lbl.fit        = ip_label_fit
    ip4lbl.draw       = ip_label_draw
    ip6lbl.fit        = ip_label_fit
    ip6lbl.draw       = ip_label_draw
    local function show()
        if not data.menu or data.menu.visible ~= true then
            if not data.menu then
                data.menu = repaint(margin)
            end
            update()
            data.menu.visible = true
        else
            data.menu.visible = false
        end
    end

    local volumewidget2 = allinone()
    volumewidget2._time = 0
    volumewidget2.set_value = set_value
    volumewidget2:hide_left(true)
    volumewidget2:set_mirror(true)
    volumewidget2:set_icon(config.iconPath .. "arrowUp.png")
    --volumewidget2:set_suffix("kBps")
    --volumewidget2:set_suffix_icon(config.iconPath .. "kbs.png")
    volumewidget2:set_value(1)
    volumewidget2:icon_align("left")

    local volumewidget3 = allinone()
    volumewidget3._time = 0
    volumewidget3.set_value = set_value
    volumewidget3:hide_left(true)
    volumewidget3:set_icon(config.iconPath .. "arrowDown.png")
    --volumewidget3:set_suffix("")
    --volumewidget3:set_suffix_icon(config.iconPath .. "kbs.png")
    volumewidget3:set_value(1)
    volumewidget3:icon_align("left")
    vicious.register(volumewidget2  , vicious.widgets.net   ,  function(widgets,args)
            local upSum,downSum=0,0
            --Sum all interface upload and download rate
            for i,v in pairs(args) do
                if i:match("up_kb") then
                    upSum=upSum+tonumber(v)
                elseif i:match("down_kb") then
                    downSum=downSum+tonumber(v)
                end
            end
            --Update graph
            netUpGraph:add_value(upSum)
            netDownGraph:add_value(downSum)

            --Update widgets
            if upSum > 1024 then
                upSum=string.format("%.2f",upSum/1024)
                volumewidget2:set_suffix("MBps")
            else
                volumewidget2:set_suffix("kBps")
            end
            
            if downSum > 1024 then
                downSum=string.format("%.2f",downSum/1024)
                volumewidget3:set_suffix("MBps")
            else
                volumewidget3:set_suffix("kBps")
            end

            volumewidget3:set_text(downSum)
            return upSum
        end   ,1 )
    --vicious.register(volumewidget3, vicious.widgets.net   ,  ,1 )

    local l = wibox.layout.fixed.horizontal()
    l:add(volumewidget2)
    l:add(volumewidget3)
    l:buttons(util.table.join(button({ }, 1, function (geo) show();data.menu.parent_geometry=geo end)))

    l.draw = function(self,w, cr, width, height)
        wibox.layout.fixed.draw(self,w, cr, width, height)
        cr:save()
        cr:set_source(color(beautiful.bg_allinone or beautiful.fg_normal))
        cr:rectangle(width/2-3,1,6,2)
        cr:rectangle(width/2-3,height-3,6,2)
        cr:arc(width/2, height/2,height/4,0,2*math.pi)
        cr:fill()
        cr:restore()
    end


    --Initial menu loading quick fix
    show()
    show()

    return l
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
