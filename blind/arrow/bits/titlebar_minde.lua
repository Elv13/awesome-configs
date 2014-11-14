local theme,path = ...
local blind      = require( "blind"          )

theme.titlebar = blind {
    close_button = blind {
        normal = path .."Icon/titlebar_minde/close_normal.png",
        focus = path .."Icon/titlebar_minde/close_normal.png",
    },

    ontop_button = blind {
        normal_inactive = path .."Icon/titlebar_minde/ontop_normal.png",
        focus_inactive  = path .."Icon/titlebar_minde/ontop_normal.png",
        normal_active   = path .."Icon/titlebar_minde/ontop_focus.png",
        focus_active    = path .."Icon/titlebar_minde/ontop_focus.png",
    },

    sticky_button = blind {
        normal_inactive = path .."Icon/titlebar_minde/sticky_normal.png",
        focus_inactive  = path .."Icon/titlebar_minde/sticky_normal.png",
        normal_active   = path .."Icon/titlebar_minde/sticky_focus.png",
        focus_active    = path .."Icon/titlebar_minde/sticky_focus.png",
    },

    floating_button = blind {
        normal_inactive = path .."Icon/titlebar_minde/floating_normal.png",
        focus_inactive  = path .."Icon/titlebar_minde/floating_normal.png",
        normal_active   = path .."Icon/titlebar_minde/floating_focus.png",
        focus_active    = path .."Icon/titlebar_minde/floating_focus.png",
    },

    maximized_button = blind {
        normal_inactive = path .."Icon/titlebar_minde/maximized_normal.png",
        focus_inactive  = path .."Icon/titlebar_minde/maximized_normal.png",
        normal_active   = path .."Icon/titlebar_minde/maximized_focus.png",
        focus_active    = path .."Icon/titlebar_minde/maximized_focus.png",
    },

    resize      = path .."Icon/titlebar/resize.png",
    tag         = path .."Icon/titlebar/tag.png",
    bg_focus    = theme.bg_normal,
    title_align = "left",
    height      = 14,
}