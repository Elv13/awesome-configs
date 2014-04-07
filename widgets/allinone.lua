local setmetatable = setmetatable
local table,math   = table,math
local pairs,ipairs = pairs,ipairs
local print        = print
local wibox        = require( "wibox"                    )
local awful        = require( "awful"                    )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo
local pango        = require( "lgi"                      ).Pango
local beautiful    = require( "beautiful"                )
local themeutils   = require( "blind.common.drawing"       )
local pangocairo = require("lgi").PangoCairo

local line_width = 2.25
local margins = 2

local outline_cache = {}
local progress_cache = {}

local function draw_outine(self,cr,wi,he)
  local hash = wi+he*1234+(self._hide_left and 1 or 2)+(self._mirror and 13.3 or 7.4)
  if not outline_cache[hash] then
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, wi, he)
    local cr2 = cairo.Context(img)
    local xoff  = self._hide_left and 0 or he/2
    local xoffi = self._hide_left and he/2 or 0

    --Mirror
    if self._mirror then
      cr2:scale(-1,1)
      cr2:translate(-wi,0)
    end

    cr2:set_source(color(beautiful.bg_allinone or beautiful.bg_highlight))
    cr2:set_line_width(line_width)
    cr2:set_antialias(cairo.ANTIALIAS_NONE)
    -- Left arc
    if self._hide_left ~= true then
      cr2:arc(xoff+margins, he/2, he/2-margins,math.pi/2,3*(math.pi/2))
      cr2:stroke()
    end

    -- Right arc
    cr2:arc(wi-he/2 -2.4, he/2, he/2-margins,3*(math.pi/2),math.pi/2)
    cr2:stroke()

    -- Top line
    cr2:move_to(xoff+2,margins)
    cr2:line_to((xoff+margins) + (wi-he-2*margins)+xoffi,margins)
    cr2:stroke()

    -- Bottom line
    cr2:move_to(xoff+margins,he-margins)
    cr2:line_to((xoff+margins) + (wi-he-2*margins)+xoffi,he-margins)
    cr2:stroke()
    outline_cache[hash] = img
  end
  cr:set_source_surface(outline_cache[hash])
  cr:paint()
end

local function draw_progres2(self,cr,percent,wi,he)
  local hash = wi+1234.5*he*percent+(self._hide_left and 1 or 2)+(self._mirror and 13.3 or 7.4)
  if not progress_cache[hash] then
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, wi, he)
    local cr2 = cairo.Context(img)
    local xoffi = self._hide_left and he/2 or 0
    local total_length = (2*(wi-he-2*margins))+2*((he/2-margins)*math.pi)
    local bar_percent = (wi-he-2*margins)/total_length
    local arc_percent = ((he/2-margins)*math.pi)/total_length

    --Mirror
    if self._mirror then
      cr2:scale(-1,1)
      cr2:translate(-wi,0)
    end

    cr2:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
    cr2:set_line_width(line_width)

    -- Bottom line
    if percent > bar_percent then
      cr2:move_to(he/2+margins,he-margins)
      cr2:line_to((he/2+margins) + (wi-he-2*margins),he-margins)
      cr2:stroke()
    elseif percent < bar_percent then
      cr2:move_to(he/2+margins,he-margins)
      cr2:line_to(he/2+margins+(total_length*percent),he-margins)
      cr2:stroke()
    end

    -- Right arc
    if percent >= bar_percent+arc_percent then
      cr2:arc(wi-he/2 -margins, he/2, he/2-margins,3*(math.pi/2),math.pi/2)
      cr2:stroke()
    elseif percent > bar_percent and percent < bar_percent+(arc_percent/2) then
      cr2:arc(wi-he/2 -margins, he/2, he/2-margins,(math.pi/2)-((math.pi/2)*((percent-bar_percent)/(arc_percent/2))),math.pi/2)
      cr2:stroke()
    elseif percent >= bar_percent+arc_percent/2 and percent < bar_percent+arc_percent then
      cr2:arc(wi-he/2 -margins, he/2, he/2-margins,0,math.pi/2)
      cr2:stroke()
      local add = (math.pi/2)*((percent-bar_percent-arc_percent/2)/(arc_percent/2))
      cr2:arc(wi-he/2 -margins, he/2, he/2-margins,2*math.pi-add,0)
      cr2:stroke()
    end

    -- Top line
    if percent > 2*bar_percent+arc_percent then
      cr2:move_to((he/2+margins) + (wi-he-2*margins),margins)
      cr2:line_to(he/2+margins,margins)
      cr2:stroke()
    elseif percent > bar_percent+arc_percent and percent < 2*bar_percent+arc_percent then
      cr2:move_to((he/2+margins) + (wi-he-2*margins),margins)
      cr2:line_to(((he/2+margins) + (wi-he-2*margins))-total_length*(percent-bar_percent-arc_percent),2)
      cr2:stroke()
    end

    -- Left arc
    if self._hide_left ~= true then
      if percent > 0.985 then
        cr2:arc(he/2+margins, he/2, he/2-margins,math.pi/2,3*(math.pi/2))
        cr2:stroke()
      elseif percent  > 2*bar_percent+arc_percent then
        local relpercent = (percent - 2*bar_percent - arc_percent)/arc_percent
        cr2:arc(he/2+margins, he/2, he/2-margins,3*(math.pi/2)-(math.pi)*relpercent,3*(math.pi/2))
        cr2:stroke()
      end
    end
    progress_cache[hash] = img
  end
  cr:set_source_surface(progress_cache[hash])
  cr:paint()
end

local function get_icon(self,height,icon)
  if self._icn then return self._icn end
  if not icon and not self._icon then return end
  if not self._icn_cache then
    local base = cairo.ImageSurface.create_from_png(icon or self._icon)
    local base_w,base_h = base:get_width(),base:get_height()
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height*(base_w/base_h), height)--themeutils.apply_color_mask
    local cr2 = cairo.Context(img)
    local aspect_h = height / base_h
    cr2:scale(aspect_h,aspect_h)
    cr2:set_source_surface(base)
    cr2:paint()
    color.apply_mask(img)
--   self._icn = img
    self._icn_cache = img
  end
  return self._icn_cache
end


local full_width = 0
local pango_l,pango_crx = nil,nil
local line_width,alpha = {1,2,3,5},{"77","55","33","10"}
local function show_text(self,cr,height,parent_width)
  if not pango_l then
    pango_crx = pangocairo.font_map_get_default():create_context()
    pango_l = pango.Layout.new(pango_crx)
    pango_l:set_font_description(beautiful.get_font(beautiful.font))
    pango_l.text = "100"
    full_width = pango_l:get_pixel_extents().width
  end
  local text = self._text and self._text or ((self.percent or 0)*(self._use_percent ~= false and 100 or 1))
  pango_l.text = text
  local width = pango_l:get_pixel_extents().width
  local icon = get_icon(self,height-4)
  local x = self._left_item and (height/2 ) or (parent_width - beautiful.default_height - full_width)/2
  if icon then
    cr:set_source_surface(icon,x,2)
    cr:paint()
  end
  local w_pos = self._left_item and (height/2 + (icon and icon:get_width())) or (x + beautiful.default_height)
  if beautiful.enable_glow then
    cr:save()
    for i=1,4 do
        cr:set_source(color((beautiful.glow_color or beautiful.fg_normal)..alpha[i]))
        cr:set_line_width(line_width[i])
        cr:move_to(w_pos,3)
        cr:layout_path(pango_l)
        cr:stroke()
    end
    cr:restore()
  end
  cr:set_source(color(beautiful.fg_normal))
  cr:move_to(w_pos,3)
  cr:show_layout(pango_l)

  cr:move_to(w_pos+full_width,3)
  pango_l.text = self._suffix

  if beautiful.enable_glow then
    for i=1,4 do
      cr:set_source(color((beautiful.glow_color or beautiful.fg_normal)..alpha[i]))
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
    cr:set_source_surface(suffix_icon,parent_width-(height/2)-height,(height-suffix_icon:get_height())/2)
    cr:paint_with_alpha(0.5)
  end
end

-- local function draw_progres(percent,cr2,he,wi) --Between 0 and 1
--   local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 200, he)--target:create_similar(target:get_content(),width,height) 
--   local cr2 = cairo.Context(img)
--   draw_outine(img,cr2)
--   draw_progres2(img,cr2,percent)
--   return img
-- end

local function draw(self,wibox, cr, width, height)
  draw_outine(self,cr,width,height)
  draw_progres2(self,cr,self.percent or 0.5,width,height)
  show_text(self,cr,height,width)
end

local function fit(self,w,h)
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

local function set_percent(self,percent,a2)
  if self._use_percent == false then
    percent = (percent or 0)*100
  end
  self.percent = percent
  self:emit_signal("widget::updated")
end

local function set_icon(self,icon)
  self._icon = icon
end

local function set_suffix(self,suffix)
  self._suffix = suffix
end

local function hide_left(self,hide)
  self._hide_left = hide
end

local function set_mirror(self,hide)
  self._mirror = hide
end

local function use_percent(self,value)
  self._use_percent = value
end

local function icon_align(self,value)
  self._left_item = value == "left"
end

local function set_text(self,value)
  self._text = value
end

local function set_suffix_icon(self,value)
--   local base = cairo.ImageSurface.create_from_png(value)
--   themeutils.apply_color_mask(base,beautiful.fg_normal)
  self._suffix_icon = value
end

local function new(args)
  local args = args or {}
  local tim = timer({})
  local ib = wibox.widget.base.empty_widget()
  ib._suffix = args.suffix or "%"
  ib.draw            = draw
  ib.fit             = fit
  ib.percent         = args.percent or 0
  ib.set_percent     = set_percent
  ib.set_value       = set_percent
  ib.set_icon        = set_icon
  ib.set_suffix      = set_suffix
  ib.hide_left       = hide_left
  ib.set_mirror      = set_mirror
  ib.use_percent     = use_percent
  ib.set_text        = set_text
  ib.icon_align      = icon_align
  ib.set_suffix_icon = set_suffix_icon
  return ib
end

-- local img = draw_progres(0)



-- tim.timeout = 0.0133
-- local counter = 1
-- tim:connect_signal("timeout",function()
--    ib:set_image(draw_progres(counter/300.0))
--    counter = counter + 1
-- end)

-- tim:start()

return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
