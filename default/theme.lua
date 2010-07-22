---------------------------
-- Default awesome theme --
---------------------------

theme = {}

theme.font          = "sans 8"

theme.bg_normal     = "#0A1535"
theme.bg_focus      = "#173758"
theme.bg_urgent     = "#ff4500"
theme.bg_minimize   = "#444444"

theme.fg_normal     = "#1577D3"
theme.fg_focus      = "#00BBD7"
theme.fg_urgent     = "#111111"
theme.fg_minimize  = "#ffffff"

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
theme.taglist_squares_sel = "/home/lepagee/.config/awesome/default/star2.png"
theme.taglist_squares_unsel = "/home/lepagee/.config/awesome/default/star.png"

theme.tasklist_floating_icon = "/home/lepagee/Icon/titlebar/floating.png"

-- Variables set for theming menu
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "/home/lepagee/icons/arrow.png"
theme.menu_height   = "20"
theme.menu_width    = "130"


-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--bg_widget    = #cc0000

-- Define the image to load
theme.titlebar_close_button_normal = "/home/lepagee/Icon/titlebar/close_normal.png"
theme.titlebar_close_button_focus = "/home/lepagee/Icon/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/home/lepagee/Icon/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = "/home/lepagee/Icon/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/home/lepagee/Icon/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = "/home/lepagee/Icon/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/home/lepagee/Icon/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = "/home/lepagee/Icon/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/home/lepagee/Icon/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = "/home/lepagee/Icon/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/home/lepagee/Icon/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = "/home/lepagee/Icon/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/home/lepagee/Icon/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = "/home/lepagee/Icon/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/home/lepagee/Icon/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = "/home/lepagee/Icon/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/home/lepagee/Icon/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = "/home/lepagee/Icon/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
theme.wallpaper_cmd = { "awsetbg /home/lepagee/bg/final/bin_ascii_ds.png" }

-- You can use your own layout icons like this:
theme.layout_fairh = "/home/lepagee/Icon/layouts/fairh.png"
theme.layout_fairv = "/home/lepagee/Icon/layouts/fairv.png"
theme.layout_floating = "/home/lepagee/Icon/layouts/floating.png"
theme.layout_magnifier = "/home/lepagee/Icon/layouts/magnifier.png"
theme.layout_max = "/home/lepagee/Icon/layouts/max.png"
theme.layout_fullscreen = "/home/lepagee/Icon/layouts/fullscreen.png"
theme.layout_tilebottom = "/home/lepagee/Icon/layouts/tilebottom.png"
theme.layout_tileleft = "/home/lepagee/Icon/layouts/tileleft.png"
theme.layout_tile = "/home/lepagee/Icon/layouts/tile.png"
theme.layout_tiletop = "/home/lepagee/Icon/layouts/tiletop.png"
theme.layout_spiral = "/home/lepagee/Icon/layouts/spiral.png"
theme.layout_spiraldwindle = "/home/lepagee/Icon/layouts/spiral_d.png"

theme.layout_fairh_s = "/home/lepagee/Icon/layouts_small/fairh.png"
theme.layout_fairv_s = "/home/lepagee/Icon/layouts_small/fairv.png"
theme.layout_floating_s = "/home/lepagee/Icon/layouts_small/floating.png"
theme.layout_magnifier_s = "/home/lepagee/Icon/layouts_small/magnifier.png"
theme.layout_max_s = "/home/lepagee/Icon/layouts_small/max.png"
theme.layout_fullscreen_s = "/home/lepagee/Icon/layouts_small/fullscreen.png"
theme.layout_tilebottom_s = "/home/lepagee/Icon/layouts_small/tilebottom.png"
theme.layout_tileleft_s = "/home/lepagee/Icon/layouts_small/tileleft.png"
theme.layout_tile_s = "/home/lepagee/Icon/layouts_small/tile.png"
theme.layout_tiletop_s = "/home/lepagee/Icon/layouts_small/tiletop.png"
theme.layout_spiral_s = "/home/lepagee/Icon/layouts_small/spiral.png"
theme.layout_spiraldwindle_s = "/home/lepagee/Icon/layouts_small/spiral_d.png"

theme.awesome_icon = "/home/lepagee/Icon/awesome.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
