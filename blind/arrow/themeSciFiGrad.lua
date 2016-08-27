local color      = require( "gears.color"    )
local shape      = require( "gears.shape"    )
local surface    = require( "gears.surface"  )
local blind      = require( "blind"          )
local radical    = require( "radical"        )
local debug      = debug
local pixmap     = require( "blind.common.pixmap")
local pattern2   = require( "blind.common.pattern2")

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

local default_height = 16

-- theme.font = "Nimbus Sans, 9"

theme.default_height = default_height

-- Mutualize some repetitive code
function pattern2:TDPat()
    return self : threeD() : to_pattern()
end

local function wipat(base)
    return pattern2(base) : grow(default_height, default_height)
end

theme.path = path

-- Background
theme.bg = blind {
    normal      = "#000000",
    focus       = "#496477",
    urgent      = "#5B0000",
    minimize    = "#040A1A",
    highlight   = "#0E2051",
    alternate   = "#081B37",
    allinone    = {
        type  = "linear" ,
        from  = { 0, 0  },
        to    = { 0, 20 },
        stops = {
            { 0, "#1D4164" },
            { 1, "#0D2144" }
        }
    },
}

-- Wibar background
local bargrad = {
    type  = "linear" ,
    from  = { 0, 0  },
    to    = { 0, 16 },
    stops = {
        { 0, "#000000" },
        { 1, "#040405" }
    }
}

-- Wibar background
theme.bar_bg = blind {
    alternate = wipat("#081B37") : noise ("#AAAACC", 0.04     ) : TDPat(),
    normal    = wipat(bargrad  ) : stripe("#26262F", nil, 1, 2) : TDPat(),
    buttons   = wipat("#00091A") : stripe("#04204F", nil, 1, 2) : TDPat(),
}

-- Forground
theme.fg = blind {
    normal   = "#6DA1D4",
    focus    = "#ABCCEA",
    urgent   = "#FF7777",
    minimize = "#1577D3",
}

-- Other
theme.icon_grad = wipat("#507289") : noise("#777788", 0.4) : TDPat()
theme.awesome_icon         = path .."Icon/awesome2.png"
theme.systray_icon_spacing = 4
theme.button_bg_normal     = pattern2("#00091A") : grow(default_height, default_height) : stripe("#04204F", nil, 1, 2) : to_pattern()
theme.enable_glow          = true
theme.glow_color           = "#105A8B"
theme.naughty_bg           = theme.bg_alternate
theme.naughty_border_color = theme.fg_normal
theme.bg_dock              = color.create_png_pattern(path .."Icon/bg/bg_dock.png"             )
theme.fg_dock_1            = "#1889F2"
theme.fg_dock_2            = "#0A3E6E"
theme.bg_systray           = theme.fg_normal
theme.bg_systray_alt       = theme.icon_grad
theme.bg_resize_handler    = "#aaaaff55"
theme.prompt_fg            = theme.bg_normal

theme.systray = blind {
    shape_border_color = icon_grad,
    shape_border_width = 1,
    bg = {
         type  = "linear" ,
         from  = { 0, 0  },
         to    = { 0, 16 },
         stops = {
            { 0, "#030B17" },
            { 1, "#081B37" }
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


theme.icon_mask = {
    type  = "linear",
    from  = { 0, 0 },
    to    = { 0, 20 },
    stops = {
        { 0, "#8AC2D5" },
        { 1, "#3D619C" }
    }
}

theme.icon_grad_invert = {
    type  = "linear" ,
    from  = { 0, 0  },
    to    = { 0, 20 },
    stops = {
        { 0, "#000000" },
        { 1, "#112543" }
    }
}

local function taglist_transform(img,data,item)
    local col = {
        type  = "linear" ,
        from  = { 0, 0  },
        to    = { 0, 20 },
        stops = {
            { 0, "#2A3F77" },
            { 1, "#000000" }
        }
    }

    return pixmap(img) : colorize(col) : to_img()
end

-- Taglist
theme.taglist = blind {
    bg = blind {
        hover     = wipat("#19324E") : stripe("#132946", nil, 7, 7) : TDPat(),
        selected  = wipat("#0D3685") : stripe("#05297F", nil, 2, 4) : TDPat(),
        used      = wipat("#00143B") : stripe("#052F77", nil, 1, 2) : TDPat(),
        urgent    = wipat("#5B0000") : stripe("#300000", nil, 1, 2) : TDPat(),
        changed   = wipat("#4D004D") : stripe("#210021", nil, 1, 2) : TDPat(),
        empty     = wipat("#090B10") : stripe("#181E39", nil, 1, 2) : TDPat(),
        highlight = "#bbbb00"
    },
    fg = blind {
        selected  = "#ffffff",
        used      = "#7EA5E3",
        urgent    = "#FF7777",
        changed   = "#B78FEE",
        highlight = "#000000",
        prefix    = theme.bg_normal,
    },
    custom_color        = function (col) return pattern2(col) : TDPat() end,
    default_icon        = path .."Icon/tags_invert/other.png",
    icon_transformation = taglist_transform,
}
theme.taglist_bg = wipat("#070A0C") : TDPat()

-- Tasklist
theme.tasklist = blind {
    underlay_bg = blind {
        urgent    = "#ff0000",
        minimized = "#4F269C",
        focus     = "#0746B2",
    },

    bg = blind {
        minimized = wipat("#14003A") : stripe("#0A090B", nil, 1, 2) : TDPat(),
        urgent    = wipat("#5B0000") : stripe("#070016", nil, 1, 2) : TDPat(),
        hover     = wipat("#19324E") : stripe("#132946", nil, 7, 7) : TDPat(),
        focus     = wipat("#00143B") : stripe("#052F77", nil, 1, 2) : TDPat(),
        used      = wipat("#070709") : stripe("#232434", nil, 1, 2) : TDPat(),
        overlay   = theme.fg_normal,
    },

    border_color = blind {
        focus     = theme.icon_grad,
        hover     = theme.icon_grad,
        used      = wipat("#374E5E") : noise("#52525E", 0.4) : TDPat(),
        minimized = wipat("#4C0D8A") : TDPat(),
    },
    spacing             = 4,
    default_icon        = path .."Icon/tags_invert/other.png",
    fg_minimized        = "#985FEE",
    icon_transformation = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path),
    item_border_width   = 1,
}
theme.tasklist_default_margins = {
    LEFT   = 5,
    RIGHT  = 5,
    TOP    = 0,
    BOTTOM = 0,
}

theme.tasklist_bg = "#00000088"
theme.tasklist_item_border_color = "#00000000"

-- Bottom menu
theme.bottom_menu_icon_transformation = function(icon,data,item)
    return color.apply_mask(icon,theme.button_bg_normal or theme.bg_normal)
end
theme.bottom_menu_border_width =1
theme.bottom_menu_border_color = icon_grad

-- Menu
theme.menu = blind {
--     submenu_icon = path .."Icon/tags_invert/arrow.png",
    height       = 20,
    width        = 170,
    border_width = 2,
    opacity      = 0.9,
    fg_normal    = "#ffffff",
    bg_focus     = wipat("#00143B") : stripe("#052F77", nil, 1, 2) : to_pattern(),
    bg_header    = wipat("#70A5D9") : stripe("#618FBC", nil, 7, 7) : to_pattern(),
    bg_normal    = wipat("#00091A") : stripe("#04204F", nil, 1, 2) : to_pattern(),
    bg_highlight = wipat("#0B1B45") : stripe("#0E245F", nil, 3, 1) : to_pattern(),
    border_color = theme.fg_normal,
}

theme.collision = blind {
    resize = blind {
        border_width = 2,
        border_color = theme.fg_normal,
        padding      = 10,
        bg           = wipat("#0D3685") : stripe("#05297F", nil, 2, 4) : to_pattern(),
    },
    focus  = blind {
        border_width = 2,
        border_color = theme.fg_normal,
        padding      = 10,
        bg           = wipat("#0D3685") : stripe("#05297F", nil, 2, 4) : to_pattern(),
        bg_center    = wipat("#AF1B1B") : stripe("#AF4040", nil, 2, 4) : to_pattern(),
    },
    screen = blind {
        border_width = 2,
        border_color = theme.fg_normal,
        padding      = 10,
        bg           = wipat("#0D3685") : stripe("#05297F", nil, 2, 4) : to_pattern(),
        bg_focus    = wipat("#AF1B1B") : stripe("#AF4040", nil, 2, 4) : to_pattern(),
    },
}

-- Shorter
-- theme.shorter = blind {
--     bg = blind_pat.to_pattern(blind_pat.mask.noise(0.14,"#AAAACC", blind_pat.mask.triangle(80,3,{color("#091629"),color("#0E2039")},"#25324A",blind_pat.sur.plain("#081B37",79))))
-- }

theme.infoshape = blind {
   shape_bg = theme.bg_alternate,
}

-- Toolbox
theme.toolbox_icon_transformation =  function(image,data,item)
    return pixmap(image) : colorize(theme.icon_grad) : to_img()
end
theme.toolbox_default_item_margins = {
    LEFT   = 5,
    RIGHT  = 5,
    TOP    = 3,
    BOTTOM = 3,
}
theme.toolbox_default_margins = {
    TOP    = 1,
    BOTTOM = 1,
    RIGHT  = 0,
    LEFT   = 2,
}
theme.toolbox_item_border_width = 1
theme.toolbox_border_color_used = icon_grad
theme.toolbox_spacing = 3
theme.toolbox_bg_used  = theme.systray_bg
theme.toolbox_item_style = radical.item.style {
    shape = shape.rounded_rect,
    shape_args = {4},
    shape_border_color = icon_grad,
    margins = {
        LEFT   = 5,
        RIGHT  = 5,
        TOP    = 1,
        BOTTOM = 1,
    }
}

-- Titlebar
loadfile(theme.path .."bits/titlebar.lua")(theme,path)
theme.titlebar = blind {
    bg_normal = theme.bar_bg_normal,
    bg_focus  = theme.tasklist_bg_focus,
}

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

-- Textbox glow
loadfile(theme.path .."bits/textbox/glow.lua")(theme,path)

-- The separator theme
require( "chopped.arrow" )

-- Add round corner to floating clients
loadfile(theme.path .."bits/client_shape.lua")(3)

return theme
