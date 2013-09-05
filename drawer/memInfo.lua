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
local vicious      = require( "extern.vicious"           )
local config       = require( "forgotten"                )
local util         = require( "awful.util"               )
local radical      = require( "radical"                  )
local themeutils   = require( "blind.common.drawing"     )
local embed        = require( "radical.embed"            )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo
local allinone     = require( "widgets.allinone"         )

local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               client = client ,
               mouse  = mouse  ,
               timer  = timer  }

local module = {}

local data = {}

local memInfo = {}

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

-- util.spawn("/bin/bash -c 'while true;do "..util.getdir("config") .."/Scripts/memStatistics.sh > /tmp/memStatistics.lua && sleep 5;done'")
-- util.spawn("/bin/bash -c 'while true; do "..util.getdir("config") .."/Scripts/topMem2.sh > /tmp/topMem.lua;sleep 5;done'")
  
local function refreshStat()
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

    if tabWdg then
        tabWdg[ tabWdgRow.RAM  ][ tabWdgCol.TOTAL ]:set_text( statNotFound or memStat[ "ram" ][ "total" ])
        tabWdg[ tabWdgRow.RAM  ][ tabWdgCol.FREE  ]:set_text( statNotFound or memStat[ "ram" ][ "free"  ])
        tabWdg[ tabWdgRow.RAM  ][ tabWdgCol.USED  ]:set_text( statNotFound or memStat[ "ram" ][ "used"  ])
        tabWdg[ tabWdgRow.SWAP ][ tabWdgCol.TOTAL ]:set_text( statNotFound or memStat[ "swap"][ "total" ])
        tabWdg[ tabWdgRow.SWAP ][ tabWdgCol.FREE  ]:set_text( statNotFound or memStat[ "swap"][ "free"  ])
        tabWdg[ tabWdgRow.SWAP ][ tabWdgCol.USED  ]:set_text( statNotFound or memStat[ "swap"][ "used"  ])
    end

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
    local anUser = wibox.widget.textbox()
    anUser:set_text(i)
    totalUser = totalUser +1
    usrMenu:add_item({text=v,suffix_widget=anUser})
  end
  return totalUser
end

local function reload_state(typeMenu,data)
  local totalState = 0
  for v, i in next, data.state or {} do
    local anState = wibox.widget.textbox()
    anState:set_text(i)
    totalState = totalState +1
    typeMenu:add_item({text=v,suffix_widget=anState})
  end
end

local function reload_top(topMenu,data)
  for i = 0, #(data.process or {}) do
    if data.process ~= nil and data.process[i]["name"] ~= nil then

--             local aPid = wibox.widget.textbox()
--             aPid:set_text(data.process[i]["pid"])

      local aMem = wibox.widget.textbox()
      aMem:set_text(data.process[i]["mem"])
      aMem.fit = function()
        return 58,topMenu.item_height
      end

      for k2,v2 in ipairs(capi.client.get()) do
        if v2.class:lower() == data.process[i]["name"]:lower() or v2.name:lower():find(data.process[i]["name"]:lower()) ~= nil then
          aMem.bg_image = v2.icon
          break
        end
      end

      aMem.draw = function(self,w, cr, width, height)
        cr:save()
        cr:set_source(color(topMenu.bg_alternate))
        cr:rectangle(0,0,width-height/2,height)
        cr:fill()
--                 if aMem.bg_image then
--                     cr:set_source(aMem.bg_image)
--                     cr:paint()
--                 end
        
        cr:set_source_surface(themeutils.get_beg_arrow2({bg_color=topMenu.bg_alternate}),width-height/2,0)
        cr:paint()
        cr:restore()
        wibox.widget.textbox.draw(self,w, cr, width, height)
      end

      testImage2       = wibox.widget.imagebox()
      testImage2:set_image(config.iconPath .. "kill.png")

      topMenu:add_item({text=data.process[i]["name"] or "N/A",prefix_widget=aMem,suffix_widget=testImage2})
    end
  end
end

local usrMenu,typeMenu,topMenu

local function repaint(margin)
  mainMenu = menu({arrow_x=90,nokeyboardnav=true,item_width=198,width=200,arrow_type=radical.base.arrow_type.CENTERED})
  mainMenu:add_widget(radical.widgets.header(mainMenu,"USAGE"),{height = 20 , width = 200})

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
  mainMenu:add_widget(radical.widgets.header(mainMenu,"USERS"),{height = 20, width = 200})
  local memStat

  usrMenu = embed({max_items=5})
  reload_user(usrMenu,data)
  mainMenu:add_embeded_menu(usrMenu)

  mainMenu:add_widget(radical.widgets.header(mainMenu,"STATE"),{height = 20 , width = 200})

  typeMenu = embed({max_items=3})
  reload_state(typeMenu,data)
  mainMenu:add_embeded_menu(typeMenu)

  local imb = wibox.widget.imagebox()
  imb:set_image(beautiful.path .. "Icon/reload.png")
  mainMenu:add_widget(radical.widgets.header(mainMenu,"PROCESS",{suffix_widget=imb}),{height = 20 , width = 200})

  topMenu = embed({max_items=3})
  reload_top(topMenu,data)
  mainMenu:add_embeded_menu(topMenu)

  mainMenu.x = capi.screen[capi.mouse.screen].geometry.width - 200 + capi.screen[capi.mouse.screen].geometry.x - margin
  mainMenu.y = 16
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
  local visible = false
  function toggle()
      if not data.menu then
          refreshStat()
          data.menu = repaint(margin-memwidget._layout:get_pixel_extents().width-20-10)
      end
      visible = not visible
      if visible then
          refreshStat()
          update()
      end
      data.menu.visible = false
      data.menu.visible = visible
  end

  local buttonclick = util.table.join(button({ }, 1, function (geo) toggle();data.menu.parent_geometry=geo end))

  local volumewidget2 = allinone()
  volumewidget2:set_icon(config.iconPath .. "cpu.png")
  vicious.register(volumewidget2, vicious.widgets.mem, '$1', 1, 'mem')

  volumewidget2:buttons (buttonclick)
  return volumewidget2
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;