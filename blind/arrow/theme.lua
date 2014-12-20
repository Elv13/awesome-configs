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
local blind      = require( "blind"          )
local blind_pat  = require( "blind.common.pattern" )
local debug      = debug

local path = debug.getinfo(1,"S").source:gsub("theme.lua",""):gsub("@","")

local theme = blind.theme
-- arrow.task.theme,arrow.tag.theme = theme,theme

local function d_mask(img,cr)
    return blind_pat.to_pattern(img,cr)
end

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.default_height = 14
-- theme.font           = "terminus mono 13"
theme.path           = path

theme.bg_normal      = "#0A1535"
theme.bg_focus       = "#003687"
theme.bg_urgent      = "#5B0000"
theme.bg_minimize    = "#040A1A"
theme.bg_highlight   = "#0E2051"
theme.bg_alternate   = "#0F2766"

theme.fg_normal      = "#1577D3"
theme.fg_focus       = "#00BBD7"
theme.fg_urgent      = "#FF7777"
theme.fg_minimize    = "#1577D3"

theme.bg_systray     = theme.fg_normal

--theme.border_width  = "1"
--theme.border_normal = "#555555"
--theme.border_focus  = "#535d6c"
--theme.border_marked = "#91231c"

theme.border_width   = "0"
theme.border_width2  = "2"
theme.border_normal  = "#555555"
theme.border_focus   = "#535d6c"
theme.border_marked  = "#91231c"

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
theme.taglist_bg_empty           = nil
theme.taglist_bg_selected        = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(path .."Icon/bg/selected_bg.png"))
theme.taglist_bg_used            = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(path .."Icon/bg/used_bg.png"))
theme.taglist_bg_urgent          = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(path .."Icon/bg/urgent_bg.png"))
theme.taglist_bg_remote_selected = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(path .."Icon/bg/selected_bg_green.png"))
theme.taglist_bg_remote_used     = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(path .."Icon/bg/used_bg_green.png"))
theme.taglist_bg_hover           = d_mask(blind_pat.sur.flat_grad("#321DBA","#201379",theme.default_height))
theme.taglist_fg_prefix                = theme.bg_normal
-- theme.taglist_squares_unsel            = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_used)     end
-- theme.taglist_squares_sel              = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
-- theme.taglist_squares_sel_empty        = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
-- theme.taglist_squares_unsel_empty      = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,nil)     end
-- theme.taglist_disable_icon             = true
-- theme.tasklist_bg_image_normal                  = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end
-- theme.tasklist_bg_image_focus                   = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_used)     end
-- theme.tasklist_bg_image_urgent                  = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_urgent)     end
-- theme.tasklist_bg_image_minimize                = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end

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

theme.dock_icon_color = { type = "linear", from = { 0, 0 }, to = { 0, 55 }, stops = { { 0, "#1889F2" }, { 1, "#083158" }}}

theme.draw_underlay = themeutils.draw_underlay


-- Titlebar
loadfile(theme.path .."bits/titlebar.lua")(theme,path)

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)

require( "chopped.arrow" )

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
