local setmetatable = setmetatable
local button       = require( "awful.button"    )
local beautiful    = require( "beautiful"       )
local naughty      = require( "naughty"         )
local tag          = require( "awful.tag"       )
local util         = require( "awful.util"      )
local tooltip2      = require( "radical.tooltip" )
local menu         = require( "widgets.menu"    )

local capi = { image  = image  ,
               widget = widget }

module("customMenu.logout")

local function create_menu()
    local m = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, autodiscard = true,has_decoration=false})
    
    return m
end

local function new(screen, args) 
  local desktopPix       = capi.widget({ type = "imagebox", align = "left" })
  local tt,m = tooltip(desktopPix,"Logout",{down = false}),nil
  desktopPix.image = capi.image(util.getdir("config") .. "/theme/darkBlue/Icon/logout.png")
  desktopPix:buttons( util.table.join( button({ }, 1, function() tag.viewnone() end) ))
  desktopPix:add_signal("mouse::enter", function() tt:showToolTip(true) ;desktopPix.bg = beautiful.bg_highlight end)
  desktopPix:add_signal("mouse::leave", function() tt:showToolTip(false);desktopPix.bg = beautiful.bg_normal    end)
  return desktopPix
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })