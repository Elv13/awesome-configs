local print = print
local io,math = io,math
local tostring,tonumber = tostring,tonumber
local color     = require( "gears.color"              )
local cairo     = require( "lgi"                      ).cairo
local gio       = require( "lgi"                      ).Gio
local wibox     = require( "wibox"                    )
local beautiful = require( "beautiful"                )

local capi = {timer=timer}

local battery_state = {
  ["Full\n"]        = "↯", ["Unknown\n"]     = "?",
  ["Charged\n"]     = "↯", ["Charging\n"]    = "⌁",
  ["Discharging\n"] = ""
}

local full_energy,bat_name,current_status = 0,"",""

local function set_value(self,value)
  self._value = value
  self:emit_signal("widget::updated")
end

local function fit(self,width,height)
  return width > (height * 1.5) and (height * 1.5) or width,height
end

local function draw(self,w,cr,width,height)
  cr:save()
  cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
  cr:paint()
  local ratio = height / 10
  cr:set_source(color(beautiful.bg_alternate or beautiful.bg_normal))
  cr:rectangle(ratio,2*ratio,width-4*ratio,height-4*ratio)
  cr:stroke()
  cr:rectangle(width-3*ratio,height/3,1.5*ratio,height/3)
  cr:fill()
  cr:rectangle(2*ratio,3*ratio,(width-6*ratio)*(self._value or 0),height-6*ratio)
  cr:fill()
  self._tooltip.text = ((self._value or 0)*100)..'%'
  cr:set_source_rgba(1,0,0,1)
  cr:set_font_size(30)
  local extents = cr:text_extents(battery_state[current_status])
  cr:move_to(ratio+(width-4*ratio)/2-extents.width/2,height/2+extents.height)
  cr:show_text(battery_state[current_status])
  cr:restore()
end

local function check_present(name)
  local f = io.open('/sys/class/power_supply/'..name..'/present','r')
  if f then f:close() end
  return f ~= nil
end

local function timeout(wdg)
  gio.File.new_for_path('/sys/class/power_supply/'..(bat_name)..'/energy_now'):load_contents_async(nil,function(file,task,c)
      local content = file:load_contents_finish(task)
      if content then
        local now = tonumber(tostring(content))
        local percent = now/full_energy
        percent = math.floor(percent* 100)/100
        wdg:set_value(percent)
      end
  end)
  gio.File.new_for_path('/sys/class/power_supply/'..(bat_name)..'/status'):load_contents_async(nil,function(file,task,c)
      local content = file:load_contents_finish(task)
      if content then
        local str = tostring(content)
        if current_status ~= str then
          current_status = str
          wdg:emit_signal("widget::updated")
        end
      end
  end)
end

local function new(args)
  local args = args or {}
  local ib = wibox.widget.base.empty_widget()
  bat_name = args.name or "BAT0"
  if check_present(bat_name) then

    -- Check try to load the full energy value
    gio.File.new_for_path('/sys/class/power_supply/'..(bat_name)..'/energy_full'):load_contents_async(nil,function(file,task,c)
        local content = file:load_contents_finish(task)
        if content then
            full_energy = tonumber(tostring(content))
        end
    end)

    ib.set_value = set_value
    ib.fit=fit
    ib.draw = draw
    ib:set_tooltip("100%")
    local t = capi.timer({timeout=15})
    t:connect_signal("timeout",function() timeout(ib) end)
    t:start()
    timeout(ib)
  end
  return ib
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
