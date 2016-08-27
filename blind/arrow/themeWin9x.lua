local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local blind      = require( "blind"          )
local radical    = require( "radical"        )
local pixmap     = require( "blind.common.pixmap")
local pattern    = require( "blind.common.pattern2")
local wall       = require( "gears.wallpaper" )

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

local default_height = 28


local bg_normal = color("#D4D0C8")

-- Win 9x fake 3D is quite simple
local function win9x_bar_bg(context, cr, width, height)
    cr:set_source(bg_normal)
    cr:paint()
    cr:set_line_width(1)
    cr:set_source_rgb(1,1,1)
    cr:rectangle(0,1,width,1)
    cr:fill()
end

local btn_c1 = color("#808080")
local btn_c2 = color("#404040")

local function win9x_button_bg(context, cr, width, height)
    win9x_bar_bg(context, cr, width, height)
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

local dit_bg = pattern("#C0C0C0") : checkerboard("#ffffff",1) : to_pattern()
local function win9x_button_pressed(context, cr, width, height)
    cr:set_source(dit_bg)
    cr:paint()
    cr:set_source_rgb(0,0,0)
    cr:rectangle(0,0,width,1)
    cr:rectangle(0,0,1,height)
    cr:fill()
    cr:set_source_rgb(1,1,1)
    cr:rectangle(width-1,0,1,height)
    cr:rectangle(0,height-1,width,1)
    cr:fill()
    cr:set_source(btn_c1)
    cr:rectangle(1,1,width-2,1)
    cr:rectangle(1,1,1,height-2)
    cr:fill()
end

local function win9x_systray_bg(context, cr, width, height)
    cr:translate(0,4)
    height = height - 6
    width  = width - 2
    cr:set_source(btn_c1)
    cr:rectangle(0,0,width,1)
    cr:rectangle(0,0,1,height)
    cr:fill()
    cr:set_source_rgb(1,1,1)
    cr:rectangle(width-1,0, 1, height)
    cr:rectangle(0, height-1, width, 1)
    cr:fill()
end

local function toolbox_transform(image,data,item)
    return pixmap(image)
        : resize_center(3,default_height,default_height)
        : colorize(
            pattern()
                : checkerboard("#000000", 1)
                : to_pattern()
            )
        : to_img()
end

-- The base colors
local fore = "#000000"
local back = "#555555"

theme.apps_title = "Start"

-- This theme use a single color with some retro "dumb" digital dithering
-- local dit_80 = pattern() : dithering(fore, 80) : to_pattern()
-- local dit_60 = pattern() : dithering(fore, 60) : to_pattern()
-- local dit_40 = pattern() : dithering(fore, 40) : to_pattern()
-- local dit_20 = pattern() : dithering(fore, 20) : to_pattern()

theme.default_height = default_height

theme.font = "C64 Pro Mono, Regular 6"


theme.path = path

-- Background
theme.bg = blind {
    normal      = back,
    focus       = dit_60,
    urgent      = dit_80,
    minimize    = dit_20,
    highlight   = dit_40,
    alternate   = dit_20,
    allinone    = back,
    systray     = theme.fg_normal
}

-- Wibar
theme.wibar = blind {
    bgimage = win9x_bar_bg,
    border_width =1,
    border_color =fore,
}

-- Forground
theme.fg = blind {
    normal      = fore,
    focus       = fore,
    urgent      = fore,
    minimize    = fore,
}

-- Other
theme.awesome_icon         = path .."Icon/win9x.png"
theme.show_desktop_icon    = path .."Icon/win9x_desk.png"
theme.systray_icon_spacing = 4
theme.button_bg_normal     = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       )
-- theme.enable_glow          = true
theme.glow_color           = "#105A8B"
theme.naughty_bg           = theme.bg_alternate
theme.naughty_border_color = theme.fg_normal
-- theme.bg_dock              = d_mask(blind_pat.sur.thick_stripe(back,"#0a0a0a",14,default_height,true))
theme.fg_dock_1            = "#1889F2"
theme.fg_dock_2            = "#1889F2"
theme.useless_gap = 3
theme.allinone_margins = 6

-- Border
theme.border = blind {
    width  = 0              ,
    normal = back      ,
    focus  = back      ,
    marked = "#91231c"      ,
}

-- theme.alttab_icon_transformation = function(image,data,item)
--     return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
-- end

-- Taglist
theme.taglist = blind {
    item_style    = radical.item.style.classic.vertical,
    bgimage = blind {
        hover     = win9x_button_bg,
        selected  = win9x_button_pressed,
        used      = win9x_button_pressed,
        changed   = win9x_button_pressed,
        empty     = win9x_button_bg,
        highlight = win9x_button_bg,
    },
    fg = blind {
        hover     = fore,
        selected  = fore,
        used      = back,
        urgent    = "#FF7777",
        changed   = fore,
        highlight = back,
        prefix    = back,--theme.fg_normal,
    },
--     custom_color = function (...) d_mask(blind_pat.sur.flat_grad(...)) end,
    default_icon       = path .."Icon/tags_invert/other.png",
    border_width = 0,
    border_color = "#00000000",
    item_border_color = "#00000000",
    item_border_color_focus = "#00000000",
    disable_index = true,
    spacing = 4,
    icon_transformation     =  toolbox_transform,
    bg_empty = color.transparent,
}
theme.taglist_default_item_margins = {
    LEFT   = 7,
    RIGHT  = 7,
    TOP    = 1,
    BOTTOM = 1,
}
theme.taglist_default_margins = {
    LEFT   = 2,
    RIGHT  = 2,
    TOP    = 2,
    BOTTOM = 3,
}

-- Tasklist
theme.tasklist = blind {
    item_style              = radical.item.style.basic,
    fg_focus                = "#000000",
    fg_hover                = back,
    underlay_bg_urgent      = dit_20,
    underlay_bg_minimized   = dit_20,
    underlay_bg_focus       = dit_20,
    underlay_bg_normal      = dit_80,
    fg_minimized            = btn_c1,
    bg_minimized            = bg_normal,
    bgimage_used                 = win9x_button_bg,
    bg_urgent               = dit_60,
    bg_hover                = dit_80,
    bgimage                      = win9x_button_bg,
    bgimage_focus                = win9x_button_pressed,
    default_icon            = path .."Icon/tags_invert/other.png",
    spacing                 = 3,
    border_color = "#00000000",
--     icon_transformation     = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path)
}

theme.tasklist_default_item_margins = {
    LEFT   = 7,
    RIGHT  = 7,
    TOP    = 1,
    BOTTOM = 1,
}
theme.tasklist_default_margins = {
    LEFT   = 2,
    RIGHT  = 2,
    TOP    = 3,
    BOTTOM = 1,
}


-- Menu
theme.menu = blind {
    height       = 20,
    width        = 170,
    border_width = 2,
    opacity      = 0.9,
    fg_normal    = theme.fg_normal,
--     fg_focus     = win9x_button_pressed,
    bgimage_focus     = win9x_button_pressed,
    bg_header    = dit_40,
    bgimage_normal    = win9x_button_bg,
    bg_highlight = dit_40,
    border_color = fore,
    default_style = radical.style.classic,
    default_item_style = radical.item.style.basic,
}

-- Toolbox

theme.toolbox = blind {
    icon_transformation = toolbox_transform,
    item_style          = radical.item.style.basic,
--     bg                  = win9x_button_bg,
    bgimage_focus            = win9x_button_pressed,
    style = radical.style.grouped_3d,
}

-- Bottom menu
theme.bottom_menu = blind {
    bgimage = win9x_button_bg,
    bgimage_used = win9x_button_bg,
    bgimage_focus=win9x_button_bg,
    spacing    = 4,
    style = radical.style.classic,
    item_style = radical.item.style.basic,
    menu_item_style = radical.item.style.basic,
--     icon_transformation = toolbox_transform
}
theme.button_menu_menu_item_style = radical.item.style.basic

theme.bottom_menu_default_item_margins = {
    LEFT   = 5,
    RIGHT  = 5,
    TOP    = 2,
    BOTTOM = 2,
}

theme.bottom_menu_default_margins = {
    LEFT   = 2,
    RIGHT  = 3,
    TOP    = 2,
    BOTTOM = 2,
}


-- Systray
theme.bgimage_systray_alt = win9x_systray_bg
theme.systray_margins_top    = 6
theme.systray_margins_bottom = 4
theme.systray_margins_left   = 4
theme.systray_margins_right  = 4

-- Dock
-- theme.dock_icon_transformation = function(img) return pixmap(img) : colorize(fore) : to_img() end

-- Titlebar
loadfile(theme.path .."bits/titlebar_win9x.lua")(theme,path)
theme.titlebar_to_upper = true

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

-- Textbox glow
loadfile(theme.path .."bits/textbox/glow.lua")(theme,path)

-- The separator theme
require( "chopped.win9x" )

-- The wallpaper
wall.centered(theme.awesome_icon, 1, "#3A6EA5")
return theme
