local theme,path = ...
local surface    = require( "gears.surface"      )
local blind      = require( "blind"              )
local color      = require( "gears.color"        )
local cairo      = require( "lgi"                ).cairo
local pixmap     = require( "blind.common.pixmap")

local active = theme.titlebar_icon_active or theme.titlebar_icon_fg or theme.fg_normal
local height = theme.titlebar_height or 22
local base_square = {}

local bg_normal = color("#D4D0C8")
local bg_c2     = color("#808080")
local bg_c3     = color("#404040")

local function bg_common(context, cr, width, height, c1, c2)
    cr:set_source(bg_normal)
    cr:paint()
    cr:set_source_rgb(1,1,1)
    cr:rectangle(1,1,width-2,1)
    cr:rectangle(1,1,1,height-2)
    cr:fill()
    cr:set_source(bg_c2)
    cr:rectangle(width-2,1,1,height-2)
    cr:set_source(bg_c3)
    cr:rectangle(width-1,0,1, height)
    cr:fill()

    cr:set_source(color {
        type = "linear",
        from = { 0, 0 },
        to = { width -6, 0 },
        stops = {
            { 0,  c1},
            { 1,  c2}
        }
    })
    cr:rectangle(3,3,width-6,height-4)
    cr:fill()
end

local function tb_bg_active(context, cr, width, height)
    bg_common(context, cr, width, height, "#0A246A", "#A6CAF0")
end

local function tb_bg_normal(context, cr, width, height)
    bg_common(context, cr, width, height, "#808080", "#C0C0C0")
end

local btn_c1 = color("#808080")
local btn_c2 = color("#404040")

local function win9x_button_bg(context, cr, width, height)
    cr:set_source(bg_normal)
    cr:rectangle(0,0,width, height)
    cr:fill()
    cr:set_line_width(1)
    cr:set_source_rgb(1,1,1)
    cr:rectangle(0,0,width,1)
    cr:fill()
    cr:rectangle(0,0,1,height)
    cr:fill()
    cr:set_source(btn_c1)
    cr:rectangle(1, height-2, width-2, 1)
    cr:rectangle(width-2, 1, 1, height -2)
    cr:fill()
    cr:set_source(btn_c2)
    cr:rectangle(0,height-1,width,1)
    cr:rectangle(width-1, 0, 1, height -1)
    cr:fill()
end

local function get_cols(state)
    return color(theme["titlebar_bg_"..state]),color(theme["titlebar_border_color_"..state])
end

local side_color = function (context, cr, width, height)
    cr:set_source(bg_normal)
    cr:paint()
    cr:set_source(bg_c2)
    cr:rectangle(width-2,0,1,height)
    cr:fill()
    cr:set_source(bg_c3)
    cr:rectangle(width-1,0,1,height)
    cr:fill()
end

local function draw_bottom(self, context, cr, width, height)
    cr:set_source(bg_normal)
    cr:paint()
    cr:set_source(bg_c2)
    cr:rectangle(0,1,width,1)
    cr:fill()
    cr:set_source(bg_c3)
    cr:rectangle(0,2,width,1)
    cr:fill()
end

local function add_icon(state,type,icon_path)
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height-2, height)
    local cr  = cairo.Context(img)
    cr:translate(0,4)
    win9x_button_bg({}, cr, height-5, height-6)
    local sur = surface(icon_path or (path .."Icon/titlebar_classic/".. type ..".png"))
    color.apply_mask(sur, "#000000")
    cr:scale(0.7,0.7)
    cr:set_source_surface(sur, 3, 3)
    cr:paint()
    return img
end

theme.titlebar = blind {
    close_button = blind {
        normal = add_icon("active","close"),
        focus  = add_icon("hover","close"),
    },

    ontop_button = blind {
        normal_inactive = add_icon("inactive","ontop"),
        focus_inactive  = add_icon("inactive","ontop"),
        normal_active   = add_icon("active","ontop"),
        focus_active    = add_icon("active","ontop"),
    },

    sticky_button = blind {
        normal_inactive = add_icon("inactive","sticky"),
        focus_inactive  = add_icon("inactive","sticky"),
        normal_active   = add_icon("active","sticky"),
        focus_active    = add_icon("active","sticky"),
    },

    floating_button = blind {
        normal_inactive = add_icon("inactive","floating"),
        focus_inactive  = add_icon("inactive","floating"),
        normal_active   = add_icon("active","floating"),
        focus_active    = add_icon("active","floating"),
    },

    maximized_button = blind {
        normal_inactive = add_icon("inactive","maximized"),
        focus_inactive  = add_icon("inactive","maximized"),
        normal_active   = add_icon("active","maximized"),
        focus_active    = add_icon("active","maximized"),
    },

    resize      = add_icon("active","maximized",path .."Icon/titlebar_classic/resize.png"),
    tag         = add_icon("active","maximized",path .."Icon/titlebar_classic/tag.png"),
    title_align = "left",
    show_icon   = true,
    bg_alternate= "#00000000",

    -- Left and right
    left = true,
    left_width = 3,
    right = true,
    right_width = 3,
    bg_sides = side_color,
    bgimage = tb_bg_normal,
    bgimage_focus = tb_bg_active,
    fg_normal = color("#ffffff"),
    fg_focus = color("#ffffff"),
    fg_normal = color("#D4D0C8"),
    height = height,
    bottom = true,
    bottom_height = 3,
    bottom_draw = draw_bottom,
}
theme.titlebar_show_separator = false
local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 5, height)

theme.titlebar_side_top_left  = img

local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, 2, height)

theme.titlebar_side_top_right = img2
