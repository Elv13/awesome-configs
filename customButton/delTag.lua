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

module("customButton.delTag")

local data = {}

function update()

end

local function toggleVisibility(aTag)
    if (#aTag:clients() == 0) then
      data[aTag.screen].visible = true
    else
      data[aTag.screen].visible = false
    end
end

function new(screen, args) 
  data[screen] = capi.widget({ type = "imagebox", align = "left" })
  data[screen].image = capi.image(util.getdir("config") .. "/Icon/tags/minus2.png")
  data[screen].visible = false
  
  data[screen]:buttons( util.table.join(
    button({ }, 1, function()
	shifty.del(tag.selected(capi.mouse.screen))
    end)
  ))
  
  tag.attached_add_signal(screen, "property::selected", toggleVisibility)
  tag.attached_add_signal(screen, "property::layout", toggleVisibility)
  
  data[screen]:add_signal("mouse::enter", function() data[screen].bg = beautiful.bg_highlight end)
  data[screen]:add_signal("mouse::leave", function() data[screen].bg = beautiful.bg_normal end)

  return data[screen]
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
