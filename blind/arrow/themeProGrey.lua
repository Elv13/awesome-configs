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
local blind_pat  = require( "blind.common.pattern" )
local blind      = require( "blind"          )
local debug      = debug

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = blind.theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

local default_height = 16

theme.default_height = default_height

local function d_mask(img,cr)
    return blind_pat.to_pattern(blind_pat.mask.ThreeD(img,cr))
end

-- theme.font           = "Arial 10"
-- theme.font           = "Nimbus Sans L 10"
theme.font           = "Roboto Medium 10"
theme.path           = path

theme.bg_normal      = "#343434"
theme.bg_focus       = "#496477"
theme.bg_urgent      = "#5B0000"
theme.bg_minimize    = "#040A1A"
theme.bg_highlight   = "#0E2051"
theme.bg_alternate   = "#081B37"
theme.bg_allinone    = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#1D4164" }, { 1, "#0D2144" }}}

local bargrad = { type = "linear", from = { 0, 0 }, to = { 0, 16 }, stops = { { 0, "#252528" }, { 1, "#282830" }}}
theme.bar_bg_alternate =  d_mask(blind_pat.mask.noise(0.04,"#AAAACC", blind_pat.sur.plain("#1F1F1F",default_height)))
theme.bar_bg_normal    =  d_mask(blind_pat.sur.flat_grad(bargrad,"#44444966",default_height))
theme.bar_bg_buttons   =  d_mask(blind_pat.sur.flat_grad("#00091A","#04204F",default_height))

theme.fg_normal      = "#C8DAE7"
theme.fg_focus       = "#ABCCEA"
theme.fg_urgent      = "#FF7777"
theme.fg_minimize    = "#1577D3"

theme.bg_systray     = theme.fg_normal

theme.systray_icon_spacing = 4


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
theme.enable_glow    = true
theme.glow_color     = "#171717"

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

theme.icon_grad        = d_mask(blind_pat.mask.noise(0.1,"#777788", blind_pat.sur.plain("#4A5157",default_height)))
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

theme.taglist_custom_color = function (...) d_mask(blind_pat.sur.flat_grad(...)) end

theme.taglist_bg                 = d_mask(blind_pat.sur.plain("#070A0C",default_height))
-- theme.taglist_bg_empty           = "#ffff00"
theme.taglist_bg_hover           = d_mask(blind_pat.sur.thick_stripe("#19324E","#132946",14,default_height,true))
theme.taglist_bg_selected        = d_mask(blind_pat.sur.thick_stripe("#0D3685","#05297F",4 ,default_height,true))
theme.taglist_fg_selected        = "#ffffff"
-- theme.taglist_bg_cloned          = grag(path .."Icon/bg/used_bg_green2.png")
-- theme.taglist_fg_cloned          = "#00bb00"
theme.taglist_bg_used            = d_mask(blind_pat.sur.flat_grad("#37413B","#285B2A",default_height))
theme.taglist_fg_used            = "#D2EED9"
theme.taglist_bg_urgent          = d_mask(blind_pat.sur.flat_grad("#5B0000","#300000",default_height))
theme.taglist_fg_urgent          = "#FF7777"
theme.taglist_bg_changed         = d_mask(blind_pat.sur.flat_grad("#4C444D","#673263",default_height))
theme.taglist_fg_changed         = "#D9D3EE"
theme.taglist_bg_highlight       = "#bbbb00"
theme.taglist_fg_highlight       = "#000000"
theme.taglist_bg_empty           = theme.bar_bg_normal --d_mask(blind_pat.sur.flat_grad("#090B10","#181E39",default_height))
-- theme.taglist_fg_empty           = "#000000"
theme.taglist_fg_prefix          = theme.bg_normal
theme.taglist_default_icon       = path .."Icon/tags/other.png"
theme.tasklist_underlay_bg_urgent      = "#ff0000"
theme.tasklist_underlay_bg_minimized   = "#4F269C"
theme.tasklist_underlay_bg_focus       = "#0746B2"
theme.tasklist_bg_image_selected       = d_mask(blind_pat.sur.flat_grad("#00091A","#04204F",default_height))
theme.tasklist_bg_minimized            = "#10002C"
theme.tasklist_fg_minimized            = "#985FEE"
theme.tasklist_bg_urgent               = d_mask(blind_pat.sur.flat_grad("#5B0000","#300000",default_height))
theme.tasklist_bg_hover                = d_mask(blind_pat.sur.thick_stripe("#19324E","#132946",14,default_height,true)) 
theme.tasklist_bg_focus                = d_mask(blind_pat.sur.flat_grad("#00143B","#052F77",default_height))
theme.tasklist_default_icon            = path .."Icon/tags/other.png"
theme.tasklist_bg                      = d_mask(blind_pat.sur.flat_grad("#22222A",nil,default_height))
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

wibox_w.textbox._fit = wibox_w.textbox.fit
wibox_w.textbox.fit = function(...)
    local w,h = wibox_w.textbox._fit(...)
    return w+3,h
end
wibox_w.textbox._draw = wibox_w.textbox.draw

-- Textbox shadow
loadfile(theme.path .."bits/textbox/shadow.lua")(theme,path)

require( "chopped.arrow" )

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
