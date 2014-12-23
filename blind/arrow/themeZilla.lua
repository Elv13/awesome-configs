local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local themeutils = require( "blind.common.drawing"    )
local blind      = require( "blind"          )
local radical    = require( "radical"        )
local debug      = debug
local cairo      = require( "lgi"            ).cairo
local pango      = require( "lgi"            ).Pango
local blind_pat  = require( "blind.common.pattern" )
local wibox_w    = require( "wibox.widget"   )
local pixmap     = require( "blind.common.pixmap")
local debug      = debug

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

local default_height = 24

theme.default_height = default_height

local function d_mask(img,cr)
    return blind_pat.to_pattern(blind_pat.mask.ThreeD(img,cr))
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
    allinone    = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#1D4164" }, { 1, "#0D2144" }}},
}

-- Wibar background
local bargrad = { type = "linear", from = { 0, 0 }, to = { 0, 16 }, stops = { { 0, "#000000" }, { 1, "#040405" }}}
theme.bar_bg = blind {
    alternate = d_mask(blind_pat.mask.noise(0.04,"#AAAACC", blind_pat.sur.plain("#081B37",default_height))),
    normal    = { type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#4f5962" }, { 1, "#282d32" }}},
    buttons   = d_mask(blind_pat.sur.flat_grad("#00091A","#04204F",default_height)),
}

-- Forground
theme.fg = blind {
    normal   = "#6DA1D4",
    focus    = "#ABCCEA",
    urgent   = "#FF7777",
    minimize = "#1577D3",
}

-- Other
theme.awesome_icon         = path .."Icon/awesome2.png"
theme.systray_icon_spacing = 4
theme.button_bg_normal     = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       )
theme.enable_glow          = true
theme.glow_color           = "#00000011"
theme.naughty_bg           = theme.bg_alternate
theme.naughty_border_color = theme.fg_normal
theme.bg_dock              = color.create_png_pattern(path .."Icon/bg/bg_dock.png"             )
theme.fg_dock_1            = "#1889F2"
theme.fg_dock_2            = "#0A3E6E"
theme.bg_systray           = theme.fg_normal
theme.bg_resize_handler    = "#aaaaff55"

-- Border
theme.border = blind {
    width  = 1         ,
    normal = "#1F1F1F" ,
    focus  = "#535d6c" ,
    marked = "#91231c" ,
}

theme.alttab_icon_transformation = function(image,data,item)
--     return themeutils.desaturate(surface(image),1,theme.default_height,theme.default_height)
    return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
end

theme.icon_grad        = d_mask(blind_pat.mask.noise(0.4,"#777788", blind_pat.sur.plain("#507289",default_height)))
theme.icon_mask        = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#8AC2D5" }, { 1, "#3D619C" }}}
theme.icon_grad_invert = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#000000" }, { 1, "#112543" }}}

local taglist_height = (default_height-4)
local taglist_grad_px = 1/taglist_height

-- Taglist
theme.taglist = blind {
    bg = blind {
        hover     ={ type = "linear", from = { 0, 0 }, to = { 0, taglist_height },
            stops = {
                { 0, "#252a2fff" } ,
                { taglist_grad_px  , "#252a2fff" },
                { 2*taglist_grad_px, "#676f78ff" },
                { 2*taglist_grad_px, "#646F78" },
                {(taglist_height-2)*taglist_grad_px,"#4D5662"},
                {(taglist_height-2)*taglist_grad_px,"#444b55ff"},
                {(taglist_height-1)*taglist_grad_px,"#202428ff"},
                {1,"#202428ff"},
            }},

        selected  = { type = "linear", from = { 0, 0 }, to = { 0, taglist_height },
            stops = {
                { 0, "#252a2fff" }, 
                { taglist_grad_px, "#252a2fff" },
                { taglist_grad_px,"#1a1c20ff"},
                {(taglist_height-1)*taglist_grad_px,"#313539ff"},
                {(taglist_height-1)*taglist_grad_px,"#202428ff"},
                {1,"#202428ff"},
            }},

        used      = { type = "linear", from = { 0, 0 }, to = { 0, taglist_height },
            stops = {
                { 0, "#252a2fff" }, 
                { taglist_grad_px, "#252a2fff" },
                { taglist_grad_px,"#25282dff"},
                {0.35, "#3d444dff"},
                {(taglist_height-1)*taglist_grad_px,"444c54ff"},
                {(taglist_height-1)*taglist_grad_px,"#202428ff"},
                {1,"#202428ff"},
            }},

        urgent    = d_mask(blind_pat.sur.flat_grad("#5B0000","#300000",default_height)),
        changed   = d_mask(blind_pat.sur.flat_grad("#4D004D","#210021",default_height)),
        empty     = { type = "linear", from = { 0, 0 }, to = { 0, taglist_height },
            stops = {
                { 0, "#252a2fff" } ,
                { taglist_grad_px  , "#252a2fff" },
                { 2*taglist_grad_px, "#676f78ff" },
                { 2*taglist_grad_px, "#505960ff" },
                {(taglist_height-2)*taglist_grad_px,"#3b424bff"},
                {(taglist_height-2)*taglist_grad_px,"#444b55ff"},
                {(taglist_height-1)*taglist_grad_px,"#202428ff"},
                {1,"#202428ff"},
            }},

        highlight = "#bbbb00"
    },
    fg = blind {
        selected  = "#65bfffff",
        used      = "#7EA5E3",
        urgent    = "#FF7777",
        changed   = "#B78FEE",
        highlight = "#000000",
        empty     = "#a0aab5ff",
        prefix    = "#CECECE",
    },

    index_prefix = "",
    index_suffix = ":",

    index_fg = blind {
        focus = "#148bf5ff",
        empty = "#CECECE",
        used  = "#428FD7"
    },

    icon_color = blind {
        focus = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#48c2ffff" }, { 1, "#0375aeff" }}},
    },
    icon_per_state = true,
    custom_color = function (...) d_mask(blind_pat.sur.flat_grad(...)) end,
    default_icon       = path .."Icon/tags/other.png",
    index_per_state = true,
    icon_transformation     = function(img,data,item)
        local col = nil
        if item then
            local current_state = item.state._current_key or nil
            local state_name = radical.base.colors_by_id[current_state] or "normal"
            col = theme["taglist_icon_color_"..state_name] or item["fg_"..state_name]
        else
            col = "#b8c7d1ff" --HACK
        end
        return pixmap(img):colorize(col):resize_center(2,taglist_height,taglist_height):shadow():to_img()
    end
}
theme.taglist_item_style     = radical.item.style.arrow_3d
theme.taglist_bg                 = d_mask(blind_pat.sur.plain("#070A0C",default_height))
theme.taglist_default_item_margins = {
    LEFT   = 2,
    RIGHT  = 17,
    TOP    = 2,
    BOTTOM = 2,
}

theme.taglist_default_margins = {
    LEFT   = 15,
    RIGHT  = 20,
    TOP    = 2,
    BOTTOM = 2,
}

-- Tasklist
theme.tasklist = blind {
    underlay_bg_urgent      = "#ff0000",
    underlay_bg_minimized   = "#4F269C",
    underlay_bg_focus       = "#0746B2",
--     bg_image_selected       = d_mask(blind_pat.sur.flat_grad("#00091A","#04204F",default_height)),
    bg_minimized            = d_mask(blind_pat.sur.flat_grad("#0E0027","#04000E",default_height)),
    fg_minimized            = "#985FEE",
    bg_urgent               = d_mask(blind_pat.sur.flat_grad("#5B0000","#070016",default_height)),
    bg_hover                = d_mask(blind_pat.sur.thick_stripe("#19324E","#132946",14,default_height,true)),
    bg_focus                = theme.taglist_bg_selected,
    default_icon            = path .."Icon/tags/other.png",
    bg                      = "#00000088",
    icon_transformation     = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path),
    item_style              = radical.item.style.rounded,
    spacing                 = 6,
}

theme.tasklist_default_item_margins = {
    LEFT   = 2,
    RIGHT  = 17,
    TOP    = 2,
    BOTTOM = 2,
}


-- Menu
theme.menu = blind {
    submenu_icon = path .."Icon/tags/arrow.png",
    height       = 20,
    width        = 170,
    border_width = 2,
    opacity      = 0.9,
    fg_normal    = "#ffffff",
    bg_focus     = color.create_png_pattern(path .."Icon/bg/menu_bg_focus_scifi.png" ),
    bg_header    = color.create_png_pattern(path .."Icon/bg/menu_bg_header_scifi.png"),
    bg_normal    = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       ),
    bg_highlight = color.create_png_pattern(path .."Icon/bg/menu_bg_highlight.png"   ),
    border_color = theme.fg_normal,
}

theme.bottom_menu_style      = radical.style.grouped_3d
theme.bottom_menu_item_style = radical.item.style.rounded
theme.bottom_menu_spacing    = 6
-- theme.bottom_menu_default_item_margins = {
--     LEFT   = 2,
--     RIGHT  = 17,
--     TOP    = 4,
--     BOTTOM = 4,
-- }
theme.bottom_menu_default_margins = {
    LEFT   = 6,
    RIGHT  = 17,
    TOP    = 4,
    BOTTOM = 4,
}

-- Shorter
theme.shorter = blind {
--     bg = blind_pat.to_pattern(blind_pat.mask.noise(0.14,"#AAAACC", blind_pat.mask.triangle(80,3,{color("#0D1E37"),color("#122848")},"#25324A",blind_pat.sur.plain("#081B37",80))))
    bg = blind_pat.to_pattern(blind_pat.mask.noise(0.14,"#AAAACC", blind_pat.mask.triangle(80,3,{color("#091629"),color("#0E2039")},"#25324A",blind_pat.sur.plain("#081B37",79))))
}

-- theme.draw_underlay = themeutils.draw_underlay


-- Titlebar
loadfile(theme.path .."bits/titlebar.lua")(theme,path)
theme.titlebar = blind {
    bg_normal = d_mask(blind_pat.mask.noise(0.02,"#AAAACC", blind_pat.sur.plain("#070A0C",default_height))),
    bg_focus  = d_mask(blind_pat.sur.flat_grad("#2A2A32",nil,default_height))
}

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

-- Textbox glow
loadfile(theme.path .."bits/textbox/shadow.lua")(theme,path)

-- The separator theme
require( "chopped.arrow" )

-- Add round corner to floating clients
loadfile(theme.path .."bits/client_shape.lua")(3)

return theme