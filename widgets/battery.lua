local setmetatable = setmetatable
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local naughty = require("naughty")
local tag = require("awful.tag")
local util = require("awful.util")
local capi = { image = image,
               widget = widget}

local module={}

local data = {}

local function update()

end

local function new(screen, args) 
  local desktopPix       = capi.widget({ type = "imagebox", align = "left" })
  desktopPix.image = capi.image(beautiful.path.."Icon/tags/desk2.png")
  
  desktopPix:buttons( util.table.join(
    button({ }, 1, function()
      tag.viewnone()
    end)
  ))
  
  desktopPix:add_signal("mouse::enter", function() desktopPix.bg = beautiful.bg_highlight end)
  desktopPix:add_signal("mouse::leave", function() desktopPix.bg = beautiful.bg_normal end)
  
  return desktopPix
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
