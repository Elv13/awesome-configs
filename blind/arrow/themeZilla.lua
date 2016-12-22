local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local themeutils = require( "blind.common.drawing"    )
local blind      = require( "blind"          )
local radical    = require( "radical"        )
local debug      = debug
local cairo      = require( "lgi"            ).cairo
local pango      = require( "lgi"            ).Pango
local blind_pat  = require( "blind.common.pattern2" )
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

theme.path = path

-- Background
theme.bg = blind {
    normal      = "#000000",
    focus       = "#496477",
    urgent      = "#5B0000",
    minimize    = "#040A1A",
    highlight   = "#0E2051",
    alternate   = "#081B37",
    underlay    = "#191A1E",
    allinone    = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#888888" }, { 1, "#4f4f4f" }}},
}

theme.allinone_margins = 6

-- Wibar background
local bargrad = { type = "linear", from = { 0, 0 }, to = { 0, 16 }, stops = { { 0, "#000000" }, { 1, "#040405" }}}
theme.bar_bg = blind {
    normal    = { type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#4f5962" }, { 1, "#282d32" }}},
    buttons   = { type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#3F474E" }, { 1, "#181B1E" }}},
}
theme.bar_bg_alternate = theme.bar_bg_normal
local normal_underlay = { type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#3F474E" }, { 1, "#181B1E" }}}

-- Forground
theme.fg = blind {
    normal   = "#DDDDDD",
    focus    = "#ABCCEA",
    urgent   = "#FF7777",
    minimize = "#1577D3",
    allinone = "#ADADAD",
}

-- Other
theme.awesome_icon         = path .."Icon/awesome2.png"
theme.systray_icon_spacing = 4
theme.button_bg_normal     = theme.fg_normal
theme.enable_glow          = true
theme.glow_color           = "#00000011"
theme.naughty_bg           = theme.bg_alternate
theme.naughty_border_color = theme.fg_normal
theme.bg_dock              = blind_pat("#2F363B") : grow(default_height, default_height) : noise("#AAAACC", 0.11) : to_pattern()
theme.fg_dock_1            = "#DDDDDD"
theme.fg_dock_2            = "#DDDDDD"
theme.dock_spacing         = 2
theme.dock_icon_transformation = function(image,data,item)
    return pixmap(image) : resize_center(2,30,30) : colorize("#DDDDDD") : shadow() : to_img()
end
theme.bg_systray           = theme.fg_normal
theme.systray_bg_alt       = "#00000000"
theme.systray_icon_fg      = theme.bar_bg_normal
theme.bg_resize_handler    = "#aaaaff55"
theme.allinone_icon        = "#ADADAD99"

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

theme.icon_grad        = blind_pat("#507289") : grow(default_height, default_height) : noise("#777788", 0.4) : to_pattern()
theme.icon_mask        = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#8AC2D5" }, { 1, "#3D619C" }}}
theme.icon_grad_invert = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#000000" }, { 1, "#112543" }}}

local taglist_height = (default_height-4)
local taglist_grad_px = 1/taglist_height

local function taglist_transform(img,data,item)
    local col = nil
    if item then
        local current_state = item.state._current_key or nil
        local state_name = radical.base.colors_by_id[current_state] or "normal"
        col = theme["taglist_icon_color_"..state_name] or item["fg_"..state_name]
    else
        col = "#b8c7d1ff" --HACK
    end
    return pixmap(img) : colorize(col) : resize_center(2,taglist_height,taglist_height) : shadow() : to_img()
end

local used_bg = { type = "linear", from = { 0, 0 }, to = { 0, taglist_height },
    stops = {
    { 0, "#252a2fff" }, 
    { taglist_grad_px, "#252a2fff" },
    { taglist_grad_px,"#25282dff"},
    {0.35, "#3d444dff"},
    {(taglist_height-1)*taglist_grad_px,"#444c54ff"},
    {(taglist_height-1)*taglist_grad_px,"#202428ff"},
    {1,"#202428ff"},
}}

local selected_bg = { type = "linear", from = { 0, 0 }, to = { 0, taglist_height },
    stops = {
    { 0, "#252a2fff" }, 
    { taglist_grad_px, "#252a2fff" },
    { taglist_grad_px,"#1a1c20ff"},
    {(taglist_height-1)*taglist_grad_px,"#313539ff"},
    {(taglist_height-1)*taglist_grad_px,"#202428ff"},
    {1,"#202428ff"},
}}

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

        selected  = selected_bg,

        used      = used_bg,
        urgent    = used_bg,
        changed   = used_bg,
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

    index_prefix = "<b>",
    index_suffix = ":</b>",

    index_fg = blind {
        focus = "#148bf5ff",
        empty = "#CECECE",
        used  = "#428FD7",
        changed   = "#8C58EE",
    },

    icon_color = blind {
        focus = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#48c2ffff" }, { 1, "#0375aeff" }}},
    },
    icon_per_state = true,
    custom_color = function (...) blind_pat(...) : to_pattern() end,
    default_icon       = path .."Icon/tags_invert/other.png",
    index_per_state = true,
    icon_transformation     = taglist_transform,
}
theme.taglist_item_style     = radical.item.style.arrow_3d
-- theme.taglist_style = radical.style.grouped_3d
theme.taglist_bg                 = "#00000000"
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

-- Toolbox

local function toolbox_transform(img,data,item)
    return pixmap(img):colorize("#a0aab5ff"):resize_center(2,taglist_height,taglist_height):shadow():to_img()
end

theme.toolbox = blind {
    icon_transformation = toolbox_transform,
    item_style          = radical.item.style.line_3d,
    bg={ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#3F474E" }, { 1, "#181B1E" }}},
    bg_focus={ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#282d32" }, { 1, "#4f5962" }}},
    style = radical.style.grouped_3d,
    fg_hover = "#ffffff",
    border_color = color{ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#282d32" }, { 1, "#4f5962" }}},
    item_border_color = "#666666",
    bg_used  = color.transparent,
    default_item_margins = {
        LEFT   = 3,
        RIGHT  = 3,
        TOP    = 3,
        BOTTOM = 3,
    },
    default_margins = {
        TOP    = 2,
        BOTTOM = 1,
        RIGHT  = 5,
        LEFT   = 5,
    }
}
theme.bg_systray_alt =color.transparent
theme.systray_bg ={ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#3F474E" }, { 1, "#181B1E" }}}



-- Tasklist
theme.tasklist = blind {
    underlay_bg_urgent      = "#ff0000",
    underlay_bg_minimized   = "#4F269C",
    underlay_bg_            = normal_underlay,
--     bg_image_selected       = d_mask(blind_pat.sur.flat_grad("#00091A","#04204F",default_height)),
--     bg_minimized            = d_mask(blind_pat.sur.flat_grad("#0E0027","#04000E",default_height)),
    fg_minimized            = "#985FEE",
--     bg_urgent               = d_mask(blind_pat.sur.flat_grad("#5B0000","#070016",default_height)),
    bg_hover                = theme.bar_bg_normal,
    bg_focus                = theme.taglist_bg_selected,
    bg_used                 = "#00000011",
    fg_focus                = "#148bf5ff",
    default_icon            = path .."Icon/tags_invert/other.png",
--     bg                      = "#ff0000",
    icon_transformation     = loadfile(theme.path .."bits/icon_transformation/state.lua")(theme,path),
    item_style              = radical.item.style.rounded_shadow,
    spacing                 = 6,
    fg                      = "#ff0000",
    item_border_color       = "#666666"
}

theme.tasklist_default_item_margins = {
    LEFT   = 4,
    RIGHT  = 4,
    TOP    = 1,
    BOTTOM = 1,
}
theme.tasklist_default_margins = {
    LEFT   = 5,
    RIGHT  = 5,
    TOP    = 3,
    BOTTOM = 3,
}


-- Menu
theme.menu = blind {
    submenu_icon = path .."Icon/tags_invert/arrow.png",
    height       = 20,
    width        = 170,
    border_width = 2,
    opacity      = 0.9,
    fg_normal    = "#ffffff",
    fg_focus     = "#148bf5ff",
    bg_focus     = selected_bg,
    bg_header    = color.create_png_pattern(path .."Icon/bg/menu_bg_header_scifi.png"),
    bg_normal    = blind_pat("#2F363B") : grow(default_height, default_height) : noise("#AAAACC", 0.06) : to_pattern(),
    bg_highlight = color.create_png_pattern(path .."Icon/bg/menu_bg_highlight.png"   ),
    item_style   = radical.item.style.classic,
    border_color = "#828282",
    item_border_color = "#21262A",
}

-- theme.bottom_menu_style      = radical.style.grouped_3d
theme.bottom_menu_item_style = radical.item.style.rounded_shadow
theme.bottom_menu_spacing    = 4
theme.bottom_menu_bg = "#00000000"
theme.bottom_menu_item_border_color = color{ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#5F6B76" }, { 1, "#30363C" }}}
theme.bottom_menu_icon_transformation = function(img,data,item)
    local col = color(theme.taglist_fg_empty)
    return pixmap(img) : colorize(col) : resize_center(2,taglist_height-6,taglist_height-6) : shadow() : to_img()
end

theme.bottom_menu_default_item_margins = {
    LEFT   = 5,
    RIGHT  = 5,
    TOP    = 2,
    BOTTOM = 2,
}

theme.bottom_menu_default_margins = {
    LEFT   = 7,
    RIGHT  = 17,
    TOP    = 2,
    BOTTOM = 2,
}

-- Shorter
theme.shorter = blind {
--     bg = blind_pat.to_pattern(blind_pat.mask.noise(0.14,"#AAAACC", blind_pat.mask.triangle(80,3,{color("#0D1E37"),color("#122848")},"#25324A",blind_pat.sur.plain("#081B37",80))))
    bg = blind_pat("#2F363B") : grow(default_height, default_height) : noise("#AAAACC", 0.11) : to_pattern()
}

-- Titlebar
theme.titlebar = blind {
    bg_focus  = theme.bar_bg_normal,
    bg_normal  = { type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#373E44" }, { 1, "#101214" }}},
    height    = 18,
    bg = blind {
        inactive = color{ type = "linear", from = { 0, 0 }, to = { 0, 12 }, stops = { { 0, "#5F6A76" }, { 1, "#3C444B" }}},
        active   = color{ type = "linear", from = { 0, 0 }, to = { 0, 12 }, stops = { { 0, "#5F6A76" }, { 1, "#3C444B" }}},
        hover    = color{ type = "linear", from = { 0, 0 }, to = { 0, 12 }, stops = { { 0, "#5F6A76" }, { 1, "#3C444B" }}},
        pressed  = "#ffff00",
    },
    border_color = blind {
        inactive = color{ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#3B434A" }, { 1, "#282d32" }}},
        active   = color{ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#3B434A" }, { 1, "#282d32" }}},
        hover    = color{ type = "linear", from = { 0, 0 }, to = { 0, default_height }, stops = { { 0, "#3B434A" }, { 1, "#282d32" }}},
        pressed  = "#ffffff",
    },
    underlay_bg = normal_underlay,
    icon_active = theme.taglist_icon_color_focus
}

theme.separator_color = "#49535B"

theme.useless_gap = 7
theme.titlebar_bottom = true

loadfile(theme.path .."bits/titlebar_square.lua")(theme,path)

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

-- Textbox glow
loadfile(theme.path .."bits/textbox/shadow.lua")(theme,path)

-- The separator theme
require( "chopped.circle" )

-- Add round corner to floating clients
loadfile(theme.path .."bits/client_shape.lua")(6,true,true)

return theme
