local setmetatable = setmetatable
local button       = require( "awful.button"    )
local beautiful    = require( "beautiful"       )
local naughty      = require( "naughty"         )
local tag          = require( "awful.tag"       )
local util         = require( "awful.util"      )
local tooltip      = require( "widgets.tooltip" )
local config       = require( "forgotten"          )
local themeutils = require( "blind.common.drawing"    )
local wibox        = require( "wibox"           )

local capi = { image  = image  ,
               widget = widget }

local module = {}


local function new(screen, args) 
  local desktopPix       = wibox.widget.imagebox()
  local tt = tooltip("Show Desktop",{down = true})
  desktopPix:set_image(themeutils.apply_color_mask(config.iconPath .. "tags/desk2.png"))
  desktopPix:buttons( util.table.join( button({ }, 1, function() tag.viewnone() end) ))
  desktopPix:connect_signal("mouse::enter", function() tt:showToolTip(true) ;desktopPix.bg = beautiful.bg_highlight end)
  desktopPix:connect_signal("mouse::leave", function() tt:showToolTip(false);desktopPix.bg = beautiful.bg_normal    end)
  return desktopPix
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })