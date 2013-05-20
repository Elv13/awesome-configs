local awful      = require( "awful"          )
local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local cairo      = require( "lgi"            ).cairo
local tag        = require( "awful.tag"      )
local client     = require( "awful.client"   )
local themeutils = require( "utils.theme"    )
local wibox_w    = require( "wibox.widget"   )
local confdir    = awful.util.getdir("config")

theme = {}

------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                    DEFAULT COLORS, FONT AND SIZE                                 --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

theme.default_height = 16
theme.font           = "snap 8"

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

--theme.border_width  = "1"
--theme.border_normal = "#555555"
--theme.border_focus  = "#535d6c"
--theme.border_marked = "#91231c"

theme.border_width   = "0"
theme.border_width2  = "2"
theme.border_normal  = "#555555"
theme.border_focus   = "#535d6c"
theme.border_marked  = "#91231c"

theme.tasklist_floating_icon       = confdir .. "/theme/darkBlue/Icon/titlebar/floating.png"
theme.tasklist_ontop_icon          = confdir .. "/theme/darkBlue/Icon/titlebar/ontop.png"
theme.tasklist_sticky_icon         = confdir .. "/theme/darkBlue/Icon/titlebar/sticky.png"
theme.tasklist_floating_focus_icon = confdir .. "/theme/darkBlue/Icon/titlebar/floating_focus.png"
theme.tasklist_ontop_focus_icon    = confdir .. "/theme/darkBlue/Icon/titlebar/ontop_focus.png"
theme.tasklist_sticky_focus_icon   = confdir .. "/theme/darkBlue/Icon/titlebar/sticky_focus.png"
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
local screen_nb_cache = {}
local function gen_screen_nb(nb)
    if screen_nb_cache[nb] then return screen_nb_cache[nb] end
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, theme.default_height, theme.default_height)
    cr = cairo.Context(img)
    cr:move_to(5,11)
    cr:set_source(color("#005500"))
    cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(10)
    cr:show_text(nb)
    screen_nb_cache[nb] = img
    return img
end

local taglist_cache = {}

local arr_tag      = themeutils.get_end_arrow2({ bg_color=theme.fg_normal    })
local arr_last_tag = themeutils.get_end_arrow2({ bg_color=theme.bg_alternate })
local arr1_tag     = themeutils.get_beg_arrow2({ fg_color=theme.bg_normal    })

local function gen_tag_bg(wdg,t,m,objects,idx,image)
    local width = wdg:fit(-1, -1)
    local hash = width..(image or "nil")..(objects[#objects] == t and ";" or "")..idx..(tag.getproperty(t,"clone_of") and "c" or "")
    if taglist_cache[t] and taglist_cache[t][hash] then
        if tag.getproperty(t,"clone_of") then
            wdg:set_markup("<span color='#006A1F'>"..t.name.."</span>")
        end
        return taglist_cache[t][hash]
    end
    local isClone = tag.getproperty(t,"clone_of")
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, width+(19+2*theme.default_height)+(isClone and 20 or 0), theme.default_height)
    m:set_left(theme.default_height+theme.default_height+7)
    m:set_right(theme.default_height/2+(isClone and 20 or 0))
    local cr = cairo.Context(img2)
    if isClone then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(theme.taglist_bg_image_remote_used))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    elseif image then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(image))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    end
    cr:set_source(color(theme.fg_normal))
    cr:rectangle(0,0,theme.default_height+theme.default_height/2+5,theme.default_height)
    cr:fill()
    local icon = tag.geticon(t) or confdir .. "/theme/darkBlue/Icon/tags_invert/other.png"
    img2 = themeutils.compose({
        img2,
        {layer=icon,x=2,y=0,scale=true,height=theme.default_height+2},
        {layer=arr1_tag,x=theme.default_height+theme.default_height/2+5,y=0},
        {layer = objects[#objects] ~= t and arr_tag or arr_last_tag,y=0,x=width+ (theme.default_height+3*(theme.default_height/2)+11) - theme.default_height/2 + 5 -9+(isClone and 20 or 0)},
        isClone and {layer=confdir .. "/theme/darkBlue/Icon/clone2.png",x=width+42} or nil,
        isClone and {layer = gen_screen_nb(tag.getscreen(isClone)),x=width+42} or nil
    })
    cr:move_to(theme.default_height+2,theme.default_height-6)
    cr:set_source(color(theme.bg_normal))
    cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(theme.default_height-6)
    cr:show_text(idx)
    taglist_cache[t] = taglist_cache[t] or {}
    taglist_cache[t][hash] = img2
    return  img2
end


local task_cache = {}
local arr,arr1=themeutils.get_end_arrow2({bg_color=theme.bg_normal}),themeutils.get_end_arrow2({bg_color=theme.bg_normal,direction="left"})

local function gen_task_bg_real(wdg,width)
   local c,m,image = wdg.data.c,wdg.data.m,wdg.data.image
   local hash = width..(image or "nil")..(client.floating.get(c) and "c" or "")..(c.ontop == true and "o" or "")..(c.sticky == true and "s" or "")
    if task_cache[c] and task_cache[c][hash] then
        return task_cache[c][hash]
    end
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, width, theme.default_height)
    cr = cairo.Context(img2)
    if image then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(image))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    end

    local composed,offset  = {img2,arr1},60
    if c.icon then
       -- Resize
        local ic = cairo.Surface(c.icon)
        local sw,sh = ic:get_width(),ic:get_height()
        local ratio = ((sw > sh) and sw or sh) / (theme.default_height-4)
        local matrix = cairo.Matrix()
        cairo.Matrix.init_scale(matrix,ratio,ratio)
        matrix:translate(-theme.default_height/2 - 6,-2)

       -- Add to stack
       composed[#composed+1] = {layer = c.icon, matrix = matrix ,y=1,}
    end

    local function gen_matrix(image,off)
        local ic = cairo.ImageSurface.create_from_png(image)
        local sw,sh = ic:get_width(),ic:get_height()
        local ratio = sh/(theme.default_height)
        local status_matrix = cairo.Matrix()
        cairo.Matrix.init_scale(status_matrix,ratio,ratio)
        offset = sw/ratio + 5/ratio
        status_matrix:translate(-(width-(off or offset)),0)
        return status_matrix
    end

    local tmp_offset = offset
    if client.floating.get(c) then
        local path  = theme["tasklist_floating".. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path)}
        tmp_offset = offset*2
    end
    if c.ontop == true then
        local path  = theme["tasklist_ontop"   .. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,tmp_offset)}
        tmp_offset = tmp_offset + offset
    end
    if c.sticky == true then
        local path  = theme["tasklist_sticky"  .. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,tmp_offset)}
    end
    composed[#composed+1] = {layer = arr,y=0,x=width-theme.default_height/2+1}
    img2 = themeutils.compose(composed)
    task_cache[c] = task_cache[c] or {}
    task_cache[c][hash] = cairo.Pattern.create_for_surface(img2)
    return  cairo.Pattern.create_for_surface(img2)
end

local function task_widget_draw(self,w, cr, width, height)
   local pattern =  gen_task_bg_real(self,width)
   cr:set_source(pattern)
   cr:paint()
   cr:update_layout(self._layout)
    local ink, logical = self._layout:get_pixel_extents()
    local offset = 0
    if self._valign == "center" then
        offset = (height - logical.height) / 2
    elseif self._valign == "bottom" then
        offset = height - logical.height
    end
    cr:move_to(theme.default_height/2 + (self.data.c.icon and theme.default_height + 12 or 6), offset)
    cr:show_layout(self._layout)
end

local function gen_task_bg(wdg,c,m,objects,image)
    m:set_margins(0)
    wdg.data = {image=image,c=c,m=m}
    wdg.draw = task_widget_draw
    return nil
end


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                       TAGLIST/TASKLIST                                           --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- Display the taglist squares
theme.taglist_bg_image_empty           = nil
theme.taglist_bg_image_selected        = confdir .. "/theme/darkBlue/Icon/bg/selected_bg.png"
theme.taglist_bg_image_used            = confdir .. "/theme/darkBlue/Icon/bg/used_bg.png"
theme.taglist_bg_image_urgent          = confdir .. "/theme/darkBlue/Icon/bg/urgent_bg.png"
theme.taglist_bg_image_remote_selected = confdir .. "/theme/darkBlue/Icon/bg/selected_bg_green.png"
theme.taglist_bg_image_remote_used     = confdir .. "/theme/darkBlue/Icon/bg/used_bg_green.png"
theme.taglist_squares_unsel            = function(wdg,m,t,objects,idx) return gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_used)     end
theme.taglist_squares_sel              = function(wdg,m,t,objects,idx) return gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
theme.taglist_squares_sel_empty        = function(wdg,m,t,objects,idx) return gen_tag_bg(wdg,m,t,objects,idx,theme.taglist_bg_image_selected) end
theme.taglist_squares_unsel_empty      = function(wdg,m,t,objects,idx) return gen_tag_bg(wdg,m,t,objects,idx,nil)     end
theme.taglist_disable_icon             = true
theme.bg_image_normal                  = function(wdg,m,t,objects) return gen_task_bg(wdg,m,t,objects,nil)     end
theme.bg_image_focus                   = function(wdg,m,t,objects) return gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_used)     end
theme.bg_image_urgent                  = function(wdg,m,t,objects) return gen_task_bg(wdg,m,t,objects,theme.taglist_bg_image_urgent)     end
theme.bg_image_minimize                = function(wdg,m,t,objects) return gen_task_bg(wdg,m,t,objects,nil)     end
theme.tasklist_disable_icon            = true



------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                               MENU                                               --
--                                                                                                  --
------------------------------------------------------------------------------------------------------


-- Variables set for theming menu
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon         = confdir .. "/theme/darkBlue/Icon/tags/arrow.png"
theme.menu_scrollmenu_down_icon = confdir .. "/theme/darkBlue/Icon/tags/arrow_down.png"
theme.menu_scrollmenu_up_icon   = confdir .. "/theme/darkBlue/Icon/tags/arrow_up.png"
theme.awesome_icon              = confdir .. "/theme/darkBlue/Icon/awesome2.png"
theme.menu_height               = 20
theme.menu_width                = 130
theme.menu_border_width         = 2
theme.border_width              = 1
theme.border_color              = theme.fg_normal
theme.wallpaper = "/home/lepagee/bg/final/bin_ascii_ds.png"


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
theme.titlebar_close_button_normal = confdir .. "/theme/darkBlue/Icon/titlebar/close_normal_inactive.png"
theme.titlebar_close_button_focus = confdir .. "/theme/darkBlue/Icon/titlebar/close_focus_inactive.png"

theme.titlebar_ontop_button_normal_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = confdir .. "/theme/darkBlue/Icon/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = confdir .. "/theme/darkBlue/Icon/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = confdir .. "/theme/darkBlue/Icon/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = confdir .. "/theme/darkBlue/Icon/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = confdir .. "/theme/darkBlue/Icon/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = confdir .. "/theme/darkBlue/Icon/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = confdir .. "/theme/darkBlue/Icon/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = confdir .. "/theme/darkBlue/Icon/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = confdir .. "/theme/darkBlue/Icon/titlebar/maximized_focus_active.png"

theme.titlebar_title_align = "left"
theme.titlebar_height = 16


------------------------------------------------------------------------------------------------------
--                                                                                                  --
--                                             LAYOUTS                                              --
--                                                                                                  --
------------------------------------------------------------------------------------------------------

-- You can use your own layout icons like this:
theme.layout_fairh           = confdir .. "/theme/darkBlue/Icon/layouts/fairh.png"
theme.layout_fairv           = confdir .. "/theme/darkBlue/Icon/layouts/fairv.png"
theme.layout_floating        = confdir .. "/theme/darkBlue/Icon/layouts/floating.png"
theme.layout_magnifier       = confdir .. "/theme/darkBlue/Icon/layouts/magnifier.png"
theme.layout_max             = confdir .. "/theme/darkBlue/Icon/layouts/max.png"
theme.layout_fullscreen      = confdir .. "/theme/darkBlue/Icon/layouts/fullscreen.png"
theme.layout_tilebottom      = confdir .. "/theme/darkBlue/Icon/layouts/tilebottom.png"
theme.layout_tileleft        = confdir .. "/theme/darkBlue/Icon/layouts/tileleft.png"
theme.layout_tile            = confdir .. "/theme/darkBlue/Icon/layouts/tile.png"
theme.layout_tiletop         = confdir .. "/theme/darkBlue/Icon/layouts/tiletop.png"
theme.layout_spiral          = confdir .. "/theme/darkBlue/Icon/layouts/spiral.png"
theme.layout_spiraldwindle   = confdir .. "/theme/darkBlue/Icon/layouts/spiral_d.png"

theme.layout_fairh_s         = confdir .. "/theme/darkBlue/Icon/layouts_small/fairh.png"
theme.layout_fairv_s         = confdir .. "/theme/darkBlue/Icon/layouts_small/fairv.png"
theme.layout_floating_s      = confdir .. "/theme/darkBlue/Icon/layouts_small/floating.png"
theme.layout_magnifier_s     = confdir .. "/theme/darkBlue/Icon/layouts_small/magnifier.png"
theme.layout_max_s           = confdir .. "/theme/darkBlue/Icon/layouts_small/max.png"
theme.layout_fullscreen_s    = confdir .. "/theme/darkBlue/Icon/layouts_small/fullscreen.png"
theme.layout_tilebottom_s    = confdir .. "/theme/darkBlue/Icon/layouts_small/tilebottom.png"
theme.layout_tileleft_s      = confdir .. "/theme/darkBlue/Icon/layouts_small/tileleft.png"
theme.layout_tile_s          = confdir .. "/theme/darkBlue/Icon/layouts_small/tile.png"
theme.layout_tiletop_s       = confdir .. "/theme/darkBlue/Icon/layouts_small/tiletop.png"
theme.layout_spiral_s        = confdir .. "/theme/darkBlue/Icon/layouts_small/spiral.png"
theme.layout_spiraldwindle_s = confdir .. "/theme/darkBlue/Icon/layouts_small/spiral_d.png"


return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
