local capi =  {timer=timer,client=client}
local awful      = require( "awful"          )
local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local cairo      = require( "lgi"            ).cairo
local pango      = require( "lgi"            ).Pango
local tag        = require( "awful.tag"      )
local client     = require( "awful.client"   )
local themeutils = require( "blind.common.drawing"    )
local wibox_w    = require( "wibox.widget"   )
local radical    = require( "radical"        )
local blind      = require( "blind"          )
local debug      = debug

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.default_height = 16
theme.font           = "ohsnap 8"
theme.font           = "Sans DemiBold 8"
-- theme.font           = "-*-Terminus sans medium-r-normal--*-30-*-*-*-*-iso10646-1"
-- theme.font           = "Terminus 8 bold"
theme.path           = path

theme.bg_normal      = "#000000"
theme.bg_focus       = "#496477"
theme.bg_urgent      = "#5B0000"
theme.bg_minimize    = "#040A1A"
theme.bg_highlight   = "#0E2051"
theme.bg_alternate   = "#081B37"
theme.bg_allinone    = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#1D4164" }, { 1, "#0D2144" }}}

theme.fg_normal      = "#6DA1D4"
theme.fg_focus       = "#ABCCEA"
theme.fg_urgent      = "#FF7777"
theme.fg_minimize    = "#1577D3"

theme.bg_systray     = theme.fg_normal


theme.button_bg_normal            = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       )

--theme.border_width  = "1"
--theme.border_normal = "#555555"
--theme.border_focus  = "#535d6c"
--theme.border_marked = "#91231c"

theme.border_width   = "0"
theme.border_width2  = "2"
theme.border_normal  = "#1F1F1F"
theme.border_focus   = "#535d6c"
theme.border_marked  = "#91231c"
theme.enable_glow    = flase
theme.glow_color     = "#105A8B"

theme.tasklist_floating_icon       = path .."Icon/titlebar/floating.png"
theme.tasklist_ontop_icon          = path .."Icon/titlebar/ontop.png"
theme.tasklist_sticky_icon         = path .."Icon/titlebar/sticky.png"
theme.tasklist_floating_focus_icon = path .."Icon/titlebar/floating_focus.png"
theme.tasklist_ontop_focus_icon    = path .."Icon/titlebar/ontop_focus.png"
theme.tasklist_sticky_focus_icon   = path .."Icon/titlebar/sticky_focus.png"
theme.tasklist_plain_task_name     = true
theme.tasklist_icon_transformation = function(image,data,item)
    if not item._state_transform_init then
        item:connect_signal("state::changed",function()
            if item._original_icon then
                item:set_icon(item._original_icon)
            end
        end)
        item._state_transform_init = true
    end
    local state = item.state or {}
    local current_state = state._current_key or nil
    local state_name = radical.base.colors_by_id[current_state] or "normal"
    return surface.tint(image,color(state_name == "normal" and theme.fg_normal or item["fg_"..state_name]  --[[theme.fg_normal]]),theme.default_height,theme.default_height)
end

theme.alttab_icon_transformation = function(image,data,item)
--     return themeutils.desaturate(surface(image),1,theme.default_height,theme.default_height)
    return surface.tint(surface(image),color(theme.fg_normal),theme.default_height,theme.default_height)
end

theme.icon_grad        = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#8AC2D5" }, { 1, "#3D619C" }}}
theme.icon_mask        = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#8AC2D5" }, { 1, "#3D619C" }}}
theme.icon_grad_invert = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#000000" }, { 1, "#112543" }}}


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
-- theme.taglist_underline                = "#094CA5"

theme.taglist_bg_unused          = "#ffffff"
theme.taglist_bg_empty           = "#111111"
theme.taglist_bg_hover           = color.create_png_pattern(path .."Icon/bg/menu_bg_focus_scifi.png" )
theme.taglist_bg_selected        = color.create_png_pattern(path .."Icon/bg/menu_bg_selected_scifi.png")
theme.taglist_fg_selected        = "#ffffff"
theme.taglist_bg_cloned          = color.create_png_pattern(path .."Icon/bg/used_bg_green2.png")
theme.taglist_fg_cloned          = "#00bb00"
theme.taglist_bg_used            = color.create_png_pattern(path .."Icon/bg/selected_bg_scifi_focus.png")
theme.taglist_fg_used            = "#7EA5E3"
theme.taglist_bg_urgent          = color.create_png_pattern(path .."Icon/bg/urgent_bg.png")
theme.taglist_fg_urgent          = "#FF7777"
theme.taglist_bg_changed         = color.create_png_pattern(path .."Icon/bg/selected_bg_scifi_changed.png")
theme.taglist_fg_changed         = "#B78FEE"
theme.taglist_bg_highlight       = "#bbbb00"
theme.taglist_fg_highlight       = "#000000"
theme.taglist_fg_prefix          = theme.bg_normal
theme.taglist_default_icon       = path .."Icon/tags/other.png"
theme.taglist_spacing            = 4
theme.taglist_icon_transformation = function(image,data,item)
    return color.apply_mask(image,color("#8186C3"))
end

theme.taglist_fg_prefix          = "#ffffff"
theme.taglist_default_item_margins = {
    LEFT   = 2,
    RIGHT  = 8,
    TOP    = 2,
    BOTTOM = 2,
}
theme.taglist_default_margins = {
    LEFT   = 2,
    RIGHT  = 20,
    TOP    = 0,
    BOTTOM = 1,
}
theme.taglist_item_style     = radical.item.style.rounded


theme.tasklist_default_item_margins = {
    LEFT   = 8,
    RIGHT  = 4,
    TOP    = 0,
    BOTTOM = 0,
}
theme.tasklist_default_margins = {
    LEFT   = 7,
    RIGHT  = 7,
    TOP    = 1,
    BOTTOM = 0,
}
theme.tasklist_item_style     = radical.item.style.rounded
-- theme.taglist_theme = radical.item.style.rounded
-- theme.taglist_squares_unsel            = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,themeutils.status_ellipse) end
-- theme.taglist_squares_sel              = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
-- theme.taglist_squares_sel_empty        = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
-- theme.taglist_squares_unsel_empty      = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,nil)     end
-- theme.taglist_disable_icon             = true
theme.tasklist_underlay_bg_urgent      = "#ff0000"
theme.tasklist_underlay_bg_minimized   = "#4F269C"
theme.tasklist_underlay_bg_focus       = "#0746B2"
theme.tasklist_bg_image_selected       = path .."Icon/bg/selected_bg_scifi.png"
theme.tasklist_bg_minimized            = "#10002C"
theme.tasklist_fg_minimized            = "#985FEE"
theme.tasklist_bg_urgent               = color.create_png_pattern(path .."Icon/bg/urgent_bg.png")
theme.tasklist_bg_hover                = color.create_png_pattern(path .."Icon/bg/menu_bg_focus_scifi.png" )
theme.tasklist_bg_focus                = color.create_png_pattern(path .."Icon/bg/selected_bg_scifi_focus.png")
theme.tasklist_default_icon            = path .."Icon/tags/other.png"
theme.tasklist_spacing                 = 4
theme.tasklist_bg_image_normal                  = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end
theme.tasklist_bg_image_focus                   = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_selected)     end
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
-- theme.menu_scrollmenu_down_icon = path .."Icon/tags/arrow_down.png"
-- theme.menu_scrollmenu_up_icon   = path .."Icon/tags/arrow_up.png"
theme.awesome_icon              = path .."Icon/awesome2.png"
theme.menu_height               = 20
theme.menu_width                = 170
theme.menu_border_width         = 2
theme.border_width              = 1
theme.menu_opacity              = 0.9
theme.border_color              = theme.fg_normal
theme.menu_fg_normal            = "#ffffff"
theme.menu_bg_focus             = color.create_png_pattern(path .."Icon/bg/menu_bg_focus_scifi.png" )
theme.menu_bg_header            = color.create_png_pattern(path .."Icon/bg/menu_bg_header_scifi.png")
theme.menu_bg_normal            = color.create_png_pattern(path .."Icon/bg/menu_bg_scifi.png"       )
theme.menu_bg_highlight         = color.create_png_pattern(path .."Icon/bg/menu_bg_highlight.png"   )
theme.bg_dock                   = color.create_png_pattern(path .."Icon/bg/bg_dock.png"             )
theme.fg_dock_1                 = "#1889F2"
theme.fg_dock_2                 = "#0A3E6E"

theme.wallpaper = "/home/lepagee/bg/final/bin_ascii_ds.png"
theme.draw_underlay = themeutils.draw_underlay

-- Titlebar
loadfile(theme.path .."bits/titlebar.lua")(theme,path)

-- Layouts
loadfile(theme.path .."bits/layout.lua")(theme,path)


require( "chopped.arrow" )

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
