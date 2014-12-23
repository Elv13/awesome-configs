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

-- Until it is merged into Awesome

if not surface.get_size then
    --- Get the size of a cairo surface
    -- @param surf The surface you are interested in
    -- @return The surface's width and height
    surface.get_size = function(surf)
        local cr = cairo.Context(surf)
        local x, y, w, h = cr:clip_extents()
        return w, h
    end
end

if not color.apply_mask then
    color.apply_mask = function(img,mask_col)
        img = surface(img)
        local cr = cairo.Context(img)
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
--         if not color then
--             color = require("gears.color")
--         end
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

--- Compose multiple surfaces as one
--
-- Examples:
--    gears.surface.compose({base_surface,surface2,{layer=other_surface,matrix=matrix},{layer=arr2,x=12}})
--
-- Each table element can be a surface, a path or a table with "x","y","layer","matrix" and "scale" as keys.
-- The matrix are standard cairo matrix
-- @note Please note that the first layer cannot be a table
-- @param layer_table An array of surfaces
-- @return A new composed surface with the same dimensions as layer_table[1]
function surface.compose(layer_table)
    local base,cr,base_w,base_h = nil,nil
    for k=1,#layer_table do --Do NOT use ipairs here as the array have some nils
        local v = layer_table[k]
        if not base then
            base = v
            if type(v) == "string" then
                base = cairo.ImageSurface.create_from_png(base)
                base_w,base_h = surface.get_size(base)
                cr = cairo.Context(base)
            else
                base_w,base_h = surface.get_size(v)
                base = v:create_similar(cairo.Content.COLOR_ALPHA, base_w,base_h)
                cr = cairo.Context(base)
                cr:set_source_surface(v)
                cr:paint()
            end
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
                local ratio = ((sw > sh) and sw or sh) / ((height or base_h or 16)-4)
                local matrix2 = cairo.Matrix()
                cairo.Matrix.init_scale(matrix2,ratio,ratio)
                if y == "align" then
                    if base_h > sh then
                        y = (base_h -sh)/2
                    else
                        y = (sh - base_h)/2
                    end
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






-- Old stuff [DEPRECATED]

-- local end_cache = {}
-- module.get_end_arrow2 = function(args)--bg_color,fg_color,padding,direction
--     local args = args or {}
--     local default_height = beautiful.default_height or 16
--     local bgt = type(args.bg_color)
--     local hash = (args.width or default_height+1)..(args.padding or 0)..(args.height or default_height)..(not args.bg_color and beautiful.fg_normal or (bgt == "string" and args.bg_color or args.bg_color.stops[1][2])  or "")..(args.direction or "")
--     if end_cache[hash] then
--         return end_cache[hash]
--     end
--     local width,height = (args.width or default_height/2+1),args.height or default_height
--     local img = cairo.ImageSurface(cairo.Format.ARGB32, width+(args.padding or 0), height)
--     local cr = cairo.Context(img)
--     cr:set_source(color(args.bg_color or beautiful.bg_normal))
--     cr:new_path()
--     if (args.direction == "left") then
--         cr:move_to(0,width+(args.padding or 0))
--         cr:line_to(0,height/2)
--         cr:line_to(width+(args.padding or 0),height)
--         cr:line_to(0,height)
--         cr:line_to(0,0)
--         cr:line_to(width+(args.padding or 0),0)
--     else
--         cr:line_to(width+(args.padding or 0),0)
--         cr:line_to(width+(args.padding or 0),height)
--         cr:line_to(0,height)
--         cr:line_to(width-1,height/2)
--         cr:line_to(0,0)
--     end
--     cr:close_path()
-- --     cr:set_antialias(cairo.ANTIALIAS_NONE)
--     cr:fill()
--     return img
-- end

-- module.get_end_arrow_wdg2 = function(args)
--     local ib = wibox.widget.imagebox()
--     ib:set_image(get_end_arrow2(args))
--     return ib
-- end

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

-- module.get_beg_arrow_wdg2 = function(args)
--     local ib = wibox.widget.imagebox()
--     ib:set_image(module.get_beg_arrow2(args))
--     return ib
-- end

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
function module.draw_text(cr,layout,x,y,enable_shadow,shadow_color,glow_x,glow_y)
    if enable_shadow and shadow_color then
        cr:save()
        for i=1,4 do
            cr:move_to(glow_x or x, glow_y or y)
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