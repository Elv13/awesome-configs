local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local themeutils = require( "blind.common.drawing"    )
local blind      = require( "blind"          )
local radical    = require( "radical"        )
local debug      = debug

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.default_height = 20
-- theme.font           = "ohsnap 8"
theme.font           = "Sans DemiBold 8"
-- theme.font           = "-*-Terminus sans medium-r-normal--*-30-*-*-*-*-iso10646-1"
-- theme.font           = "Terminus 8 bold"
theme.path           = path

theme.bg = blind {
    normal      = "#000000",
    focus       = "#496477",
    urgent      = "#5B0000",
    minimize    = "#040A1A",
    highlight   = "#0E2051",
    alternate   = "#101010",
    allinone    = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#1D4164" }, { 1, "#0D2144" }}}
}

theme.fg = blind {
    normal   = "#6DA1D4",
    focus    = "#ABCCEA",
    urgent   = "#FF7777",
    minimize = "#1577D3",
}

theme.bg_systray     = theme.fg_normal


theme.button_bg_normal            = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       )

--theme.border_width  = "1"
--theme.border_normal = "#555555"
--theme.border_focus  = "#535d6c"
--theme.border_marked = "#91231c"

theme.border_width   = "0"
theme.border_normal  = "#1F1F1F"
theme.border_focus   = "#535d6c"
theme.border_marked  = "#91231c"
theme.enable_glow    = false
theme.glow_color     = "#105A8B"

theme.alttab_icon_transformation = function(image,data,item)
--     return themeutils.desaturate(surface(image),1,theme.default_height,theme.default_height)
    return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
end

theme.icon_grad        = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#8AC2D5" }, { 1, "#3D619C" }}}
theme.icon_mask        = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#8AC2D5" }, { 1, "#3D619C" }}}
-- theme.icon_grad        = "#14617A"
-- theme.icon_mask        = "#2EACDA"
theme.icon_grad_invert = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#000000" }, { 1, "#112543" }}}

theme.bottom_menu_item_style = radical.item.style.slice_prefix


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                       TAGLIST/TASKLIST                                           --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- Display the taglist squares
-- theme.taglist_underline                = "#094CA5"

theme.taglist = blind {

    bg = blind {
        unused    = "#ffffff",
        empty     = "#111111",
        hover     = color.create_png_pattern(path .."Icon/bg/menu_bg_focus_scifi.png" ),
        selected  = color.create_png_pattern(path .."Icon/bg/menu_bg_selected_scifi.png"),
        cloned    = color.create_png_pattern(path .."Icon/bg/used_bg_green2.png"),
        used      = color.create_png_pattern(path .."Icon/bg/selected_bg_scifi_focus.png"),
        urgent    = color.create_png_pattern(path .."Icon/bg/urgent_bg.png"),
        changed   = color.create_png_pattern(path .."Icon/bg/selected_bg_scifi_changed.png"),
        highlight = "#bbbb00",
    },

    fg = blind {
        selected  = "#ffffff",
        cloned    = "#00bb00",
        used      = "#7EA5E3",
        urgent    = "#FF7777",
        changed   = "#B78FEE",
        highlight = "#000000",
        prefix    = "#ffffff",
    },

    default = blind {
        item_margins = {
            LEFT   = 2,
            RIGHT  = 8,
            TOP    = 0,
            BOTTOM = 6,
        },
        margins = {
            LEFT   = 2,
            RIGHT  = 20,
            TOP    = 0,
            BOTTOM = 1,
        },
    },

    default_icon = path .."Icon/tags/other.png",
    spacing      = 4,
    item_style   = radical.item.style.holo,
    icon_transformation = function(image,data,item)
        return color.apply_mask(image,color("#8186C3"))
    end
}

theme.tasklist = blind {
    item_style              = radical.item.style.holo_top,

    bg = blind {
        urgent         = color.create_png_pattern(path .."Icon/bg/urgent_bg.png"),
        hover          = color.create_png_pattern(path .."Icon/bg/menu_bg_focus_scifi.png" ),
        focus          = color.create_png_pattern(path .."Icon/bg/selected_bg_scifi_focus.png"),
        image_normal   = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end,
        image_focus    = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_selected)     end,
        image_urgent   = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_urgent)     end,
        image_minimize = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end,
        image_selected = path .."Icon/bg/selected_bg_scifi.png",
        minimized      = "#10002C",
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
            BOTTOM = 0,
        },
        margins = {
            LEFT   = 7,
            RIGHT  = 7,
            TOP    = 1,
            BOTTOM = 0,
        },
    },

    fg_minimized        = "#985FEE",
    default_icon        = path .."Icon/tags/other.png",
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
theme.bg_dock                   = color.create_png_pattern(path .."Icon/bg/bg_dock.png"             )
theme.fg_dock_1                 = "#1889F2"
theme.fg_dock_2                 = "#0A3E6E"

theme.draw_underlay = themeutils.draw_underlay

theme.menu = blind {
    submenu_icon         = path .."Icon/tags/arrow.png",
    height               = 20,
    width                = 170,
    border_width         = 2,
    opacity              = 0.9,
    fg_normal            = "#ffffff",

    bg = blind {
        focus     = color.create_png_pattern(path .."Icon/bg/menu_bg_focus_scifi.png" ),
        header    = color.create_png_pattern(path .."Icon/bg/menu_bg_header_scifi.png"),
        normal    = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       ),
        highlight = color.create_png_pattern(path .."Icon/bg/menu_bg_highlight.png"   ),
    }
}


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                             TITLEBAR                                             --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- Titlebar
loadfile(theme.path .."bits/titlebar.lua")(theme,path)

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

require( "chopped.slice" )

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
