local setmetatable = setmetatable
local io = io
local button    = require( "awful.button"    )
local beautiful = require( "beautiful"       )
local util      = require( "awful.util"      )
local config    = require( "forgotten"          )
local tooltip2   = require( "radical.tooltip" )
local wibox     = require( "wibox"           )
local themeutils = require( "blind.common.drawing"    )
local color = require("gears.color")

local module={}

local data = {}

local function update()

end

local function setupKb()
  --local keyboardPipe = io.open('/tmp/kbMap',"r") --This is not reliable
  --local text = keyboardPipe:read("*all")
  --keyboardPipe:close()
  return "us"--text
end

local function new(screen, args) 
  local keyboardSwitcher = wibox.widget.imagebox()
  local tt = tooltip2(keyboardSwitcher,"Change keyboard layout",{down=true})

  keyboardSwitcher:connect_signal("mouse::enter", function()keyboardSwitcher.bg = beautiful.bg_highlight end)
  keyboardSwitcher:connect_signal("mouse::leave", function()keyboardSwitcher.bg = beautiful.bg_normal end)

  if setupKb() ==  "us" then
    keyboardSwitcher:set_image(color.apply_mask(config.iconPath .. "us_flag.png"))
  else
    keyboardSwitcher:set_image(color.apply_mask(config.iconPath .. "canada_flag.png"))
  end

  keyboardSwitcher:buttons( util.table.join(
    button({ }, 1, function()
	if setupKb() ==  "us" then
	  keyboardSwitcher.text = "ca"
	  local aFile = io.open('/tmp/kbMap',"w")
	  aFile:write("ca")
	  aFile:close() 
	  util.spawn("setxkbmap ca")
	  keyboardSwitcher:set_image(config.iconPath .. "canada_flag.png")
	else
	  keyboardSwitcher.text = "us"
	  local aFile = io.open('/tmp/kbMap',"w")
	  aFile:write("us")
	  aFile:close()
	  util.spawn("setxkbmap us")
	  keyboardSwitcher:set_image(config.iconPath .. "us_flag.png")
	end
    end)
  ))
  return keyboardSwitcher
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
