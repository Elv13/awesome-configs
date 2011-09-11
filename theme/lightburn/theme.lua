-------------------------------
--  "lightburn" awesome theme  --
--    By Emmanuel Lepage Vallee
--    mostly derived from ZenBurn by Adrian C. (anrxc)   --
-------------------------------

-- {{{ Main
theme = {}
-- theme.wallpaper_cmd = { "awsetbg ".. os.getenv('HOME').."/.config/awesome/lightburn/lightburn-background.png" }
theme.wallpaper_cmd = { "feh --bg-scale "..awful.util.getdir("config").."/theme/lightburn/lightburn-background.png" }
-- }}}

-- {{{ Styles
theme.font      = "sans 8"

-- {{{ Colors
theme.fg_normal = "#6C6B61"
theme.fg_focus  = "#F9E7B6"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#E5DFC1"
theme.bg_focus  = "#3B3E36"
theme.bg_urgent = "#B3753B"
-- }}}

-- {{{ Borders
theme.border_width  = "1"
theme.border_normal = "#B6B4A4"
theme.border_focus  = "#B6B4A4"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
-- theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_focus  = "#969487"
theme.titlebar_bg_normal = "#B6B4A4"
theme.titlebar_fg_focus  = "#F6F3DE"
theme.titlebar_fg_normal = "#4D4C45"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = "15"
theme.menu_width  = "100"
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = awful.util.getdir("config").."/theme/lightburn/taglist/squarefz.png"
theme.taglist_squares_unsel = awful.util.getdir("config").."/theme/lightburn/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = awful.util.getdir("config").."/theme/lightburn/awesome-icon.png"
theme.menu_submenu_icon      = awful.util.getdir("config").."/default/submenu.png"
theme.tasklist_floating_icon = awful.util.getdir("config").."/default/tasklist/floatingw.png"
-- }}}

-- {{{ Layout
theme.layout_tile         = awful.util.getdir("config").."/theme/lightburn/layouts/tile.png"
theme.layout_tileleft     = awful.util.getdir("config").."/theme/lightburn/layouts/tileleft.png"
theme.layout_tilebottom   = awful.util.getdir("config").."/theme/lightburn/layouts/tilebottom.png"
theme.layout_tiletop      = awful.util.getdir("config").."/theme/lightburn/layouts/tiletop.png"
theme.layout_fairv        = awful.util.getdir("config").."/theme/lightburn/layouts/fairv.png"
theme.layout_fairh        = awful.util.getdir("config").."/theme/lightburn/layouts/fairh.png"
theme.layout_spiral       = awful.util.getdir("config").."/theme/lightburn/layouts/spiral.png"
theme.layout_dwindle      = awful.util.getdir("config").."/theme/lightburn/layouts/dwindle.png"
theme.layout_max          = awful.util.getdir("config").."/theme/lightburn/layouts/max.png"
theme.layout_fullscreen   = awful.util.getdir("config").."/theme/lightburn/layouts/fullscreen.png"
theme.layout_magnifier    = awful.util.getdir("config").."/theme/lightburn/layouts/magnifier.png"
theme.layout_floating     = awful.util.getdir("config").."/theme/lightburn/layouts/floating.png"


theme.layout_tile_s       = awful.util.getdir("config").."/theme/lightburn/layouts/tile.png"
theme.layout_tileleft_s   = awful.util.getdir("config").."/theme/lightburn/layouts/tileleft.png"
theme.layout_tilebottom_s = awful.util.getdir("config").."/theme/lightburn/layouts/tilebottom.png"
theme.layout_tiletop_s    = awful.util.getdir("config").."/theme/lightburn/layouts/tiletop.png"
theme.layout_fairv_s      = awful.util.getdir("config").."/theme/lightburn/layouts/fairv.png"
theme.layout_fairh_s      = awful.util.getdir("config").."/theme/lightburn/layouts/fairh.png"
theme.layout_spiral_s     = awful.util.getdir("config").."/theme/lightburn/layouts/spiral.png"
theme.layout_dwindle_s    = awful.util.getdir("config").."/theme/lightburn/layouts/dwindle.png"
theme.layout_max_s        = awful.util.getdir("config").."/theme/lightburn/layouts/max.png"
theme.layout_fullscreen_s = awful.util.getdir("config").."/theme/lightburn/layouts/fullscreen.png"
theme.layout_magnifier_s  = awful.util.getdir("config").."/theme/lightburn/layouts/magnifier.png"
theme.layout_floating_s   = awful.util.getdir("config").."/theme/lightburn/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = awful.util.getdir("config").."/theme/lightburn/titlebar/close_focus.png"
theme.titlebar_close_button_normal = awful.util.getdir("config").."/theme/lightburn/titlebar/close_normal.png"

-- theme.titlebar_ontop_button_focus_active  = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_focus_active.png"
-- theme.titlebar_ontop_button_normal_active = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_normal_active.png"
-- theme.titlebar_ontop_button_focus_inactive  = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_focus_inactive.png"
-- theme.titlebar_ontop_button_normal_inactive = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_normal_inactive.png"

theme.titlebar_ontop_button_focus_active  = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = awful.util.getdir("config").."/theme/lightburn/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = awful.util.getdir("config").."/theme/lightburn/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = awful.util.getdir("config").."/theme/lightburn/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = awful.util.getdir("config").."/theme/lightburn/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = awful.util.getdir("config").."/theme/lightburn/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = awful.util.getdir("config").."/theme/lightburn/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = awful.util.getdir("config").."/theme/lightburn/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = awful.util.getdir("config").."/theme/lightburn/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = awful.util.getdir("config").."/theme/lightburn/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = awful.util.getdir("config").."/theme/lightburn/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = awful.util.getdir("config").."/theme/lightburn/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = awful.util.getdir("config").."/theme/lightburn/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = awful.util.getdir("config").."/theme/lightburn/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme
