---------------------------
-- Default awesome theme --
---------------------------

theme = {}

theme.font          = "snap 8"

theme.bg_normal     = "#0A1535"
theme.bg_focus      = "#003687"
theme.bg_urgent     = "#5B0000"
theme.bg_minimize   = "#040A1A"
theme.bg_highlight  = "#0E2051"

theme.fg_normal     = "#1577D3"
theme.fg_focus      = "#00BBD7"
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

theme.tasklist_floating_icon = awful.util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/floating.png"

-- Variables set for theming menu
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = awful.util.getdir("config").."/theme/darkBlue/Icon/tags/arrow.png"
theme.menu_height   = "20"
theme.menu_width    = "130"


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

-- You can use your own command to set your wallpaper
theme.wallpaper_cmd = { "feh --bg-tile /home/lepagee/bg/final/bin_ascii_ds.png" }

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
