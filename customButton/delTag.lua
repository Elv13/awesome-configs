local setmetatable = setmetatable
local button = require("awful.button")
local beautiful = require("beautiful")
local tag = require("awful.tag")
local config = require("config")
local util = require("awful.util")
local wibox = require("wibox")
-- local shifty = require("shifty")
local tooltip2   = require( "widgets.tooltip2" )
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
--     if (#aTag:clients() == 0) then
--       data[tag.getscreen(aTag)].visible = true
--     else
--       data[tag.getscreen(aTag)].visible = false
--     end
end

function new(screen, args) 
  data[screen]         = wibox.widget.imagebox()
  data[screen]:set_image(config.data().iconPath .. "tags/minus2.png")
  data[screen].visible = false
  data[screen].bg      = beautiful.bg_alternate
  tooltip2(data[screen],"Remove Tag",{})
  
  data[screen]:buttons( util.table.join(
    button({ }, 1, function()
	tag.delete(tag.selected(capi.mouse.screen))
    end)
  ))
  
  tag.attached_connect_signal(screen, "property::selected", toggleVisibility)
  tag.attached_connect_signal(screen, "property::layout", toggleVisibility)
  
--   data[screen]:connect_signal("mouse::enter", function() tt:showToolTip(true) ;data[screen].bg = beautiful.bg_normal    end)
--   data[screen]:connect_signal("mouse::leave", function() tt:showToolTip(false);data[screen].bg = beautiful.bg_alternate end)

  return data[screen]
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
