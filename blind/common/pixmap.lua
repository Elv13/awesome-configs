local surface    = require( "gears.surface"  )
local cairo      = require( "lgi"            ).cairo
local color      = require( "gears.color"    )
local beautiful  = require( "beautiful"      )

local module = {}

local init = nil

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
function tint(request,col,height,width,padding)
    local img,cr,mask= create_transformation_mask(request._img,height,width,padding)

    -- Apply the tint
    cr:set_operator(cairo.Operator.HSL_COLOR)
    cr:set_source(color(col))
    cr:mask(cairo.Pattern.create_for_surface(mask))
    return request
end

local function resize_center(request,padding,h,w)
    local img = request._img
    local pat = cairo.Pattern.create_for_surface(img)
    local ow,oh = img:get_width(),img:get_height()
    w,h = w or ow, h or oh
    local ratio = ow > oh and 2.0 or oh/(h-padding*2)

    local matrix = cairo.Matrix()
    cairo.Matrix.init_scale(matrix,ratio,ratio)

    local matrix2 = cairo.Matrix()
    cairo.Matrix.init_translate(matrix2,-padding,-padding)

    local matrix3 = cairo.Matrix()
    matrix3:multiply(matrix,matrix2)

    pat:set_matrix(matrix3)

    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
    local cr = cairo.Context(img2)
    cr:set_source(pat)
    cr:translate(40,10)
    cr:paint()

    -- Update the request
    request._img = img2
    request._cr   = cr

    return request
end

local function colorize(request,mask_col)
    local img = request._img
    local cr = request._cr or cairo.Context(img)
    request._cr = cr

    cr:set_source(color(mask_col or beautiful.icon_mask or beautiful.fg_normal))
    cr:set_operator(cairo.Operator.IN)
    cr:paint()
    return request
end

local function shadow(request,radius,col,intensity)
    local img = request._img
    local col,radius,intensity = col or "#000000",radius or 3,intensity or 0.15
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, request._img:get_width(), request._img:get_height())
    local cr = cairo.Context(img2)

    local img3 = request:copy():colorize(col):to_img()

    cr:set_source(color(col))
    for i=1, radius do
        cr:set_source_surface(img3,radius-i+1,radius-i+1)
        cr:paint_with_alpha(intensity)
    end
    cr:set_source_surface(img)
    cr:paint()

    -- Update the request
    request._img = img2
    request._cr   = cr

    return request
end

local function glow(request,radius,col,intensity)
--     local img = request._img
--     local col,radius,intensity = col or "#000000",radius or 3,intensity or 0.15
--     local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, request._img:get_width(), request._img:get_height())
--     local cr = cairo.Context(img2)
-- 
--     local img3 = request:copy():colorize(col):to_img()
-- 
--     cr:set_source(color(col))
--     for i=1, radius do
--         cr:set_source_surface(img3,radius-i+1,radius-i+1)
--         cr:paint_with_alpha(intensity)
--     end
--     cr:set_source_surface(img)
--     cr:paint()
-- 
--     -- Update the request
--     request._img = img2
--     request._cr   = cr
-- 
--     return request
end

local function to_img(request)
    return request._img
end

local function to_pattern(request)
    local pat = cairo.Pattern.create_for_surface(request._img)
    pat:set_extend(cairo.Extend.REPEAT)
    return pat
end

local function copy(request)
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, request._img:get_width(), request._img:get_height())
    local cr = cairo.Context(img2)
    cr:set_source_surface(request._img)
    cr:paint()

    return init(img2,cr)
end

init = function(img,cr)
    local request = {
        _img          = surface(img),
        _cr           = cr,

        -- Operations
        resize_center = resize_center,
        colorize      = colorize,
        shadow        = shadow,
        tint          = tint,
        glow          = glow,

        -- Request handling
        to_img        = to_img,
        to_pattern    = to_pattern,
        copy          = copy,
    }
    return request
end

return setmetatable(module, { __call = function(_, ...) return init(...) end })