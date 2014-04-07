local setmetatable = setmetatable
local button = require("awful.button")
local beautiful = require("beautiful")
local tag = require("awful.tag")
local config = require("forgotten")
local util = require("awful.util")
local wibox = require("wibox")
-- local shifty = require("shifty")
local tooltip2   = require( "radical.tooltip" )
local themeutils = require( "blind.common.drawing"    )
local color = require("gears.color")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

local module = {}

local data = {}

local function update()

end

local function toggleVisibility(aTag)
--     if (#aTag:clients() == 0) then
--       data[tag.getscreen(aTag)].visible = true
--     else
--       data[tag.getscreen(aTag)].visible = false
--     end
end

local function new(screen, args) 
  data[screen]         = wibox.widget.imagebox()
  data[screen]:set_image(color.apply_mask(config.iconPath .. "tags/minus2.png"))
  data[screen].visible = false
  data[screen].bg      = beautiful.bg_alternate
  tooltip2(data[screen],"Remove Tag",{})

  data[screen]:buttons( util.table.join(
    button({ }, 1, function()
        tag.delete(tag.selected(capi.mouse.screen))
    end)
  ))

--   tag.attached_connect_signal(screen, "property::selected", toggleVisibility)
--   tag.attached_connect_signal(screen, "property::layout", toggleVisibility)

  return data[screen]
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
