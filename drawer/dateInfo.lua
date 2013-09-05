local setmetatable = setmetatable
local io           = io
local os           = os
local string       = string
local print        = print
local util         = require( "awful.util"               )
local wibox        = require( "wibox"                    )
local button       = require( "awful.button"             )
local vicious      = require( "extern.vicious"           )
local menu         = require( "radical.context"          )
local widget       = require( "awful.widget"             )
local themeutils   = require( "blind.common.drawing"     )
local radical      = require( "radical"                  )

local capi = { screen = screen , mouse  = mouse  , timer  = timer  }

local module = {}
local mainMenu = nil

local function getHour(input)
  local toReturn
  if input < 0 then
    toReturn = 24 + input
  elseif input > 24 then
    toReturn = input - 24
  else
    toReturn = input
  end
  return toReturn
end

local function testFunc()
  local dateInfo = ""
  dateInfo = dateInfo .. "<b><u>Europe:</u></b>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> UTC: </b><i>" ..  getHour(os.date('%H') + 5) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> CET: </b><i>" ..  getHour(os.date('%H') + 6) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> EET: </b><i>" ..  getHour(os.date('%H') + 7) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n\n<b><u>America:</u></b>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> EST: </b><i>" ..  getHour(os.date('%H') + 0) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> PST: </b><i>" ..  getHour(os.date('%H') - 3) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> CST: </b><i>" ..  getHour(os.date('%H') - 1) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n\n<b><u>Japan:</u></b>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">⌚</span> JST: </b><i>" ..  getHour(os.date('%H') + 13) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>\n\n"
  return {dateInfo}
end

local function createDrawer()
  local f = io.popen('/usr/bin/cal | sed -r -e "s/(^| )(`date +\\"%d\\"`)($| )/\\1<b><span background=\\"#1577D3\\" foreground=\\"#0A1535\\">\\2<\\/span><\\/b>\\3/"',"r")
  local someText2 = "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
  f:close()

  local month = os.date('%m')
  local year = os.date('%Y')

  --Display the next month
  if month == '12' then
    month = 1
    year = year + 1
  else
    month = month + 1
  end

  f = io.popen('/usr/bin/cal ' .. month .. ' ' .. year ,"r")
  someText2 = someText2 .. "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
  f:close()

  util.spawn("/bin/bash -c '"..util.getdir("config") .."/Scripts/curWeather2.sh > /tmp/weather2.txt'")

  local weatherInfo2 = wibox.widget.textbox()
  function updateWeater()
    local f = io.open('/tmp/weather2.txt',"r")
    local weatherInfo = nil
    if f ~= nil then
      weatherInfo = f:read("*all")
      f:close()
      weatherInfo = string.gsub(weatherInfo, "@cloud", "☁" )
      weatherInfo = string.gsub(weatherInfo, "@sun", "✸"   )
      weatherInfo = string.gsub(weatherInfo, "@moon", "☪"  )
      weatherInfo = string.gsub(weatherInfo, "@rain", "☔"  )--☂
      weatherInfo = string.gsub(weatherInfo, "@snow", "❄"  )
      weatherInfo = string.gsub(weatherInfo, "deg", "°"    )
      weatherInfo2:set_markup(weatherInfo or "N/A")
    end
  end
  mytimer2 = capi.timer({ timeout = 2000 })
  mytimer2:connect_signal("timeout", updateWeater)
  mytimer2:start()
  updateWeater()

  local timeInfo = wibox.widget.textbox()
  local calInfo = wibox.widget.textbox()

  mytimer = capi.timer({ timeout = 3600 })
  mytimer:connect_signal("timeout", function ()
      local f = io.popen('/usr/bin/cal | sed -r -e "s/(^| )(`date +\\"%d\\"`)($| )/\\1<b><span background=\\"#1577D3\\" foreground=\\"#0A1535\\">\\2<\\/span><\\/b>\\3/"',"r")
      local someText3 = "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
      f:close()
      local month = os.date('%m')
      local year = os.date('%Y')
      --Display the next month
      if month == '12' then
        month = 1
        year = year + 1
      else
        month = month + 1
      end
      f = io.popen('/usr/bin/cal ' .. month .. ' ' .. year ,"r")
      someText3 = someText3 .. "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
      f:close()
      calInfo:set_markup(someText3)
    end)
  mytimer:start()

  calInfo:set_markup(someText2)
  local testImage2       = wibox.widget.imagebox()
  local testImage3                       = wibox.widget.imagebox()
  testImage3:set_image("/tmp/flower_crop.jpg")

  local spacer96                   = wibox.widget.textbox()
  spacer96:set_text("\n\n")

  vicious.register(timeInfo,  testFunc, '$1',1)

  mainMenu:add_widget(radical.widgets.header(mainMenu, "CALANDAR"     ),{height = 20 , width = 200})
  mainMenu:add_widget(calInfo)
  mainMenu:add_widget(radical.widgets.header(mainMenu, "INTERNATIONAL"),{height = 20 , width = 200})
  mainMenu:add_widget(timeInfo)
  mainMenu:add_widget(radical.widgets.header(mainMenu, "SATELLITE"    ),{height = 20 , width = 200})
  mainMenu:add_widget(testImage2)
  mainMenu:add_widget(testImage3)
  mainMenu:add_widget(spacer96)
  mainMenu:add_widget(radical.widgets.header(mainMenu, "FORCAST"      ),{height = 20 , width = 200})
  return calInfo:fit(9999,9999)
end

local function new(screen, args)
  local mytextclock = widget.textclock(" %H:%M ")
  mytextclock:buttons (util.table.join(button({ }, 1, function (geo)
      if not mainMenu then
        mainMenu = menu({arrow_type=radical.base.arrow_type.CENTERED})
        min_width = createDrawer()
        mainMenu.width = min_width + 2*mainMenu.border_width + 150
        mainMenu._internal.width = min_width
      end
      mainMenu.parent_geometry = geo
      mainMenu.visible = not mainMenu.visible
  end)))
  return mytextclock
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
