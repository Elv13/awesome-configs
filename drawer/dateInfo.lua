local setmetatable = setmetatable
local io           = io
local os           = os
local string       = string
local print        = print
local beautiful    = require( "beautiful"                    )
local util         = require( "awful.util"                   )
local textclock    = require( "awful.widget.textclock"       )
local wibox        = require( "wibox"                        )
local button       = require( "awful.button"                 )
local vicious      = require( "extern.vicious"               )
local menu         = require( "widgets.menu"                 )
local widget       = require( "awful.widget"                 )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo

local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               mouse  = mouse  ,
               timer  = timer  }

local module = {}

local data = {}
local calPopup

local function update()

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
  timeInfo:set_markup(dateInfo)
  
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
  
--   margins[calInfo] = {bottom = 0, left =5}
    

  testImage2       = wibox.widget.imagebox()
  --testImage2.image = capi.image("/tmp/1600.jpg")
--   margins.margins[testImage2]      = {left = 5, right = 25}
  
  testImage3                       = wibox.widget.imagebox()
  testImage3:set_image("/tmp/flower_crop.jpg")
--   margins.margins[testImage3]      = {left = 10, right = 25, top = 10}
  
  local calendarHeader,calH_b      = wibox.widget.textbox(),wibox.widget.background()
  calendarHeader:set_markup( " <span color='".. beautiful.bg_normal .."'><b><tt>CALENDAR</tt></b></span> ")
  calendarHeader.width             = 147
  calendarHeader.height            = 21
  local calH_l                     = wibox.layout.fixed.horizontal()
  calH_l:add(calendarHeader)
  calH_b:set_bg(beautiful.fg_normal)
  calH_b:set_widget(calH_l)
  
  local internationalHeader,inH_bg = wibox.widget.textbox(),wibox.widget.background()
  internationalHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>INTERNATIONAL</tt></b></span> ")
  internationalHeader.width        = 147
  local inH_l                      = wibox.layout.fixed.horizontal()
  inH_l:add(internationalHeader)
  inH_bg:set_bg(beautiful.fg_normal)
  inH_bg:set_widget(inH_l)
  
  local satelliteHeader,satH_bg    = wibox.widget.textbox(),wibox.widget.background()
  satelliteHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>SATELLITE</tt></b></span> ")
  satelliteHeader.width            = 147
  local satH_l                     = wibox.layout.fixed.horizontal()
  satH_l:add(satelliteHeader)
  satH_bg:set_bg(beautiful.fg_normal)
  satH_bg:set_widget(satH_l)
  
  local forecastHeader,forH_bg     = wibox.widget.textbox(),wibox.widget.background()
  forecastHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>FORCAST</tt></b></span> ")
  forecastHeader.width             = 147
  local forH_l                     = wibox.layout.fixed.horizontal()
  forH_l:add(forecastHeader)
  forH_bg:set_bg(beautiful.fg_normal)
  forH_bg:set_widget(forH_l)
  
  local spacer96                   = wibox.widget.textbox()
  spacer96:set_text("\n\n")
  spacer96.width                   = 147
  
  vicious.register(timeInfo,  testFunc, '$1',1)

--   data.wibox.widgets =                    {
--       calH_b                      ,
--       calInfo                             ,
--       inH_bg                 ,
--       timeInfo                            ,
--       satH_bg                     ,
--       testImage2                          ,
--       testImage3                          ,
--       spacer96                            ,
--       forH_bg                      ,
--       weatherInfo2                        ,
--       layout = margins.vertical.topbottom ,
--   }
  local mylaunchertext     = wibox.widget.textbox()
--     mylaunchertext:margin({ left = 30,right=17})
  mylaunchertext:set_text("Apps")
  mylaunchertext.bg_resize = false
  local l = wibox.layout.fixed.vertical()
  l:add( calH_b       )
  l:add( calInfo      )
  l:add( inH_bg       )
  l:add( timeInfo     )
  l:add( satH_bg      )
  l:add( testImage2   )
  l:add( testImage3   )
  l:add( spacer96     )
  l:add( forH_bg      )
  l:add( weatherInfo2 )
  l:fill_space(true)
  data.wibox:set_widget(l)
end

local function new(screen, args)
  local mytextclock = widget.textclock()
  local top,bottom
  mytextclock:buttons (util.table.join(button({ }, 1, function ()
      if not data.wibox then
        data.wibox         = wibox({ position = "free", screen = capi.screen.count() , bg = beautiful.menu_bg})
        data.wibox.ontop   = true
        data.wibox.visible = false
        top,bottom = menu.gen_menu_decoration(153,{arrow_x=153 - mytextclock._layout:get_pixel_extents().width/2 - 10})
        local guessHeight = capi.screen[capi.mouse.screen].geometry.height-140
        local img = cairo.ImageSurface(cairo.Format.ARGB32, 153, guessHeight)
        local cr = cairo.Context(img)
        cr:set_operator(cairo.Operator.SOURCE)
        cr:set_source_rgba( 1, 1, 1, 1 )
        cr:paint()
        cr:set_source_rgba( 0, 0, 0, 0 )
        cr:rectangle(0,0, 3, guessHeight)
        cr:rectangle(153-3,0, 3, guessHeight)
        cr:fill()
--         data.wibox.shape_clip     = img._native
        data.wibox.border_color = beautiful.fg_normal

        createDrawer()
      end
      data.wibox:geometry({ width = 153, height = capi.screen[capi.mouse.screen].geometry.height-140, x = capi.screen[capi.mouse.screen].geometry.width - 153 + capi.screen[capi.mouse.screen].geometry.x - 5, y = 16 + (top and top.height or 0)})
      data.wibox.visible = not data.wibox.visible
      top.x = data.wibox.x
      top.y = 16
      bottom.x = data.wibox.x
      bottom.y = data.wibox.y+data.wibox.height
      top.visible = data.wibox.visible
      bottom.visible = data.wibox.visible
  end)))

  return mytextclock
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
