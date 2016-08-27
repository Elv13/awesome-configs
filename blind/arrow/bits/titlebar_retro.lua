local theme,path = ...
local capi       = {client = client}
local blind      = require( "blind"          )
local color      = require( "gears.color"    )
local cairo      = require( "lgi"            ).cairo
local surface    = require( "gears.surface"  )
local pixmap     = require( "blind.common.pixmap")
local shape      = require( "gears.shape" )
local bind_pat   = require( "blind.common.pattern2")

local col = color(theme.fg_normal)

local bgs = {
    [true ] = "titlebar_bg_title_active",
    [false] = "titlebar_bg_title_normal",
}

local function bg_retro(context, cr, w, h)
    local active = context.client == capi.client.focus
    cr:set_line_width(2)
    cr:rectangle(1,1,w-2,h-2)
    cr:set_source(color(theme[bgs[active]] or "#000000"))
    cr:fill_preserve()
    cr:set_source(col)
    cr:stroke()
end

local function bg_bottom(context, cr, w, h)
    cr:set_source(color(theme.titlebar_bg or "#000000"))
    cr:paint()
    cr:rectangle(0,h/2-1,w,2)
    cr:set_source(col)
    cr:fill()
end

local titlebar_color = color(theme.fg_normal)

local function draw_bottom(self, context, cr, width, height)
    cr:set_line_width(2)

    cr:set_source_rgb(0,0,0)
    cr:rectangle(1,1, 20, height-2)
    cr:fill_preserve()
    cr:set_source(titlebar_color)
    cr:stroke()

    cr:set_source_rgb(0,0,0)
    cr:rectangle(width/2 - 20, 1, 40, height-2)
    cr:fill_preserve()
    cr:set_source(titlebar_color)
    cr:stroke()

    cr:set_source_rgb(0,0,0)
    cr:rectangle(width - 21,1, 20, height-2)
    cr:fill_preserve()
    cr:set_source(titlebar_color)
    cr:stroke()
end

local height = 18
local bottom_height = height/2

local img = cairo.ImageSurface.create(cairo.Format.ARGB32, height/2, height)
local cr  = cairo.Context(img)
cr:set_source(color(theme.fg_normal))
cr:rectangle(0, height/2, 2, height/2)
cr:fill()
theme.titlebar_side_top_left  = img

img = cairo.ImageSurface.create(cairo.Format.ARGB32, height/2, height)
cr  = cairo.Context(img)
cr:set_source(color(theme.fg_normal))
cr:rectangle(height/2 - 2, height/2, 2, height/2)
cr:fill()
theme.titlebar_side_top_right  = img

img = cairo.ImageSurface.create(cairo.Format.ARGB32, 20, bottom_height)
cr  = cairo.Context(img)
cr:set_source(color(theme.fg_normal))
cr:rectangle(0, 0, 2, bottom_height/2)
cr:fill()
theme.titlebar_side_bottom_left  = img

img = cairo.ImageSurface.create(cairo.Format.ARGB32, 20, bottom_height)
cr  = cairo.Context(img)
cr:set_source(color(theme.fg_normal))
cr:rectangle(18, 0, 2, bottom_height/2)
cr:fill()
theme.titlebar_side_bottom_right  = img

local function from_char(char, state)
    local test,w,h = surface.load_from_string(char, nil, height - 8, theme.fg_normal, nil, "C64 Pro Mono, Regular 8")
    local width = w > height and width or height
    local pat = color((state == "focus_active" or state == "normal_active") and bind_pat(theme.bg_normal) : dithering(theme.fg_normal, 40) : to_pattern() or "#00000000")

    local req = pixmap.from_size(width, height, pat, shape.rounded_rect, 2)

    req:compose(pixmap(test), (width -w)/2, (height-h)/2)

    return req:to_img()
end

local char_to_name = {
    T   = "ontop"    ,
    M   = "maximize" ,
    S   = "sticky"   ,
    X   = "close"    ,
    F   = "floating" ,
    R   = "resize"   ,
    TAG = "tag"      ,
}

local function from_iconset(char, state)
    local col = state == ("normal_active" or state == "focus_active") and theme.fg_urgent or theme.fg_normal

    return pixmap(path .. "Icon/titlebar_scifi/" .. char_to_name[char] .. ".png")
        : colorize(col)
        : resize_center(4)
        : to_img()
end

from_char = from_iconset
theme.titlebar = blind {
    close_button = blind {
        normal = from_char("X", "normal"),
        focus = from_char("X" , "focus" ),
    },

    ontop_button = blind {
        normal_inactive = from_char("T", "normal_inactive"),
        focus_inactive  = from_char("T", "focus_inactive" ),
        normal_active   = from_char("T", "normal_active"  ),
        focus_active    = from_char("T", "focus_active"   ),
    },

    sticky_button = blind {
        normal_inactive = from_char("S", "normal_inactive"),
        focus_inactive  = from_char("S", "focus_inactive" ),
        normal_active   = from_char("S", "normal_active"  ),
        focus_active    = from_char("S", "focus_active"   ),
    },

    floating_button = blind {
        normal_inactive = from_char("F", "normal_inactive"),
        focus_inactive  = from_char("F", "focus_inactive" ),
        normal_active   = from_char("F", "normal_active"  ),
        focus_active    = from_char("F", "focus_active"   ),
    },

    maximized_button = blind {
        normal_inactive = from_char("M", "normal_inactive"),
        focus_inactive  = from_char("M", "focus_inactive" ),
        normal_active   = from_char("M", "normal_active"  ),
        focus_active    = from_char("M", "focus_active"   ),
    },

    resize      = from_char("R", "focus_inactive" ),
    tag         = from_char("TAG", "focus_inactive" ),
    bgimage_focus    = bg_bottom,
    title_align = "center",
    height      = height,
    bgimage_alternate= bg_retro,
    bgimage = bg_retro,

    -- The buttons
    bgimage_normal= bg_bottom,

    title = blind {
        bgimage = bg_retro
    },

    bottom = true,
    bottom_height = bottom_height,
    left = true,
    left_width = 2,
    right = true,
    right_width = 2,
    bottom_draw = draw_bottom,
    show_underlay = true,
    show_separator = false,
--     fg_focus = "#ff0000",
    underlay_fg = theme.fg_normal,
    underlay_bg = bind_pat("#081B37") : grow(15, 15) : noise("#4A5D72", 0.65) : to_pattern(),
    underlay_border_color = theme.fg_normal,
    underlay_border_width = 3,
}

