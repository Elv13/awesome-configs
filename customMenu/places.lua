local setmetatable = setmetatable
local string       = string
local io           = io
local print        = print
local os           = os
local table        = table
local button       = require( "awful.button"               )
local beautiful    = require( "beautiful"                  )
local util         = require( "awful.util"                 )
local menu         = require( "radical.context"            )
local config       = require( "config"                     )
local tooltip2     = require( "widgets.tooltip2"           )
local fdutil       = require( "extern.freedesktop.utils"   )
local themeutils   = require( "utils.theme"                )
local wibox        = require( "wibox"                      )
local style        = require( "radical.style.classic"      )
local item_style   = require( "radical.item_style.classic" )
local color        = require( "gears.color"                )
local cairo        = require( "lgi"                        ).cairo
local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               mouse  = mouse  }

module("customMenu.places")

local function read_kde_bookmark(offset)
    local m = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, 
    autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,maxvisible=20,style=style,item_style=item_style,
    show_filter=true})
    local f = io.open(os.getenv("HOME").. '/.kde/share/apps/kfileplaces/bookmarks.xml','r')
    local inBook=false
    local currentItem,toReturn = {},{}
    if f ~= nil then
        local line = f:read("*line")
        while line do
            inBook = (inBook or string.match(line,"<bookmark ")) and not string.match(line,"</bookmark>")
            currentItem.path  = currentItem.path  or (inBook and string.match(line,'<bookmark href=\"file://(.*)">'))
            currentItem.title = currentItem.title or (inBook and string.match(line,'<title>(.*)</title>'))
            if string.match(line,"<bookmark:icon") then
                currentItem.icon = string.match(line,'<bookmark:icon name=\"(.*)"/>')
                if currentItem.icon then
                    currentItem.icon = fdutil.lookup_icon({icon_sizes={"32x32"},icon=currentItem.icon})
                end
            end

            if string.match(line,"</bookmark") and currentItem.title and currentItem.path then
                local item = m:add_item({text =  currentItem.title, icon = currentItem.icon, onclick = function() util.spawn("dolphin " .. currentItem.path) end})
                currentItem = {}
            end
            line = f:read("*line")
        end
        f:close()
    end
    return m
end

function new(offset, args)
    local data = nil

    local mylauncher2text = wibox.widget.textbox()--capi.widget({ type = "textbox" })
    tooltip2(mylauncher2text,"Folder shortcut",{down=true})
--     mylauncher2text:margin({ left = 30,right = 17})
    mylauncher2text:set_text("Places")
    mylauncher2text.bg_align = "left"
    mylauncher2text.bg_resize = true

    local head_img      = config.data().iconPath .. "tags/home2.png"
--     local extents       = mylauncher2text:extents()
--     extents.height      = 16
--     local normal_bg_img = themeutils.gen_button_bg(head_img,extents,false) --TODO port
--     local focus_bg_img  --= themeutils.gen_button_bg(head_img,extents,true )

    local bgb = wibox.widget.background()
    local l = wibox.layout.fixed.horizontal()
    local m = wibox.layout.margin(mylauncher2text)
    m:set_right(10)
    l:add(m)
    l:fill_space(true)
    bgb:set_widget(l)    
    local wdg_width = mylauncher2text._layout:get_pixel_extents().width
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32,wdg_width+28+beautiful.default_height, beautiful.default_height)
    local arr = themeutils.get_end_arrow2({bg_color=beautiful.fg_normal})
    local arr2 = themeutils.get_beg_arrow2({bg_color=beautiful.fg_normal})
    local cr = cairo.Context(img2)
    local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(beautiful.taglist_bg_image_used))
    cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
    cr:set_source(pat)
    cr:paint()

    local ic = cairo.ImageSurface.create_from_png(head_img)
    local sw,sh = ic:get_width(),ic:get_height()
    local ratio = ((sw > sh) and sw or sh) / (beautiful.default_height)
    local matrix = cairo.Matrix()
    cairo.Matrix.init_scale(matrix,ratio,ratio)


    img2 = themeutils.compose({img2,{layer=ic,matrix=matrix},{layer=arr2,x=beautiful.default_height},{layer = arr,y=0,x=wdg_width+14+beautiful.default_height}})
    bgb:set_bgimage(img2)
    m:set_left(beautiful.default_height*1.5+3)

    mylauncher2text.bg_image = normal_bg_img

--     bgb:connect_signal("mouse::enter", function()
--         tt:showToolTip(true)
--         if not focus_bg_img then 
--             focus_bg_img  = themeutils.gen_button_bg(head_img,extents,true )
--         end
--         mylauncher2text.bg_image = focus_bg_img
--     end)
--     bgb:connect_signal("mouse::leave", function() tt:showToolTip(false);mylauncher2text.bg_image = normal_bg_img  end)

    bgb:buttons( util.table.join(
        button({ }, 1, function(geometry)
--         tt:showToolTip(false)
        data = data or read_kde_bookmark(offset)
--         data.settings.x = geometry.x
--         data.settings.y = geometry.drawable.drawable.geometry(geometry.drawable.drawable).y
--         data:set_coords(geometry.x,geometry.y)
        data.parent_geometry = geometry
        data.visible = not data.visible

    end)
    ))

    return bgb
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
