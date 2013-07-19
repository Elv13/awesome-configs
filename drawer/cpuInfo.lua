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
local config       = require( "forgotten"         )
local vicious      = require( "extern.vicious" )
local menu         = require( "radical.context"   )
local util         = require( "awful.util"     )
local wibox        = require( "wibox"          )
local radtab       = require("radical.widgets.table")
local themeutils = require( "blind.common.drawing"    )

local data     = {}
local procMenu = nil

local capi = { image  = image  ,
               screen = screen ,
               client = client ,
               widget = widget ,
               mouse  = mouse  ,
               timer  = timer  }

local module = {}

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
            wdg.kill:set_image(config.iconPath .. "kill.png")

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

            procMenu:add_widget(processWl , {height = 20  , width = 200})
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

    local infoHeaderWl    
    local usageHeaderWl   
    local processHeaderWl 
    local modelWl         
    local cpuWidgetArrayL
    local main_table
    
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
        local tab,widgets = radtab({
            {"","","","",""},
            {"","","","",""},
            {"","","","",""},
            {"","","","",""}},
            {row_height=20,v_header = {"C1","C2","C3","C4"},
            h_header = {"GHz","Temp","Used","I/O","Idle"}
        })
        main_table = widgets

        infoHeaderWl    = wibox.layout.fixed.horizontal()
        usageHeaderWl   = wibox.layout.fixed.horizontal()
        processHeaderWl = wibox.layout.fixed.horizontal()
        modelWl         = wibox.layout.fixed.horizontal()
        infoHeaderWl:add    ( infoHeader    )
        usageHeaderWl:add   ( usageHeader2  )
        processHeaderWl:add ( processHeader )
        modelWl:add         ( cpuModel      )


        loadData()
        
        cpuWidgetArrayL = wibox.layout.margin()
        cpuWidgetArrayL:set_margins(3)
        cpuWidgetArrayL:set_bottom(10)
        cpuWidgetArrayL:set_widget(tab)
        
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

        local f2 = io.popen("cat /proc/cpuinfo | grep processor | tail -n1 | grep -e'[0-9]*' -o")
        local coreNb = f2:read("*all") or "0"
        f2:close()
        coreWidgets["count"] = tonumber(coreNb)
        processHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>PROCESS</tt></b></span> ")
        processHeader.bg = beautiful.fg_normal
        processHeader.width = 212
    end

    local function updateTable()
        local cols = {
            CLOCK = 1,
            TEMP  = 2,
            USED  = 3,
            IO    = 4,
            IDLE  = 5,
        }
        if data.cpuStat ~= nil and data.cpuStat["core0"] ~= nil and main_table ~= nil then  
            for i=0 , data.cpuStat["core"] do --TODO add some way to correct the number of core, it usually fail on load --Solved
                if i <= (#main_table or 1) and main_table[i+1] then
                    main_table[i+1][cols["CLOCK"]]:set_text(tonumber(data.cpuStat["core"..i]["speed"]) /1024 .. "Ghz")
                    main_table[i+1][cols["TEMP"]]:set_text(data.cpuStat["core"..i].temp)
                    main_table[i+1][cols["USED"]]:set_text(data.cpuStat["core"..i].usage)
                    main_table[i+1][cols["IO"]]:set_text(data.cpuStat["core"..i].iowait)
                    main_table[i+1][cols["IDLE"]]:set_text(data.cpuStat["core"..i].idle)
                end
            end
        end
    end

    local function regenMenu()
        aMenu = menu({item_width=198,width=200})
        aMenu:add_widget(infoHeaderWl    , {height = 20  , width = 200})
        aMenu:add_widget(modelWl         , {height = 40  , width = 200})
        aMenu:add_widget(usageHeaderWl   , {height = 20  , width = 200})
        aMenu:add_widget(volUsage        , {height = 30  , width = 200})
        aMenu:add_widget(cpuWidgetArrayL         , {width = 200})
        aMenu:add_widget(processHeaderWl , {height = 20  , width = 200})
        procMenu = menu({width=198,maxvisible=6,has_decoration=false,has_side_deco=true})
        aMenu:add_embeded_menu(procMenu)

        aMenu.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x - margin + 40 + 15 + 15
        aMenu.y = 16
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
        data.menu.visible = visible
    end

    cpulogo:set_image(themeutils.apply_color_mask(config.iconPath .. "brain.png"))
    cpulogo.bg = beautiful.bg_alternate
    cpuwidget.width = 27
    cpuwidget.bg = beautiful.bg_alternate
  vicious.register(cpuwidget, vicious.widgets.cpu,'$1%')

  local buttons2 = util.table.join(button({ }, 1, function () show() end))

  cpuwidget:buttons (buttons2)
  cpulogo:buttons   (buttons2)

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
