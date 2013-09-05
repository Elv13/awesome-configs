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

local function draw_outine(cr2,wi,he)
  cr2:set_source(color(beautiful.bg_allinone or beautiful.bg_highlight))
  cr2:set_line_width(line_width)
  cr2:set_antialias(cairo.ANTIALIAS_NONE)
  -- Left arc
  cr2:arc(he/2+margins, he/2, he/2-margins,math.pi/2,3*(math.pi/2))
  cr2:stroke()

  -- Right arc
  cr2:arc(wi-he/2 -2.4, he/2, he/2-margins,3*(math.pi/2),math.pi/2)
  cr2:stroke()

  -- Top line
  cr2:move_to(he/2+2,margins)
  cr2:line_to((he/2+margins) + (wi-he-2*margins),margins)
  cr2:stroke()

  -- Bottom line
  cr2:move_to(he/2+margins,he-margins)
  cr2:line_to((he/2+margins) + (wi-he-2*margins),he-margins)
  cr2:stroke()
end

local function draw_progres2(cr2,percent,wi,he)
  local total_length = (2*(wi-he-2*margins))+2*((he/2-margins)*math.pi)
  local bar_percent = (wi-he-2*margins)/total_length
  local arc_percent = ((he/2-margins)*math.pi)/total_length

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
  if percent > 0.985 then
    cr2:arc(he/2+margins, he/2, he/2-margins,math.pi/2,3*(math.pi/2))
    cr2:stroke()
--     tim:stop()
  elseif percent  > 2*bar_percent+arc_percent then
    local relpercent = (percent - 2*bar_percent - arc_percent)/arc_percent
    cr2:arc(he/2+margins, he/2, he/2-margins,3*(math.pi/2)-(math.pi)*relpercent,3*(math.pi/2))
    cr2:stroke()
  end
end

local function get_icon(self,height)
  if not self._icon then return end
  local base = cairo.ImageSurface.create_from_png(self._icon)
  local base_w,base_h = base:get_width(),base:get_height()
  local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height, height)--themeutils.apply_color_mask
  local cr2 = cairo.Context(img)
  local aspect_h = height / base_h
  cr2:scale(aspect_h,aspect_h)
  cr2:set_source_surface(base)
  cr2:paint()
  themeutils.apply_color_mask(img)
  return img
end

local pango_l,pango_crx = nil,nil
local line_width,alpha = {1,2,3,5},{"77","55","33","10"}
local function show_text(self,cr,height)
  if not pango_l then
    pango_crx = pangocairo.font_map_get_default():create_context()
    pango_l = pango.Layout.new(pango_crx)
    pango_l:set_font_description(pango.font_description_from_string(beautiful.font))
  end
  pango_l.text = (self.percent*100).."%"
  local width = pango_l:get_pixel_extents().width
  local icon = get_icon(self,height-4)
  if icon then
    cr:set_source_surface(icon,(self.width or 80)/2 - width/2 - height/2,2)
    cr:paint()
  end
  if beautiful.enable_glow then
    cr:save()
    for i=1,4 do
        cr:move_to(x, y)
        cr:set_source(color((beautiful.glow_color or beautiful.fg_normal)..alpha[i]))
        cr:set_line_width(line_width[i])
        cr:move_to((self.width or 80)/2 - width/2 + (icon and height/2 or 0),3)
        cr:layout_path(pango_l)
        cr:stroke()
    end
    cr:restore()
  end
  cr:set_source(color(beautiful.fg_normal))
  cr:move_to((self.width or 80)/2 - width/2 + (icon and height/2 or 0),3)
  cr:show_layout(pango_l)
end

-- local function draw_progres(percent,cr2,he,wi) --Between 0 and 1
--   local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 200, he)--target:create_similar(target:get_content(),width,height) 
--   local cr2 = cairo.Context(img)
--   draw_outine(img,cr2)
--   draw_progres2(img,cr2,percent)
--   return img
-- end

local function draw(self,wibox, cr, width, height)
  draw_outine(cr,width,height)
  draw_progres2(cr,self.percent or 0.5,width,height)
  show_text(self,cr,height)
end

local function fit(self,w,h)
    return self.width or 80,h
end

local function set_percent(self,percent,a2)
  self.percent = percent
end

local function set_icon(self,icon)
  self._icon = icon
end

local function new(args)
  local args = args or {}
  local tim = timer({})
  local ib = wibox.widget.base.empty_widget()
  ib.draw= draw
  ib.fit = fit
  ib.percent = args.percent or 0
  ib.set_percent = set_percent
  ib.set_value = set_percent
  ib.set_icon = set_icon
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