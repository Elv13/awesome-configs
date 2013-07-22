local setmetatable = setmetatable
local print = print
local color = require("gears.color")
local cairo     = require( "lgi"              ).cairo
local wibox = require("wibox")

local beautiful    = require( "beautiful"    )

local module = {}

local function new(data,text)
  local bg = wibox.widget.background()
  local infoHeader     = wibox.widget.textbox()
  infoHeader:set_font("")
  infoHeader:set_markup( " <span color='".. beautiful.bg_normal .."'><b><tt>".. text .."</tt></b></span> " )
  local l = wibox.layout.fixed.horizontal()
  l:add(infoHeader)
  bg:set_widget(l)
  bg:set_bg(beautiful.fg_normal)
  return bg
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
