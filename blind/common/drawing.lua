local setmetatable = setmetatable
local type         = type
local math         = math
local surface      = require("gears.surface")
local beautiful    = require( "beautiful"    )
local wibox        = require( "wibox"  )
local color = require("gears.color")
local cairo = require("lgi").cairo
local pango = require("lgi").Pango
local pangocairo = require("lgi").PangoCairo
local module = {}

local end_cache = {}
module.get_end_arrow2 = function(args)--bg_color,fg_color,padding,direction
    local args = args or {}
    local default_height = beautiful.default_height or 16
    local bgt = type(args.bg_color)
    local hash = (args.width or default_height+1)..(args.padding or 0)..(args.height or default_height)..(not args.bg_color and beautiful.fg_normal or (bgt == "string" and args.bg_color or args.bg_color.stops[1][2])  or "")..(args.direction or "")
    if end_cache[hash] then
        return end_cache[hash]
    end
    local width,height = (args.width or default_height/2+1),args.height or default_height
    local img = cairo.ImageSurface(cairo.Format.ARGB32, width+(args.padding or 0), height)
    local cr = cairo.Context(img)
    cr:set_source(color(args.bg_color or beautiful.bg_normal))
    cr:new_path()
    if (args.direction == "left") then
        cr:move_to(0,width+(args.padding or 0))
        cr:line_to(0,height/2)
        cr:line_to(width+(args.padding or 0),height)
        cr:line_to(0,height)
        cr:line_to(0,0)
        cr:line_to(width+(args.padding or 0),0)
    else
        cr:line_to(width+(args.padding or 0),0)
        cr:line_to(width+(args.padding or 0),height)
        cr:line_to(0,height)
        cr:line_to(width-1,height/2)
        cr:line_to(0,0)
    end
    cr:close_path()
--     cr:set_antialias(cairo.ANTIALIAS_NONE)
    cr:fill()
    return img
end

module.get_end_arrow_wdg2 = function(args)
    local ib = wibox.widget.imagebox()
    ib:set_image(get_end_arrow2(args))
    return ib
end

local beg_cache = {}
module.get_beg_arrow2 = function(args)--bg_color,fg_color,padding,direction
    local args = args or {}
    local default_height = beautiful.default_height or 16
    local bgt = type(args.bg_color)
    local hash = (args.width or default_height/2 + 1)..(args.padding or 0)..(args.height or default_height)..(not args.bg_color and beautiful.fg_normal or (bgt == "string" and args.bg_color or args.bg_color.stops[1][2]) or "")..(args.direction or "")
    if beg_cache[hash] then
        return beg_cache[hash]
    end
    local width,height = (args.width or default_height/2+1)+(args.padding or 0),args.height or default_height
    local img = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
    local cr = cairo.Context(img)
    cr:set_source(color(args.bg_color or beautiful.fg_normal))
    cr:new_path()
    if (args.direction == "left") then
        cr:move_to(0,width)
        cr:line_to(0,height/2)
        cr:line_to(width,height)
        cr:line_to(width,0)
    else
        cr:line_to(width,height/2)
        cr:line_to(0,height)
        cr:line_to(0,0)
    end
    cr:close_path()
--     cr:set_antialias(cairo.ANTIALIAS_NONE)
    cr:fill()
    beg_cache[hash] = img
    return img
end

module.get_beg_arrow_wdg2 = function(args)
    local ib = wibox.widget.imagebox()
    ib:set_image(module.get_beg_arrow2(args))
    return ib
end

--Take multiple layers or path_to_png and add them on top of each other
module.compose = surface.compose

-- Draw information buble intended for menus background
local pango_l,pango_crx = {},{}
function module.draw_underlay(text,args)
    local args = args or {}
    local padding = beautiful.default_height/3
    local height = args.height or (beautiful.menu_height)
    if not pango_l[height] then
        local pango_crx = pangocairo.font_map_get_default():create_context()
        pango_l[height] = pango.Layout.new(pango_crx)
        local desc = pango.FontDescription()
        desc:set_family("Verdana")
        desc:set_weight(pango.Weight.BOLD)
        desc:set_size((height-padding*2) * pango.SCALE)
        pango_l[height]:set_font_description(desc)
    end
    pango_l[height].text = text
    local width = pango_l[height]:get_pixel_extents().width + height + padding
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, width+(args.padding_right or 0), height+padding)
    cr = cairo.Context(img)
    cr:set_source(color(args.bg or beautiful.bg_alternate))
    cr:arc((height-padding)/2 + 2, (height-padding)/2 + padding/4 + (args.margins or 0), (height-padding)/2+(args.padding or 0)/2,0,2*math.pi)
    cr:fill()
    cr:arc(width - (height-padding)/2 - 2, (height-padding)/2 + padding/4 + (args.margins or 0), (height-padding)/2+(args.padding or 0)/2,0,2*math.pi)
    cr:rectangle((height-padding)/2+2,padding/4 + (args.margins or 0)-(args.padding or 0)/2,width - (height),(height-padding)+(args.padding or 0))
    cr:fill()
    cr:set_source(color(args.fg or beautiful.bg_normal))
    cr:set_operator(cairo.Operator.CLEAR)
    cr:move_to(height/2 + 2,padding/4 + (args.margins or 0)-(args.padding or 0)/2)
    cr:show_layout(pango_l[height])
    return img
end

local line_width,alpha = {1,2,3,5},{"77","55","33","10"}
function module.draw_text(cr,layout,x,y,enable_shadow,shadow_color)
    if enable_shadow and shadow_color then
        cr:save()
        for i=1,4 do
            cr:move_to(x, y)
            cr:set_source(color(shadow_color..alpha[i]))
            cr:set_line_width(line_width[i])
            cr:layout_path(layout)
            cr:stroke()
        end
        cr:restore()
    end
    cr:move_to(x, y)
    cr:show_layout(layout)
end

local sep_wdgs = nil
function module.separator_widget()
    if not sep_wdgs then
        local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, beautiful.default_height/2+2, beautiful.default_height)
        local cr = cairo.Context(img2)
        cr:set_source(color(beautiful.icon_grad or beautiful.bg_normal))
        cr:set_line_width(1.2)
        cr:move_to(beautiful.default_height/2+2,-2)
        cr:line_to(2,beautiful.default_height/2)
        cr:line_to(beautiful.default_height/2+2,beautiful.default_height+2)
        cr:stroke()
        sep_wdgs = wibox.widget.imagebox()
        sep_wdgs:set_image(img2)
    end
    return sep_wdgs
end

module.apply_icon_transformations = surface.tint

return setmetatable(module, { })