local theme,path = ...
local blind      = require( "blind"          )

theme.titlebar = blind {
    close_button = blind {
        normal = path .."Icon/titlebar/close_normal_inactive.png",
        focus = path .."Icon/titlebar/close_focus_inactive.png",
    },

    ontop_button = blind {
        normal_inactive = path .."Icon/titlebar/ontop_normal_inactive.png",
        focus_inactive  = path .."Icon/titlebar/ontop_focus_inactive.png",
        normal_active   = path .."Icon/titlebar/ontop_normal_active.png",
        focus_active    = path .."Icon/titlebar/ontop_focus_active.png",
    },

    sticky_button = blind {
        normal_inactive = path .."Icon/titlebar/sticky_normal_inactive.png",
        focus_inactive  = path .."Icon/titlebar/sticky_focus_inactive.png",
        normal_active   = path .."Icon/titlebar/sticky_normal_active.png",
        focus_active    = path .."Icon/titlebar/sticky_focus_active.png",
    },

    floating_button = blind {
        normal_inactive = path .."Icon/titlebar/floating_normal_inactive.png",
        focus_inactive  = path .."Icon/titlebar/floating_focus_inactive.png",
        normal_active   = path .."Icon/titlebar/floating_normal_active.png",
        focus_active    = path .."Icon/titlebar/floating_focus_active.png",
    },

    maximized_button = blind {
        normal_inactive = path .."Icon/titlebar/maximized_normal_inactive.png",
        focus_inactive  = path .."Icon/titlebar/maximized_focus_inactive.png",
        normal_active   = path .."Icon/titlebar/maximized_normal_active.png",
        focus_active    = path .."Icon/titlebar/maximized_focus_active.png",
    },

    resize      = path .."Icon/titlebar/resize.png",
    tag         = path .."Icon/titlebar/tag.png",
    bg_focus    = theme.bg_normal,
    title_align = "left",
    height      = 14,
}