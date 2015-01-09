local theme,path = ...
local surface    = require( "gears.surface"      )
local blind      = require( "blind"              )
local shape      = require( "blind.common.shape" )
local color      = require( "gears.color"        )
local cairo      = require( "lgi"                ).cairo
local pixmap     = require( "blind.common.pixmap")

local active = theme.titlebar_icon_active or theme.titlebar_icon_fg or theme.fg_normal
local height = theme.titlebar_height or 18
local base_square = {}

local square = nil

local function get_cols(state)
    return color(theme["titlebar_bg_"..state]),color(theme["titlebar_border_color_"..state])
end

local function gen_squares()
    for _,v in ipairs {"inactive","active", "hover", "pressed"} do
        local bg,border = get_cols(v)
        local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height+1, height)
        local cr  = cairo.Context(img)
        if square then
            cr:append_path(square)
        else
            shape.draw_round_rect(cr,2,2,height-4,height-5,3)
            square = cr:copy_path()
        end
        cr:set_source(bg)
        cr:fill_preserve()
        cr:set_source(border)
        cr:set_line_width(2)
        cr:stroke()
        base_square[v] = img
        print(v)
    end
end
gen_squares()

local function add_icon(state,type,icon_path)
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height+1, height)
    local cr  = cairo.Context(img)
    cr:set_source_surface(base_square[state])
    cr:paint()
    cr:set_source_surface(surface(icon_path or (path .."Icon/titlebar/".. type .."_normal_inactive.png")))
    cr:paint()
    return pixmap(img) : shadow(nil,"#000000BB") : to_img()
end

local close     = base_square.active
local ontop     = base_square.active
local sticky    = base_square.active
local floating  = base_square.active
local maximized = base_square.active

theme.titlebar = blind {
    close_button = blind {
        normal = add_icon("active","close",path .."Icon/titlebar/close_focus_inactive.png"),
        focus  = add_icon("hover","close",path .."Icon/titlebar/close_focus_inactive.png"),
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

    resize      = add_icon("active","maximized",path .."Icon/titlebar/resize.png"),
    tag         = add_icon("active","maximized",path .."Icon/titlebar/tag.png"),
    title_align = "left",
    bg_alternate= "#00000000"
}

local img = cairo.ImageSurface.create(cairo.Format.ARGB32, 7, height)
local cr  = cairo.Context(img)
cr:set_source(color({ type = "linear", from = { 0, 0 }, to = { 4, 0 }, stops = { { 0, "#666666ff" }, { 1, "#66666600" }}}))
cr:rectangle(0,6,4,height-6)
cr:fill()
cr:set_source(color({ type = "radial", from = { 6,6,2 }, to = { 6,6,6 }, stops = { { 0, "#66666600" }, { 1, "#666666ff" }}}))
cr:arc(6,6,6,math.pi,2*math.pi)
cr:fill()
theme.titlebar_side_left  = img

local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, 7, height)
local cr2  = cairo.Context(img2)
cr2:set_source(color({ type = "linear", from = { 3, 0 }, to = { 7, 0 }, stops = { { 0, "#66666600" }, { 1, "#666666ff" }}}))
cr2:rectangle(0,6,7,height-6)
cr2:fill()
cr2:set_source(color({ type = "radial", from = { 6,6,2 }, to = { 6,6,6 }, stops = { { 0, "#66666600" }, { 1, "#666666ff" }}}))
-- cr2:set_source_rgba(1,0,0,1)
cr2:move_to(1,0)
cr2:line_to(1,6)
cr2:line_to(6,6)
cr2:arc(7,6,6,3*(math.pi/2),4*(math.pi/2))
cr2:close_path()
cr2:fill()
theme.titlebar_side_right = img2