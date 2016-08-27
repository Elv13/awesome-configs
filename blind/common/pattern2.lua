---------------------------------------------------------------------------
-- A bitmap pattern builder
--
-- This module allow to compose complex patterns from atomic elements such as
-- gradient, dithering, geometric shape repetition and more.
--
-- Please be aware that using these function is slow, always cache result
--
-- @author Emmanuel Lepage Vallee
-- @copyright 2012-2016 Emmanuel Lepage Vallee
-- @release @AWESOME_VERSION@
-- @module gears.pattern
---------------------------------------------------------------------------
local unpack  = unpack or table.unpack
local color   = require( "gears.color"   )
local surface = require( "gears.surface" )
local cairo   = require( "lgi"           ).cairo

local manipulations = {}

--TODO shape pattern
--TODO fix stripe
--TODO integrate the missing 2
--TODO fully drop the old code
--TODO matrix support
--TODO create wallpapers from pattern
--TODO create widget hierarchy -> surface/pattern
--TODO no_repeat
--TODO add a beatiful "get_namespace" method to automagically handle my_namespace_foo_bar with automatic (or manual) cascading back
--TODO ^^ Maybe even add a metatable() based set_state to relevant widgets and mangle the namespace+state .ns1_ns2_ns3_state

-- Convert a surface to a bitmap pattern
local function sur_to_pat(img)
    local pat = cairo.Pattern.create_for_surface(img)
    pat:set_extend(cairo.Extend.REPEAT)
    return pat
end

-- Make transparent
local function clear(cr)
    cr:set_operator(cairo.Operator.CLEAR)
    cr:paint()
    cr:set_operator(cairo.Operator.OVER)
end

-- Patterns need to support repetition. Different patterns will require
-- different dimensions to "look right". When composing a pattern from
-- two different base multiplier, the dimension have to grow to the
-- least common multiplier where
-- (origin_w * n = destination_w and pat2_w * m = destination_w)
--   --> n = pat2_w, m = origin_w, destination_w = n*m
local function ajust_size(builder, w_s, h_s)
    local img, cr, w, h = builder._img, builder._cr, builder._w, builder._h

    -- There is nothing yet
    if not img then
        builder._img = cairo.ImageSurface.create(cairo.Format.ARGB32, w_s, h_s)
        builder._cr  = cairo.Context(builder._img)
        clear(builder._cr)
        builder._w, builder._h = w_s, h_s

        return
    end

    -- If the pattern is already compatible, stop here
    if (w % w_s == 0 and h % h_s == 0) then
        builder._w = w_s > builder._w and w_s or builder._w
        builder._h = h_s > builder._h and h_s or builder._h
        return
    end

    -- There may be a more efficient solution, but factoring it is slow
    local new_w = (w_s % w == 0 or w % w_s == 0) and (w > w_s and w or w_s) or w*w_s
    local new_h = (h_s % h == 0 or h % h_s == 0) and (h > h_s and h or h_s) or h*w_s

    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, new_w, new_h)
    local cr2  = cairo.Context(img2)

    cr2:set_source(sur_to_pat(img))
    cr2:paint()

    builder._img, builder._cr = img2 , cr2
    builder._w  , builder._h  = new_w, new_h
end


-- Supported multipliers for dithering
local dithering_dimension = {
    [100] = {1,1},
    [80 ] = {2,2},
    [60 ] = {4,4},
    [40 ] = {4,2},
    [20 ] = {3,3}
}

-- Classic digital dithering patterns
local dithering_pattern = {
    [100] = function(cr)
        cr:rectangle(0,0,1,1)
    end,
    [80 ] = function(cr)
        cr:rectangle(0,0,1,1)
        cr:rectangle(1,1,1,1)
    end,
    [60 ] = function(cr)
        cr:rectangle(0,0,1,1)
        cr:rectangle(2,0,1,1)
        cr:rectangle(1,1,1,1)
        cr:rectangle(0,2,1,1)
        cr:rectangle(2,2,1,1)
        cr:rectangle(3,3,1,1)
    end,
    [40 ] = function(cr)
        cr:rectangle(0,0,1,1)
        cr:rectangle(2,1,1,1)
    end,
    [20 ] = function(cr)
        cr:rectangle(1,1,1,1)
    end
}

--- Emulate MS-DOS/1980's color emulation (dithering)
-- The main color is applied to some pixels only to emulate intermediate colors
-- between color1 and color2. Enjoy the retro effect!
-- There is 6 intensity of dithering, expressed in percent:
--   100=full color, 0=transparent
-- @return The builder
function manipulations:dithering(col, intensity)
    local intensity = intensity - (intensity%20)

    if intensity > 100 or intensity < 20 then return img, cr end

    local dim = dithering_dimension[intensity]

    ajust_size(self, unpack(dim))

    self._cr:set_source(color(col))
    dithering_pattern[intensity](self._cr)
    self._cr:fill()

    return self
end

--- A checkerboard pattern, like a chessboard
-- @param col A color/gradient/pattern
-- @tparam[opt=2] number size The pattern size
-- @return The builder
function manipulations:checkerboard(col, size)
    local size = size or 2
    ajust_size(self, size*2, size*2)

    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, size*2, size*2)
    local cr  = cairo.Context(img)
    clear(cr)
    cr:set_source(color(col))
    cr:rectangle(0,0,size,size)
    cr:rectangle(size,size,size,size)
    cr:fill()

    self._cr:set_source(sur_to_pat(img))
    self._cr:paint()

    return self
end

local black = color("#ffffff")

--- Add a smooth 3D effect to a surface
-- This effect does not work very well with replication. It is recommanded to
-- use it as the last step.
-- @tparam[opt="#777777"] string col A "#aabbcc" formatted color
-- @tparam[opt=25] number intensity Opacity (in percent, 0 to 100)
-- @return The builder
function manipulations:threeD(col, intensity)
    local col = col or "#777777"

    ajust_size(self, 1, 1)

    -- Force alpha
    local s,r,g,b,a = color(col):get_rgba()
    local c2        = cairo.Pattern.create_rgba(r, g, b, (intensity or 25) / 100)

    local grabpat = color {
        type  = "linear"     ,
        from  = { 0, 0       },
        to    = { 0, self._h },
        stops = {
            { 0.2, "#ffffff"   },
            { 1  , "#66666655" }
--             { 0.2, black }, --FIXME need to use Cairo gradient directly
--             { 1  , c2    }
        }
    }

    -- Preserve the operator
    local op = self._cr:get_operator()

    self._cr:set_source  ( grabpat                )
    self._cr:set_operator( cairo.Operator.OVERLAY )
    self._cr:paint       (                        )
    self._cr:set_operator( op                     )

    return self
end

--- Create diagonal lines
-- @param col The line color
-- @tparam[opt=math.pi/4] number angle The line angle (in radiant)
-- @tparam[opt=1] number line_width The line width
-- @tparam[opt=width] number spacing The space between the lines
-- @return The builder
function manipulations:stripe(col, angle, line_width, spacing)
    local angle      = angle or math.pi/4
    local line_width = line_width or 1
    local spacing    = spacing or line_width

    local hy = line_width + 2*spacing

    -- Get the necessary width and height so the line repeat itself correctly
    local a, o = math.cos(angle)*hy, math.sin(angle)*hy

    --FIXME spacing need to be in "w", not "hy"
    local w, h = math.ceil(a + (line_width - 1)), math.ceil(o + (line_width - 1))
--     ajust_size(self, w, h) --FIXME need a "force_size" method

    -- Create the pattern
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, w, h)
    local cr2  = cairo.Context(img2)

    -- Avoid artefacts caused by anti-aliasing
    local offset = line_width

    -- Setup
    cr2:set_source(color(col))
    cr2:set_line_width(line_width)

    -- The central line
    cr2:move_to(-offset, -offset)
    cr2:line_to(w+offset, h+offset)
    cr2:stroke()

    --FIXME sin/cos required for this to work with other angles than 45 degree

    -- Top right
    cr2:move_to(-offset + w - spacing/2+line_width, -offset)
    cr2:line_to(2*w+offset - spacing/2+line_width, h+offset)
    cr2:stroke()

    -- Bottom left
    cr2:move_to(-offset + spacing/2-line_width, -offset + h)
    cr2:line_to(w+offset + spacing/2-line_width, 2*h+offset)
    cr2:stroke()

    -- Apply the stripes
    self._cr:set_source(sur_to_pat(img2))
    self._cr:paint()

    return self
end

--- Create random noise
-- A 12x12 noise matrix will be created and repeated
-- @param base_color The noise color
-- @tparam[opt=0.15] number strength The noise strength, between 0 and 1
-- @return The builder
function manipulations:noise(base_color, strength)
    local img, cr  = self._img, self._cr
    local w,h      = img:get_width(), img:get_height()
    local strength = strength or 0.15

    -- It need at least 11x11 to look non-repetitive
    if w < 11 or h < 11 then
        -- Less than 11 look really bad, but 12 is a better multiplier
        ajust_size(self, 12, 12)
        w,h = img:get_width(),img:get_height()
    end

    -- The complexity is h*w, it get very, very slow on more than 100x100
    -- as it wont really make a difference, make sure LGI is only invoked
    -- 144 iteration rather than 10000
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, 12, 12)
    local cr2  = cairo.Context(img2)

    local s,r,g,b,a = color(base_color):get_rgba()
    cr2:set_antialias(cairo.ANTIALIAS_NONE)
    for i=0, 11 do
        for j=0, 11 do
            local alpha = math.random()*strength
            cr2:set_source_rgba(r,g,b,alpha)
            cr2:rectangle(i,j,1,1)
            cr2:fill()
        end
    end

    local pat = sur_to_pat(img2)
    cr:set_source(pat)
    cr:paint()

    return self
end

-- Create a grid pattern
function manipulations:grid(col, spacing, thickness)
    local spacing = spacing or 10

    ajust_size(self, spacing, spacing)
    local img, cr  = self._img, self._cr

    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, spacing, spacing)
    local cr2  = cairo.Context(img2)

    cr2:set_line_width((thickness or 1))

    cr2:set_antialias(1)

    cr2:move_to( math.ceil(spacing/2), 0                   )
    cr2:line_to( math.ceil(spacing/2), spacing             )
    cr2:move_to( 0                   , math.ceil(spacing/2))
    cr2:line_to( spacing             , math.ceil(spacing/2))
    cr2:set_source(color(col))
    cr2:stroke()

    local pat = sur_to_pat(img2)
    cr:set_source(pat)
    cr:paint()

    return self
end


--- Draw triangles on to of img
-- @arg size The size of the triangles
-- @arg border The border size
-- @arg cols an array of colors for the triangles
-- @arg border_col The triangle border color
-- @arg img A surface
-- @arg cr A cairo context
-- function blind_pat.mask.triangle(size, border, cols, border_col, img,cr)
--     local w,h = img:get_width(),img:get_height()
-- 
--     -- The width need to be a multiple of the size or repetition will be wrong
--     if w < size or math.floor(w%size) > 0 then
--         w,h = math.ceil(w/size)*size,h
--         img,cr = resize(img,w,h)
--     end
-- 
--     local multiple_w,muliple_h = math.ceil(w/size),math.ceil(h/size)
-- 
--     for i=0, multiple_w do
--         for j=0, muliple_h do
--             -- First triangle
--             cr:move_to(i*size, j*size)
--             cr:line_to(i*size + size,j*size)
--             cr:line_to(i*size + math.ceil(size/2), j*size + size)
--             cr:close_path()
--             if border > 0 then
--                 cr:set_source(color(border_col))
--                 cr[#cols > 0 and "stroke_preserve" or "stroke"](cr)
--             end
--             local c = cols[1]
--             if c then
--                 cr:set_source(c)
--                 cr:fill()
--             end
-- 
--             -- Second triangle
--             c = cols[2]
--             if c then
--                 cr:set_source(c)
--                 cr:move_to(i*size + size, j*size)
--                 cr:line_to(i*size + size             , j*size + size)
--                 cr:line_to(i*size + math.ceil(size/2), j*size + size)
--                 cr:fill()
--                 cr:move_to(i*size, j*size)
--                 cr:line_to(i*size + math.ceil(size/2), j*size + size)
--                 cr:line_to(i*size, j*size + size)
--                 cr:fill()
--             end
--         end
--     end
-- 
--     return img,cr
-- end
-- 
-- function blind_pat.mask.honeycomb(size, border, cols, border_col, img,cr)
--     local w,h = img:get_width(),img:get_height()
--     local dx = size/3
--     local dy = size/2
--     local wi = (2*dx)
-- 
--     -- The surface size has to be a multiple of size
--     if w < size or math.floor(w%(4*dx)) > 0 then
--         w,h = math.ceil(w/size)*size,h
--         img,cr = resize(img,w,h)
--     end
-- 
--     cr:set_source(color(border_col or cols[1]))
--     local multiple_w,muliple_h = math.ceil(w/wi),math.ceil(h/size)
--     for j=0, muliple_h do
--         local m = false
--         for i=0, multiple_w do
--             local dy_ = m and (-dy) or 0
--             cr:move_to(i*wi + 2*dx, j*size+dy_)
--             cr:line_to(i*wi + dx, j*size+dy_)
--             cr:line_to(i*wi, j*size+dy+dy_)
--             cr:line_to(i*wi + dx, j*size+size+dy_)
--             cr:stroke()
--             m = not m
--         end
--     end
--     return img,cr
-- end

--- Grow the builder canvas
-- Some patterns will change depending on the bitmap canvas size
-- @tparam[opt] number width  Resize the pattern to the closest point to width
-- @tparam[opt] number height Resize the pattern to the closest point to height
-- @return The builder
function manipulations:grow(width, height)
    ajust_size(self, width or self._w, height or self._h)
    return self
end

--- Paint an existing pattern on top of the builder one
-- If the pattern require a certain size to display correctly, `:grow()`
-- should be called prior to this method.
-- @param col The color/gradient/pattern
-- @return The builder
function manipulations:pattern(col)
    ajust_size(self, 1, 1)
    self._cr:set_source(color(col))
    self._cr:paint()

    return self
end

--- Load a pattern from an image file
-- @tparam string path The file path
-- @return The builder
function manipulations:file(path)
    local img  = surface(path)
    local w, h = img:get_width(), img:get_height()

    ajust_size(self, w, h)

    self._cr:set_source(sur_to_pat(img))
    self._cr:paint()

    return self
end

function manipulations:opacity(opacity)
    local img, cr  = self._img, self._cr
    local w,h      = img:get_width(), img:get_height()
    local strength = strength or 0.15

    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, 12, 12)
    local cr2  = cairo.Context(img2)
    cr2:set_source_surface(img)
    cr2:paint_with_alpha(opacity or 1)

    self._img, self._cr = img2 , cr2

    return self
end

--- Set the pattern composition operator
-- The default is cairo.Operator.OVER
-- See http://cairographics.org/operators/ for more details
-- @tparam number op The cairo operator (enum)
-- @return The builder
function manipulations:operator(op)
    if not self._cr then return self end

    self._cr:set_operator(op)
end

function manipulations:set_dpi(dpi)
    --TODO
end

--- Convert the builder into a pattern
-- @return A cairo pattern
function manipulations:to_pattern()
    if not self._img then return nil end

    local pat = cairo.Pattern.create_for_surface(self._img)
    pat:set_extend(cairo.Extend.REPEAT)

    return pat
end

--- Create a PNG from this pattern
-- @tparam string path The file path
-- @tparam number w The width
-- @tparam number h The height
function manipulations:save_to_file(path, w, h)
    --TODO for regression test
end

--- Create a bitmap pattern builder
-- @param[opt=transparent] An optional base color/gradient/pattern to start with
-- @return A bitmap pattern builder
local function create_builder(base)
    local builder = setmetatable({},{__index=manipulations})

    if base then
        builder : pattern(base)
    end

    return builder
end

return setmetatable(manipulations, {__call = function(_,...) return create_builder(...) end})
