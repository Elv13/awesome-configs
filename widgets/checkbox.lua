local setmetatable = setmetatable
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

local capi = { image  = image  ,
               widget = widget }

module("widgets.checkbox")

local checkedI
local notcheckedI
local isinit      = false

function new(screen, args) 
  local desktopPix       = capi.widget({ type = "imagebox", align = "left" })
  desktopPix.image = capi.image(util.getdir("config") .. "/theme/darkBlue/Icon/tags/desk2.png")
  desktopPix:buttons( util.table.join( button({ }, 1, function() tag.viewnone() end) ))
  desktopPix:add_signal("mouse::enter", function() desktopPix.bg = beautiful.bg_highlight end)
  desktopPix:add_signal("mouse::leave", function() desktopPix.bg = beautiful.bg_normal    end)
  return desktopPix
end

local function init()
    local size = beautiful.menu_height or 16
    checkedI    = capi.image.argb32(size, size, nil)
    notcheckedI = capi.image.argb32(size, size, nil)
    local sp = 3
    local rs = size - (2*sp)
    checkedI:draw_line    ( sp , sp , rs , sp , beautiful.fg_normal )
    checkedI:draw_line    ( sp , sp , sp , rs , beautiful.fg_normal )
    checkedI:draw_line    ( sp , rs , rs , rs , beautiful.fg_normal )
    checkedI:draw_line    ( rs , sp , rs , rs , beautiful.fg_normal )
    checkedI:draw_line    ( sp , sp , rs , rs , beautiful.fg_normal )
    checkedI:draw_line    ( sp , rs , rs , sp , beautiful.fg_normal )
    
    notcheckedI:draw_line ( sp , sp , rs , sp , beautiful.fg_normal )
    notcheckedI:draw_line ( sp , sp , sp , rs , beautiful.fg_normal )
    notcheckedI:draw_line ( sp , rs , rs , rs , beautiful.fg_normal )
    notcheckedI:draw_line ( rs , sp , sp , rs , beautiful.fg_normal )
    
    isinit = true
end

function checked()
    if not isinit then
        init()
    end
    return checkedI
end

function unchecked()
    if not isinit then
        init()
    end
    return notcheckedI
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })