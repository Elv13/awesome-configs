local capi =  {timer=timer,client=client}
local awful      = require( "awful"          )
local color      = require( "gears.color"    )
local cairo      = require( "lgi"            ).cairo
local client     = require( "awful.client"   )
local themeutils = require( "blind.common.drawing"    )
local radical    = require( "radical"        )
local wibox      = require( "wibox" )
local beautiful  = require( "beautiful" )

local module = {}



--------------------------------------------------------------
--Generate the status (ontop,floating,sitcky) resize matrix --
--------------------------------------------------------------
local function gen_matrix(image,off,width)
    local ic = cairo.ImageSurface.create_from_png(image)
    local sw,sh = ic:get_width(),ic:get_height()
    local ratio = sh/(beautiful.default_height)
    local status_matrix = cairo.Matrix()
    cairo.Matrix.init_scale(status_matrix,ratio,ratio)
    offset = sw/ratio + 5/ratio
    status_matrix:translate(-(width-(off or offset)),0)
    return status_matrix
end




--------------------------------------------------
-- Add status indicator to the composited image --
--------------------------------------------------
local function add_status_indicator(composed,c,image,width)
    local tmp_offset = offset
    if client.floating.get(c) then
        local path  = beautiful["tasklist_floating".. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,nil,width)}
        tmp_offset = offset*2
    end
    if c.ontop == true then
        local path  = beautiful["tasklist_ontop"   .. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,tmp_offset,width)}
        tmp_offset = tmp_offset + offset
    end
    if c.sticky == true then
        local path  = beautiful["tasklist_sticky"  .. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,tmp_offset,width)}
    end
end




--------------------------------------------------------------
-- Compose all layers to create the widget background image --
--------------------------------------------------------------
local task_cache = {}
local icon_cache = setmetatable({}, { __mode = "kv" })
local arr,arr1=nil,nil
local function gen_task_bg_real(wdg,width,args,col,image)
    if not arr1 then
        arr,arr1=themeutils.get_end_arrow2({bg_color=beautiful.bg_normal}),themeutils.get_end_arrow2({bg_color=beautiful.bg_normal,direction="left"})
    end
    local c,m = wdg.data.c,wdg.data.m
    local height = args.height or beautiful.default_height
    local hash = width..(image or "nil")..(client.floating.get(c) and "c" or "")..(c.ontop == true and "o" or "")..
        (c.sticky == true and "s" or "")..(c.urgent and "u" or "")..(height)
    if task_cache[c] and task_cache[c][hash] then
        return task_cache[c][hash]
    end
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
    cr = cairo.Context(img2)
    if image then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(image))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    end

    local composed,offset  = {img2,arr1},60
    if c.icon then
        if not icon_cache[c.icon] then
            icon_cache[c.icon] = {}
        end
        if c.icon and not icon_cache[c.icon][(c.urgent and "u" or "") .. ((capi.client.focus == c) and "f" or "")] then
            --Cache
            icon_cache[c.icon][(c.urgent and "u" or "") .. ((capi.client.focus == c) and "f" or "")] = themeutils.apply_icon_transformations(c.icon,col)
        end

        if c.icon then
            composed[#composed+1] = {layer = icon_cache[c.icon][(c.urgent and "u" or "") .. ((capi.client.focus == c) and "f" or "")] ,y=2,x=height/2 + 6}
        end
    end

    if not args.no_marker then
        add_status_indicator(composed,c,image,width,offset)
    end
    composed[#composed+1] = {layer = arr,y=0,x=width-height/2+1}
    img2 = themeutils.compose(composed)
    task_cache[c] = task_cache[c] or {}
    task_cache[c][hash] = cairo.Pattern.create_for_surface(img2)
    return  cairo.Pattern.create_for_surface(img2)
end




-----------------------------------------------------------------------------------------
-- Overload the widget :draw() method to have more control over how the text is drawn. --
-- This is necessary to implement the "..." dots as I want them to look                --
-----------------------------------------------------------------------------------------
function module.task_widget_draw(self,w, cr, width, height,args)
   args = args or {}
   args.height = height
   local col,image = nil,nil
    if capi.client.focus == self.data.c then
        col   = color(awful.util.color_strip_alpha(beautiful.fg_focus))
        image = beautiful.tasklist_bg_image_selected or beautiful.taglist_bg_image_selected
    elseif self.data.c.urgent then
        col   = color(awful.util.color_strip_alpha(beautiful.fg_urgent))
        image = beautiful.taglist_bg_image_urgent
    else
        col   = color(awful.util.color_strip_alpha(beautiful.fg_normal))
        image = self.data.image
    end
    local pattern =  gen_task_bg_real(self,width,args,col,image)
    cr:set_source(pattern)
    cr:paint()
    cr:set_source(col)
    cr:update_layout(self._layout)
    local ink, logical = self._layout:get_pixel_extents()
    local offset = 0
    if self._valign == "center" then
        offset = (height - logical.height) / 2
    elseif self._valign == "bottom" then
        offset = height - logical.height
    end
    self._layout:set_font_description(beautiful.get_font(beautiful.font))
--     cr:select_font_face(beautiful.get_font(beautiful.font), cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)

    local x_offset = beautiful.default_height/2 + (self.data.c.icon and beautiful.default_height + 12 or 6)

    if width-x_offset-height/2 -4 < logical.width then
        local rad = height/11
        for i=0,2 do
            cr:arc(width-height/2 -2 - i*3*rad,height/2 + rad/2,rad,0,2*math.pi)
        end
        cr:fill()
        cr:rectangle(x_offset,0,width-x_offset-height/2 - 1 - 9*rad,height)
        cr:clip()
    end

    themeutils.draw_text(cr,self._layout,x_offset,(height-logical.height)/2 - ink.y/4,beautiful.enable_glow or false,self.data.c.urgent and "#220000" or beautiful.glow_color)

    if width-x_offset-height/2 -4 < logical.width then
        cr:reset_clip()
    end
end




--------------------------------------------------------------------------------
-- Display a preview popup if the cursor stay on the widget for over a second --
--------------------------------------------------------------------------------
local function handle_preview(geo,data)
    if not data.time then
        data.time = capi.timer({})
        data.time.timeout = 1
        data.time:connect_signal("timeout",function()
            beautiful.on_task_hover(data.c,geo,true)
            data.time:stop()
        end)
    end
    data.geom = geo
    data.time:start()
end




------------------
-- "Constrctor" --
------------------
function module.gen_task_bg(wdg,c,m,objects,image)
    m:set_margins(0)
    wdg.data = {image=image,c=c,m=m}
    wdg.draw = module.task_widget_draw

    local data = {c=c}
    if not wdg.hover_ready and beautiful.on_task_hover then
        wdg:connect_signal("mouse::enter", function(_,geo)
            beautiful.on_task_hover(nil,nil,false)
            handle_preview(geo,data)
        end)
        wdg:connect_signal("mouse::leave", function()
            if data.time and data.time.started then
                data.time:stop()
            end
            beautiful.on_task_hover(data.c,geo,false)
        end)
        wdg.hover_ready = true
    end
    return nil
end

return module