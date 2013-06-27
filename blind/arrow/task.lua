local capi =  {timer=timer,client=client}
local awful      = require( "awful"          )
local color      = require( "gears.color"    )
local cairo      = require( "lgi"            ).cairo
local client     = require( "awful.client"   )
local themeutils = require( "blind.common.drawing"    )
local radical    = require( "radical"        )

local module = {}

-----------------------------------------------------------------------------
--1) Take the client icon                                                  --
--2) Resize and move it                                                    --
--3) Apply a few layers of color effects to desaturate, then tint the icon --
-----------------------------------------------------------------------------
local function apply_icon_transformations(c)
    -- Get size
    local ic = cairo.Surface(c.icon)
    local icp = cairo.Pattern.create_for_surface(ic)
    local sw,sh = ic:get_width(),ic:get_height()

    -- Create matrix
    local ratio = (module.theme.default_height-2) / ((sw > sh) and sw or sh)
    local matrix = cairo.Matrix()
    cairo.Matrix.init_scale(matrix,ratio,ratio)
    matrix:translate(module.theme.default_height/2 - 6,-2)

    --Copy to surface
    local img5 = cairo.ImageSurface.create(cairo.Format.ARGB32, sw, sh)
    local cr5 = cairo.Context(img5)
    cr5:set_operator(cairo.Operator.CREAR)
    cr5:paint()
    cr5:set_operator(cairo.Operator.SOURCE)
    cr5:set_matrix(matrix)
    cr5:set_source(icp)
    cr5:paint()

    --Generate the mask
    local img4 = cairo.ImageSurface.create(cairo.Format.A8, sw, sh)
    local cr4 = cairo.Context(img4)
    --cr4:set_matrix(matrix)
    cr4:set_source(icp)
    cr4:paint()

    -- Apply desaturation
    cr5:set_source_rgba(0,0,0,1)
    cr5:set_operator(cairo.Operator.HSL_SATURATION)
    cr5:mask(cairo.Pattern.create_for_surface(img4))
    cr5:set_operator(cairo.Operator.HSL_COLOR)
    if capi.client.focus == c then
        cr5:set_source(color(module.theme.fg_focus))
    elseif c.urgent then
        cr5:set_source(color(module.theme.bg_urgent))
    else
        cr5:set_source(color(module.theme.fg_normal))
    end
    cr5:mask(cairo.Pattern.create_for_surface(img4))
    return img5
end




--------------------------------------------------------------
--Generate the status (ontop,floating,sitcky) resize matrix --
--------------------------------------------------------------
local function gen_matrix(image,off,width)
    local ic = cairo.ImageSurface.create_from_png(image)
    local sw,sh = ic:get_width(),ic:get_height()
    local ratio = sh/(module.theme.default_height)
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
        local path  = module.theme["tasklist_floating".. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,nil,width)}
        tmp_offset = offset*2
    end
    if c.ontop == true then
        local path  = module.theme["tasklist_ontop"   .. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,tmp_offset,width)}
        tmp_offset = tmp_offset + offset
    end
    if c.sticky == true then
        local path  = module.theme["tasklist_sticky"  .. (image and "_focus" or "") .."_icon"]
        composed[#composed+1] = {layer=path,matrix=gen_matrix(path,tmp_offset,width)}
    end
end




--------------------------------------------------------------
-- Compose all layers to create the widget background image --
--------------------------------------------------------------
local task_cache = {}
local icon_cache = setmetatable({}, { __mode = "kv" })
local arr,arr1=nil,nil
local function gen_task_bg_real(wdg,width,args)
    if not arr1 then
        arr,arr1=themeutils.get_end_arrow2({bg_color=module.theme.bg_normal}),themeutils.get_end_arrow2({bg_color=module.theme.bg_normal,direction="left"})
    end
    local c,m,image = wdg.data.c,wdg.data.m,nil
    if c.urgent then
        image = module.theme.taglist_bg_image_urgent
    else
        image = wdg.data.image
    end

    local hash = width..(image or "nil")..(client.floating.get(c) and "c" or "")..(c.ontop == true and "o" or "")..(c.sticky == true and "s" or "")..(c.urgent and "u" or "")
    if task_cache[c] and task_cache[c][hash] then
        return task_cache[c][hash]
    end
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, width, module.theme.default_height)
    cr = cairo.Context(img2)
    if image then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(image))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    end

    local composed,offset  = {img2,arr1},60
    if not icon_cache[c.icon] then
        icon_cache[c.icon] = {}
    end
    if c.icon and not icon_cache[c.icon][(c.urgent and "u" or "") .. ((capi.client.focus == c) and "f" or "")] then
        --Cache
        icon_cache[c.icon][(c.urgent and "u" or "") .. ((capi.client.focus == c) and "f" or "")] = apply_icon_transformations(c)
    end

    if c.icon then
       composed[#composed+1] = {layer = icon_cache[c.icon][(c.urgent and "u" or "") .. ((capi.client.focus == c) and "f" or "")] ,y=2,x=module.theme.default_height/2 + 6}
    end

    if not args.no_marker then
        add_status_indicator(composed,c,image,width,offset)
    end
    composed[#composed+1] = {layer = arr,y=0,x=width-module.theme.default_height/2+1}
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
   local pattern =  gen_task_bg_real(self,width,args)
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

    cr:select_font_face(module.theme.font, cairo.FontSlant.NORMAL, cairo.FontWeight.NORMAL)
    if capi.client.focus == self.data.c then
        cr:set_source(color(awful.util.color_strip_alpha(module.theme.fg_focus)))
    elseif self.data.c.urgent then
        cr:set_source(color(awful.util.color_strip_alpha(module.theme.fg_urgent)))
    else
        cr:set_source(color(awful.util.color_strip_alpha(module.theme.fg_normal)))
    end

    local extents = cr:text_extents(self.data.c.name)

    local x_offset = module.theme.default_height/2 + (self.data.c.icon and module.theme.default_height + 12 or 6)

    if width-x_offset-height/2 -4 < extents.width then
        local rad = height/11
        for i=0,2 do
            cr:arc(width-height/2 -2 - i*3*rad,height/2 + rad/2,rad,0,2*math.pi)
        end
        cr:fill()
        cr:rectangle(x_offset,0,width-x_offset-height/2 - 1 - 9*rad,height)
        cr:clip()
    end
    cr:move_to(x_offset, extents.height + (height - extents.height)/2 - 1)
    local prefix = ""
    cr:show_text(prefix..(self.data.c.name or "N/A"))

    if width-x_offset-height/2 -4 < extents.width then
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
            if not data.menu then
                data.menu = radical.context({layout=radical.layout.horizontal,item_width=140,item_height=140,icon_size=100,arrow_type=radical.base.arrow_type.CENTERED})
                data.item = data.menu:add_item({text = "<b>"..data.c.name.."</b>",icon=data.c.content})
                data.menu.wibox.opacity=0.8
            end
            data.item.icon = data.c.content
            data.item.text  = "<b>"..data.c.name.."</b>"
            data.menu.parent_geometry = data.geom
            data.menu.visible = true
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
    if not wdg.hover_ready then
        wdg:connect_signal("mouse::enter", function(_,geo)
            handle_preview(geo,data)
        end)
        wdg:connect_signal("mouse::leave", function()
            if data.time and data.time.started then
                data.time:stop()
            end
            if data.menu and data.menu.visible then
                data.menu.visible = false
            end
        end)
        wdg.hover_ready = true
    end
    return nil
end

return module