local setmetatable = setmetatable
local table,math   = table,math
local wibox        = require( "wibox"       )
local color        = require( "gears.color" )
local cairo        = require( "lgi"         ).cairo
local pango        = require( "lgi"         ).Pango
local beautiful    = require( "beautiful"   )
local pangocairo   = require( "lgi"         ).PangoCairo
local util         = require( "awful.util"  )

local line_width = 2.25
local fallback_margins = 2

local module = {}

local function get_icon(self,height,icon)
  if self._icn then return self._icn end
  if not icon and not self._icon then return end

  if not self._icn_cache then
    local base = cairo.ImageSurface.create_from_png(icon or self._icon)
    local base_w,base_h = base:get_width(),base:get_height()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height*(base_w/base_h), height)
    local cr2 = cairo.Context(img)
    local aspect_h = height / base_h
    cr2:scale(aspect_h,aspect_h)
    cr2:set_source_surface(base)
    cr2:paint()
    color.apply_mask(img,beautiful.allinone_icon)
    self._icn_cache = img
  end

  return self._icn_cache
end


local full_width = 0
local pango_l,pango_crx = nil,nil
local line_width,alpha = {1,2,3,5},{"77","55","33","10"}

function module:draw(context, cr, width, height)
  local margins = beautiful.allinone_margins or fallback_margins
  if not pango_l then
    pango_crx = pangocairo.font_map_get_default():create_context()
    pango_l = pango.Layout.new(pango_crx)
    pango_l:set_font_description(beautiful.get_font(beautiful.font))
    pango_l.text = "100"
    full_width = pango_l:get_pixel_extents().width
  end
  pango_l.text = self._text and self._text or ((self.percent or 0)*(self._use_percent ~= false and 100 or 1))

  local icon = get_icon(self,height-2*margins)
  local x = self._left_item and (height/2 ) or (width - beautiful.default_height - full_width)/2
  if icon then
    cr:set_source_surface(icon,x,margins)
    cr:paint()
  end
  local w_pos = self._left_item and (height/2 + (icon and icon:get_width())) or (x + beautiful.default_height)
  if beautiful.enable_glow then
    cr:save()
    for i=1,4 do
        local col = (beautiful.glow_color or beautiful.fg_normal)
        cr:set_source(color(col:len() == 7 and col..alpha[i] or col))
        cr:set_line_width(line_width[i])
        cr:move_to(w_pos,margins)
        cr:layout_path(pango_l)
        cr:stroke()
    end
    cr:restore()
  end
  cr:set_source(color(beautiful.fg_normal))
  cr:move_to(w_pos,margins)
  cr:show_layout(pango_l)

  cr:move_to(w_pos+full_width,margins)
  pango_l.text = self._suffix

  if beautiful.enable_glow then
    for i=1,4 do
      local col = (beautiful.glow_color or beautiful.fg_normal)
      cr:set_source(color(col:len() == 7 and col..alpha[i] or col))
      pango_l.text = self._suffix
      cr:show_layout(pango_l)
    end
  end
  cr:set_source(color(beautiful.fg_normal.."7f"))
  cr:show_layout(pango_l)

  -- Display suffix image, if any
  if self._suffix_icon then
    cr:set_antialias(cairo.ANTIALIAS_NONE)
    local suffix_icon = get_icon(self,height*0.6,self._suffix_icon)
    cr:set_source_surface(suffix_icon,width-(height/2)-height,(height-suffix_icon:get_height())/2)
    cr:paint_with_alpha(0.5)
  end
end

function module:fit(context,w,h)
  if not pango_l then
    pango_crx = pangocairo.font_map_get_default():create_context()
    pango_l = pango.Layout.new(pango_crx)
    pango_l:set_font_description(beautiful.get_font(beautiful.font))
    pango_l.text = "100"..self._suffix
    full_width = pango_l:get_pixel_extents().width
  end
  if pango_l then
    return full_width + 3*h + beautiful.default_height/2 , h
  else
    return self.width or beautiful.default_height*5,h
  end
end

function module:set_percent(percent)
  if self._use_percent == false then
    percent = (percent or 0)*100
  end
  self.percent = percent
  self:emit_signal("widget::updated")
end

module.set_value = module.set_percent

function module:set_icon(icon)
  self._icon = icon
end

function module:set_suffix(suffix)
  self._suffix = suffix
end

function module:hide_left(hide)
  self._hide_left = hide
end

function module:set_mirror(hide)
  self._mirror = hide
end

function module:use_percent(value)
  self._use_percent = value
end

function module:icon_align(value)
  self._left_item = value == "left"
end

function module:set_text(value)
  self._text = value
end

function module:set_suffix_icon(value)
  self._suffix_icon = value
end

local function new(args)
  local args = args or {}
  local tim = timer({})
  local ib = wibox.widget.base.empty_widget()
  ib._suffix = args.suffix or "%"

  util.table.crush(ib, module)

  return ib
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
