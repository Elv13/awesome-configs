local setmetatable = setmetatable
local io = io
local os = os
local string = string
local beautiful = require("beautiful")
local util = require("awful.util")
local textclock = require("awful.widget.textclock")
local margins = require("awful.widget.layout")
local wibox = require("awful.wibox")
local topbottom = require("awful.widget.layout.vertical")
local vicious = require("vicious")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
               timer = timer}

module("drawer.dateinfo")

local data = {}
local calPopup

function update()

end

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
  return dateInfo  
end

local function createDrawer()
  local f = io.popen('cal | sed -r -e "s/(^| )(`date +\\"%d\\"`)($| )/\\1<b><span background=\\"#1577D3\\" foreground=\\"#0A1535\\">\\2<\\/span><\\/b>\\3/"',"r")
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
  
  f = io.popen('cal ' .. month .. ' ' .. year ,"r")
  someText2 = someText2 .. "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
  f:close()
  
  
  local dateInfo = ""
  dateInfo = dateInfo .. "<b><u>Europe:</u></b>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">?</span> UTC: </b><i>" ..  getHour(os.date('%H') + 5) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">?</span> CET: </b><i>" ..  getHour(os.date('%H') + 6) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">?</span> EET: </b><i>" ..  getHour(os.date('%H') + 7) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n\n<b><u>America:</u></b>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">?</span> EST: </b><i>" ..  getHour(os.date('%H') + 0) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">?</span> PST: </b><i>" ..  getHour(os.date('%H') - 3) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">?</span> CST: </b><i>" ..  getHour(os.date('%H') - 1) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>"
  dateInfo = dateInfo .. "\n\n<b><u>Japan:</u></b>"
  dateInfo = dateInfo .. "\n<b>  <span size=\"x-large\">?</span> JST: </b><i>" ..  getHour(os.date('%H') + 13) .. ":" .. os.date('%M').. ":" .. os.date('%S') .. "</i>\n"

  util.spawn("/bin/bash -c '"..util.getdir("config") .."/Scripts/curWeather2.sh > /tmp/weather2.txt'")
  
  local weatherInfo2 = capi.widget({ type = 'textbox', })
  function updateWeater()
    local f = io.open('/tmp/weather2.txt',"r")
    local weatherInfo = nil
    if f ~= nil then
      weatherInfo = f:read("*all")
      f:close()
    
      weatherInfo = string.gsub(weatherInfo, "@cloud", "☁")
      weatherInfo = string.gsub(weatherInfo, "@sun", "✸")
      weatherInfo = string.gsub(weatherInfo, "@moon", "☪")
      weatherInfo = string.gsub(weatherInfo, "@rain", "☔")--☂
      weatherInfo = string.gsub(weatherInfo, "@snow", "❄")
      weatherInfo = string.gsub(weatherInfo, "deg", "°")
      weatherInfo2.text = weatherInfo or "N/A"
    end
  end
  mytimer2 = capi.timer({ timeout = 2000 })
  mytimer2:add_signal("timeout", updateWeater)
  mytimer2:start()
  updateWeater()
  

  local timeInfo = capi.widget({ type = 'textbox', })
  timeInfo.text = dateInfo
  
  local calInfo = capi.widget({ type = 'textbox', })
  
  mytimer = capi.timer({ timeout = 3600 })
  mytimer:add_signal("timeout", function ()
                                  local f = io.popen('cal | sed -r -e "s/(^| )(`date +\\"%d\\"`)($| )/\\1<b><span background=\\"#1577D3\\" foreground=\\"#0A1535\\">\\2<\\/span><\\/b>\\3/"',"r")
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
                                  
                                  f = io.popen('cal ' .. month .. ' ' .. year ,"r")
                                  someText3 = someText3 .. "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
                                  f:close()
                                  calInfo.text = someText3
                                end)
  mytimer:start()
  
  
  calInfo.text = someText2
  
  margins[calInfo] = {bottom = 0, left =5}
    

  testImage2       = capi.widget({ type = "imagebox"})
  testImage2.image = capi.image("/tmp/1600.jpg")
  margins.margins[testImage2] = {left = 5, right = 25}
  
  testImage3       = capi.widget({ type = "imagebox"})
  testImage3.image = capi.image("/tmp/flower_crop.jpg")
  margins.margins[testImage3] = {left = 10, right = 25, top = 10}
  
  vicious.register(timeInfo,  testFunc, '$1',1)
  
  local calendarHeader = capi.widget({type = "textbox"})
  calendarHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>CALENDAR</tt></b></span> "
  calendarHeader.bg = beautiful.fg_normal
  calendarHeader.width = 147
  calendarHeader.height = 21
  
  local internationalHeader = capi.widget({type = "textbox"})
  internationalHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>INTERNATIONAL</tt></b></span> "
  internationalHeader.bg = beautiful.fg_normal
  internationalHeader.width = 147
  
  local satelliteHeader = capi.widget({type = "textbox"})
  satelliteHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>SATELLITE</tt></b></span> "
  satelliteHeader.bg = beautiful.fg_normal
  satelliteHeader.width = 147
  
  local forecastHeader = capi.widget({type = "textbox"})
  forecastHeader.text = " <span color='".. beautiful.bg_normal .."'><b><tt>FORCAST</tt></b></span> "
  forecastHeader.bg = beautiful.fg_normal
  forecastHeader.width = 147
  
  local spacer96 = capi.widget({type = "textbox"})
  spacer96.text = "\n\n"
  spacer96.width = 147

  data.wibox.widgets = {
      calendarHeader,
      calInfo,
      internationalHeader,
      timeInfo,
      satelliteHeader,
      testImage2,
      testImage3,
      spacer96,
      forecastHeader,
      weatherInfo2,
      layout = margins.vertical.topbottom
  }

  
end

  
function new(screen, args)
  data.wibox = wibox({ position = "free", screen = capi.screen.count() })
  data.wibox.ontop = true
  data.wibox.visible = false
  createDrawer() 
  data.wibox:geometry({ width = 147, height = 994, x = capi.screen[capi.mouse.screen].geometry.width*2 -  147, y = 20})
  
  mytextclock = textclock({ align = "right" })

  mytextclock:add_signal("mouse::enter", function() data.wibox.visible = not data.wibox.visible end)

  mytextclock:add_signal("mouse::leave", function() data.wibox.visible = not data.wibox.visible end)
  
  return mytextclock
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
