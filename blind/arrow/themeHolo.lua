local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local themeutils = require( "blind.common.drawing"    )
local blind      = require( "blind"          )
local radical    = require( "radical"        )
local debug      = debug
local pixmap     = require( "blind.common.pixmap")

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

local default_height = 20
theme.default_height = default_height
theme.font           = "Sans DemiBold 8"
theme.path           = path

theme.bg = blind {
    normal      = "#000000",
    focus       = "#496477",
    urgent      = "#5B0000",
    minimize    = "#040A1A",
    highlight   = "#0E2051",
    alternate   = "#18191B",
    allinone    = "#0F2650"
}

theme.allinone_margins = 3

theme.fg = blind {
    normal   = "#4197D4",
    focus    = "#ABCCEA",
    urgent   = "#FF7777",
    minimize = "#1577D3",
}

theme.bg_systray     = "#1590D7"


theme.button_bg_normal            = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       )

--theme.border_width  = "1"
--theme.border_normal = "#555555"
--theme.border_focus  = "#535d6c"
--theme.border_marked = "#91231c"

theme.border_width   = "0"
theme.border_normal  = theme.fg_normal
theme.border_focus   = theme.fg_normal
theme.border_marked  = "#91231c"
theme.enable_glow    = false
theme.glow_color     = "#105A8B"

theme.alttab_icon_transformation = function(image,data,item)
--     return themeutils.desaturate(surface(image),1,theme.default_height,theme.default_height)
    return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
end

theme.icon_grad        = "#1590D7"
theme.icon_mask        = "#2A72A5"
-- theme.icon_grad        = "#14617A"
-- theme.icon_mask        = "#2EACDA"
theme.icon_grad_invert = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#000000" }, { 1, "#112543" }}}

theme.bottom_menu_item_style = radical.item.style.slice_prefix
theme.bottom_menu_icon_transformation = function(img,data,item)
    return pixmap(img) : colorize(color(theme.bg_alternate)) : to_img()
end

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                       TAGLIST/TASKLIST                                           --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- Display the taglist squares
-- theme.taglist_underline                = "#094CA5"

theme.taglist = blind {

    bg = blind {
        hover     = "#91D1FF",
        selected  = "#00A6FF",
        used      = "#123995",
        urgent    = "#ff0000",
        changed   = "#95127D",
        highlight = "#bbbb00"
    },

    fg = blind {
        selected  = "#ffffff",
--         used      = "#7EA5E3",
        urgent    = "#FF7777",
        changed   = "#B78FEE",
        highlight = "#000000",
        prefix    = theme.bg_normal,
    },

    default = blind {
        item_margins = {
            LEFT   = 3,
            RIGHT  = 4,
            TOP    = 2,
            BOTTOM = 6,
        },
        margins = {
            LEFT   = 2,
            RIGHT  = 20,
            TOP    = 0,
            BOTTOM = 1,
        },
    },

--     default_icon = path .."Icon/tags_invert/other.png",
    disable_icon  = true,
    disable_index = true,
    spacing      = 2,
    item_style   = radical.item.style.holo,
--     icon_transformation = function(image,data,item)
--         return color.apply_mask(image,color("#8186C3"))
--     end
}

theme.tasklist = blind {
    item_style         = radical.item.style.holo_top,

    bg = blind {
        urgent         = "#D30000",
        hover          = "#91D1FF",
        focus          = "#00A6FF",
        image_selected = path .."Icon/bg/selected_bg_scifi.png",
        minimized      = "#200058",
    },

    underlay_bg = blind {
        urgent    = "#ff0000",
        minimized = "#4F269C",
        focus     = "#0746B2",
    },

    default = blind {
        item_margins = {
            LEFT   = 8,
            RIGHT  = 4,
            TOP    = 6,
            BOTTOM = 2,
        },
        margins = {
            LEFT   = 7,
            RIGHT  = 7,
            TOP    = 1,
            BOTTOM = 0,
        },
    },

    fg_minimized        = "#985FEE",
    default_icon        = path .."Icon/tags_invert/other.png",
    spacing             = 4,
    disable_icon        = true,
    plain_task_name     = true,
    icon_transformation = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path)
}


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                               MENU                                               --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.border_width              = 1
theme.border_color              = theme.fg_normal
theme.awesome_icon              = path .."Icon/awesome2.png"
theme.bg_dock                   = "#000000"
theme.fg_dock_1                 = "#1889F2"
theme.fg_dock_2                 = "#0A3E6E"
theme.dock_corner_radius        = 4

theme.menu = blind {
    submenu_icon         = path .."Icon/tags_invert/arrow.png",
    height               = 20,
    width                = 170,
    border_width         = 2,
    opacity              = 0.9,
    fg_normal            = "#ffffff",
    corner_radius        = 5,
    border_color         = "#252525",
    outline_color        = "#B7B7B7",
    table_bg_header      = "#999999",
    checkbox_style       = "holo",
    item_style           = radical.item.style.classic,

    bg = blind {
        focus     = "#14617A",
        header    = "#1A1A1A",
        normal    = "#1A1A1A",
        highlight = "#252525",
    }
}

-- Toolbox
theme.toolbox_default_item_margins = {
    LEFT   = 2,
    RIGHT  = 2,
    TOP    = 2,
    BOTTOM = 2,
}
theme.toolbox_default_margins = {
    TOP    = 2,
    BOTTOM = 2,
    RIGHT  = 0,
    LEFT   = 0,
}

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                             TITLEBAR                                             --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- Titlebar
loadfile(theme.path .."bits/titlebar_round.lua")(theme,path)
theme.titlebar = blind {
    bg_normal = "#000000",
    bg_focus  = "#184E99",
    fg_focus  = "#ffffff",
}

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

theme.useless_gap = 15

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                               DOCK                                               --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.dock_icon_transformation = function(image,data,item) return surface.outline( surface(image), theme.icon_grad) end


require( "chopped.slice" )

-- Add round corner to floating clients
loadfile(theme.path .."bits/client_shape.lua")(8,true,true)

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
