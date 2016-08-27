local type         = type
local surface      = require("gears.surface")
local beautiful    = require( "beautiful"    )
local wibox        = require( "wibox"  )
local color = require("gears.color")
local cairo = require("lgi").cairo
local module = {}

-- Until it is merged into Awesome

if not color.apply_mask then
    color.apply_mask = function(img,mask_col)
        img = surface(img)
        local cr = cairo.Context(img)
        local t = type(mask_col)

        if t == "function" then return img end

        cr:set_source(color(mask_col or beautiful.icon_mask or beautiful.fg_normal))
        cr:set_operator(cairo.Operator.IN)
        cr:paint()
        return img
    end

    --- Setup a surface to be transformed
    -- @return A new surface
    -- @return a context
    -- @return the mask surface
    local function create_transformation_mask(sur,height,width,padding)
        -- Get size
        local ic = surface(sur)
        local icp = cairo.Pattern.create_for_surface(ic)
        local sw,sh = surface.get_size(ic)
        local height,width = height or sh,width or sw
        local padding = padding or 2
        local main_ratio = (sw > sh) and sw or sh
        local ratio = (height-padding) / main_ratio

        -- Create matrix
        local matrix = cairo.Matrix()
        cairo.Matrix.init_scale(matrix,ratio,ratio)
        matrix:translate(height/2-6,padding/2)

        --Copy to surface
        local img = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
        local cr = cairo.Context(img)
        cr:set_operator(cairo.Operator.CREAR)
        cr:paint()
        cr:set_operator(cairo.Operator.SOURCE)
        cr:set_matrix(matrix)
        cr:set_source(icp)
        cr:paint()

        --Generate the mask
        local mask = ic:create_similar(cairo.Content.ALPHA, sw, sh)
        local cr4 = cairo.Context(mask)
        cr4:set_source(icp)
        cr4:paint()

        return img,cr,mask
    end

    --- Return a surface where colors have been replaced by a tint
    -- @param sur A surface or image path
    -- @param col The tint color
    -- @param height The height of the resulting surface
    -- @param width The width of the resulting surface
    -- @param padding a padding
    -- @return A new surface
    function surface.tint(sur,col,height,width,padding)
        local img,cr,mask= create_transformation_mask(sur,height,width,padding)

        -- Apply the tint
        cr:set_operator(cairo.Operator.HSL_COLOR)
        cr:set_source(color(col))
        cr:mask(cairo.Pattern.create_for_surface(mask))
        return img
    end

    function surface.tint2(sur,col)
        local w,h = sur:get_width(),sur:get_height()
        local img = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
        local cr = cairo.Context(img)
        cr:set_operator(cairo.Operator.HSL_COLOR)
        cr:set_source(color(col))
        cr:mask(cairo.Pattern.create_for_surface(sur))
        return img
    end

    --- Return a desaturated surface
    -- @param sur A surface or image path
    -- @param factor The desaturation strength (0-1)
    -- @param height The height of the resulting surface
    -- @param width The width of the resulting surface
    -- @param padding a padding
    -- @return A new surface
    function surface.desaturate(sur,factor,height,width,padding)
        local img,cr,mask= create_transformation_mask(sur,height,width,padding)
        local factor = factor or 1

        -- Apply desaturation
        cr:set_source_rgba(0,0,0,factor)
        cr:set_operator(cairo.Operator.HSL_SATURATION)
        cr:mask(cairo.Pattern.create_for_surface(mask))

        return img
    end

    function surface.outline(sur,c)
        local img,cr,mask= create_transformation_mask(sur,height,width,padding)
        local w,h = surface.get_size(img)
        local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
        local cr2 = cairo.Context(img2)
        cr2:set_source(color(c))
        cr2:translate(-3,-3)
        cr2:scale(1.1,1.1)
        cr2:mask(cairo.Pattern.create_for_surface(mask))
        cr2:set_operator(cairo.Operator.CLEAR)
        cr2:translate(3,3)
        cr2:scale(0.85,0.85)
        cr2:mask(cairo.Pattern.create_for_surface(mask))
        return img2
    end

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

local line_width,alpha = {1,2,3,5},{"77","55","33","10"}
function module.draw_text(cr,layout,x,y,enable_shadow,shadow_color,glow_x,glow_y)
    if enable_shadow and shadow_color then
        cr:save()
        for i=1,4 do
            if shadow_color:len() == 7 then
                cr:move_to(glow_x or x, glow_y or y)
                cr:set_source(color(shadow_color..alpha[i]))
                cr:set_line_width(line_width[i])
                cr:layout_path(layout)
                cr:stroke()
            end
        end
        cr:restore()
    end
    cr:move_to(x, y)
    cr:show_layout(layout)
end

module.apply_icon_transformations = surface.tint

return module
