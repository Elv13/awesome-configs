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
local wibox = require("awful.wibox")
local shifty = require("shifty")
local menu = require("awful.menu")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("widget.spacer")

local data = {}

function update()

end

function new(args) 
  local spacer  = capi.widget({ type = "textbox", align = "left" })
  spacer.text = args.text or ""
  spacer.width = args.width or 0
  
  return spacer
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
