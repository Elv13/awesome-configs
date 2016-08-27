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
local function tint(request,col,height,width,padding)
    local img,cr,mask= create_transformation_mask(request._img,height,width,padding)

    -- Apply the tint
    cr:set_operator(cairo.Operator.HSL_COLOR)
    cr:set_source(color(col))
    cr:mask(cairo.Pattern.create_for_surface(mask))
    return request
end

local function clip(shape)
    --TODO
end

local function reset_clip()
    --TODO
end

local function resize_center(request,padding,h,w)
    local img = request._img
    local pat = cairo.Pattern.create_for_surface(img)
    local ow,oh = img:get_width(),img:get_height()
    w,h = w or ow, h or oh

    -- Compute the ratio to honor the padding
    local ratio = w < h and ((h-2*padding) / oh) or ((w-2*padding) / ow)

    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
    local cr = cairo.Context(img2)
    cr:scale(ratio, ratio)
    cr:set_source_surface(img, padding, padding)
    cr:paint()

    -- Update the request
    request._img = img2
    request._cr   = cr

    return request
end

local function resize_surface(request, padding_w, padding_h)
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32,
        request._img:get_width() + padding_w,
        request._img:get_height() + padding_h
    )

    local cr = cairo.Context(img2)
    cr:set_source_surface(request._img, padding_w/2, padding_h/2)
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

local function glow(request,radius,col,intensity, reset_clip)
    local img = request._img
    local col,radius,intensity = col or "#000000",radius or 3,intensity or 0.15
    local w,h = request._img:get_width(), request._img:get_height()
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, w,h)
    local cr = cairo.Context(img2)

    cr:save()

    if reset_clip then
        cr:reset_clip()
    end

    local img3 = request:copy():colorize(col):to_img()

    local step_x, step_y = 1/w, 1/h
    cr:set_source(color(col))
    for i=1, radius do
        cr:translate(-radius*0.15,-radius*0.1)
        cr:scale(1+i*step_x, 1+i*step_y)
        cr:set_source_surface(img3, -i/2, -i/2)
        cr:paint_with_alpha(intensity)
    end
    cr:restore()
    cr:set_source_surface(img)
    cr:paint()

    -- Update the request
    request._img = img2
    request._cr   = cr

    return request
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

--- Append one or more request on top of self
-- @param request2 One or more request
local function compose(request, request2, padding_x, padding_h)
    local img = request._img
    local cr  = request._cr

    cr:set_source_surface(request2._img, padding_x, padding_h)
    cr:paint()

    return request
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
        resize_surface= resize_surface,

        -- Request handling
        to_img        = to_img,
        to_pattern    = to_pattern,
        copy          = copy,
        compose       = compose,
    }
    return request
end

function module.from_size(width, height, pattern, shape, ...)
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
    local cr = cairo.Context(img)

    if shape then
        shape(cr, width, height, ...)
        cr:clip()
    end

    if pattern then
        cr:set_source(pattern)
        cr:paint()
    end

    cr:reset_clip()

    return init(img, cr)
end

return setmetatable(module, { __call = function(_, ...) return init(...) end })