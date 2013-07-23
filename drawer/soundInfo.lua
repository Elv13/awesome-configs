local setmetatable = setmetatable
local tonumber = tonumber
local table = table
local io = io
local type = type
local print = print
local button = require("awful.button")
local vicious = require("extern.vicious")
local wibox = require("wibox")
local widget2 = require("awful.widget")
local config = require("forgotten")
local beautiful = require("beautiful")
local util = require("awful.util")
local themeutils = require( "blind.common.drawing"    )
local radical      = require( "radical"                  )
local capi = { screen = screen, mouse = mouse}

local module = {}

local mainMenu = nil

function amixer_volume_int(format)
   local f = io.popen('amixer sget Master | tail -n1 |cut -f 6 -d " " | grep -o -e "[0-9]*"')
   local l = f:read()
   f:close()
   local toReturn
   if l == "" then
    toReturn = 0
   else
    toReturn = tonumber(l)
   end
   return {toReturn}
end

function soundInfo()
  local f = io.popen('amixer | grep "Simple mixer control" | cut -f 2 -d "\'" | sort -u')

  local soundHeader = wibox.widget.textbox()
  soundHeader:set_markup(" <span color='".. beautiful.bg_normal .."'><b><tt>CHANALS</tt></b></span> ")

  local counter = 0
  while true do
    local aChannal = f:read("*line")
    if aChannal == nil then break end

    local f2= io.popen('amixer sget '.. aChannal ..' | tail -n1 |cut -f 6 -d " " | grep -o -e "[0-9]*" 2> /dev/null')
    local aVolume = (tonumber(f2:read("*line")) or 0) / 100
    f2:close()

    local mute = wibox.widget.imagebox()
    mute:set_image(config.iconPath .. "volm.png")

    local plus = wibox.widget.imagebox()
    plus:set_image(config.iconPath .. "tags/cross2.png")

    local volume = widget2.progressbar()
    volume:set_width(40)
    volume:set_height(20)
    volume:set_background_color(beautiful.bg_normal)
    volume:set_border_color(beautiful.fg_normal)
    volume:set_color(beautiful.fg_normal)
    volume:set_value(aVolume or 0)
    if (widget2.progressbar.set_offset ~= nil) then
      volume:set_offset(1)
    end

    local minus = wibox.widget.imagebox()
    minus:set_image(config.iconPath .. "tags/minus2.png")
    counter = counter +1
    local l2 = wibox.layout.fixed.horizontal()
    l2:add(plus)
    l2:add(volume)
    l2:add(minus)
    mainMenu:add_item({text=aChannal,prefix_widget=mute,suffix_widget=l2})
  end
  f:close()
end

local function new(mywibox3,left_margin)
  local volumewidget = wibox.widget.textbox()
  local volumepixmap =  wibox.widget.imagebox()
  volumepixmap:set_image(themeutils.apply_color_mask(config.iconPath .. "vol.png"))


  local top,bottom

  local btn = util.table.join(
     button({ }, 1, function(geo)
        if not mainMenu then
            mainMenu = radical.context({width=200,arrow_type=radical.base.arrow_type.CENTERED})
            soundInfo()
        end
        mainMenu.visible = not mainMenu.visible
        mainMenu.parent_geometry = geo

        if mywibox3 and type(mywibox3) == "wibox" then
            mywibox3.visible = not mywibox3.visible
        end
        musicBarVisibility = true
      end),
      button({ }, 4, function()
          util.spawn("amixer -c0 sset Master 2dB+ >/dev/null") 
      end),
      button({ }, 5, function()
          util.spawn("amixer -c0 sset Master 2dB- >/dev/null") 
      end)
  )

  vicious.register(volumewidget, amixer_volume_int, '$1%')
  local l = wibox.layout.fixed.horizontal()
  l:add(volumepixmap)
  l:add(volumewidget)
  l:buttons(btn)
  return l
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
