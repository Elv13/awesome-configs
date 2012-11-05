---------------------------
-- Default awesome theme --
---------------------------
theme = {}

theme.font          = "Arial 10"

theme.bg_normal     = "#616161"
theme.bg_focus      = "#003687"
theme.bg_urgent     = "#5B0000"
theme.bg_minimize   = "#040A1A"
theme.bg_highlight  = "#262626"
theme.bg_alternate  = "#323232"

theme.bg_normal_grad = {
    "#575651",
    "#3C3A37",
    '#302D2B'
}

theme.taskbar_selected_grad = {
    "#292825",
    '#0A0908',
    "#292825",
}

theme.taskbar_used_grad = {
    "#775651",
    "#5C3A37",
    '#502D2B'
}

theme.fg_normal     = "#BBBBBB"
theme.fg_focus      = "#DADADA"
theme.fg_urgent     = "#ABA6A6"
theme.fg_minimize   = "#1577D3"

--theme.border_width  = "1"
--theme.border_normal = "#555555"
--theme.border_focus  = "#535d6c"
--theme.border_marked = "#91231c"

theme.border_width  = "1"
theme.border_normal = "#555555"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"

-- There are another variables sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- Example:
--taglist_bg_focus = #ff0000

-- Display the taglist squares
theme.taglist_squares_sel = awful.util.getdir("config") .. "/default/star2.png"
theme.taglist_squares_unsel = awful.util.getdir("config") .. "/default/star.png"
-- theme.taglist_bg_image_empty    = nil
-- theme.taglist_bg_image_selected = "/home/lepagee/test2.png"
-- theme.taglist_bg_image_used     = "/home/lepagee/test2.png"

theme.tasklist_floating_icon = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating.png"

-- Variables set for theming menu
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = awful.util.getdir("config").."/theme/darkBlue/Icon/tags/arrow.png"
theme.menu_height   = 25
theme.menu_width    = 150
theme.menu_bg       = "#0A0A0ACC"
theme.menu_border_width  = 0
theme.menu_border_color  = "#ACBBCD"


theme.dock_bg       = "#0A0A0ACC"
theme.tooltip_bg    = "#0A0A0ACC"


-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--bg_widget    = #cc0000

-- Define the image to load
theme.titlebar_close_button_normal = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/close_normal_inactive.png"
theme.titlebar_close_button_focus = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/close_focus_inactive.png"

theme.titlebar_ontop_button_normal_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_focus_active.png"

theme.titlebar_close_button_normal_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/close_normal_inactive_hover.png"
theme.titlebar_close_button_focus_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/close_focus_inactive_hover.png"

theme.titlebar_ontop_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_normal_inactive_hover.png"
theme.titlebar_ontop_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_focus_inactive_hover.png"
theme.titlebar_ontop_button_normal_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_normal_active_hover.png"
theme.titlebar_ontop_button_focus_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_focus_active_hover.png"

theme.titlebar_sticky_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_normal_inactive_hover.png"
theme.titlebar_sticky_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_focus_inactive_hover.png"
theme.titlebar_sticky_button_normal_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_normal_active_hover.png"
theme.titlebar_sticky_button_focus_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/sticky_focus_active_hover.png"

theme.titlebar_floating_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_normal_inactive_hover.png"
theme.titlebar_floating_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_focus_inactive_hover.png"
theme.titlebar_floating_button_normal_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_normal_active_hover.png"
theme.titlebar_floating_button_focus_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating_focus_active_hover.png"

theme.titlebar_maximized_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_normal_inactive_hover.png"
theme.titlebar_maximized_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_focus_inactive_hover.png"
theme.titlebar_maximized_button_normal_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_normal_active_hover.png"
theme.titlebar_maximized_button_focus_active_hover = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/maximized_focus_active_hover.png"

--Mini titlebar
theme.titlebar_mini_close_button_normal = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/close_mini_normal_inactive.png"
theme.titlebar_mini_close_button_focus = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/close_mini_focus_inactive.png"

theme.titlebar_mini_ontop_button_normal_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_normal_inactive.png"
theme.titlebar_mini_ontop_button_focus_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_focus_inactive.png"
theme.titlebar_mini_ontop_button_normal_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_normal_active.png"
theme.titlebar_mini_ontop_button_focus_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_focus_active.png"

theme.titlebar_mini_sticky_button_normal_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_normal_inactive.png"
theme.titlebar_mini_sticky_button_focus_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_focus_inactive.png"
theme.titlebar_mini_sticky_button_normal_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_normal_active.png"
theme.titlebar_mini_sticky_button_focus_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_focus_active.png"

theme.titlebar_mini_floating_button_normal_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_normal_inactive.png"
theme.titlebar_mini_floating_button_focus_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_focus_inactive.png"
theme.titlebar_mini_floating_button_normal_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_normal_active.png"
theme.titlebar_mini_floating_button_focus_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_focus_active.png"

theme.titlebar_mini_maximized_button_normal_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_normal_inactive.png"
theme.titlebar_mini_maximized_button_focus_inactive = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_focus_inactive.png"
theme.titlebar_mini_maximized_button_normal_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_normal_active.png"
theme.titlebar_mini_maximized_button_focus_active = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_focus_active.png"

theme.titlebar_mini_close_button_normal_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/close_mini_normal_inactive_hover.png"
theme.titlebar_mini_close_button_focus_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/close_mini_focus_inactive_hover.png"

theme.titlebar_mini_ontop_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_normal_inactive_hover.png"
theme.titlebar_mini_ontop_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_focus_inactive_hover.png"
theme.titlebar_mini_ontop_button_normal_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_normal_active_hover.png"
theme.titlebar_mini_ontop_button_focus_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/ontop_mini_focus_active_hover.png"

theme.titlebar_mini_sticky_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_normal_inactive_hover.png"
theme.titlebar_mini_sticky_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_focus_inactive_hover.png"
theme.titlebar_mini_sticky_button_normal_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_normal_active_hover.png"
theme.titlebar_mini_sticky_button_focus_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/sticky_mini_focus_active_hover.png"

theme.titlebar_mini_floating_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_normal_inactive_hover.png"
theme.titlebar_mini_floating_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_focus_inactive_hover.png"
theme.titlebar_mini_floating_button_normal_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_normal_active_hover.png"
theme.titlebar_mini_floating_button_focus_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/floating_mini_focus_active_hover.png"

theme.titlebar_mini_maximized_button_normal_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_normal_inactive_hover.png"
theme.titlebar_mini_maximized_button_focus_inactive_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_focus_inactive_hover.png"
theme.titlebar_mini_maximized_button_normal_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_normal_active_hover.png"
theme.titlebar_mini_maximized_button_focus_active_hover = awful.util.getdir("config") .. "/theme/ubuntu/Icon/titlebar/maximized_mini_focus_active_hover.png"

theme.titlebar_bg_normal_grad = {
    "#191919",
    "#121212",
    "#101010",
    "#161616",
}

theme.titlebar_bg_focus_grad = {
    "#1C1C1C",
    "#151515",
    "#131313",
    "#191919",
}

theme.titlebar_mask = function(width,height)
    local img = image.argb32(width,height,nil)
    img:draw_rectangle(0,0,width,height,true,"#ffffff")
    img:draw_rectangle(0,5,width,height-5,true,"#000000")
    img:draw_rectangle(6,0,width-12,5,true,"#000000")
    img:draw_circle(6, 6, 5, 5, true, "#000000")
    img:draw_circle(width-6, 6, 5, 5, true, "#000000")
    return img
end

theme.titlebar_height = 18
theme.titlebar_mini_height = 6
theme.titlebar_fg_normal = "#727272"
theme.titlebar_fg_focus = "#C3C3C3"

-- You can use your own command to set your wallpaper
theme.wallpaper_cmd = { "feh --bg-scale "..awful.util.getdir("config") .. "/theme/ubuntu/background.png" }

-- You can use your own layout icons like this:
theme.layout_fairh           = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/fairh.png"
theme.layout_fairv           = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/fairv.png"
theme.layout_floating        = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/floating.png"
theme.layout_magnifier       = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/magnifier.png"
theme.layout_max             = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/max.png"
theme.layout_fullscreen      = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/fullscreen.png"
theme.layout_tilebottom      = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/tilebottom.png"
theme.layout_tileleft        = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/tileleft.png"
theme.layout_tile            = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/tile.png"
theme.layout_tiletop         = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/tiletop.png"
theme.layout_spiral          = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/spiral.png"
theme.layout_spiraldwindle   = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts/spiral_d.png"

theme.layout_fairh_s         = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/fairh.png"
theme.layout_fairv_s         = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/fairv.png"
theme.layout_floating_s      = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/floating.png"
theme.layout_magnifier_s     = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/magnifier.png"
theme.layout_max_s           = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/max.png"
theme.layout_fullscreen_s    = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/fullscreen.png"
theme.layout_tilebottom_s    = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/tilebottom.png"
theme.layout_tileleft_s      = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/tileleft.png"
theme.layout_tile_s          = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/tile.png"
theme.layout_tiletop_s       = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/tiletop.png"
theme.layout_spiral_s        = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/spiral.png"
theme.layout_spiraldwindle_s = awful.util.getdir("config") .. "/theme/darkBlue/Icon/layouts_small/spiral_d.png"

theme.awesome_icon           = awful.util.getdir("config") .. "/theme/darkBlue/Icon/awesome2.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
