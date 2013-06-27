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
local button       = require("awful.button")
local beautiful    = require("beautiful")
local widget2      = require("awful.widget")
local wibox        = require("wibox")
local menu         = require("widgets.menu")
local vicious      = require("extern.vicious")
local config       = require("config")
local util         = require("awful.util")

local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               client = client ,
               mouse  = mouse  ,
               timer  = timer  }

local module = {}

local data = {}

local memInfo = {}

local infoHeader     = wibox.widget.textbox()
local totalRam       = wibox.widget.textbox()
local freeRam        = wibox.widget.textbox()
local usedRam        = wibox.widget.textbox()
local freeSwap       = wibox.widget.textbox()
local usedSwap       = wibox.widget.textbox()
local totalSwap      = wibox.widget.textbox()
local userHeader     = wibox.widget.textbox()
local stateHeader    = wibox.widget.textbox()
local processHeader  = wibox.widget.textbox()

local totalRamLabel  = wibox.widget.textbox()
local freeRamLabel   = wibox.widget.textbox()
local usedRamLabel   = wibox.widget.textbox()
local totalSwapLabel = wibox.widget.textbox()
local freeSwapLabel  = wibox.widget.textbox()
local usedSwapLabel  = wibox.widget.textbox()

local ramLabel       = wibox.widget.textbox()
local swapLabel      = wibox.widget.textbox()
local totalLabel     = wibox.widget.textbox()
local usedLabel      = wibox.widget.textbox()
local freeLabel      = wibox.widget.textbox()

local infoHeaderW    
local ramW           
local userHeaderW    
local stateHeaderW   
local processHeaderW 

-- util.spawn("/bin/bash -c 'while true;do "..util.getdir("config") .."/Scripts/memStatistics.sh > /tmp/memStatistics.lua && sleep 5;done'")
-- util.spawn("/bin/bash -c 'while true; do "..util.getdir("config") .."/Scripts/topMem2.sh > /tmp/topMem.lua;sleep 5;done'")
  
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

    totalRam:set_text ( statNotFound or memStat["ram"]["total"]  )
    freeRam:set_text  ( statNotFound or memStat["ram"]["free"]   )
    usedRam:set_text  ( statNotFound or memStat["ram"]["used"]   )
    totalSwap:set_text( statNotFound or memStat["swap"]["total"] )
    freeSwap:set_text ( statNotFound or memStat["swap"]["free"]  )
    usedSwap:set_text ( statNotFound or memStat["swap"]["used"]  )

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
        print("Failed to open memStat")
        statNotFound = "N/A"
    end

    if memStat ~= nil and memStat["users"] then
        data.users = memStat["users"]
    end

    if memStat ~= nil and memStat["state"] ~= nil then
        data.state = memStat["state"]
    end

    local process
    local f = io.open('/tmp/topMem.lua','r')
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
        data.process = process
    end
end

  --memory.widgets = {layout = widget2.layout.horizontal.leftright}

local function reload_user(usrMenu,data)
    local totalUser = 0
    local sorted = {}
    for v, i in pairs(data.users or {}) do
        local tmp = tonumber(i)*10
        while sorted[tmp] do
            tmp = tmp + 1
        end
        sorted[tmp] = {value=v,key=i}
    end
    for i2, v2 in pairs(sorted) do
        local v,i= v2.value,v2.key
        local userW = wibox({ position = "free", screen = s,ontop = true, bg = beautiful.menu_bg})
        userW.visible = false
        local anUser = wibox.widget.textbox()
        anUser:set_text(i)
        local anUserLabel = wibox.widget.textbox()
--         anUserLabel:margin({ left = 7, right = 7 })
        anUserLabel:set_text(v..":")
        anUserLabel.width = 70
        anUserLabel.bg = "#0F2051"
--         userW.widgets = {anUserLabel,anUser, layout = widget2.layout.horizontal.leftrightcached}
        local userWl    = wibox.layout.fixed.horizontal()
        userWl:add(anUserLabel)
        userWl:add(anUser)
        userW:set_widget(userWl)
        totalUser = totalUser +1
        usrMenu:add_wibox(userW,{height = 20, width = 200})
    end
    return totalUser
end

local function reload_state(typeMenu,data)
    local totalState = 0
    for v, i in next, data.state or {} do
        local stateW = wibox({ position = "free", screen = s,ontop = true, bg = beautiful.menu_bg})
        stateW.visible = false
        local anState = wibox.widget.textbox()
        anState:set_text(i)
        local anStateLabel = wibox.widget.textbox()
--         anStateLabel:margin({ left = 7, right = 7 })
        anStateLabel:set_text(v..":")
        anStateLabel.width = 70
        anStateLabel.bg = "#0F2051"
--         stateW.widgets = {anStateLabel,anState, layout = widget2.layout.horizontal.leftrightcached}
        local stateWl    = wibox.layout.fixed.horizontal()
        stateWl:add( anStateLabel )
        stateWl:add( anState      )
        stateW:set_widget(stateWl)
        totalState = totalState +1
        typeMenu:add_wibox(stateW,{height = 20, width = 200})
    end
end

local function reload_top(topMenu,data)
    for i = 0, #(data.process or {}) do
        if data.process ~= nil and data.process[i]["name"] ~= nil then
            local processW = wibox({ position = "free", screen = s,ontop = true, bg = beautiful.menu_bg})
            processW.visible = false
            local aProcess = wibox.widget.textbox()
            aProcess:set_text(" "..data.process[i]["name"] or "N/A")

            local aPid = wibox.widget.textbox()
            aPid:set_text(data.process[i]["pid"])

            local aMem = wibox.widget.textbox()
            aMem:set_text(data.process[i]["mem"])
            aMem.width = 70
            aMem.bg = "#0F2051"
            aMem.border_width = 1
            aMem.border_color = beautiful.bg_normal
            aMem.align = "right"

            for k2,v2 in ipairs(capi.client.get()) do
                if v2.class:lower() == data.process[i]["name"]:lower() or v2.name:lower():find(data.process[i]["name"]:lower()) ~= nil then
                    aMem.bg_image = v2.icon
                    break 
                end
            end

            testImage2       = wibox.widget.imagebox()
            testImage2:set_image(config.data().iconPath .. "kill.png")

--             processW.widgets = {aMem, {testImage2, layout = widget2.layout.horizontal.rightleftcached}, layout = widget2.layout.horizontal.leftrightcached,{
--                                 aProcess , 
--                                 layout = widget2.layout.horizontal.flexcached,
--                                 }}
            
            local processWl = wibox.layout.align.horizontal()
            processWl:set_left   ( aMem       )
            processWl:set_middle ( aProcess   )
            processWl:set_right  ( testImage2 )
            processW:set_widget(processWl)
            
            topMenu:add_wibox(processW,{height = 20, width = 200})
        end
    end
end

local usrMenu,typeMenu,topMenu

local function repaint(margin)
    infoHeaderW    = wibox({ position = "free", screen = s,ontop = true,height = 20, bg = beautiful.menu_bg})
    ramW           = wibox({ position = "free", screen = s,ontop = true,height = 72, bg = beautiful.menu_bg})
    userHeaderW    = wibox({ position = "free", screen = s,ontop = true,height = 20, bg = beautiful.menu_bg})
    stateHeaderW   = wibox({ position = "free", screen = s,ontop = true,height = 20, bg = beautiful.menu_bg})
    processHeaderW = wibox({ position = "free", screen = s,ontop = true,height = 20, bg = beautiful.menu_bg})
    infoHeaderW.visible = false
    ramW.visible = false
    userHeaderW.visible = false
    stateHeaderW.visible = false
    processHeaderW.visible = false
    for k,v in ipairs({ramLabel,swapLabel,totalLabel,usedLabel,freeLabel}) do
        v.width          = 55
        v.border_width   = 1
        v.bg             = beautiful.fg_normal
        v.border_color   = beautiful.bg_normal
    end
    ramLabel:set_markup   ("<span color='".. beautiful.bg_normal .."'>Ram</span>"   )
    swapLabel:set_markup  ("<span color='".. beautiful.bg_normal .."'>Swap</span>"  )
    totalLabel:set_markup ("<span color='".. beautiful.bg_normal .."'>Total</span>" )
    usedLabel:set_markup  ("<span color='".. beautiful.bg_normal .."'>Used</span>"  )
    freeLabel:set_markup  ("<span color='".. beautiful.bg_normal .."'>Free</span>"  )
    totalLabel.align        = "center"
    usedLabel.align         = "center"
    freeLabel.align         = "center"

    infoHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>USAGE</tt></b></span> ")
    infoHeader.width     = 212

    userHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>USERS</tt></b></span> ")
    userHeader.width     = 212

    stateHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>STATE</tt></b></span> ")
    stateHeader.width    = 212

    processHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>PROCESS</tt></b></span> ")
    processHeader.width  = 212

    for k,v in ipairs({totalRam , freeRam  , usedRam  , totalSwap, freeSwap , usedSwap }) do
        v.border_color   = beautiful.fg_normal
        v.width          = 55
        v.border_width   = 1
    end

--     infoHeaderW.widgets = {infoHeader,layout = widget2.layout.horizontal.leftrightcached}
--     userHeaderW.widgets = {userHeader,layout = widget2.layout.horizontal.leftrightcached}
--     stateHeaderW.widgets   = {stateHeader,layout = widget2.layout.horizontal.leftrightcached}
--     processHeaderW.widgets = {processHeader,layout = widget2.layout.horizontal.leftrightcached}
    local infoHeaderWl    = wibox.layout.fixed.horizontal()
    local userHeaderWl    = wibox.layout.fixed.horizontal()
    local stateHeaderWl   = wibox.layout.fixed.horizontal()
    local processHeaderWl = wibox.layout.fixed.horizontal()
    infoHeaderWl:add   ( infoHeader    )
    userHeaderWl:add   ( userHeader    )
    stateHeaderWl:add  ( stateHeader   )
    processHeaderWl:add( processHeader )
    infoHeaderW:set_widget   ( infoHeaderWl    )
    userHeaderW:set_widget   ( userHeaderWl    )
    stateHeaderW:set_widget  ( stateHeaderWl   )
    processHeaderW:set_widget( processHeaderWl )
    infoHeaderW:set_bg    ( beautiful.fg_normal )
    userHeaderW:set_bg    ( beautiful.fg_normal )
    stateHeaderW:set_bg   ( beautiful.fg_normal )
    processHeaderW:set_bg ( beautiful.fg_normal )

--     ramW.widgets = {
--                         {totalLabel,totalLabel,usedLabel,freeLabel, layout = widget2.layout.horizontal.leftrightcached},
--                         {ramLabel  ,totalRam  ,usedRam  ,freeRam  , layout = widget2.layout.horizontal.leftrightcached},
--                         {swapLabel ,totalSwap ,usedSwap ,freeSwap , layout = widget2.layout.horizontal.leftrightcached},
--                         layout = widget2.layout.vertical.flexcached
--                     }
    local ramWVl  = wibox.layout.fixed.vertical()
    local ramWH1l = wibox.layout.fixed.horizontal()
    local ramWH2l = wibox.layout.fixed.horizontal()
    local ramWH3l = wibox.layout.fixed.horizontal()
    ramWH1l:add( totalLabel ) ; ramWH1l:add( totalLabel) ; ramWH1l:add( usedLabel ) ; ramWH1l:add( freeLabel )
    ramWH1l:add( ramLabel   ) ; ramWH1l:add( totalRam  ) ; ramWH1l:add( usedRam   ) ; ramWH1l:add( freeRam   )
    ramWH3l:add( swapLabel  ) ; ramWH3l:add( totalSwap ) ; ramWH3l:add( usedSwap  ) ; ramWH3l:add( freeSwap  )
    ramWVl:add(ramWH1l)
    ramWVl:add(ramWH2l)
    ramWVl:add(ramWH3l)
    ramW:set_widget(ramWVl)

    mainMenu = menu({arrow_x=90,nokeyboardnav=true})
    mainMenu.settings.itemWidth = 198
    mainMenu:add_wibox(infoHeaderW,{height = 20 , width = 200})
    mainMenu:add_wibox(ramW       ,{height = 72, width = 200})
    mainMenu:add_wibox(userHeaderW,{height = 20, width = 200})
    local memStat

    usrMenu = menu({width=198,maxvisible=10,has_decoration=false,has_side_deco=true,nokeyboardnav=true})
    reload_user(usrMenu,data)
    mainMenu:add_embeded_menu(usrMenu)

    mainMenu:add_wibox(stateHeaderW,{height = 20 , width = 200})

    typeMenu = menu({width=198,maxvisible=5,has_decoration=false,has_side_deco=true,nokeyboardnav=true})
    reload_state(typeMenu,data)
    mainMenu:add_embeded_menu(typeMenu)

    mainMenu:add_wibox(processHeaderW,{height = 20 , width = 200})

    topMenu = menu({width=198,maxvisible=3,has_decoration=false,has_side_deco=true,nokeyboardnav=true})
    reload_top(topMenu,data)
    mainMenu:add_embeded_menu(topMenu)

    mainMenu.settings.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x - margin
    mainMenu.settings.y = 16
    return mainMenu
end

local function update()
    usrMenu:clear()
    typeMenu:clear()
    topMenu:clear()
    reload_user(usrMenu,data)
    reload_state(typeMenu,data)
    reload_top(topMenu,data)
end

local function new(margin, args)

    local memwidget = wibox.widget.textbox()
    memwidget:buttons( util.table.join(
        button({ }, 1, function()
            toggleSensorBar()
        end)
    ))

    refreshStat()

    --It does work, but there is some exteral issues with the menu
--     local mytimer = capi.timer({ timeout = 10 })
--     mytimer:add_signal("timeout", function()
--         if data.menu.settings.visible == true then
--             refreshStat()
--             update()
--             data.menu:toggle(true)
--         end
--     end)
--     mytimer:start()

    ramlogo       = wibox.widget.imagebox()
    ramlogo:set_image(config.data().iconPath .. "cpu.png")
    ramlogo:buttons( util.table.join(
    button({ }, 1, function()
        toggleSensorBar()
    end)
    ))

    local visible = false
    function toggle()
        if not data.menu then
            data.menu = repaint(margin-memwidget._layout:get_pixel_extents().width-20-10)
        end
        visible = not visible
        if visible then
            refreshStat()
            update()
        end
        data.menu:toggle(visible)
    end




    vicious.register(memwidget, vicious.widgets.mem, '$1%')

    local buttonclick = util.table.join(button({ }, 1, function () toggle() end))
    ramlogo:buttons   (buttonclick)
    memwidget:buttons (buttonclick)

    ramlogo.bg = beautiful.bg_alternate
    memwidget.bg = beautiful.bg_alternate

    membarwidget = widget2.progressbar()
    membarwidget:set_width(40)
    membarwidget:set_height(14)
    if (widget2.progressbar.set_offset ~= nil) then
        membarwidget:set_offset(1)
    end

--     if widget2.progressbar.set_margin then
--     membarwidget:set_margin({top=2,bottom=2})
--     end
    membarwidget:set_vertical(false)
    membarwidget:set_background_color(beautiful.bg_alternate)
    membarwidget:set_border_color(beautiful.fg_normal)
    membarwidget:set_color(beautiful.fg_normal)

    local marg = wibox.layout.margin(membarwidget)
    marg:set_top(2)
    marg:set_bottom(2)
    marg:set_right(4)
--     membarwidget:set_gradient_colors({
--         beautiful.fg_normal,
--         beautiful.fg_normal,
--         '#CC0000'
--     })

    vicious.register(membarwidget, vicious.widgets.mem, '$1', 1, 'mem')
    
    memwidget.fit = function(box, w, h)
        local w, h = wibox.widget.textbox.fit(box, w, h);
        return 22, h
    end

    local l = wibox.layout.fixed.horizontal()
    l:add(ramlogo)
    l:add(memwidget)
    l:add(marg)
    return l--{ logo = ramlogo, text = memwidget, bar = membarwidget.widget}
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
