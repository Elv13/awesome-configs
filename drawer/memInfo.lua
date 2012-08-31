local setmetatable = setmetatable
local io           = io
local pairs        = pairs
local ipairs       = ipairs
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
               client = client ,
               mouse  = mouse  ,
	       timer  = timer  }

module("drawer.memInfo")

local data = {}

local memInfo = {}

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
    
    local f = io.open('/tmp/memStatistics.lua','r')
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
    
function repaint(margin)
    mainMenu = menu({arrow_x=90})
    mainMenu.settings.itemWidth = 200
    mainMenu:add_wibox(infoHeaderW,{height = 20 , width = 200})
    mainMenu:add_wibox(ramW       ,{height = 72, width = 200})
    mainMenu:add_wibox(userHeaderW,{height = 20, width = 200})
    local memStat
    local totalUser = 0
    local totalState = 0
    
    for v, i in next, data.users or {} do
        local userW = wibox({ position = "free", screen = s,ontop = true})
        userW.visible = false
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
    
    mainMenu:add_wibox(stateHeaderW,{height = 20 , width = 200})
    
    for v, i in next, data.state or {} do
        local stateW = wibox({ position = "free", screen = s,ontop = true})
        stateW.visible = false
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
    
    mainMenu:add_wibox(processHeaderW,{height = 20 , width = 200})
    
    for i = 0, #(data.process or {}) do
        if data.process ~= nil and data.process[i]["name"] ~= nil then
            local processW = wibox({ position = "free", screen = s,ontop = true})
            processW.visible = false
            local aProcess = capi.widget({type = "textbox"})
            aProcess.text = " "..data.process[i]["name"] or "N/A"
            
            local aPid = capi.widget({type = "textbox"})
            aPid.text = data.process[i]["pid"]
            
            local aMem = capi.widget({type = "textbox"})
            aMem.text = data.process[i]["mem"]
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
            
            testImage2       = capi.widget({ type = "imagebox"})
            testImage2.image = capi.image(config.data().iconPath .. "kill.png")
            
            processW.widgets = {aMem, {testImage2, layout = widget2.layout.horizontal.rightleft}, layout = widget2.layout.horizontal.leftright,{
                                aProcess , 
                                layout = widget2.layout.horizontal.flex,
                                }}
            mainMenu:add_wibox(processW,{height = 20, width = 200})
        end
    end
    
    mainMenu.settings.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x - margin
    mainMenu.settings.y = 16
    return mainMenu
end

function update()

end

function new(margin, args)
    infoHeaderW    = wibox({ position = "free", screen = s,ontop = true})
    ramW           = wibox({ position = "free", screen = s,ontop = true})
    userHeaderW    = wibox({ position = "free", screen = s,ontop = true})
    stateHeaderW   = wibox({ position = "free", screen = s,ontop = true})
    processHeaderW = wibox({ position = "free", screen = s,ontop = true})
    infoHeaderW.visible = false
    ramW.visible = false
    userHeaderW.visible = false
    stateHeaderW.visible = false
    processHeaderW.visible = false
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
    freeLabel.text          = "<span color='".. beautiful.bg_normal .."'>Free</span>"
    freeLabel.width         = 55
    freeLabel.border_width  = 1
    freeLabel.bg            = beautiful.fg_normal
    freeLabel.border_color  = beautiful.bg_normal
    
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
    
    infoHeaderW.widgets = {infoHeader,layout = widget2.layout.horizontal.leftright}
    userHeaderW.widgets = {userHeader,layout = widget2.layout.horizontal.leftright}
    stateHeaderW.widgets   = {stateHeader,layout = widget2.layout.horizontal.leftright}
    processHeaderW.widgets = {processHeader,layout = widget2.layout.horizontal.leftright}
    
    ramW.widgets = {
                        {totalLabel,totalLabel,usedLabel,freeLabel, layout = widget2.layout.horizontal.leftright},
                        {ramLabel  ,totalRam  ,usedRam  ,freeRam  , layout = widget2.layout.horizontal.leftright},
                        {swapLabel ,totalSwap ,usedSwap ,freeSwap , layout = widget2.layout.horizontal.leftright},
                        layout = widget2.layout.vertical.flex
                    }

    local memwidget = capi.widget({
        type  = 'textbox',
    })
    memwidget:buttons( util.table.join(
        button({ }, 1, function()
            toggleSensorBar()
        end)
    ))

    refreshStat()
    data.menu = repaint(margin-memwidget:extents().width-20-10)
    
--     mytimer = capi.timer({ timeout = 2 })
--     mytimer:add_signal("timeout", function()
--         refreshStat()
--         if data.menu.settings.visible == true then
--             data.menu:toggle(false)
--             data.menu = repaint()
--             data.menu:toggle(true)
--         end
--     end)
--     mytimer:start()

    ramlogo       = capi.widget({ type = "imagebox", align = "right" })
    ramlogo.image = capi.image(config.data().iconPath .. "cpu.png")
    ramlogo:buttons( util.table.join(
    button({ }, 1, function()
        toggleSensorBar()
    end)
    ))
    
    local visible = false
    function toggle()
        if not visible then
            data.menu = repaint(margin-memwidget:extents().width-20-10)
        end
        visible = not visible
        data.menu:toggle(visible)
    end

    


    vicious.register(memwidget, vicious.widgets.mem, '$1%')
    
    ramlogo:buttons   (util.table.join(button({ }, 1, function () toggle() end)))
    memwidget:buttons (util.table.join(button({ }, 1, function () toggle() end)))
        
    ramlogo.bg = beautiful.bg_alternate
    memwidget.bg = beautiful.bg_alternate

--     memwidget:add_signal("mouse::leave", function ()
--         data.menu:toggle(false)
--     end)

    membarwidget = widget2.progressbar({ layout = widget2.layout.horizontal.rightleft })
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
    membarwidget:set_gradient_colors({
        beautiful.fg_normal,
        beautiful.fg_normal,
        '#CC0000'
    })

    vicious.register(membarwidget, vicious.widgets.mem, '$1', 1, 'mem')

    return { logo = ramlogo, text = memwidget, bar = membarwidget}
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
