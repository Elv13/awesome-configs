local capi =  {timer=timer,client=client,tag=tag}
local awful      = require( "awful"          )
local color      = require( "gears.color"    )
local cairo      = require( "lgi"            ).cairo
local surface    = require( "gears.surface")
local tag        = require( "awful.tag"      )
local themeutils = require( "blind.common.drawing"    )
local beautiful  = require( "beautiful" )
local print,type = print,type

local module = {}

----------------------------------------------------------------
--                 Handle on mouse over event                 --
----------------------------------------------------------------

local function setup_hover(wdg,t)
    if not wdg.hover_ready and beautiful.on_tag_hover then
        wdg:connect_signal("mouse::enter", function(_,geo)
        beautiful.on_tag_hover(nil,nil,false)
        if not wdg.timer then
            wdg.timer = capi.timer({})
            wdg.timer.timeout = 3
            wdg.timer:connect_signal("timeout",function()
                beautiful.on_tag_hover(t,geo,true)
                wdg.timer:stop()
            end)
        end
        wdg.timer:start()
        end)
        wdg:connect_signal("mouse::leave", function()
            if wdg.timer and wdg.timer.started then
                wdg.timer:stop()
            end
            beautiful.on_tag_hover(t,geo,false)
        end)
        wdg.hover_ready = true
    end
end

----------------------------------------------------------------
-- Watch urgent clients and set the tag to urgent accordingly --
----------------------------------------------------------------
-- capi.tag.add_signal("property::urgent")
-- local function watch_urgent(c)
--     local modif = c.urgent == true and 1 or -1
--     for k,t in ipairs(c:tags()) do
--         local current = (awful.tag.getproperty(t,"urgent") or 0)
--         if current + modif < 0 then
--             awful.tag.setproperty(t,"urgent",0)
--         else
--             awful.tag.setproperty(t,"urgent",(awful.tag.getproperty(t,"urgent") or 0) + modif)
--         end
--     end
-- end
-- capi.client.connect_signal("manage", function(c)
--     c:connect_signal("property::urgent",watch_urgent)
--     if c.urgent then
--         watch_urgent(c)
--     end
-- end)
-- capi.client.connect_signal("unmanage", function(c)
--     c:disconnect_signal("property::urgent",watch_urgent)
-- end)





-------------------------------------------------------
-- Get or draw the pixmap for the absolute tag index --
-------------------------------------------------------
local screen_nb_cache = {}
local function gen_screen_nb(nb)
    if screen_nb_cache[nb] then return screen_nb_cache[nb] end
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, beautiful.default_height, beautiful.default_height)
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
        arr_tag      = themeutils.get_end_arrow2({ bg_color=beautiful.icon_grad or beautiful.fg_normal    })
        arr_last_tag = themeutils.get_end_arrow2({ bg_color=beautiful.bg_alternate })
        arr1_tag     = themeutils.get_beg_arrow2({ bg_color=beautiful.icon_grad or beautiful.fg_normal    })
        local cr = cairo.Context(arr_last_tag)
        cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
        cr:set_line_width(1.5)
        cr:move_to(0,-2)
        cr:line_to(beautiful.default_height/2,beautiful.default_height/2)
        cr:line_to(0,beautiful.default_height+2)
        cr:stroke()
    end
    setup_hover(m,t)

    wdg.draw = function(self,w, cr, width, height,args)
        local ink, logical = self._layout:get_pixel_extents()
        themeutils.draw_text(cr,self._layout,x_offset,(height-logical.height)/2 - ink.y/4,beautiful.enable_glow or false,beautiful.glow_color)
    end

    local width = wdg:fit(-1, -1)
    if (awful.tag.getproperty(t,"urgent") or 0) > 0 and not t.selected then
        image = beautiful.taglist_bg_image_urgent
    end
    local is_fct = type(image) == "function"
    local isLast = objects[#objects] == t
    local isClone = tag.getproperty(t,"clone_of")

    --Set the margins before loading the cache
    local real_width = width+(19+2*beautiful.default_height)+(isClone and 20 or 0)+(isLast and 2 or 0)
    m:set_left(beautiful.default_height+beautiful.default_height+7)
    m:set_right(beautiful.default_height/2+(isClone and 20 or 0))

    --Create a low collision hash as the tags are often the exact same pixmap
    local hash = width..(is_fct and "fct" or image or "nil")..idx..(tag.getproperty(t,"clone_of") and "c" or "")..(isLast and ";" or "")
    if taglist_cache[t] and taglist_cache[t][hash] then
        if tag.getproperty(t,"clone_of") then
            wdg:set_markup("<span color='#006A1F'>"..t.name.."</span>")
        end
        return taglist_cache[t][hash]
    end
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, real_width, beautiful.default_height)
    local cr = cairo.Context(img2)
    if isClone then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(beautiful.taglist_bg_image_remote_used))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    elseif is_fct then
        image(cr,real_width+20,beautiful.default_height)
    elseif image then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(image))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    end
    cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
    cr:rectangle(0,0,beautiful.default_height+beautiful.default_height/2+5,beautiful.default_height)
    cr:fill()
    local col = color(beautiful.icon_grad_invert or beautiful.bg_normal)
    cr:set_source(col)

    -- Apply a color/gradient on top of the icon
    local icon = tag.geticon(t) or beautiful.path .."Icon/tags_invert/other.png"
    if icon and beautiful.monochrome_icons then
        icon=color.apply_mask(icon,col)
    end

    img2 = themeutils.compose({
        img2,
        {layer=icon,x=2,y=1--[["align"]],scale=true,height=beautiful.default_height+2},
        {layer=arr1_tag,x=beautiful.default_height+beautiful.default_height/2+5,y=0},
        {layer = (not isLast) and arr_tag or arr_last_tag,y=0,x=width+ (beautiful.default_height+3*(beautiful.default_height/2)+11) - beautiful.default_height/2 + 5 -9+(isClone and 20 or 0)+(isLast and -1 or 0)},
        isClone and {layer=beautiful.path .."Icon/clone2.png",x=width+42} or nil,
        isClone and {layer = gen_screen_nb(tag.getscreen(isClone)),x=width+42} or nil
    })
    cr:move_to(beautiful.default_height+2,beautiful.default_height-5)
    cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(beautiful.default_height-6)
    cr:show_text(idx)
    taglist_cache[t] = taglist_cache[t] or {}
    taglist_cache[t][hash] = img2
    return  img2
end

return module