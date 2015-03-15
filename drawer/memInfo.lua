local setmetatable = setmetatable
local io           = io
local pairs        = pairs
local ipairs       = ipairs
local print        = print
local loadstring   = loadstring
local tonumber     = tonumber
local next         = next
local type         = type
local table        = table
local button       = require( "awful.button"             )
local beautiful    = require( "beautiful"                )
local widget2      = require( "awful.widget"             )
local wibox        = require( "wibox"                    )
local menu         = require( "radical.context"          )
local radtab       = require( "radical.widgets.table"    )
local vicious      = require("extern.vicious")
local config       = require( "forgotten"                )
local util         = require( "awful.util"               )
local radical      = require( "radical"                  )
local themeutils   = require( "blind.common.drawing"     )
local embed        = require( "radical.embed"            )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo
local allinone     = require( "widgets.allinone"         )
local fd_async     = require("utils.fd_async"         )

local capi = { image  = image  ,
    screen = screen ,
    widget = widget ,
    client = client ,
    mouse  = mouse  ,
    timer  = timer  }

local module = {}

local dataMenu = nil

local process = {}
local memState = {}

--local myTimer

local tabWdg = nil
local tabWdgCol = {
    TOTAL =1,
    FREE  =2,
    USED  =3,
}
local tabWdgRow = {
    RAM =1,
    SWAP=2
}

--MENUS
local usrMenu,typeMenu,topMenu

local function refreshStat()
    process={}
    memState={}
    --Load all info
    fd_async.exec.command(util.getdir("config")..'/drawer/Scripts/memStatistics.sh'):connect_signal("new::line",function(content)
            --Ignore nil content
            if content == nil then return end

            --Check header
            local packet = content:split(";")
            --Check for header
            if packet[1] == 't' then
                --Top line

                --Check for empty packet line
                if packet[2] ~= nil then
                    --Insert process
                    table.insert(process,packet[2]:split(","))
                else
                    --Repaint
                    topMenu:clear()
                    for i = 0, #(process or {}) do
                        if process[i] ~= nil then
                            local aMem = wibox.widget.textbox()
                            aMem:set_text(process[i][1].." %")
                            aMem.fit = function()
                                return 58,topMenu.item_height
                            end

                            for k2,v2 in ipairs(capi.client.get()) do
                                if v2.class:lower() == process[i][2]:lower() or v2.name:lower():find(process[i][2]:lower()) ~= nil then
                                    aMem.bg_image = v2.icon
                                    break
                                end
                            end

                            aMem.draw = function(self,w, cr, width, height)
                                cr:save()
                                cr:set_source(color(topMenu.bg_alternate))
                                cr:rectangle(0,0,width-height/2,height)
                                cr:fill()
                                cr:set_source_surface(themeutils.get_beg_arrow2({bg_color=topMenu.bg_alternate}),width-height/2,0)
                                cr:paint()
                                cr:restore()
                                wibox.widget.textbox.draw(self,w, cr, width, height)
                            end

                            testImage2       = wibox.widget.imagebox()
                            testImage2:set_image(config.iconPath .. "kill.png")

                            topMenu:add_item({text=process[i][2] or "N/A",prefix_widget=aMem,suffix_widget=testImage2})
                        end
                    end
                end



            elseif packet[1] == 'u' then
                -- Users line
                --Clear User menu
                usrMenu:clear()
                --Reload User list
                if packet[2] ~= nil then
                    local data=packet[2]:split(',')
                    for key,field in pairs(data) do
                        --Load user data
                        local user=field:split(' ')
                        --print("N:",user[1],"User:",user[2])

                        local totalUser = 0

                        local anUser = wibox.widget.textbox()
                        anUser:set_text(user[1])
                        totalUser = totalUser +1
                        usrMenu:add_item({text=user[2],suffix_widget=anUser})
                    end
                end
            elseif packet[1] == 'p' then
                --Process line
                if packet[2] ~= nil then
                    local data=packet[2]:split(',')
                    for key,field in pairs(data) do
                        local temp=field:split(' ')
                        memState[temp[2]]=temp[1]
                        --print("PL:",temp[2],":",temp[1])
                    end
                    if memState ~= nil then
                        typeMenu:set_data(memState)
                    end
                end
            else
                print("INFO@memInfo: Unknown line",packet[2])
            end
        end)


end

local function parseViciousMemstat(widget,content)
    if dataMenu.visible then
        tabWdg[ tabWdgRow.RAM  ][ tabWdgCol.TOTAL ]:set_text( string.format("%.2f GB",content[3]/1024) or "N/A")
        tabWdg[ tabWdgRow.RAM  ][ tabWdgCol.FREE  ]:set_text( string.format("%.2f GB",content[4]/1024) or "N/A")
        tabWdg[ tabWdgRow.RAM  ][ tabWdgCol.USED  ]:set_text((string.format("%.1f",content[1]) or "N/A") .. " %" )
        tabWdg[ tabWdgRow.SWAP ][ tabWdgCol.TOTAL ]:set_text( string.format("%.1f GB",content[7]/1024) or "N/A")
        tabWdg[ tabWdgRow.SWAP ][ tabWdgCol.FREE  ]:set_text( string.format("%.1f GB",content[8]/1024) or "N/A")
        tabWdg[ tabWdgRow.SWAP ][ tabWdgCol.USED  ]:set_text((string.format("%.2f",content[5]) or "N/A") .. " %" )
    end
    return content[1]
end

local function repaint()

    local imb = wibox.widget.imagebox()
    imb:set_image(beautiful.path .. "Icon/reload.png")
    imb:buttons(button({ }, 1, function (geo) refreshStat() end))

    mainMenu = menu({arrow_x=90,nokeyboardnav=true,item_width=198,width=210,arrow_type=radical.base.arrow_type.CENTERED})
    mainMenu:add_widget(radical.widgets.header(mainMenu,"USAGE",{suffix_widget=imb}),{height = 20 , width = 200})

    local m3 = wibox.layout.margin()
    m3:set_margins(3)
    m3:set_bottom(10)
    local tab,wdgs = radtab({
            {"","",""},
            {"","",""}},
        {row_height=20,v_header = {"Ram","Swap"},
            h_header = {"Total","Free","Used"}
        })
    tabWdg = wdgs
    m3:set_widget(tab)
    mainMenu:add_widget(m3,{width = 200})
    mainMenu:add_widget(radical.widgets.header(mainMenu,"USERS",{suffix_widget=imb}),{height = 20, width = 200})
    local memStat

    usrMenu = embed({max_items=3})
    mainMenu:add_embeded_menu(usrMenu)

    mainMenu:add_widget(radical.widgets.header(mainMenu,"STATE",{suffix_widget=imb}),{height = 20 , width = 200})

    typeMenu = radical.widgets.piechart()
    mainMenu:add_widget(typeMenu,{height = 100 , width = 100})


    mainMenu:add_widget(radical.widgets.header(mainMenu,"PROCESS",{suffix_widget=imb}),{height = 20 , width = 200})

    topMenu = embed({max_items=8})
    mainMenu:add_embeded_menu(topMenu)

    return mainMenu
end


local function new(margin, args)
    local function toggle()
        if not dataMenu then
            dataMenu = repaint()
        else
        end
        if not dataMenu.visible then
            refreshStat()
        else
        end
        dataMenu.visible = not dataMenu.visible
    end

    local buttonclick = util.table.join(button({ }, 1, function (geo) toggle();dataMenu.parent_geometry=geo end))

    local volumewidget2 = allinone()
    volumewidget2:set_icon(config.iconPath .. "cpu.png")
    dataMenu = repaint()
    vicious.register(volumewidget2, vicious.widgets.mem, parseViciousMemstat, 1)

    volumewidget2:buttons (buttonclick)

    --Same old trick to fix first load
    --TODO: Fix first load problem with embed widgets
    toggle()
    toggle()
    return volumewidget2
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
