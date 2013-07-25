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
local arrow = require("blind.arrow")
local debug      = debug

local path = debug.getinfo(1,"S").source:gsub("theme.*",""):gsub("@","")

local theme = {}
arrow.task.theme,arrow.tag.theme = theme,theme

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.default_height = 16
theme.font           = "snap"
theme.path           = path

theme.bg_normal      = "#000000"
theme.bg_focus       = "#496477"
theme.bg_urgent      = "#5B0000"
theme.bg_minimize    = "#040A1A"
theme.bg_highlight   = "#0E2051"
theme.bg_alternate   = "#081B37"

theme.fg_normal      = "#6DA1D4"
theme.fg_focus       = "#ABCCEA"
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
theme.enable_glow    = true
theme.glow_color     = "#105A8B"

theme.tasklist_floating_icon       = path .."Icon/titlebar/floating.png"
theme.tasklist_ontop_icon          = path .."Icon/titlebar/ontop.png"
theme.tasklist_sticky_icon         = path .."Icon/titlebar/sticky.png"
theme.tasklist_floating_focus_icon = path .."Icon/titlebar/floating_focus.png"
theme.tasklist_ontop_focus_icon    = path .."Icon/titlebar/ontop_focus.png"
theme.tasklist_sticky_focus_icon   = path .."Icon/titlebar/sticky_focus.png"
theme.tasklist_plain_task_name     = true

theme.icon_grad        = { type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#8AC2D5" }, { 1, "#3D619C" }}}
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
theme.taglist_bg_image_empty           = nil
theme.taglist_bg_image_selected        = path .."Icon/bg/selected_bg_scifi.png"
theme.taglist_bg_image_used            = path .."Icon/bg/selected_bg_scifi.png"
theme.taglist_bg_image_urgent          = path .."Icon/bg/urgent_bg.png"
theme.taglist_bg_image_remote_selected = path .."Icon/bg/selected_bg_green.png"
theme.taglist_bg_image_remote_used     = path .."Icon/bg/used_bg_green.png"
theme.taglist_squares_unsel            = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,themeutils.status_ellipse) end
theme.taglist_squares_sel              = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
theme.taglist_squares_sel_empty        = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
theme.taglist_squares_unsel_empty      = function(wdg,m,t,objects,idx) return arrow.tag.gen_tag_bg(wdg,m,t,objects,idx,nil)     end
theme.taglist_disable_icon             = true
theme.bg_image_normal                  = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end
theme.bg_image_focus                   = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_selected)     end
theme.bg_image_urgent                  = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_urgent)     end
theme.bg_image_minimize                = function(wdg,m,t,objects) return arrow.task.gen_task_bg(wdg,m,t,objects,nil)     end
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
theme.menu_fg_normal            = "#ffffff"
theme.menu_bg_focus             = themeutils.pattern(path .."Icon/bg/menu_bg_focus_scifi.png" )
theme.menu_bg_header            = themeutils.pattern(path .."Icon/bg/menu_bg_header_scifi.png")
theme.menu_bg_normal            = themeutils.pattern(path .."Icon/bg/menu_bg_scifi.png"       )
theme.menu_bg_highlight         = themeutils.pattern(path .."Icon/bg/menu_bg_highlight.png"   )
theme.bg_dock                   = themeutils.pattern(path .."Icon/bg/bg_dock.png"             )

theme.wallpaper = "/home/lepagee/bg/final/bin_ascii_ds.png"
theme.draw_underlay = themeutils.draw_underlay


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                             TITLEBAR                                             --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--bg_widget    = #cc0000

-- Define the image to load
theme.titlebar_close_button_normal = path .."Icon/titlebar/close_normal_inactive.png"
theme.titlebar_close_button_focus = path .."Icon/titlebar/close_focus_inactive.png"

theme.titlebar_ontop_button_normal_inactive = path .."Icon/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = path .."Icon/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = path .."Icon/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = path .."Icon/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = path .."Icon/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = path .."Icon/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = path .."Icon/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = path .."Icon/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = path .."Icon/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = path .."Icon/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = path .."Icon/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = path .."Icon/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = path .."Icon/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = path .."Icon/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = path .."Icon/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = path .."Icon/titlebar/maximized_focus_active.png"

theme.titlebar_resize = path .."Icon/titlebar/resize.png"
theme.titlebar_tag    = path .."Icon/titlebar/tag.png"

theme.titlebar_bg_focus = theme.bg_normal

theme.titlebar_title_align = "left"
theme.titlebar_height = 16


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                             LAYOUTS                                              --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- You can use your own layout icons like this:
theme.layout_fairh           = path .."Icon/layouts/fairh.png"
theme.layout_fairv           = path .."Icon/layouts/fairv.png"
theme.layout_floating        = path .."Icon/layouts/floating.png"
theme.layout_magnifier       = path .."Icon/layouts/magnifier.png"
theme.layout_max             = path .."Icon/layouts/max.png"
theme.layout_fullscreen      = path .."Icon/layouts/fullscreen.png"
theme.layout_tilebottom      = path .."Icon/layouts/tilebottom.png"
theme.layout_tileleft        = path .."Icon/layouts/tileleft.png"
theme.layout_tile            = path .."Icon/layouts/tile.png"
theme.layout_tiletop         = path .."Icon/layouts/tiletop.png"
theme.layout_spiral          = path .."Icon/layouts/spiral.png"
theme.layout_spiraldwindle   = path .."Icon/layouts/spiral_d.png"

theme.layout_fairh_s         = path .."Icon/layouts_small/fairh.png"
theme.layout_fairv_s         = path .."Icon/layouts_small/fairv.png"
theme.layout_floating_s      = path .."Icon/layouts_small/floating.png"
theme.layout_magnifier_s     = path .."Icon/layouts_small/magnifier.png"
theme.layout_max_s           = path .."Icon/layouts_small/max.png"
theme.layout_fullscreen_s    = path .."Icon/layouts_small/fullscreen.png"
theme.layout_tilebottom_s    = path .."Icon/layouts_small/tilebottom.png"
theme.layout_tileleft_s      = path .."Icon/layouts_small/tileleft.png"
theme.layout_tile_s          = path .."Icon/layouts_small/tile.png"
theme.layout_tiletop_s       = path .."Icon/layouts_small/tiletop.png"
theme.layout_spiral_s        = path .."Icon/layouts_small/spiral.png"
theme.layout_spiraldwindle_s = path .."Icon/layouts_small/spiral_d.png"

wibox_w.textbox.draw = function(self,w, cr, width, height,args)
    --Create the cache
    if not self.cache then
        self.cache = {}
        self.cached_text = self._layout.text
        self:connect_signal("widget::updated",function()
            if self._layout.text ~= self.cached_text then
                self.cache = {}
            end
        end)
    end

    local cached = self.cache[width+(10000*height)]
    if cached then
        -- Use the cache
        cr:set_source_surface(cached)
        cr:paint()
        return
    end

    --Init the textbox layout
    self._layout.width = pango.units_from_double(width)
    self._layout.height = pango.units_from_double(height)
    local ink, logical = self._layout:get_pixel_extents()

    --Draw in the cache
    local img  = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)--target:create_similar(target:get_content(),width,height) 
    local cr2 = cairo.Context(img)
--     cr2:set_operator(cairo.Operator.CLEAR)
--     cr2:paint()
--     cr2:set_operator(cairo.Operator.OVER)
    cr2:set_source(cr:get_source())
    cr2:update_layout(self._layout)
    themeutils.draw_text(cr2,self._layout,x_offset,(height-logical.height)/2 - ink.y/4,theme.enable_glow or false,theme.glow_color)
    self.cache[width+(10000*height)] = img

    --Use the cache
    cr:set_source_surface(img)
    cr:paint()
end

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
