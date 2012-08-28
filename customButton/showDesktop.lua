local setmetatable = setmetatable
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )
local tooltip   = require( "widgets.tooltip" )

local capi = { image  = image  ,
               widget = widget }

module("customButton.showDesktop")

function new(screen, args) 
  local desktopPix       = capi.widget({ type = "imagebox", align = "left" })
  local tt = tooltip("Show Desktop",{down = true})
  desktopPix.image = capi.image(util.getdir("config") .. "/theme/darkBlue/Icon/tags/desk2.png")
  desktopPix:buttons( util.table.join( button({ }, 1, function() tag.viewnone() end) ))
  desktopPix:add_signal("mouse::enter", function() tt:showToolTip(true) ;desktopPix.bg = beautiful.bg_highlight end)
  desktopPix:add_signal("mouse::leave", function() tt:showToolTip(false);desktopPix.bg = beautiful.bg_normal    end)
  return desktopPix
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })