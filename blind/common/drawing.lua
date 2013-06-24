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
local cairo = require("lgi").cairo

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
    local hash = (args.width or default_height+1)..(args.padding or 0)..(args.height or default_height)..(args.bg_color or beautiful.fg_normal or "")..(args.direction or "")
    if end_cache[hash] then
        return end_cache[hash]
    end
    local img = cairo.ImageSurface(cairo.Format.ARGB32, (args.width or default_height/2+1)+(args.padding or 0), args.height or default_height)
    local cr = cairo.Context(img)
    cr:move_to(0,0)
    cr:set_source(color(args.bg_color or beautiful.bg_normal))
    cr:set_antialias(0)
    for i=0,(default_height/2+1) do
        cr:rectangle((args.direction == "left") and 0 or i+1, i               , default_height/2-i, 1)
        cr:rectangle((args.direction == "left") and 0 or i+1, default_height-i, default_height/2-i, 1)
    end
    cr:stroke()
    end_cache[hash] = img
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
    local hash = (args.width or default_height/2 + 1)..(args.padding or 0)..(args.height or default_height)..(args.bg_color or beautiful.fg_normal or "")..(args.direction or "")
    if beg_cache[hash] then
        return beg_cache[hash]
    end
    local img = cairo.ImageSurface(cairo.Format.ARGB32, (args.width or default_height/2)+(args.padding or 0), args.height or default_height)
    local cr = cairo.Context(img)
    cr:move_to(0,0)
    cr:set_source(color(args.bg_color or beautiful.fg_normal))
    cr:set_antialias(0)
    for i=0,(default_height/2) do
        cr:rectangle((args.direction == "left") and default_height/2-i+(args.padding or 0) or 0, i   , i, 1)
        cr:rectangle((args.direction == "left") and default_height/2-i+(args.padding or 0) or 0, default_height-i, i, 1)
    end
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
    local base,cr = nil,nil
    for k=1,#layer_array do --Do NOT use ipairs here as the array have some nils
        local v = layer_array[k]
        if not base then
            base = v
            if type(base) == "string" then
                base = cairo.ImageSurface.create_from_png(base)
            end
            cr = cairo.Context(base)
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

return setmetatable(module, { })