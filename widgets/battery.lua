local setmetatable = setmetatable
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local naughty = require("naughty")
local tag = require("awful.tag")
local util = require("awful.util")
local capi = { image = image,
               widget = widget}

module("widgets.battery")

local data = {}

function update()

end

function new(screen, args) 
  local desktopPix       = capi.widget({ type = "imagebox", align = "left" })
  desktopPix.image = capi.image(util.getdir("config") .. "/theme/darkBlue/Icon/tags/desk2.png")
  
  desktopPix:buttons( util.table.join(
    button({ }, 1, function()
      tag.viewnone()
    end)
  ))
  
  desktopPix:add_signal("mouse::enter", function() desktopPix.bg = beautiful.bg_highlight end)
  desktopPix:add_signal("mouse::leave", function() desktopPix.bg = beautiful.bg_normal end)
  
  return desktopPix
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
