local capi =  {timer=timer,client=client}
local awful      = require( "awful"          )
local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local cairo      = require( "lgi"            ).cairo
local tag        = require( "awful.tag"      )
local client     = require( "awful.client"   )
local themeutils = require( "blind.common.drawing"    )
local wibox_w    = require( "wibox.widget"   )
local radical    = require( "radical"        )
local arrow = require("blind.arrow")
local blind      = require( "blind"          )
local debug      = debug

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme
arrow.task.theme,arrow.tag.theme = theme,theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.default_height = 16
theme.font           = "snap"
theme.path           = path

theme.bg_normal      = "#071504"
theme.bg_focus       = "#00B400"
theme.bg_urgent      = "#5B0000"
theme.bg_minimize    = "#040A1A"
theme.bg_highlight   = "#0E2051"
theme.bg_alternate   = "#062709"

theme.fg_normal      = "#00FF00"
theme.fg_focus       = "#7ACE75"
theme.fg_urgent      = "#FF7777"
theme.fg_minimize    = "#1577D3"

--theme.border_width  = "1"
--theme.border_normal = "#555555"
--theme.border_focus  = "#535d6c"
--theme.border_marked = "#91231c"

theme.border_width   = "0"
theme.border_width2  = "2"
theme.border_normal  = "#555555"
theme.border_focus   = "#535d6c"
theme.border_marked  = "#91231c"

theme.tasklist_floating_icon       = path .."Icon/titlebar/floating.png"
theme.tasklist_ontop_icon          = path .."Icon/titlebar/ontop.png"
theme.tasklist_sticky_icon         = path .."Icon/titlebar/sticky.png"
theme.tasklist_floating_focus_icon = path .."Icon/titlebar/floating_focus.png"
theme.tasklist_ontop_focus_icon    = path .."Icon/titlebar/ontop_focus.png"
theme.tasklist_sticky_focus_icon   = path .."Icon/titlebar/sticky_focus.png"
theme.tasklist_plain_task_name     = true


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                        TAG AND TASKLIST FUNCTIONS                                --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- There are another variables sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- Example:
--taglist_bg_focus = #ff0000


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                       TAGLIST/TASKLIST                                           --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- Display the taglist squares
theme.taglist_bg_image_empty           = nil
theme.taglist_bg_image_selected        = path .."Icon/bg/used_bg_green2.png"
theme.taglist_bg_image_used            = path .."Icon/bg/used_bg_green.png"
theme.taglist_bg_image_urgent          = path .."Icon/bg/urgent_bg.png"
theme.taglist_bg_image_remote_selected = path .."Icon/bg/selected_bg_green.png"
theme.taglist_bg_image_remote_used     = path .."Icon/bg/used_bg_green.png"
theme.taglist_squares_unsel            = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_used)     end
theme.taglist_squares_sel              = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
theme.taglist_squares_sel_empty        = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
theme.taglist_squares_unsel_empty      = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,nil)     end
theme.taglist_disable_icon             = true
theme.tasklist_bg_image_normal                  = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end
theme.tasklist_bg_image_focus                   = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_used)     end
theme.tasklist_bg_image_urgent                  = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_urgent)     end
theme.tasklist_bg_image_minimize                = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end
theme.tasklist_disable_icon            = true
theme.monochrome_icons                 = true


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                               MENU                                               --
--                                                                                                  --
------------------------------------------------------------------------------------------------------


-- Variables set for theming menu
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon         = path .."Icon/tags/arrow.png"
theme.menu_scrollmenu_down_icon = path .."Icon/tags/arrow_down.png"
theme.menu_scrollmenu_up_icon   = path .."Icon/tags/arrow_up.png"
theme.awesome_icon              = path .."Icon/awesome2.png"
theme.menu_height               = 20
theme.menu_width                = 130
theme.menu_border_width         = 2
theme.border_width              = 1
theme.border_color              = theme.fg_normal
theme.wallpaper = "/home/lepagee/bg/final/bin_ascii_ds.png"


-- Titlebar
loadfile(theme.path .."bits/titlebar.lua")(theme,path)

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)


return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
