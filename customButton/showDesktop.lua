local setmetatable = setmetatable
local button       = require( "awful.button"    )
local beautiful    = require( "beautiful"       )
local naughty      = require( "naughty"         )
local tag          = require( "awful.tag"       )
local util         = require( "awful.util"      )
local tooltip2      = require( "radical.tooltip" )
local config       = require( "forgotten"          )
local themeutils = require( "blind.common.drawing"    )
local wibox        = require( "wibox"           )
local color = require("gears.color")

local capi = { image  = image  ,
               widget = widget }

local module = {}


local function new(screen, args) 
  local desktopPix       = wibox.widget.imagebox()
  tooltip2(desktopPix,"Show Desktop",{down=true})
  desktopPix:set_image(color.apply_mask(config.iconPath .. "tags/desk2.png"))
  desktopPix:buttons( util.table.join( button({ }, 1, function() tag.viewnone() end) ))
  return desktopPix
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })