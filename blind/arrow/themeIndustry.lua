local color      = require( "gears.color"          )
local surface    = require( "gears.surface"        )
local blind      = require( "blind"                )
local radical    = require( "radical"              )
local pixmap     = require( "blind.common.pixmap"  )
local pattern    = require( "blind.common.pattern2")
local shape      = require( "gears.shape"          )

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

local default_height = 16

theme.default_height = default_height

theme.font  = "Roboto, Semibold 10"

-- Mutualize some repetitive code
function pattern:TDPat()
    return self : threeD() : to_pattern()
end

local function wipat(base)
    return pattern(base) : grow(default_height, default_height)
end

local function common_3d(pat)
    return pat : grow(default_height, default_height) : threeD() : to_pattern()
end

local bg_normal = common_3d(pattern("#1A1A1A") : checkerboard("#0C0C0C", 2))
local bg_alt    = common_3d(pattern("#242424") : checkerboard("#181818", 2))
local bg_button = common_3d(pattern("#281F01") : checkerboard("#321002", 2))
local icon_grad = common_3d(pattern("#282828") : checkerboard("#1B1B1B", 2))
local bg_used   = common_3d(pattern("#A07D08") : checkerboard("#906206", 2))
local bg_focus  = common_3d(pattern("#594504") : checkerboard("#442E02", 2))
local bg_under  = common_3d(pattern("#3C1B04") : checkerboard("#200E02", 2))

theme.path = path

-- Background
theme.bg = blind {
    normal      = "#000000",
    focus       = "#496477",
    urgent      = "#5B0000",
    minimize    = "#040A1A",
    highlight   = "#0E2051",
    alternate   = "#081B37",
    allinone    = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#7C6900" }, { 1, "#635400" }}},
}

-- Wibar background
local bargrad = { type = "linear", from = { 0, 0 }, to = { 0, 16 }, stops = { { 0, "#000000" }, { 1, "#040405" }}}
theme.bar_bg = blind {
    alternate = bg_alt,
    normal    = bg_normal,
    buttons   = bg_button,
}

-- Forground
theme.fg = blind {
    normal   = "#C2D3E3",
    focus    = "#ABCCEA",
    urgent   = "#FF7777",
    minimize = "#1577D3",
    allinone    = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#FFD900" }, { 1, "#FFD900" }}},
}

theme.icon_grad        = icon_grad
theme.icon_mask        = { type = "linear", from = { 0, 0 }, to = { 0, 16 }, stops = { { 0, "#C9A803" }, { 1, "#524401" }}}
theme.icon_grad_invert = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#000000" }, { 1, "#112543" }}}

-- Other
theme.awesome_icon         = path .."Icon/awesome2.png"
theme.systray_icon_spacing = 4
theme.button_bg_normal     = theme.icon_mask
theme.enable_glow          = true
theme.glow_color           = "#0B0C0E"
theme.naughty_bg           = theme.bg_alternate
theme.naughty_border_color = theme.fg_normal
theme.bg_dock              = bg_alt
theme.fg_dock_1            = "#D6A62D"
theme.fg_dock_2            = "#8B6C1D"
theme.bg_systray           = theme.fg_normal
theme.bg_resize_handler    = "#aaaaff55"

theme.systray = blind {
    shape_border_color = icon_grad,
    shape_border_width = 1,
    bg = {
         type  = "linear" ,
         from  = { 0, 0  },
         to    = { 0, 16 },
         stops = {
            { 0, "#141400" },
            { 1, "#18170A" }
         }
    }
}

-- Border
theme.border = blind {
    width  = 1         ,
    normal = "#1F1F1F" ,
    focus  = "#535d6c" ,
    marked = "#91231c" ,
}

theme.alttab_icon_transformation = function(image,data,item)
    return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
end

local function taglist_transform(img,data,item)
    local col = nil
    if item then
        local current_state = item.state._current_key or nil
        local state_name = radical.base.colors_by_id[current_state] or "normal"
        col = theme["taglist_icon_color_"..state_name] or item["fg_"..state_name]
    else
        col = theme.icon_mask --HACK
    end
    return pixmap(img) : colorize(col) : resize_center(1,taglist_height,taglist_height) : shadow() : to_img()
end

-- Taglist
theme.taglist = blind {
    bg = blind {
        hover     = wipat("#19324E") : stripe("#132946", nil, 7, 7) : TDPat(),
        selected  = wipat("#7A7A00") : TDPat(),
        used      = wipat("#5F5F00") : checkerboard("#3A3B23", 2  ) : TDPat(),
        urgent    = wipat("#5B0000") : stripe("#300000", nil, 1, 2) : TDPat(),
        changed   = wipat("#623100") : checkerboard("#4F4005", 2  ) : TDPat(),
        empty     = bg_normal,
        highlight = "#bbbb00"
    },
    fg = blind {
        empty     = wipat("#B79C00") : TDPat(),
        selected  = wipat("#111111") : TDPat(),
        used      = "#dddddd",
        urgent    = "#FF7777",
        changed   = wipat("#D0B100") : TDPat(),
        highlight = "#000000",
        prefix    = "#9C8531",
    },
--     default_item_margins = {
--         LEFT = 20,
--     },
    custom_color         = function (col) return wipat(col) : TDPat() end,
    default_icon         = path .."Icon/tags_invert/other.png",
    icon_transformation  = taglist_transform,
    item_style           = radical.item.style.slice_prefix,
}
theme.taglist_bg = wipat("#070A0C") : TDPat()

-- Tasklist
theme.tasklist = blind {
    underlay_bg = blind {
        urgent      = "#ff0000",
        minimized   = "#4F269C",
        focus       = bg_under ,
    },
    bg_minimized            = wipat("#0E0027") : stripe("#04000E", nil, 1, 2) : TDPat(),
    bg_urgent               = wipat("#5B0000") : stripe("#070016", nil, 1, 2) : TDPat(),
    bg_hover                = wipat("#19324E") : stripe("#132946", nil, 7, 7) : TDPat(),
    bg_used                 = common_3d(pattern("#151515") : checkerboard("#0B0B0B", 2)),
    bg_focus                = bg_focus,
    fg_minimized            = "#985FEE",
    fg_focus                = "#EDAB3D",
    default_icon            = path .."Icon/tags_invert/other.png",
    bg                      = "#00000088",
    icon_transformation     = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path),
    item_style = radical.item.style {
        shape = shape.octogon,
        shape_args = {7},
        margins = {
            LEFT   = 5,
            RIGHT  = 5,
            TOP    = 0,
            BOTTOM = 0,
        }
    },
    item_border_width = 1,
    item_border_color = wipat("#B79C00") : TDPat(),
    spacing = 10,
}


-- Menu
theme.menu = blind {
    submenu_icon = path .."Icon/tags_invert/arrow.png",
    height       = 20,
    width        = 170,
    border_width = 2,
    opacity      = 0.9,
    fg_normal    = "#ffffff",
    bg = blind {
        focus    = pattern("#594504") : checkerboard("#442E02") : grow(20, 20) : threeD() : to_pattern(),
        header   = color.create_png_pattern(path .."Icon/bg/menu_bg_header_scifi.png"),
        normal   = bg_alt,
        highlight= color.create_png_pattern(path .."Icon/bg/menu_bg_highlight.png"   ),
    },
    border_color = theme.fg_normal,
}

-- Shorter
theme.shorter = blind {
    bg = pattern("#0C0C0C") : checkerboard("#1A1A1A",4) : to_pattern(),
}

-- Toolbox
theme.toolbox_icon_transformation =  function(image,data,item)
    return pixmap(image) : colorize(theme.icon_mask) : to_img()
end

-- Titlebar
theme.titlebar = blind {
    bg_normal = bg_normal,
    bg_focus  = bg_normal,
    icon_fg   = {
        type = "linear", from = { 0, 0 }, to = { 0, 16 }, stops = { { 0, "#FFD503" }, { 1, "#A18601" }}
    }
}
loadfile(theme.path .."bits/titlebar_minde.lua")(theme,path)

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

-- Textbox glow
loadfile(theme.path .."bits/textbox/shadow.lua")(theme,path)

-- The separator theme
require( "chopped.slice" )

-- Add round corner to floating clients
loadfile(theme.path .."bits/client_shape.lua")(3)

return theme
