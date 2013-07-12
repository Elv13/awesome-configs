local capi =  {timer=timer,client=client,tag=tag}
local awful      = require( "awful"          )
local color      = require( "gears.color"    )
local cairo      = require( "lgi"            ).cairo
local surface    = require( "gears.surface")
local tag        = require( "awful.tag"      )
local themeutils = require( "blind.common.drawing"    )
local print,type = print,type

local module = {}

----------------------------------------------------------------
-- Watch urgent clients and set the tag to urgent accordingly --
----------------------------------------------------------------
capi.tag.add_signal("property::urgent")
local function watch_urgent(c)
    local modif = c.urgent == true and 1 or -1
    for k,t in ipairs(c:tags()) do
        local current = (awful.tag.getproperty(t,"urgent") or 0)
        if current + modif < 0 then
            awful.tag.setproperty(t,"urgent",0)
        else
            awful.tag.setproperty(t,"urgent",(awful.tag.getproperty(t,"urgent") or 0) + modif)
        end
    end
end
capi.client.connect_signal("manage", function(c)
    c:connect_signal("property::urgent",watch_urgent)
    if c.urgent then
        watch_urgent(c)
    end
end)
capi.client.connect_signal("unmanage", function(c)
    c:disconnect_signal("property::urgent",watch_urgent)
end)





-------------------------------------------------------
-- Get or draw the pixmap for the absolute tag index --
-------------------------------------------------------
local screen_nb_cache = {}
local function gen_screen_nb(nb)
    if screen_nb_cache[nb] then return screen_nb_cache[nb] end
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, module.theme.default_height, module.theme.default_height)
    cr = cairo.Context(img)
    cr:move_to(5,11)
    cr:set_source(color("#005500"))
    cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(10)
    cr:show_text(nb)
    if not nb then return nil end
    screen_nb_cache[nb] = img
    return img
end



----------------
-- Render tag --
----------------
local taglist_cache = {}
local arr_tag      = nil
local arr_last_tag = nil
local arr1_tag     = nil
function module.gen_tag_bg(wdg,t,m,objects,idx,image)
    if not arr_tag then
        arr_tag      = themeutils.get_end_arrow2({ bg_color=module.theme.fg_normal    })
        arr_last_tag = themeutils.get_end_arrow2({ bg_color=module.theme.bg_alternate })
        arr1_tag     = themeutils.get_beg_arrow2({ fg_color=module.theme.bg_normal    })
    end
    
    wdg.draw = function(self,w, cr, width, height,args)
        local ink, logical = self._layout:get_pixel_extents()
        themeutils.draw_text(cr,self._layout,x_offset,(height-logical.height)/2 - ink.y/4,module.theme.enable_glow or false,module.theme.glow_color)
    end
    
    local width = wdg:fit(-1, -1)
    if (awful.tag.getproperty(t,"urgent") or 0) > 0 and not t.selected then
        image = module.theme.taglist_bg_image_urgent
    end
    local is_fct = type(image) == "function"
    local hash = width..(is_fct and "fct" or image or "nil")..(objects[#objects] == t and ";" or "")..idx..(tag.getproperty(t,"clone_of") and "c" or "")
    if taglist_cache[t] and taglist_cache[t][hash] then
        if tag.getproperty(t,"clone_of") then
            wdg:set_markup("<span color='#006A1F'>"..t.name.."</span>")
        end
        return taglist_cache[t][hash]
    end
    local isClone = tag.getproperty(t,"clone_of")
    local real_width = width+(19+2*module.theme.default_height)+(isClone and 20 or 0)
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, real_width, module.theme.default_height)
    m:set_left(module.theme.default_height+module.theme.default_height+7)
    m:set_right(module.theme.default_height/2+(isClone and 20 or 0))
    local cr = cairo.Context(img2)
    if isClone then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(module.theme.taglist_bg_image_remote_used))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    elseif is_fct then
        image(cr,real_width+20,module.theme.default_height)
    elseif image then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(image))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    end
    cr:set_source(color(module.theme.fg_normal))
    cr:rectangle(0,0,module.theme.default_height+module.theme.default_height/2+5,module.theme.default_height)
    cr:fill()
    local col = color(module.theme.bg_normal)
    cr:set_source(col)

    -- Apply a color/gradient on top of the icon
    local icon = tag.geticon(t) or module.theme.path .."Icon/tags_invert/other.png"
    if icon and module.theme.monochrome_icons then
        themeutils.apply_color_mask(icon,col)
    end

    img2 = themeutils.compose({
        img2,
        {layer=icon,x=2,y=1--[["align"]],scale=true,height=module.theme.default_height+2},
        {layer=arr1_tag,x=module.theme.default_height+module.theme.default_height/2+5,y=0},
        {layer = objects[#objects] ~= t and arr_tag or arr_last_tag,y=0,x=width+ (module.theme.default_height+3*(module.theme.default_height/2)+11) - module.theme.default_height/2 + 5 -9+(isClone and 20 or 0)},
        isClone and {layer=module.theme.path .."Icon/clone2.png",x=width+42} or nil,
        isClone and {layer = gen_screen_nb(tag.getscreen(isClone)),x=width+42} or nil
    })
    cr:move_to(module.theme.default_height+2,module.theme.default_height-5)
    cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(module.theme.default_height-6)
    cr:show_text(idx)
    taglist_cache[t] = taglist_cache[t] or {}
    taglist_cache[t][hash] = img2
    return  img2
end

return module