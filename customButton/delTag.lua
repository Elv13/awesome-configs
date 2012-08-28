local setmetatable = setmetatable
local button = require("awful.button")
local beautiful = require("beautiful")
local tag = require("awful.tag")
local config = require("config")
local util = require("awful.util")
local shifty = require("shifty")
local tooltip   = require( "widgets.tooltip" )
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
  data[screen].image = capi.image(config.data().iconPath .. "tags/minus2.png")
  data[screen].visible = false
  local tt = tooltip("Remove Tag",{})
  
  data[screen]:buttons( util.table.join(
    button({ }, 1, function()
	shifty.del(tag.selected(capi.mouse.screen))
    end)
  ))
  
  tag.attached_add_signal(screen, "property::selected", toggleVisibility)
  tag.attached_add_signal(screen, "property::layout", toggleVisibility)
  
  data[screen]:add_signal("mouse::enter", function() tt:showToolTip(true) ;data[screen].bg = beautiful.bg_highlight end)
  data[screen]:add_signal("mouse::leave", function() tt:showToolTip(false);data[screen].bg = beautiful.bg_normal end)

  return data[screen]
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
