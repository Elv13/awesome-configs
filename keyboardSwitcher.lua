local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local loadstring = loadstring
local button = require("awful.button")
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local naughty = require("naughty")
local vicious = require("vicious")
local tag = require("awful.tag")
local print = print
local util = require("awful.util")
local shifty = require("shifty")
local menu = require("awful.menu")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("keyboardSwitcher")

local data = {}

function update()

end

local function setupKb()
  local keyboardPipe = io.open('/tmp/kbMap',"r")
  local text = keyboardPipe:read("*all")
  keyboardPipe:close()
  return text
end

function new(screen, args) 
  local keyboardSwitcher = capi.widget({ type = "imagebox"})

  if setupKb() ==  "us" then
    keyboardSwitcher.image = capi.image(util.getdir("config") .. "/Icon/us_flag.png")
  else
    keyboardSwitcher.image = capi.image(util.getdir("config") .. "/Icon/canada_flag.png")
  end

  keyboardSwitcher:buttons( util.table.join(
    button({ }, 1, function()
	if setupKb() ==  "us" then
	  keyboardSwitcher.text = "ca"
	  local aFile = io.open('/tmp/kbMap',"w")
	  aFile:write("ca")
	  aFile:close() 
	  util.spawn("setxkbmap ca") 
	  keyboardSwitcher.image = capi.image(util.getdir("config") .. "/Icon/canada_flag.png")
	else
	  keyboardSwitcher.text = "us"
	  local aFile = io.open('/tmp/kbMap',"w")
	  aFile:write("us")
	  aFile:close() 
	  util.spawn("setxkbmap us")
	  keyboardSwitcher.image = capi.image(util.getdir("config") .. "/Icon/us_flag.png")
	end
    end)
  ))
  return keyboardSwitcher
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
