local capi       = {screen = screen}
local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local blind      = require( "blind"          )
local radical    = require( "radical"        )
local debug      = debug
local cairo      = require( "lgi"            ).cairo
local pango      = require( "lgi"            ).Pango
local pattern2   = require( "blind.common.pattern2" )
local wibox_w    = require( "wibox.widget"   )
local pixmap     = require( "blind.common.pixmap")
local wall       = require( "gears.wallpaper" )
local debug      = debug
local shape      = require( "gears.shape")

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

local default_height = 16

theme.default_height = default_height

local function wipat(base)
    return pattern2(base) : grow(default_height, default_height)
end

theme.path = path

theme.font = "Neuropolitical, Semibold 7.5"
-- theme.font = "Roboto, Medium 8"
-- theme.font = "Radio Space, Regular 8"

local hover_pat = wipat("#1E3D5F") : stripe("#132946", nil, 10, 10) : noise("#4A5D72", 0.65) : to_pattern()

-- Background
theme.bg = blind {
    normal      = "#000000",
    focus       = "#496477",
    urgent      = "#5B0000",
    minimize    = "#040A1A",
    highlight   = "#0E2051",
    alternate   = "#081B37",
    prefix      = wipat("#081B37") : noise("#4A5D72", 0.65) : to_pattern(),
    allinone    = {
        type  = "linear" ,
        from  = { 0, 0  },
        to    = { 0, 20 },
        stops = {
            { 0, "#1D4164" },
            { 1, "#0D2144" }
        }
    },
    systray     = theme.fg_normal,
    systray_alt = hover_pat,
}

-- Wibar background
local bargrad = {
    type  = "linear",
    from  = { 0, 0  },
    to    = { 0, 16 },
    stops = {
        { 0, "#000000" },
        { 1, "#040405" }
    }
}

theme.bar_bg = blind {
    alternate = wipat("#081B37") : noise ("#AAAACC", 0.04     ) : to_pattern(),
    normal    = wipat(bargrad  ) : stripe("#1C1C22", nil, 1, 2) : to_pattern(),
    buttons   = wipat("#00091A") : stripe("#04204F", nil, 1, 2) : to_pattern(),
}

-- Forground
theme.fg = blind {
    normal      = "#6DA1D4",
    focus       = "#ABCCEA",
    urgent      = "#FF7777",
    minimize    = "#1577D3",
}

-- Other
theme.awesome_icon         = path .."Icon/awesome2.png"
theme.systray_icon_spacing = 4
theme.systray_icon_fg      = theme.bg_normal
theme.separator_color      = hover_pat
theme.button_bg_normal     = pattern2("#00091A") : grow(default_height, default_height) : stripe("#04204F", nil, 1, 2) : to_pattern()
theme.enable_glow          = true
theme.glow_color           = "#105A8B"
theme.naughty_bg           = theme.bg_alternate
theme.naughty_border_color = theme.fg_normal
theme.notification_bg           = theme.bg_alternate
theme.notification_border_color = theme.fg_normal
theme.bg_dock              = pattern2() : grid("#6DA1D422", 10) : to_pattern()
theme.fg_dock_1            = "#1889F2"
theme.fg_dock_2            = "#1889F2"

-- Border
theme.border = blind {
    width  = 0              ,
    normal = "#000000"      ,
    focus  = "#000000"      ,
    marked = "#91231c"      ,
}
theme.useless_gap = 5

theme.alttab_icon_transformation = function(image,data,item)
    return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
end

local function taglist_transform(img,data,item)
    return pixmap(img) : colorize("#000000") : resize_surface(6,0) : glow(4, theme.glow_color, nil, true) : to_img()
end

-- Taglist
theme.taglist = blind {
    bg = blind {
        hover     = hover_pat,
        selected  = wipat("#0D3685") : stripe("#05297F", nil, 2 , 4 ) : to_pattern(),
        used      = wipat("#00143B") : stripe("#052F77", nil, 1 , 2 ) : to_pattern(),
        urgent    = wipat("#5B0000") : stripe("#300000", nil, 1 , 2 ) : to_pattern(),
        changed   = wipat("#4D004D") : stripe("#210021", nil, 1 , 2 ) : to_pattern(),
        empty     = wipat("#090B10") : stripe("#181E39", nil, 1 , 2 ) : to_pattern(),
        highlight = "#bbbb00"
    },
    fg = blind {
        selected  = "#ffffff",
        used      = "#7EA5E3",
        urgent    = "#FF7777",
        changed   = "#B78FEE",
        highlight = "#000000",
        prefix    = "#000000",
    },
    default_icon         = path .."Icon/tags_invert/other.png",
    border_width         = 2,
    border_color         = "#ff0000",
    item_border_width    = 2,
    item_border_color    = "#7AB4ED",
    icon_transformation  = taglist_transform,
    default_item_margins = {
        LEFT   = 0,
        RIGHT  = 2,
        TOP    = 0,
        BOTTOM = 0,
    }
}

-- Tasklist
theme.tasklist = blind {
    underlay_bg = blind {
        urgent    = "#ff0000",
        minimized = "#4F269C",
        focus     = "#0746B2",
    },
    bg = blind {
        minimized      = wipat("#0E0027") : stripe("#04000E", nil, 1 , 2 ) : to_pattern(),
        image_selected = wipat("#00091A") : stripe("#04204F", nil, 1 , 2 ) : to_pattern(),
        urgent         = wipat("#5B0000") : stripe("#300000", nil, 1 , 2 ) : to_pattern(),
        focus          = wipat("#00143B") : stripe("#052F77", nil, 1 , 2 ) : to_pattern(),
        hover          = hover_pat,
    },
    fg_minimized        = "#985FEE",
    default_icon        = path .."Icon/tags_invert/other.png",
    icon_transformation = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path),
    border_color = blind {
        focus     = theme.fg_normal,
        hover     = theme.fg_normal,
        minimized = "#4C0D8A",
    },
    item_border_width = 1,
    item_border_color = "#111111",
    item_style = radical.item.style.arrow_single,
}
theme.tasklist_bg = wipat("#22222A"): stripe(nil,default_heightnil, 1, 2) : to_pattern()

-- Bottom menu
theme.bottom_menu = blind {
    item_border_width = 1,
    item_border_color = theme.fg_normal,
    icon_transformation = function(icon,data,item)
        return color.apply_mask(icon,theme.button_bg_normal or theme.bg_normal)
    end
}


-- Menu
theme.menu = blind {
    height       = 20 ,
    width        = 170,
    border_width = 2  ,
    opacity      = 0.9,
    fg = blind {
        normal   = theme.fg_normal,
        focus    = "#ffffff"      ,
    },
    bg = blind {
        focus     = theme.tasklist_bg_hover,
        header    = wipat("#70A5D999") : stripe("#618FBC", nil, 7, 7) : to_pattern(),
        normal    = wipat("#06070B99") : stripe("#12162B", nil, 1, 2) : to_pattern(),
        highlight = wipat("#0B1B4599") : stripe("#0E245F", nil, 3, 1) : to_pattern(),
    },
    border_color = "#7AB4ED",
    checkbox_style       = "holo",
    item_border_width = 1,
    item_border_color = color.transparent,
    border_color_focus = theme.fg_normal,
    default_item_style = radical.item.style {
        shape = shape.octogon,
        shape_args = {7},
        margins = {
            LEFT   = 5,
            RIGHT  = 5,
            TOP    = 0,
            BOTTOM = 0,
        }
    },
    default_margins  = {
        LEFT   = 10,
        RIGHT  = 10,
        TOP    = 0,
        BOTTOM = 0,
    }
}

-- Toolbox
theme.toolbox_icon_transformation = taglist_transform
theme.toolbox_default_item_margins = {
    LEFT   = 2,
    RIGHT  = 2,
    TOP    = 2,
    BOTTOM = 2,
}
theme.toolbox_default_margins = {
    TOP    = 1,
    BOTTOM = 1,
    RIGHT  = 0,
    LEFT   = 0,
}
theme.toolbox_spacing = 3
theme.toolbox_item_style = radical.item.style {
    shape = shape.rounded_bar,
    margins = {
        LEFT   = 5,
        RIGHT  = 5,
        TOP    = 1,
        BOTTOM = 1,
    }
}

local dock_fg_normal_cache = {}
local dock_fg_focus_cache  = {}

theme.dock_icon_transformation = function(img,data,item)
    local state_name = radical.base.colors_by_id[item.state._current_key],item.state._current_key

    if state_name == "focus" then
        if not dock_fg_focus_cache[item] then
            dock_fg_focus_cache[item] = pixmap(img) : colorize("#000000") : resize_surface(6,4) : glow(7, "#1475B4", nil, true) : to_img()
        end

        return dock_fg_focus_cache[item]
    end

    if not dock_fg_normal_cache[item] then
        dock_fg_normal_cache[item] = pixmap(img) : colorize("#83C2FF55") : resize_surface(6,4) : glow(7, "#1475B4", nil, true) : to_img()
    end

    return dock_fg_normal_cache[item]
end
theme.dock_icon_per_state = true
theme.dock_always_show = true
theme.dock_margin = 0
theme.dock_shape = shape.rectangle

-- Shorter
theme.shorter = blind {
    bg = "#00000000",
    border_width = 0,
}

theme.infoshape = blind {
   shape_bg = theme.bg_alternate,
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

theme.slider = blind {
    bar = blind {
        shape        = shape.rounded_rect,
        height       = 3,
        color        = theme.fg_normal,
--         border_color = theme.fg_normal,
--         border_width = 2,
    },
    handle = blind {
        color = theme.bg_prefix,
        shape = shape.circle,
        border_color = theme.fg_normal,
        border_width = 1,
    },
}

theme.tabbar = blind {
    client = blind {
        shape = shape.hexagon,
        shape_border_color = theme.fg_normal,
        shape_border_width = 1,
        bg = blind {
            normal = theme.tasklist_bg,
            active = theme.tasklist_bg_focus,
        },
    },
    spacing = 5,
    bg = color.transparent,
}

-- Titlebar
loadfile(theme.path .."bits/titlebar_retro.lua")(theme,path)
theme.titlebar_show_icon = true
theme.titlebar_show_underlay = true
theme.titlebar_bg = "#ff00ff00"
theme.titlebar_bg_title_active = wipat("#46206F"  ) : noise("#4A5D72", 0.25) : to_pattern()
theme.titlebar_fg_title_active= "#000000"
theme.titlebar_bg_title_normal = wipat("#081B37"  ) : noise("#4A5D72", 0.25) : to_pattern()

-- Layouts icons
loadfile(theme.path .."bits/layout.lua")(theme,path)

-- Textbox glow
loadfile(theme.path .."bits/textbox/glow.lua")(theme,path)

-- The separator theme
require( "chopped.arrow" )

-- The wallpaper
local wall_pat = pattern2("#000000") : grid("#6DA1D422", 10)  : grid("#6DA1D455", 50, 2) : to_pattern()
for s=1, capi.screen.count() do
    local geo = capi.screen[s].geometry
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, geo.width, geo.height)
    local cr  = cairo.Context(img)
    cr:set_source(wall_pat)
    cr:paint()
    wall.centered(img, s)
end

return theme
