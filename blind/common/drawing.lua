local setmetatable = setmetatable
local print        = print
local tostring = tostring
local type         = type
local ipairs       = ipairs
local math         = math
local surface      = require("gears.surface")
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local wibox        = require( "wibox"  )
local color = require("gears.color")
local gsurface = require("gears.surface")
local cairo = require("lgi").cairo
local pango = require("lgi").Pango
local pangocairo = require("lgi").PangoCairo

local capi = { image  = image  ,
               widget = widget,
               screen = screen}
local module = {}

local cacheE,cacheB = {},{}

-- local function move_and_apply(cr,pat,x,y)
--     cr:set_source_surface(surface.load(pat),x or 0,y or 0)
--     cr:paint()
-- end

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
module.compose = function(layer_array)
    local base,cr,base_w,base_h = nil,nil
    for k=1,#layer_array do --Do NOT use ipairs here as the array have some nils
        local v = layer_array[k]
        if not base then
            base = v
            if type(base) == "string" then
                base = cairo.ImageSurface.create_from_png(base)
            end
            cr = cairo.Context(base)
            base_w,base_h = base:get_width(),base:get_height()
        elseif v then
            local s,x,y,matrix,scale,height = v,0,0,nil,false,nil
            local layer_type=type(s)
            if layer_type == "table" then
                x,y,matrix,scale,height = v.x,v.y,v.matrix,v.scale,v.height
                s = s.layer
                layer_type = type(s)
            end
            if layer_type == "string" then
                s = cairo.ImageSurface.create_from_png(s)
            elseif layer_type == "userdata" then
                s = surface.load(s)
            end

            if scale then
                local sw,sh = s:get_width(),s:get_height()
                local ratio = ((sw > sh) and sw or sh) / ((height or beautiful.default_height or 16)-4)
                local matrix2 = cairo.Matrix()
                cairo.Matrix.init_scale(matrix2,ratio,ratio)
                if y == "align" then
                    if base_h > sh then
                        y = (base_h -sh)/2
                    else
                        y = (sh - base_h)/2
                    end
                    print(y,base_h,sh)
                end
                matrix2:translate(-x,-y)
                local pattern = cairo.Pattern.create_for_surface(s)
                pattern:set_matrix(matrix2)
                cr:set_source(pattern)
            elseif matrix then
                local pattern = cairo.Pattern.create_for_surface(s)
                pattern:set_matrix(matrix)
                cr:set_source(pattern)
                cr:move_to(x,y)
            else
                cr:set_source_surface(s,x,y)
            end
            cr:paint()
        end
    end
    return base
end

function module.apply_color_mask(img,mask)
    img = surface(img)
    local cr = cairo.Context(img)
    cr:set_source(color(mask or beautiful.icon_grad or beautiful.fg_normal))
    cr:set_operator(cairo.Operator.IN)
    cr:paint()
    return img
end

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

function module.status_ellipse(cr,width,height)
    cr:save()
    cr:set_source(color({ type = "radial", from = { width/2,0, 0 }, to = { width/2, -10, width/5 }, stops = { { 0, "#1960EF" }, { 1, "#00000000" }}}))
    cr:rectangle(0,0,width,height)
    cr:fill()
    cr:set_source(color({ type = "linear", from = { 0, 0 }, to = { 0, 7 }, stops = { { 0, "#0c2e72dd" }, { 1, "#00000000" }}}))
    cr:rectangle(0,0,width,7)
    cr:fill()
    cr:set_source(color(beautiful.taglist_underline or beautiful.bg_alternate))
    cr:rectangle(2*height+5,height-2,width - 3*height-25,2)
    cr:fill()
    cr:restore()
end

function module.pattern(path)
    local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(path))
    cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
    return pat
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

-----------------------------------------------------------------------------
--1) Take the client icon                                                  --
--2) Resize and move it                                                    --
--3) Apply a few layers of color effects to desaturate, then tint the icon --
-----------------------------------------------------------------------------
function module.apply_icon_transformations(icon,col)
    -- Get size
    local ic = gsurface(icon)
    local icp = cairo.Pattern.create_for_surface(ic)
    local sw,sh = ic:get_width(),ic:get_height()
    local height = beautiful.default_height
    -- Create matrix
    local ratio = (height-2) / ((sw > sh) and sw or sh)
    local matrix = cairo.Matrix()
    cairo.Matrix.init_scale(matrix,ratio,ratio)
    matrix:translate(height/2 - 6,-2)

    --Copy to surface
    local img5 = cairo.ImageSurface.create(cairo.Format.ARGB32, height*1.5, height)
    local cr5 = cairo.Context(img5)
    cr5:set_operator(cairo.Operator.CREAR)
    cr5:paint()
    cr5:set_operator(cairo.Operator.SOURCE)
    cr5:set_matrix(matrix)
    cr5:set_source(icp)
    cr5:paint()

    --Generate the mask
    local img4 = cairo.ImageSurface.create(cairo.Format.A8, sw, sh)
    local cr4 = cairo.Context(img4)
    --cr4:set_matrix(matrix)
    cr4:set_source(icp)
    cr4:paint()

    -- Apply desaturation
    cr5:set_source_rgba(0,0,0,1)
    cr5:set_operator(cairo.Operator.HSL_SATURATION)
    cr5:mask(cairo.Pattern.create_for_surface(img4))
    cr5:set_operator(cairo.Operator.HSL_COLOR)
    cr5:set_source(col)
    cr5:mask(cairo.Pattern.create_for_surface(img4))
    return img5
end



return setmetatable(module, { })