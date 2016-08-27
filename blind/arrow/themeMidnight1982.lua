local color   = require( "gears.color"    )
local surface = require( "gears.surface"  )
local blind   = require( "blind"          )
local radical = require( "radical"        )
local pixmap  = require( "blind.common.pixmap")
local pattern = require( "blind.common.pattern2")

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

local default_height = 16

-- The base colors
local fore = "#00FF00"
local back = "#000000"

-- This theme use a single color with some retro "dumb" digital dithering
local dit_80 = pattern(back) : dithering(fore, 80) : to_pattern()
local dit_60 = pattern(back) : dithering(fore, 60) : to_pattern()
local dit_40 = pattern(back) : dithering(fore, 40) : to_pattern()
local dit_20 = pattern(back) : dithering(fore, 20) : to_pattern()

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
    bg = back,
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
theme.awesome_icon         = path .."Icon/awesome2.png"
theme.systray_icon_spacing = 4
theme.button_bg_normal     = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       )
-- theme.enable_glow          = true
theme.glow_color           = "#105A8B"
theme.naughty_bg           = theme.bg_alternate
theme.naughty_border_color = theme.fg_normal
-- theme.bg_dock              = d_mask(blind_pat.sur.thick_stripe(back,"#0a0a0a",14,default_height,true))
theme.fg_dock_1            = "#1889F2"
theme.fg_dock_2            = "#1889F2"

-- Border
theme.border = blind {
    width  = 2              ,
    normal = back      ,
    focus  = back      ,
    marked = "#91231c"      ,
}

theme.alttab_icon_transformation = function(image,data,item)
    return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
end

-- Taglist
theme.taglist = blind {
    item_style    = radical.item.style.classic.vertical,
    bg = blind {
        hover     = dit_80,
        selected  = fore,
        used      = dit_40,
--         urgent    = d_mask(blind_pat.sur.flat_grad("#5B0000","#300000",default_height)),
        changed   = dit_60,
        empty     = back,
        highlight = dit_80,
    },
    fg = blind {
        hover     = back,
        selected  = back,
        used      = fore,
        urgent    = "#FF7777",
        changed   = fore,
        highlight = back,
        prefix    = back,--theme.fg_normal,
    },
--     custom_color = function (...) d_mask(blind_pat.sur.flat_grad(...)) end,
    default_icon       = path .."Icon/tags_invert/other.png",
    border_width = 2,
    disable_index = true,
    border_color = "#ff0000",
    icon_transformation     =  function(img) return pixmap(img) : colorize(fore) : to_img() end,
}

-- Tasklist
theme.tasklist = blind {
    item_style              = radical.item.style.classic.vertical,
    fg_focus                = back,
    fg_hover                = back,
    underlay_bg_urgent      = dit_20,
    underlay_bg_minimized   = dit_20,
    underlay_bg_focus       = dit_20,
    underlay_bg_normal      = dit_80,
    bg_minimized            = dit_20,
    bg_urgent               = dit_60,
    bg_hover                = dit_80,
    bg_focus                = fore,
    default_icon            = path .."Icon/tags_invert/other.png",
    icon_transformation     = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path)
}


-- Menu
theme.menu = blind {
    height       = 20,
    width        = 170,
    border_width = 2,
    opacity      = 0.9,
    fg_normal    = theme.fg_normal,
    fg_focus     = back,
    bg_focus     = dit_80,
    bg_header    = dit_40,
    bg_normal    = dit_20,
    bg_highlight = dit_40,
    border_color = fore,
    default_style = radical.style.classic,
    default_item_style = radical.item.style.classic,
}

-- Toolbox
local function toolbox_transform(image,data,item)
    return pixmap(image) : colorize(theme.icon_grad) : to_img()
end

theme.toolbox = blind {
    icon_transformation = toolbox_transform,
    item_style          = radical.item.style.line_3d,
    bg=dit_20,
    bg_focus=dit_80,
    style = radical.style.grouped_3d,
}

-- Bottom menu
theme.bottom_menu = blind {
    item_style = radical.item.style.classic.vertical,
    bg = back,
    icon_transformation = toolbox_transform
}

-- Systray
theme.bg_systray_alt = dit_60

-- Dock
theme.dock_icon_transformation = function(img) return pixmap(img) : colorize(fore) : to_img() end

-- Titlebar
loadfile(theme.path .."bits/titlebar_retro.lua")(theme,path)
theme.titlebar_to_upper = true
theme.titlebar_bg_title_active = dit_40
theme.titlebar_bg_title_normal = back

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

-- Textbox glow
loadfile(theme.path .."bits/textbox/glow.lua")(theme,path)

-- The separator theme
require( "chopped.simple" )

return theme
