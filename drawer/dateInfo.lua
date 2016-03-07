local setmetatable = setmetatable
local io           = io
local os           = os
local string       = string
local print        = print
local tonumber     = tonumber
local util         = require( "awful.util"               )
local wibox        = require( "wibox"                    )
local button       = require( "awful.button"             )
local vicious      = require( "extern.vicious"           )
local menu         = require( "radical.context"          )
local widget       = require( "awful.widget"             )
local themeutils   = require( "blind.common.drawing"     )
local radical      = require( "radical"                  )
local beautiful    = require( "beautiful"                )
local json         = require( "drawer.JSON"              )
local capi = { screen = screen , mouse  = mouse  , timer  = timer  }

local dateModule = {}
local mainMenu = nil
local month = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}

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
  local pipe=io.popen(util.getdir("config")..'/drawer/Scripts/worldTime.sh')
  dateInfo=pipe:read("*a")
  pipe:close()
  return {dateInfo}
end

local function createDrawer()
  print("CREATE DRAWER")
  local calInfo = wibox.widget.textbox()
  local timeInfo = wibox.widget.textbox()

  --Weather stuff
  local weatherInfo2=wibox.widget.textbox()

  function updateWeater()
    return --Has been reported broken in 3.5.9
--    if dateModule.latitude ~= nil and dateModule.longitude ~= nil then
--      local f=io.popen("curl -S 'http://api.openweathermap.org/data/2.5/weather?lat="..dateModule.latitude.."&lon="..dateModule.longitude.."'")
--      local weatherInfo = nil
--      if f ~= nil then
--        local wData=json:decode(f:read("*all"))
--        f:close()
--        if wData ~= nil then
--          weatherInfo=" "..wData.name..", "..wData.sys.country.."\n"
--          weatherInfo=weatherInfo.."  <b>Temp:</b> "..(wData.main.temp-273.15).." °C\n"
--          weatherInfo=weatherInfo.."  <b>Wind:</b> "..(wData.wind.speed).." m/s\n"
--          weatherInfo=weatherInfo.."  <b>Humidity:</b> "..(wData.main.humidity).." hPa"
--
--          weatherInfo2:set_markup(weatherInfo or "N/A")
--        else
--          weatherInfo2:set_markup("N/A")
--        end
--      end
 --   end
  end

  mytimer2 = capi.timer({ timeout = 1800 })
  mytimer2:connect_signal("timeout", updateWeater)
  mytimer2:start()
  updateWeater()

  function updateCalendar()
    local f = io.popen('/usr/bin/cal',"r")
    local someText3 = "<tt><b><i>" .. f:read() .. "</i></b><u>" .. "\n" .. f:read() .. '</u>\n' .. f:read("*all") .. "</tt>"
    f:close()
    local day = tonumber(os.date('%d'))
    someText3 = someText3:gsub("(%D)"..day.."(%D)","%1<b><u>"..day.."</u></b>%2")
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
  end

  --Calendar stuff

  updateCalendar()
  local camImage       = wibox.widget.imagebox()
  local testImage3     = wibox.widget.imagebox()
  camImage:set_image("/tmp/cam")
  testImage3:set_image("/tmp/dateInfo.map")

  --local spacer96                   = wibox.widget.textbox()
  --spacer96:set_text("\n\n")

  vicious.register(timeInfo,  testFunc, '$1',1)
  mainMenu:add_widget(weatherInfo2)
  mainMenu:add_widget(radical.widgets.header(mainMenu, "CALENDAR"     ),{height = 20 , width = 200})
  mainMenu:add_widget(calInfo)
  mainMenu:add_widget(radical.widgets.header(mainMenu, "INTERNATIONAL"),{height = 20 , width = 200})
  mainMenu:add_widget(timeInfo)
  mainMenu:add_widget(radical.widgets.header(mainMenu, "CAM"    ),{height = 20 , width = 200})
  mainMenu:add_widget(camImage)
  mainMenu:add_widget(radical.widgets.header(mainMenu, "MAP"    ),{height = 20 , width = 200})
  mainMenu:add_widget(testImage3)
  --mainMenu:add_widget(radical.widgets.header(mainMenu, "FORCAST"      ),{height = 20 , width = 200})
  return calInfo:fit(9999,9999)
end

--Widget stuff
local ib2 = nil
function dateModule.update_date_widget()
  ib2:set_image(themeutils.draw_underlay(month[tonumber(os.date('%m'))].." "..os.date('%d'),
  {
    bg=beautiful.fg_normal,
    fg=beautiful.bg_alternate,
    --       height=beautiful.default_height,
    margins=beautiful.default_height*.2,
    padding=2,
    padding_right=3
  }))
end



local function new(screen, args)
  --Location variables
  dateModule.city,dateModule.country,dateModule.mapUrl = nil,nil,nil
  --Cam variables
  local camUrl,camTimeout = nil,nil

  --Arg parsing
  if args ~= nil then
    camUrl=args.camUrl
    camTimeout=args.camTimeout or 1800
  end

  --Functions-------------------------------------------------
  --Private-------------
  local function getPosition()
    local pipe=io.popen("curl -s http://whatismycountry.com/ | awk '/<h3>/;/Location/;/Coordinates/'")
    local buffer=pipe:read("*a")
    pipe:close()

    _, _, city, country = string.find(buffer, "(%a+),(%a+)")
    _, _, latitude,longitude = string.find(buffer, "Coordinates ([0-9.]+)%s+([0-9.]+)")
    _, _, mapUrl = string.find(buffer, "src=\"(%S+)\"[^<>]+Location")

    --print(city, country,latitude,longitude,mapUrl)

    --Save map image
    if mapUrl ~= nil then
      util.spawn_with_shell("wget -q \""..mapUrl.."\" -O /tmp/dateInfo.map > /dev/null")
    end

    --Save Position
    dateModule.latitude=latitude or dateModule.latitude
    dateModule.longitude=longitude or dateModule.longitude
    dateModule.city=city or dateModule.city
    dateModule.country=country or dateModule.country

  end

  --Public--------------
  --Toggles date menu and returns visibility
  function dateModule.toggle(geo)
    if not  mainMenu then
      mainMenu = menu({arrow_type=radical.base.arrow_type.CENTERED})
      min_width = createDrawer()
      mainMenu.width = min_width + 2*mainMenu.border_width + 150
      mainMenu._internal.width = min_width
    end
    if not mainMenu.visible then
      if geo then
        mainMenu.parent_geometry = geo
      end

      mainMenu.visible = true
      return true
    else
      mainMenu.visible = false
      mainMenu=nil
      return false
    end
  end

  --Constructor---------------------------------------------
  if camUrl then
    --Download new image every camTimeout
    local timerCam = capi.timer({ timeout = camTimeout })
    timerCam:connect_signal("timeout", function() util.spawn_with_shell("wget -q "..camUrl.." -O /tmp/cam") end)
    timerCam:start()
  end

  --Check for position every 60 minutes 
  local timerPosition = capi.timer({ timeout = 3600 })
  timerPosition:connect_signal("timeout", getPosition)
  timerPosition:start()
  getPosition()

  local mytextclock = widget.textclock(" %H:%M ")

  --Date widget
  ib2 = wibox.widget.imagebox()
  local mytimer5 = capi.timer({ timeout = 1800 }) -- 30 mins
  dateModule.update_date_widget()
  mytimer5:connect_signal("timeout", dateModule.update_date_widget)
  mytimer5:start()

  local right_layout = wibox.layout.fixed.horizontal()

  right_layout:add(mytextclock)
  right_layout:add(ib2)

  right_layout:buttons (util.table.join(button({ }, 1, dateModule.toggle )))

  return right_layout
end

return setmetatable(dateModule, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
