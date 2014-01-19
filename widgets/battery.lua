local print = print
local io = io
local vicious = require("extern.vicious")
local color   = require( "gears.color"              )
local cairo   = require( "lgi"                      ).cairo
local wibox   = require( "wibox"                    )
local beautiful = require("beautiful")

local function set_value(self,value)
  print(value)
  self._value = value
  self:emit_signal("widget::updated")
end

local function fit(self,width,height)
  return height * 1.5,height
end

local function draw(self,w,cr,width,height)
  cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
  cr:paint()
  local ratio = height / 10
  cr:set_source(color(beautiful.bg_alternate or beautiful.bg_normal))
  cr:rectangle(ratio,2*ratio,width-3*ratio,height-4*ratio)
  cr:stroke()
  cr:rectangle(width-2*ratio,height/3,ratio,height/3)
  cr:fill()
  cr:rectangle(2*ratio,3*ratio,(width-5*ratio)*self._value,height-6*ratio)
  cr:fill()
  self._tooltip.text = (self._value*100)..'%'
end

local function check_present(name)
  local f = io.open('/sys/class/power_supply/'..name..'/present','r')
  if f then f:close() end
  return f ~= nil
end

local function new(args)
  local args = args or {}
  local ib = wibox.widget.base.empty_widget()
  if check_present(args.name or "BAT0") then
    ib.set_value = set_value
    ib.fit=fit
    ib.draw = draw
    vicious.register(ib, vicious.widgets.bat, '$2', 1, 'BAT0')
    ib:set_tooltip("100%")
  end
  return ib
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
