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
local debug      = debug
local print = print

local module = {}

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
    screen_nb_cache[nb] = img
    return img
end

local taglist_cache = {}

local arr_tag      = nil--themeutils.get_end_arrow2({ bg_color=module.theme.fg_normal    })
local arr_last_tag = nil--themeutils.get_end_arrow2({ bg_color=module.theme.bg_alternate })
local arr1_tag     = nil--themeutils.get_beg_arrow2({ fg_color=module.theme.bg_normal    })

function module.gen_tag_bg(wdg,t,m,objects,idx,image)
    if not arr_tag then
        arr_tag      = themeutils.get_end_arrow2({ bg_color=module.theme.fg_normal    })
        arr_last_tag = themeutils.get_end_arrow2({ bg_color=module.theme.bg_alternate })
        arr1_tag     = themeutils.get_beg_arrow2({ fg_color=module.theme.bg_normal    })
    end
    local width = wdg:fit(-1, -1)
    local hash = width..(image or "nil")..(objects[#objects] == t and ";" or "")..idx..(tag.getproperty(t,"clone_of") and "c" or "")
    if taglist_cache[t] and taglist_cache[t][hash] then
        if tag.getproperty(t,"clone_of") then
            wdg:set_markup("<span color='#006A1F'>"..t.name.."</span>")
        end
        return taglist_cache[t][hash]
    end
    local isClone = tag.getproperty(t,"clone_of")
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, width+(19+2*module.theme.default_height)+(isClone and 20 or 0), module.theme.default_height)
    m:set_left(module.theme.default_height+module.theme.default_height+7)
    m:set_right(module.theme.default_height/2+(isClone and 20 or 0))
    local cr = cairo.Context(img2)
    if isClone then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(module.theme.taglist_bg_image_remote_used))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    elseif image then
        local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(image))
        cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
        cr:set_source(pat)
        cr:paint()
    end
    cr:set_source(color(module.theme.fg_normal))
    cr:rectangle(0,0,module.theme.default_height+module.theme.default_height/2+5,module.theme.default_height)
    cr:fill()
    local icon = tag.geticon(t) or path .."Icon/tags_invert/other.png"
    img2 = themeutils.compose({
        img2,
        {layer=icon,x=2,y=0,scale=true,height=module.theme.default_height+2},
        {layer=arr1_tag,x=module.theme.default_height+module.theme.default_height/2+5,y=0},
        {layer = objects[#objects] ~= t and arr_tag or arr_last_tag,y=0,x=width+ (module.theme.default_height+3*(module.theme.default_height/2)+11) - module.theme.default_height/2 + 5 -9+(isClone and 20 or 0)},
        isClone and {layer=path .."Icon/clone2.png",x=width+42} or nil,
        isClone and {layer = gen_screen_nb(tag.getscreen(isClone)),x=width+42} or nil
    })
    cr:move_to(module.theme.default_height+2,module.theme.default_height-6)
    cr:set_source(color(module.theme.bg_normal))
    cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
    cr:set_font_size(module.theme.default_height-6)
    cr:show_text(idx)
    taglist_cache[t] = taglist_cache[t] or {}
    taglist_cache[t][hash] = img2
    return  img2
end

return module