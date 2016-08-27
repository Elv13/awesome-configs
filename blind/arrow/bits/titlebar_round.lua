local theme,path = ...
local blind      = require( "blind"          )
local color      = require( "gears.color"    )
local cairo      = require( "lgi"            ).cairo
local shape      = require( "gears.shape" )

local col = color(theme.fg_normal)

local bgs = {
    top = function(context, cr, w, h)
        cr:translate(1,1)
        shape.rounded_rect(cr, w-2, h*3, 12)
        cr:set_source(col)
        cr:set_line_width(3)
        cr:stroke()
        cr:translate(-2,-2)
    end,
    bottom = function(context, cr, w, h)
        cr:translate(1,-3*h+ 17)
        shape.rounded_rect(cr, w-2, h*3, 12)
        cr:set_source(col)
        cr:set_line_width(3)
        cr:stroke()
        cr:translate(-1,-2)
    end,
    left = function(context, cr, w, h)
        cr:set_source_rgb(0,0,0)
        cr:paint()
        cr:set_source(col)
        cr:rectangle(0,0,2,h)
        cr:fill()
    end,
    right = function(context, cr, w, h)
        cr:set_source_rgb(0,0,0)
        cr:paint()
        cr:set_source(col)
        cr:rectangle(w-2,0,2,h)
        cr:fill()
    end,
}

local function bg_retro(context, cr, w, h)
    bgs[context.position](context, cr, w, h)
end

local height = 18
local bottom_height = height

local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height*.66, height)
theme.titlebar_side_top_left  = img
theme.titlebar_side_top_right  = img

local function rect_img(close, state)
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 30, 18)
    local cr  = cairo.Context(img)

    if state == "normal_inactive" or state == "normal" then
        return img
    elseif close then
        cr:set_source(color(theme.fg_urgent))
    else
        cr:set_source(color(theme.fg_normal))
    end

    cr:translate(4,height-8)
    shape.hexagon(cr, 26,6)
    cr:fill()

    return img
end

for _, btn in ipairs {"ontop", "sticky", "floating", "maximized"} do
    for _, state in ipairs {"normal_inactive", "focus_inactive", "normal_active", "focus_active"} do
        theme["titlebar_"..btn.."_button_"..state] = rect_img(false, state)
    end
end

theme.titlebar = blind {
    close_button = blind {
        normal = rect_img(true, "normal"),
        focus  = rect_img(true , "focus" ),
    },

    resize      = rect_img(false, "focus_inactive" ),
    tag         = rect_img(false, "focus_inactive" ),
    title_align = "center",
    height      = height,
    bg_alternate= "#00000000",
    bgimage     = bg_retro,

    title = blind {
        bg = "#00000000",
    },

    bottom = true,
    bottom_height = bottom_height,
    left = true,
    left_width = 6,
    bg_sides = "#00000000",
    right = true,
    right_width = 6,
    bottom_draw = nil,
    show_underlay = false,
    fg_normal = "#00000000",
    fg_focus = "#ffffff",
}