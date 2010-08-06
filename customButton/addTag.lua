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

module("customButton.addTag")

local data = {}

function update()

end

function new(screen, args) 
  local addTag = capi.widget({ type = "imagebox", align = "left" })
  addTag.image = capi.image(util.getdir("config") .. "/Icon/tags/cross2.png")
  
  addTag:buttons( util.table.join(
    button({ }, 1, function()
      shifty.add({name = "NewTag"})
      delTag[capi.mouse.screen].visible = true
  end)
  ))
  
  return addTag
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
