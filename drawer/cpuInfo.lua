local setmetatable = setmetatable
local io           = io
local table        = table
local ipairs       = ipairs
local loadstring   = loadstring
local print        = print
local tonumber     = tonumber
local beautiful    = require( "beautiful"    )
local button       = require( "awful.button" )
local widget2      = require( "awful.widget" )
local config       = require( "config"       )
local vicious      = require( "extern.vicious"      )
local menu         = require( "widgets.menu" )
local util         = require( "awful.util"   )
local wibox        = require( "awful.wibox"  )

local capi = { image  = image  ,
               screen = screen ,
               client = client ,
               widget = widget ,
               mouse  = mouse  ,
               timer  = timer  }

module("drawer.cpuInfo")


function update()

end

function new(margin, args)
    
    local data              = {}
    local coreWidgets       = {}
    local processWidgets    = {}
    local cpuInfo           = {}

    local infoHeader        = capi.widget({ type = "textbox"  })
    local usageHeader       = capi.widget({ type = "textbox"  })
    local tempHeader        = capi.widget({ type = "textbox"  })
    local processHeader     = capi.widget({ type = "textbox"  })
    local cpuModel          = capi.widget({ type = "textbox"  })
    local iowaitHeader      = capi.widget({ type = "textbox"  })
    local usageHeader2      = capi.widget({ type = "textbox"  })
    local emptyCornerHeader = capi.widget({ type = "textbox"  })
    local clockHeader       = capi.widget({ type = "textbox"  })
    local idleHeader        = capi.widget({ type = "textbox"  })
    local cpulogo           = capi.widget({ type = "imagebox" })
    local cpuwidget         = capi.widget({ type = "textbox"  })
    local spacer1           = capi.widget({ type = "textbox"  })
    local volUsage          = widget2.graph()

    local topCpuW           = {}
    local infoHeaderW       = wibox({ position = "free" , screen = s , ontop = true, height = 20 })
    local usageHeaderW      = wibox({ position = "free" , screen = s , ontop = true, height = 20 })
    local processHeaderW    = wibox({ position = "free" , screen = s , ontop = true, height = 20 })
    local modelW            = wibox({ position = "free" , screen = s , ontop = true, height = 40 })
    local tableW            = wibox({ position = "free" , screen = s , ontop = true, height = 120})
    
    topCpuW.visible        = false
    infoHeaderW.visible    = false
    usageHeaderW.visible   = false
    processHeaderW.visible = false
    modelW.visible         = false
    tableW.visible         = false
    
    for i=1,10 do
    topCpuW[i] = wibox({ position = "free" , screen = s , ontop = true })
    topCpuW[i].visible = false
    
    processWidgets[i] = {}
    processWidgets[i].percent       = capi.widget({ type = "textbox"  })
    processWidgets[i].percent.width = 50
    processWidgets[i].percent.bg    = "#0F2051"
    processWidgets[i].percent.align = "right"
    processWidgets[i].process       = capi.widget({ type = "textbox"  })
    processWidgets[i].kill          = capi.widget({ type = "imagebox"})
    processWidgets[i].kill.image    = capi.image(config.data().iconPath .. "kill.png")
    
    topCpuW[i].widgets = {
                            processWidgets[i].percent, 
                            {
                                processWidgets[i].kill, layout = widget2.layout.horizontal.rightleft
                            }
                            , layout = widget2.layout.horizontal.leftright,
                            {
                                processWidgets[i].process , 
                                layout = widget2.layout.horizontal.flex,
                            }
                         }
    end

    infoHeaderW.widgets     = {infoHeader    , layout = widget2.layout.horizontal.leftright}
    usageHeaderW.widgets    = {usageHeader2  , layout = widget2.layout.horizontal.leftright}
    processHeaderW.widgets  = {processHeader , layout = widget2.layout.horizontal.leftright}
    modelW.widgets          = {cpuModel      , layout = widget2.layout.horizontal.leftright}
    
    function createDrawer() 

        --util.spawn("/bin/bash -c 'while true; do sleep 3 &&"..util.getdir("config") .."/Scripts/cpuInfo2.sh > /tmp/cpuStatistic.lua;done'")
        local cpuStat = {}
        local f = io.open('/tmp/cpuStatistic.lua','r')
        if f ~= nil then
            local text3 = f:read("*all")
            text3 = text3.." return cpuInfo"
            f:close()
            local afunction = loadstring(text3)
            if afunction ~= nil then
            cpuStat = afunction() 
            infoNotFound = nil
            else
            infoNotFound = "N/A"
            end
        else
            infoNotFound = "N/A"
        end
        
        if cpuStat == nil then
            infoNotFound = "N/A"
        end
        
        cpuWidgetArray     = {}
        infoHeader.text    = " <span color='".. beautiful.bg_normal .."'><b><tt>INFO</tt></b></span> "
        infoHeader.bg      = beautiful.fg_normal
        infoHeader.width   = 212
        cpuModel.text      = data.cpuStat and cpuStat.model or "N/A"
        cpuModel.width     = 212
        usageHeader2.text  = " <span color='".. beautiful.bg_normal .."'><b><tt>USAGE</tt></b></span> "
        usageHeader2.bg    = beautiful.fg_normal
        usageHeader2.width = 212
        
        volUsage:set_width        ( 212                                  )
        volUsage:set_height       ( 30                                   )
        volUsage:set_scale        ( true                                 )
        volUsage:set_border_color ( beautiful.fg_normal                  )
        volUsage:set_color        ( beautiful.fg_normal                  )
        vicious.register          ( volUsage, vicious.widgets.cpu,'$1',1 )
        table.insert              ( cpuWidgetArray, volUsage             )
        
        --Table header
        emptyCornerHeader.text         = " <span color='".. beautiful.bg_normal .."'>Core</span> "
        emptyCornerHeader.bg           = beautiful.fg_normal
        emptyCornerHeader.width        = 35
        emptyCornerHeader.border_width = 1
        emptyCornerHeader.border_color = beautiful.bg_normal
        clockHeader.text               = " <span color='".. beautiful.bg_normal .."'>Ghz</span> "
        clockHeader.bg                 = beautiful.fg_normal
        clockHeader.width              = 30
        clockHeader.border_width       = 1
        clockHeader.border_color       = beautiful.bg_normal
        tempHeader.text                = " <span color='".. beautiful.bg_normal .."'>Temp</span> "
        tempHeader.bg                  = beautiful.fg_normal
        tempHeader.width               = 40
        tempHeader.border_width        = 1
        tempHeader.border_color        = beautiful.bg_normal
        usageHeader.text               = " <span color='".. beautiful.bg_normal .."'>Used</span> "
        usageHeader.bg                 = beautiful.fg_normal
        usageHeader.width              = 37
        usageHeader.border_width       = 1
        usageHeader.border_color       = beautiful.bg_normal
        iowaitHeader.text              = " <span color='".. beautiful.bg_normal .."'> I/O</span> "
        iowaitHeader.bg                = beautiful.fg_normal
        iowaitHeader.width             = 35
        iowaitHeader.border_width      = 1
        iowaitHeader.border_color      = beautiful.bg_normal
        idleHeader.text                = " <span color='".. beautiful.bg_normal .."'> Idle</span> "
        idleHeader.bg                  = beautiful.fg_normal
        idleHeader.width               = 35
        idleHeader.border_width        = 1
        idleHeader.border_color        = beautiful.bg_normal
        table.insert(cpuWidgetArray, {emptyCornerHeader,clockHeader,tempHeader,usageHeader,iowaitHeader,idleHeader, layout = widget2.layout.horizontal.leftright})


        local f2 = io.popen("cat /proc/cpuinfo | grep processor | tail -n1 | grep -e'[0-9]*' -o")
        local coreNb = f2:read("*all") or "0"
        f2:close() 
        coreWidgets["count"] = tonumber(coreNb)
        for i=0 , coreWidgets["count"] do
            coreWidgets[i]           = {}
            local aCore              = capi.widget({type = "textbox"})
            aCore.text               = " <span color='".. beautiful.bg_normal .."'>".."C"..i.."</span> "
            aCore.bg                 = beautiful.fg_normal
            aCore.width              = 35
            coreWidgets[i]["core"]   = aCore
            local aCoreClock         = capi.widget({type = "textbox"})
            aCoreClock.width         = 30
            aCoreClock.border_width  = 1
            aCoreClock.border_color  = beautiful.fg_normal
            coreWidgets[i]["clock"]  = aCoreClock
            local aCoreTemp          = capi.widget({type = "textbox"})
            aCoreTemp.width          = 40
            aCoreTemp.border_width   = 1
            aCoreTemp.border_color   = beautiful.fg_normal
            coreWidgets[i]["temp"]   = aCoreTemp
            local aCoreUsage         = capi.widget({type = "textbox"})
            aCoreUsage.width         = 37
            aCoreUsage.border_width  = 1
            aCoreUsage.border_color  = beautiful.fg_normal
            coreWidgets[i]["usage"]  = aCoreUsage
            local aCoreIoWait        = capi.widget({type = "textbox"})
            aCoreIoWait.width        = 35
            aCoreIoWait.border_width = 1
            aCoreIoWait.border_color = beautiful.fg_normal
            coreWidgets[i]["wait"]   =  aCoreIoWait
            local aCoreIdle          = capi.widget({type = "textbox"})
            aCoreIdle.width          = 35
            aCoreIdle.border_width   = 1
            aCoreIdle.border_color   = beautiful.fg_normal
            coreWidgets[i]["idle"]   = aCoreIdle
            aCore.border_width       = 1
            aCore.border_color       = beautiful.bg_normal
            table.insert(cpuWidgetArray, {aCore,aCoreClock,aCoreTemp,aCoreUsage,aCoreIoWait,aCoreIdle, layout = widget2.layout.horizontal.leftright})
        end
        cpuWidgetArray.layout = widget2.layout.vertical.flex
        tableW.widgets = cpuWidgetArray
        
        --   spacer1.text = ""
        --   table.insert(cpuWidgetArray, spacer1)
        --   
        processHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>PROCESS</tt></b></span> "
        processHeader.bg = beautiful.fg_normal
        processHeader.width = 212
    end

    local function loadData()
        local f = io.open('/tmp/cpuStatistic.lua','r')
        local cpuStat = {}
        if f ~= nil then
            local text3 = f:read("*all")
            text3 = text3.." return cpuInfo"
            f:close()
            local afunction = loadstring(text3)
            if afunction ~= nil then
                cpuStat = afunction() 
                infoNotFound = nil
            else
                infoNotFound = "N/A"
            end
        else
            infoNotFound = "N/A"
        end

        if cpuStat then
            data.cpuStat = cpuStat
            cpuModel.text = cpuStat.model
        end
        
        local process = {}
        f = io.open('/tmp/topCpu.lua','r')
        if f ~= nil then
            text3 = f:read("*all")
            text3 = text3.." return cpuStat"
            f:close()
            local afunction = loadstring(text3) or nil
            if afunction ~= nil then
                process = afunction()
            else
                process = nil
            end
        end
        if process then
            data.process = process
        end
    end

    local function updateTable()
        if data.cpuStat ~= nil and data.cpuStat["core0"] ~= nil and coreWidgets ~= nil then  
            for i=0 , data.cpuStat["core"] do --TODO add some way to correct the number of core, it usually fail on load --Solved
                if i <= (coreWidgets.count  or 1) and coreWidgets[i] then
                    coreWidgets[i].core.text  = " <span color='".. beautiful.bg_normal .."'>".."C"..i.."</span> "
                    coreWidgets[i].clock.text = tonumber(data.cpuStat["core"..i]["speed"]) /1024 .. "Ghz"
                    coreWidgets[i].temp.text  = data.cpuStat["core"..i].temp
                    coreWidgets[i].usage.text = data.cpuStat["core"..i].usage
                    coreWidgets[i].wait.text  = data.cpuStat["core"..i].iowait
                    coreWidgets[i].idle.text  = data.cpuStat["core"..i].idle
                end
            end
        end
    end
    
    createDrawer() 
    loadData()
    updateTable()
    
    function regenMenu()
        aMenu          = menu({arrow_x=90})
        aMenu.settings.itemWidth = 200
        aMenu:add_wibox(infoHeaderW    , {height = 20  , width = 200})
        aMenu:add_wibox(modelW         , {height = 40  , width = 200})
        aMenu:add_wibox(usageHeaderW   , {height = 20  , width = 200})
        aMenu:add_wibox(tableW         , {height = 120 , width = 200})
        aMenu:add_wibox(processHeaderW , {height = 20  , width = 200})
        local procMenu = menu({width=198,maxvisible=6,has_decoration=false,has_side_deco=true})
        if data.process then
            for i=1,10 do
                if #data.process > i then
                    processWidgets[i].percent.text  = data.process[i].percent.."%"
                    processWidgets[i].process.text  = " "..data.process[i].name
                    
                    for k2,v2 in ipairs(capi.client.get()) do
                        if v2.class:lower() == data.process[i].name:lower() or v2.name:lower():find(data.process[i].name:lower()) ~= nil then
                            processWidgets[i].percent.bg_image = v2.icon
                            processWidgets[i].percent.bg_resize = true
                            break 
                        end
                    end
                    
                    procMenu:add_wibox(topCpuW[i] , {height = 20  , width = 200})
                end
            end
        end
        aMenu:add_embeded_menu(procMenu)
        
        aMenu.settings.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x - margin + 40 + 15 + 15
        aMenu.settings.y = 16
        aMenu:toggle(true)
        return aMenu
    end

    local visible = false
    function show()
        if not visible then
            data.menu = regenMenu()
        end
        visible = not visible
        data.menu:toggle(visible)
    end
    
    cpulogo.image = capi.image(config.data().iconPath .. "brain.png")
    cpulogo.bg = beautiful.bg_alternate
    cpuwidget.width = 27
    cpuwidget.bg = beautiful.bg_alternate
  vicious.register(cpuwidget, vicious.widgets.cpu,'$1%')

  cpuwidget:buttons (util.table.join(button({ }, 1, function () show() end)))
  cpulogo:buttons   (util.table.join(button({ }, 1, function () show() end)))

--   mytimer = capi.timer({ timeout = 2 })
--   mytimer:add_signal("timeout", updateTable)
--   mytimer:start()

  local cpuBar = widget2.graph({ layout = widget2.layout.horizontal.rightleft })
  cpuBar:set_width(40)
  cpuBar:set_height(14)
  cpuBar:set_background_color(beautiful.bg_alternate)
  cpuBar:set_border_color(beautiful.fg_normal)
  cpuBar:set_color(beautiful.fg_normal)

  if (widget2.graph.set_offset ~= nil) then
    cpuBar:set_offset(1)
  end

  --vicious.register(cpuBar, vicious.widgets.cpu, '$1', 1, 'cpu')
  vicious.register(cpuBar, vicious.widgets.cpu,'$1',1)
  
  return {logo = cpulogo, text = cpuwidget, graph = cpuBar}
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
