local setmetatable = setmetatable
local io           = io
local ipairs       = ipairs
local loadstring   = loadstring
local print        = print
local tonumber     = tonumber
local beautiful    = require( "beautiful"                )
local button       = require( "awful.button"             )
local widget2      = require( "awful.widget"             )
local config       = require( "forgotten"                )
local vicious      = require( "extern.vicious"           )
local menu         = require( "radical.context"          )
local util         = require( "awful.util"               )
local wibox        = require( "wibox"                    )
local themeutils   = require( "blind.common.drawing"     )
local radtab       = require( "radical.widgets.table"    )
local embed        = require( "radical.embed"            )
local radical      = require( "radical"                  )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo

local data     = {}
local procMenu = nil

local capi = { screen = screen , client = client ,
               mouse  = mouse  , timer  = timer  }

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
            local wdg = {}
            wdg.percent       = wibox.widget.textbox()
            wdg.percent.fit = function()
                return 30,procMenu.item_height
            end
            wdg.percent.draw = function(self,w, cr, width, height)
                cr:save()
                cr:set_source(color(procMenu.bg_alternate))
                cr:paint()
                cr:restore()
                wibox.widget.textbox.draw(self,w, cr, width, height)
            end
            wdg.kill          = wibox.widget.imagebox()
            wdg.kill:set_image(config.iconPath .. "kill.png")

            wdg.percent:set_text(data.process[i].percent.."%")

            if procIcon[data.process[i].name:lower()] then
                wdg.percent.bg_image = procIcon[data.process[i].name:lower()].icon
            else --Slower, but better chances of success
                wdg.percent.bg_image = match_icon(procIcon,data.process[i].name:lower())
            end
            wdg.percent.bg_resize = true

            procMenu:add_item({text=data.process[i].name,suffix_widget=wdg.kill,prefix_widget=wdg.percent})
        end
    end
end

local function new(margin, args)
    local cpuInfo           = {}
    local cpulogo           = wibox.widget.imagebox()
    local cpuwidget         = wibox.widget.textbox()

    local cpuModel
    local spacer1
    local volUsage

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
        cpuModel          = wibox.widget.textbox()
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
        modelWl         = wibox.layout.fixed.horizontal()
        modelWl:add         ( cpuModel      )

        loadData()

        cpuWidgetArrayL = wibox.layout.margin()
        cpuWidgetArrayL:set_margins(3)
        cpuWidgetArrayL:set_bottom(10)
        cpuWidgetArrayL:set_widget(tab)

        cpuModel:set_text(data.cpuStat and data.cpuStat.model or "N/A")
        cpuModel.width     = 212

        volUsage:set_width        ( 212                                  )
        volUsage:set_height       ( 30                                   )
        volUsage:set_scale        ( true                                 )
        volUsage:set_border_color ( beautiful.fg_normal                  )
        volUsage:set_color        ( beautiful.fg_normal                  )
        vicious.register          ( volUsage, vicious.widgets.cpu,'$1',1 )

        local f2 = io.popen("cat /proc/cpuinfo | grep processor | tail -n1 | grep -e'[0-9]*' -o")
        local coreNb = f2:read("*all") or "0"
        f2:close()
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
                    main_table[i+1][cols[ "CLOCK" ]]:set_text(tonumber(data.cpuStat["core"..i]["speed"]) /1024 .. "Ghz"  )
                    main_table[i+1][cols[ "TEMP"  ]]:set_text(data.cpuStat["core"..i].temp                               )
                    main_table[i+1][cols[ "USED"  ]]:set_text(data.cpuStat["core"..i].usage                              )
                    main_table[i+1][cols[ "IO"    ]]:set_text(data.cpuStat["core"..i].iowait                             )
                    main_table[i+1][cols[ "IDLE"  ]]:set_text(data.cpuStat["core"..i].idle                               )
                end
            end
        end
    end

    local function regenMenu()
        aMenu = menu({item_width=198,width=200,arrow_type=radical.base.arrow_type.CENTERED})
        aMenu:add_widget(radical.widgets.header(aMenu,"INFO")  , {height = 20  , width = 200})
        aMenu:add_widget(modelWl         , {height = 40  , width = 200})
        aMenu:add_widget(radical.widgets.header(aMenu,"USAGE")   , {height = 20  , width = 200})
        aMenu:add_widget(volUsage        , {height = 30  , width = 200})
        aMenu:add_widget(cpuWidgetArrayL         , {width = 200})
        aMenu:add_widget(radical.widgets.header(aMenu,"PROCESS") , {height = 20  , width = 200})
        procMenu = embed({max_items=6})
        aMenu:add_embeded_menu(procMenu)
        return aMenu
    end

    local function show()
        if not data.menu then
            createDrawer()
            data.menu = regenMenu()
        else
        end
        if not data.menu.visible then
            loadData()
            updateTable()
            reload_top(procMenu,data)
        end
        data.menu.visible = not data.menu.visible
    end

    cpulogo:set_image(themeutils.apply_color_mask(config.iconPath .. "brain.png"))
    cpulogo.bg = beautiful.bg_alternate
    cpuwidget.width = 27
    cpuwidget.bg = beautiful.bg_alternate
  vicious.register(cpuwidget, vicious.widgets.cpu,'$1%')

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
  l:buttons (util.table.join(button({ }, 1, function (geo) show(); data.menu.parent_geometry = geo end)))
  return l
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
