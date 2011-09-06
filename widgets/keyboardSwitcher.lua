local setmetatable = setmetatable
local io = io
local button = require("awful.button")
local beautiful = require("beautiful")
local util = require("awful.util")
local config = require("config")
local capi = { image = image,
               widget = widget }

module("widgets.keyboardSwitcher")

local data = {}

function update()

end

local function setupKb()
  --local keyboardPipe = io.open('/tmp/kbMap',"r") --This is not reliable
  --local text = keyboardPipe:read("*all")
  --keyboardPipe:close()
  return "us"--text
end

function new(screen, args) 
  local keyboardSwitcher = capi.widget({ type = "imagebox"})
  
  keyboardSwitcher:add_signal("mouse::enter", function() keyboardSwitcher.bg = beautiful.bg_highlight end)
  keyboardSwitcher:add_signal("mouse::leave", function() keyboardSwitcher.bg = beautiful.bg_normal end)

  if setupKb() ==  "us" then
    keyboardSwitcher.image = capi.image(config.data.iconPath .. "us_flag.png")
  else
    keyboardSwitcher.image = capi.image(config.data.iconPath .. "canada_flag.png")
  end

  keyboardSwitcher:buttons( util.table.join(
    button({ }, 1, function()
	if setupKb() ==  "us" then
	  keyboardSwitcher.text = "ca"
	  local aFile = io.open('/tmp/kbMap',"w")
	  aFile:write("ca")
	  aFile:close() 
	  util.spawn("setxkbmap ca") 
	  keyboardSwitcher.image = capi.image(config.data.iconPath .. "canada_flag.png")
	else
	  keyboardSwitcher.text = "us"
	  local aFile = io.open('/tmp/kbMap',"w")
	  aFile:write("us")
	  aFile:close() 
	  util.spawn("setxkbmap us")
	  keyboardSwitcher.image = capi.image(config.data.iconPath .. "us_flag.png")
	end
    end)
  ))
  return keyboardSwitcher
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
