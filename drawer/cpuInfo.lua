local setmetatable = setmetatable
local io           = io
local table        = table
local ipairs       = ipairs
local loadstring   = loadstring
local print        = print
local tonumber     = tonumber
local beautiful    = require( "beautiful"      )
local button       = require( "awful.button"   )
local widget2      = require( "awful.widget"   )
local config       = require( "config"         )
local vicious      = require( "extern.vicious" )
local menu         = require( "widgets.menu"   )
local util         = require( "awful.util"     )
local wibox        = require( "wibox"          )

local data     = {}
local procMenu = nil

local capi = { image  = image  ,
               screen = screen ,
               client = client ,
               widget = widget ,
               mouse  = mouse  ,
               timer  = timer  }

local module = {}

local function create_core_w(width,i,text,bg,fg)
    local aCore        = wibox.widget.textbox()
    aCore:set_text(text or "")
    aCore.bg           = bg or beautiful.bg_normal
    aCore.width        = width or 35
    aCore.border_width = 1
    aCore.border_color = fg or beautiful.fg_normal
    aCore.align        = "center"
    return aCore
end

local function match_icon(arr,name)
    for k2,v2 in ipairs(arr) do
        if k2:find(name) ~= nil then
            return v2
        end
    end
end

local function reload_top(procMenu,data)
    procMenu:clear()
    if data.process then
        local procIcon = {}
        for k2,v2 in ipairs(capi.client.get()) do
            if v2.icon then
                procIcon[v2.class:lower()] = v2.icon
            end
        end
        for i=1,#data.process do
            local w = wibox({ position = "free" , screen = s , ontop = true, bg = beautiful.menu_bg})
            w.visible = false

            local wdg = {}
            wdg.percent       = wibox.widget.textbox()
            wdg.percent.width = 50
            wdg.percent.bg    = "#0F2051"
            wdg.percent.align = "right"
            wdg.process       = wibox.widget.textbox()
            wdg.kill          = wibox.widget.imagebox()
            wdg.kill:set_image(config.data().iconPath .. "kill.png")

--             w.widgets = { wdg.percent,
--                             { wdg.kill, layout = widget2.layout.horizontal.rightleftcached }
--                             , layout = widget2.layout.horizontal.leftrightcached,
--                             { wdg.process , layout = widget2.layout.horizontal.flexcached, }
--                         }

            local processWl = wibox.layout.align.horizontal()
            processWl:set_left   ( wdg.percent       )
            processWl:set_middle ( wdg.process   )
            processWl:set_right  ( wdg.kill )
            w:set_widget(processWl)

            wdg.percent:set_text(data.process[i].percent.."%")
            wdg.process:set_text(" "..data.process[i].name)

            if procIcon[data.process[i].name:lower()] then
                wdg.percent.bg_image = procIcon[data.process[i].name:lower()].icon
            else --Slower, but better chances of success
                wdg.percent.bg_image = match_icon(procIcon,data.process[i].name:lower())
            end
            wdg.percent.bg_resize = true

            procMenu:add_wibox(w , {height = 20  , width = 200})
        end
    end
end


local function update()

end

local function new(margin, args)
    local coreWidgets       = {}
    local cpuInfo           = {}
    local cpulogo           = wibox.widget.imagebox()
    local cpuwidget         = wibox.widget.textbox()

    local infoHeader
    local usageHeader
    local tempHeader
    local processHeader
    local cpuModel
    local iowaitHeader
    local usageHeader2
    local emptyCornerHeader
    local clockHeader
    local idleHeader
    local spacer1
    local volUsage

    local topCpuW
    local infoHeaderW
    local usageHeaderW
    local processHeaderW
    local modelW
    local tableW
    
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
            cpuModel:set_text(cpuStat.model)
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

    local function createDrawer()
        infoHeader        = wibox.widget.textbox()
        usageHeader       = wibox.widget.textbox()
        tempHeader        = wibox.widget.textbox()
        processHeader     = wibox.widget.textbox()
        cpuModel          = wibox.widget.textbox()
        iowaitHeader      = wibox.widget.textbox()
        usageHeader2      = wibox.widget.textbox()
        emptyCornerHeader = wibox.widget.textbox()
        clockHeader       = wibox.widget.textbox()
        idleHeader        = wibox.widget.textbox()
        spacer1           = wibox.widget.textbox()
        volUsage          = widget2.graph()

        topCpuW           = {}
        infoHeaderW       = wibox({ position = "free" , screen = s , ontop = true, height = 20  , bg=beautiful.menu_bg })
        usageHeaderW      = wibox({ position = "free" , screen = s , ontop = true, height = 20  , bg=beautiful.menu_bg })
        processHeaderW    = wibox({ position = "free" , screen = s , ontop = true, height = 20  , bg=beautiful.menu_bg })
        modelW            = wibox({ position = "free" , screen = s , ontop = true, height = 40  , bg=beautiful.menu_bg })
        tableW            = wibox({ position = "free" , screen = s , ontop = true, height = 120 , bg=beautiful.menu_bg })

        topCpuW.visible        = false
        infoHeaderW.visible    = false
        usageHeaderW.visible   = false
        processHeaderW.visible = false
        modelW.visible         = false
        tableW.visible         = false

--         infoHeaderW   .widgets  = {infoHeader    , layout = widget2.layout.horizontal.leftrightcached}
--         usageHeaderW  .widgets  = {usageHeader2  , layout = widget2.layout.horizontal.leftrightcached}
--         processHeaderW.widgets  = {processHeader , layout = widget2.layout.horizontal.leftrightcached}
--         modelW        .widgets  = {cpuModel      , layout = widget2.layout.horizontal.leftrightcached}
        local infoHeaderWl    = wibox.layout.fixed.horizontal()
        local usageHeaderWl   = wibox.layout.fixed.horizontal()
        local processHeaderWl = wibox.layout.fixed.horizontal()
        local modelWl         = wibox.layout.fixed.horizontal()
        infoHeaderWl:add    ( infoHeader    )
        usageHeaderWl:add   ( usageHeader2  )
        processHeaderWl:add ( processHeader )
        modelWl:add         ( cpuModel      )
        infoHeaderW:set_widget    ( infoHeaderWl    )
        usageHeaderW:set_widget   ( usageHeaderWl   )
        processHeaderW:set_widget ( processHeaderWl )
        modelW:set_widget         ( modelWl         )
        infoHeaderW:set_bg     ( beautiful.fg_normal )
        usageHeaderW:set_bg   ( beautiful.fg_normal )
        processHeaderW:set_bg ( beautiful.fg_normal )
        modelW:set_bg         ( beautiful.fg_normal )


        loadData()
--         cpuWidgetArray     = {}
        local cpuWidgetArrayL = wibox.layout.fixed.vertical()
        infoHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>INFO</tt></b></span> ")
        infoHeader.bg      = beautiful.fg_normal
        infoHeader.width   = 212
        cpuModel:set_text(data.cpuStat and data.cpuStat.model or "N/A")
        cpuModel.width     = 212
        usageHeader2:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>USAGE</tt></b></span> ")
        usageHeader2.bg    = beautiful.fg_normal
        usageHeader2.width = 212

        volUsage:set_width        ( 212                                  )
        volUsage:set_height       ( 30                                   )
        volUsage:set_scale        ( true                                 )
        volUsage:set_border_color ( beautiful.fg_normal                  )
        volUsage:set_color        ( beautiful.fg_normal                  )
        vicious.register          ( volUsage, vicious.widgets.cpu,'$1',1 )
--         table.insert              ( cpuWidgetArray, volUsage             )
        cpuWidgetArrayL:add(volUsage)

        --Table header
        emptyCornerHeader:set_markup(" <span color='".. beautiful.bg_normal .."'>Core</span> ")
        emptyCornerHeader.bg           = beautiful.fg_normal
        emptyCornerHeader.width        = 35
        emptyCornerHeader.border_width = 1
        emptyCornerHeader.border_color = beautiful.bg_normal
        clockHeader:set_markup(" <span color='".. beautiful.bg_normal .."'>Ghz</span> ")
        clockHeader.bg                 = beautiful.fg_normal
        clockHeader.width              = 30
        clockHeader.border_width       = 1
        clockHeader.border_color       = beautiful.bg_normal
        tempHeader:set_markup(" <span color='".. beautiful.bg_normal .."'>Temp</span> ")
        tempHeader.bg                  = beautiful.fg_normal
        tempHeader.width               = 40
        tempHeader.border_width        = 1
        tempHeader.border_color        = beautiful.bg_normal
        usageHeader:set_markup(" <span color='".. beautiful.bg_normal .."'>Used</span> ")
        usageHeader.bg                 = beautiful.fg_normal
        usageHeader.width              = 37
        usageHeader.border_width       = 1
        usageHeader.border_color       = beautiful.bg_normal
        iowaitHeader:set_markup(" <span color='".. beautiful.bg_normal .."'> I/O</span> ")
        iowaitHeader.bg                = beautiful.fg_normal
        iowaitHeader.width             = 35
        iowaitHeader.border_width      = 1
        iowaitHeader.border_color      = beautiful.bg_normal
        idleHeader:set_markup(" <span color='".. beautiful.bg_normal .."'> Idle</span> ")
        idleHeader.bg                  = beautiful.fg_normal
        idleHeader.width               = 35
        idleHeader.border_width        = 1
        idleHeader.border_color        = beautiful.bg_normal
--         table.insert(cpuWidgetArray, {emptyCornerHeader,clockHeader,tempHeader,usageHeader,iowaitHeader,idleHeader, layout = widget2.layout.horizontal.leftrightcached})
        local rowL = wibox.layout.fixed.horizontal()
        rowL:add( emptyCornerHeader )
        rowL:add( clockHeader       )
        rowL:add( tempHeader        )
        rowL:add( usageHeader       )
        rowL:add( iowaitHeader      )
        rowL:add( idleHeader        )
        cpuWidgetArrayL:add( rowL )


        local f2 = io.popen("cat /proc/cpuinfo | grep processor | tail -n1 | grep -e'[0-9]*' -o")
        local coreNb = f2:read("*all") or "0"
        f2:close() 
        coreWidgets["count"] = tonumber(coreNb)
        for i=0 , coreWidgets["count"] do
            coreWidgets[i]           = {}
            coreWidgets[i]["core"]   = create_core_w(35,i," <span color='".. beautiful.bg_normal .."'>".."C"..i.."</span> ",beautiful.fg_normal,beautiful.bg_normal)
            coreWidgets[i]["clock"]  = create_core_w(30,i,nil,beautiful.bg_normal,beautiful.fg_normal)
            coreWidgets[i]["temp"]   = create_core_w(40,i,nil,beautiful.bg_normal,beautiful.fg_normal)
            coreWidgets[i]["usage"]  = create_core_w(37,i,nil,beautiful.bg_normal,beautiful.fg_normal)
            coreWidgets[i]["wait"]   = create_core_w(35,i,nil,beautiful.bg_normal,beautiful.fg_normal)
            coreWidgets[i]["idle"]   = create_core_w(35,i,nil,beautiful.bg_normal,beautiful.fg_normal)
            coreWidgets[i]["clock"]  = create_core_w(30,i,nil,beautiful.bg_normal,beautiful.fg_normal)
            coreWidgets[i]["core"].border_width       = 1
            coreWidgets[i]["core"].border_color       = beautiful.bg_normal
--             table.insert(cpuWidgetArray, {coreWidgets[i]["core"],coreWidgets[i]["clock"],coreWidgets[i]["temp"],coreWidgets[i]["usage"],
--                 coreWidgets[i]["wait"],coreWidgets[i]["idle"], layout = widget2.layout.horizontal.leftrightcached})
            local rowDL = wibox.layout.fixed.horizontal()
            rowDL:add( coreWidgets[i]["core" ] )
            rowDL:add( coreWidgets[i]["clock"] )
            rowDL:add( coreWidgets[i]["temp" ] )
            rowDL:add( coreWidgets[i]["usage"] )
            rowDL:add( coreWidgets[i]["wait" ] )
            rowDL:add( coreWidgets[i]["idle" ] )
            cpuWidgetArrayL:add( rowDL )
        end
--         cpuWidgetArray.layout = widget2.layout.vertical.flexcached
        tableW:set_widget(cpuWidgetArrayL)
        
        --   spacer1.text = ""
        --   table.insert(cpuWidgetArray, spacer1)
        --   
        processHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>PROCESS</tt></b></span> ")
        processHeader.bg = beautiful.fg_normal
        processHeader.width = 212
    end

    local function updateTable()
        if data.cpuStat ~= nil and data.cpuStat["core0"] ~= nil and coreWidgets ~= nil then  
            for i=0 , data.cpuStat["core"] do --TODO add some way to correct the number of core, it usually fail on load --Solved
                if i <= (coreWidgets.count  or 1) and coreWidgets[i] then
                    coreWidgets[i].core:set_markup(" <span color='".. beautiful.bg_normal .."'>".."C"..i.."</span> ")
                    coreWidgets[i].clock:set_text(tonumber(data.cpuStat["core"..i]["speed"]) /1024 .. "Ghz")
                    coreWidgets[i].temp:set_text(data.cpuStat["core"..i].temp)
                    coreWidgets[i].usage:set_text(data.cpuStat["core"..i].usage)
                    coreWidgets[i].wait:set_text(data.cpuStat["core"..i].iowait)
                    coreWidgets[i].idle:set_text(data.cpuStat["core"..i].idle)
                end
            end
        end
    end

    local function regenMenu()
        aMenu          = menu({arrow_x=90})
        aMenu.settings.itemWidth = 200
        aMenu:add_wibox(infoHeaderW    , {height = 20  , width = 200})
        aMenu:add_wibox(modelW         , {height = 40  , width = 200})
        aMenu:add_wibox(usageHeaderW   , {height = 20  , width = 200})
        aMenu:add_wibox(tableW         , {height = 120 , width = 200})
        aMenu:add_wibox(processHeaderW , {height = 20  , width = 200})
        procMenu = menu({width=198,maxvisible=6,has_decoration=false,has_side_deco=true})
        aMenu:add_embeded_menu(procMenu)

        aMenu.settings.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x - margin + 40 + 15 + 15
        aMenu.settings.y = 16
        return aMenu
    end

    local visible = false
    function show()
        if not data.menu then
            createDrawer()
            data.menu = regenMenu()
        else
        end
        if not visible then
            loadData()
            updateTable()
            reload_top(procMenu,data)
        end
        visible = not visible
        data.menu:toggle(visible)
    end

    cpulogo:set_image(config.data().iconPath .. "brain.png")
    cpulogo.bg = beautiful.bg_alternate
    cpuwidget.width = 27
    cpuwidget.bg = beautiful.bg_alternate
  vicious.register(cpuwidget, vicious.widgets.cpu,'$1%')

  local buttons2 = util.table.join(button({ }, 1, function () show() end))

  cpuwidget:buttons (buttons2)
  cpulogo:buttons   (buttons2)

--   mytimer = capi.timer({ timeout = 2 })
--   mytimer:add_signal("timeout", updateTable)
--   mytimer:start()

  local cpuBar = widget2.graph()
  cpuBar:set_width(40)
  cpuBar:set_height(14)
  cpuBar:set_background_color(beautiful.bg_alternate)
  cpuBar:set_border_color(beautiful.fg_normal)
  cpuBar:set_color(beautiful.fg_normal)

  local marg = wibox.layout.margin(cpuBar)
  marg:set_top(2)
  marg:set_bottom(2)
  marg:set_right(4)

  if (widget2.graph.set_offset ~= nil) then
    cpuBar:set_offset(1)
  end

  vicious.register(cpuBar, vicious.widgets.cpu,'$1',1)
  
  cpuwidget.fit = function(box, w, h)
      local w, h = wibox.widget.textbox.fit(box, w, h)
      return 27, h
  end

  local l = wibox.layout.fixed.horizontal()
  l:add(cpulogo)
  l:add(cpuwidget)
  l:add(marg)
  return l--{logo = cpulogo, text = cpuwidget, graph = cpuBar.widget}
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
