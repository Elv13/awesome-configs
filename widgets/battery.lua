local print = print
local io,math = io,math
local tostring,tonumber = tostring,tonumber
local color     = require( "gears.color"              )
local cairo     = require( "lgi"                      ).cairo
local pango      = require("lgi").Pango
local pangocairo = require("lgi").PangoCairo
local gio       = require( "lgi"                      ).Gio
local wibox     = require( "wibox"                    )
local beautiful = require( "beautiful"                )
local shape     = require( "gears.shape"              )

local capi = {timer=timer}

local full_energy,bat_name,current_status = 0,"",""

local text_fit = nil

local function set_value(self,value)
  self._value = value
  self:emit_signal("widget::updated")
end

local pl = nil

local function init_pl(height)
    if not pl and height > 0 then
        local pango_crx = pangocairo.font_map_get_default():create_context()
        pl = pango.Layout.new(pango_crx)
        local desc = pango.FontDescription()
        desc:set_family("Verdana")
        desc:set_weight(pango.Weight.ULTRABOLD)
        desc:set_absolute_size((height) * pango.SCALE)
        pl:set_font_description(desc)
    end
end

local function fit(self,context,width,height)
    if not text_fit then
        init_pl(height)

        if pl then
            pl.text = " 100%"
            text_fit = pl:get_pixel_extents().width
        end
    end

    return (width > (height * 2) and (height * 2) or width) + (text_fit or 0),height
end

local function draw_battery(self,context,cr,width,height)
    cr:set_source(color(self._color or beautiful.fg_normal))
    cr:set_antialias(0)
    local width = width - (text_fit or 0)

    local ratio = height / 7
    -- The outline
    cr:set_line_width(ratio)
    cr:rectangle(0,0,width-1.5*ratio,height)
    cr:stroke()

    -- The battery positive pole
    cr:rectangle(width-1.5*ratio, height/4, 1.5*ratio ,height/2)

    -- The content
    cr:rectangle(ratio,ratio,(width-3*ratio)*(self._value or 0),height-2*ratio)
    cr:fill()
end

local function draw_plug(self,context,cr,width,height)

    cr:set_source(color(self._color or beautiful.fg_normal))

    cr:arc(height/2, height/2, height/3 , 0, 2*math.pi)

    cr:rectangle(height/2,height/6,5,2*(height/3))

    cr:rectangle(0, height/2 -1, height/6, 2)

    cr:rectangle(height/2+5, height/4, 3, 2)
    cr:rectangle(height/2+5, height/2, 3, 2)

    cr:fill()
end

local function draw(self,w,cr,width,height)

    cr:save()

    if current_status == "Discharging\n" then
        draw_battery(self,w,cr,width,height)
    else
        draw_plug(self,w,cr,width,height)
    end
    self._tooltip.text = ((self._value or 0)*100)..'%'
    if pl then
        pl.text =  " "..((self._value or 0)*100)..'%'

        cr:translate(width-text_fit,0)
        cr:show_layout(pl)
    end

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
    bat_name = args.name or "BAT0"
    local ib = wibox.widget.base.empty_widget()

    if check_present(bat_name) then

        -- Check try to load the full energy value
        gio.File.new_for_path('/sys/class/power_supply/'..(bat_name)..'/energy_full'):load_contents_async(nil,function(file,task,c)
            local content = file:load_contents_finish(task)
            if content then
                full_energy = tonumber(tostring(content))
            end
        end)

        ib._color = args.fg or args.color
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
