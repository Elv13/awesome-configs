local theme,path = ...
local blind      = require( "blind"          )
local shape      = require( "gears.shape"    )
local pixmap     = require( "blind.common.pixmap")
local pattern2   = require( "blind.common.pattern2")

local function mask_icon(path)
    return pixmap(path) : colorize(theme.icon_grad) : to_img()
end

theme.titlebar = blind {
    close_button = blind {
        normal = path .."Icon/titlebar/close_normal_inactive.png",
        focus  = path .."Icon/titlebar/close_focus_inactive.png",
    },

    ontop_button = blind {
        normal_inactive = mask_icon(path .."Icon/titlebar/ontop_normal_inactive.png" ),
        focus_inactive  = mask_icon(path .."Icon/titlebar/ontop_focus_inactive.png" ),
        normal_active   = mask_icon(path .."Icon/titlebar/ontop_normal_active.png" ),
        focus_active    = mask_icon(path .."Icon/titlebar/ontop_focus_active.png" ),
    },

    sticky_button = blind {
        normal_inactive = mask_icon(path .."Icon/titlebar/sticky_normal_inactive.png" ),
        focus_inactive  = mask_icon(path .."Icon/titlebar/sticky_focus_inactive.png" ),
        normal_active   = mask_icon(path .."Icon/titlebar/sticky_normal_active.png" ),
        focus_active    = mask_icon(path .."Icon/titlebar/sticky_focus_active.png" ),
    },

    floating_button = blind {
        normal_inactive = mask_icon(path .."Icon/titlebar/floating_normal_inactive.png" ),
        focus_inactive  = mask_icon(path .."Icon/titlebar/floating_focus_inactive.png" ),
        normal_active   = mask_icon(path .."Icon/titlebar/floating_normal_active.png" ),
        focus_active    = mask_icon(path .."Icon/titlebar/floating_focus_active.png" ),
    },

    maximized_button = blind {
        normal_inactive = mask_icon(path .."Icon/titlebar/maximized_normal_inactive.png" ),
        focus_inactive  = mask_icon(path .."Icon/titlebar/maximized_focus_inactive.png" ),
        normal_active   = mask_icon(path .."Icon/titlebar/maximized_normal_active.png" ),
        focus_active    = mask_icon(path .."Icon/titlebar/maximized_focus_active.png" ),
    },

    resize      = path .."Icon/titlebar/resize.png",
    tag         = path .."Icon/titlebar/tag.png",
    bg_focus    = theme.bg_normal,
    show_icon   = true,
    title = blind {
        align = "center",
        shape                 = shape.hexagon,
        bg                    = theme.tasklist_bg_focus,
        border_color_active   = theme.icon_grad,
        border_color_inactive = theme.icon_grad,
        border_width          = 1,
    },
    height      = 14,
    top_left_shape = function(cr, w, h)
        local s = shape.transform(shape.rectangular_tag) : translate(w, 0) : scale(-1,1)
        s(cr, w, h, -5)
    end,
    top_left_shape_border_width = 1,
    top_left_shape_border_color = theme.icon_grad,
    top_left_bg = theme.tasklist_bg_focus,
    top_left_shape_args = {-5},
    top_right_shape = function(cr, w, h) shape.rectangular_tag(cr, w, h,-7) end,
    top_right_shape_border_width = 1,
    top_right_shape_border_color = theme.icon_grad,
    top_right_shape_args = {-5},
    top_right_bg = theme.tasklist_bg_focus,
    show_separator = false,
    underlay_bg = pattern2("#459FFF") : noise("#777788", 0.4) : threeD() : opacity(0.3) : to_pattern(),
    underlay_border_color = theme.icon_grad,
    underlay_border_width = 1,
}
