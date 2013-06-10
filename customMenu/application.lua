local setmetatable = setmetatable
local pairs = pairs
local print = print
local ipairs = ipairs
local button       = require( "awful.button"             )
local beautiful    = require( "beautiful"                )
local util         = require( "awful.util"               )
local menu         = require( "radical.context"          )
local tooltip      = require( "widgets.tooltip"          )
local mouse        = require( "awful.mouse"              )
local fdutils      = require( "extern.freedesktop.utils" )
local themeutils   = require( "utils.theme"              )
local wibox        = require("wibox")
local color = require("gears.color")
local cairo = require("lgi").cairo
local style = require("radical.style.classic")
local item_style = require("radical.item_style.classic")
local capi = { image   = image  ,
               screen  = screen ,
               mouse   = mouse  ,
               widget  = widget ,
               awesome = awesome}

local module = {}
fdutils.icon_theme = 'oxygen'

all_menu_dirs = { '/usr/share/applications/', '/usr/local/share/applications/',
    '~/.local/share/applications/', '/home/kde-devel/kde/share/applications/' }

show_generic_name = false

fdutils.add_base_path ( "/home/kde-devel/kde/share/icons/"         )
fdutils.add_theme_path( "/home/kde-devel/kde/share/icons/hicolor/" )
local function gen_menu(parent)
    local programs,config = {},arg or {}

    local categories = {'AudioVideo','Development','Education','Game','Graphics','Network','Office','Settings','System','Utility','Other'}
    for i=1,#categories do
        programs[categories[i]] = menu({has_decoration=false,style=style,item_style=item_style})
    end
    local m = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, 
    autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,maxvisible=20,style=style,item_style=item_style,
    show_filter=true})
    local item = m:add_item({text = "System Tools", icon = fdutils.lookup_icon({ icon = 'applications-system.png'     , icon_size='22x22' }), sub_menu = programs[ 'System'      ] })
    local item = m:add_item({text = "Settings"    , icon = fdutils.lookup_icon({ icon = 'preferences-desktop.png'     , icon_size='22x22' }), sub_menu = programs[ 'Settings'    ] })
    local item = m:add_item({text = "Other"       , icon = fdutils.lookup_icon({ icon = 'applications-other.png'      , icon_size='22x22' }), sub_menu = programs[ 'Other'       ] })
    local item = m:add_item({text = "Office"      , icon = fdutils.lookup_icon({ icon = 'applications-office.png'     , icon_size='22x22' }), sub_menu = programs[ 'Office'      ] })
    local item = m:add_item({text = "Multimedia"  , icon = fdutils.lookup_icon({ icon = 'applications-multimedia.png' , icon_size='22x22' }), sub_menu = programs[ 'AudioVideo'  ] })
    local item = m:add_item({text = "Internet"    , icon = fdutils.lookup_icon({ icon = 'applications-internet.png'   , icon_size='22x22' }), sub_menu = programs[ 'Network'     ] })
    local item = m:add_item({text = "Graphics"    , icon = fdutils.lookup_icon({ icon = 'applications-graphics.png'   , icon_size='22x22' }), sub_menu = programs[ 'Graphics'    ] })
    local item = m:add_item({text = "Games"       , icon = fdutils.lookup_icon({ icon = 'applications-games.png'      , icon_size='22x22' }), sub_menu = programs[ 'Game'        ] })
    local item = m:add_item({text = "Education"   , icon = fdutils.lookup_icon({ icon = 'applications-science.png'    , icon_size='22x22' }), sub_menu = programs[ 'Education'   ] })
    local item = m:add_item({text = "Development" , icon = fdutils.lookup_icon({ icon = 'applications-development.png', icon_size='22x22' }), sub_menu = programs[ 'Development' ] })
    local item = m:add_item({text = "Accessories" , icon = fdutils.lookup_icon({ icon = 'applications-accessories.png', icon_size='22x22' }), sub_menu = programs[ 'Utility'     ] })

    local dirs = config.menu_dirs or all_menu_dirs
    for i=1,#dirs do
        local entries = fdutils.parse_desktop_files({dir = dirs[i],size='22x22',category='apps'})
        for j=1, #entries do
            local program = entries[j]
            -- check whether to include in the menu
            if program.show and program.Name and program.cmdline then
                if show_generic_name and program.GenericName then
                    program.Name = program.Name .. ' (' .. program.GenericName .. ')'
                end
                local target_category = nil
                if program.categories then
                    for k=1, #program.categories do
                        local category = program.categories[k]
                        if programs[category] then
                            target_category = category
                            break
                        end
                    end
                end
                target_category = target_category or 'Other'
                program.Name = program.Name:gsub('&',"&amp;")
                programs[target_category]:add_item({text = program.Name, icon = program.icon_path,onclick = function() util.spawn(program.cmdline,true) end})
            end
        end
    end
    return m
end



local function new(screen, args)
    local tt = tooltip("Classic application menu",{down=true})


    local bgb = wibox.widget.background()
    local mylaunchertext     = wibox.widget.textbox()
    mylaunchertext:set_text("Apps")
    mylaunchertext.bg_resize = false
    local l = wibox.layout.fixed.horizontal()
    local m = wibox.layout.margin(mylaunchertext)
    m:set_right(10)
    l:add(m)
    l:fill_space(true)
    bgb:set_widget(l)
    local wdg_width = mylaunchertext._layout:get_pixel_extents().width
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32,wdg_width+28+beautiful.default_height, beautiful.default_height)
    local arr = themeutils.get_end_arrow2({bg_color=beautiful.fg_normal})
    local arr2 = themeutils.get_beg_arrow2({bg_color=beautiful.fg_normal})
    local cr = cairo.Context(img2)
    local pat = cairo.Pattern.create_for_surface(cairo.ImageSurface.create_from_png(beautiful.taglist_bg_image_used))
    cairo.Pattern.set_extend(pat,cairo.Extend.REPEAT)
    cr:set_source(pat)
    cr:paint()

    local ic = cairo.ImageSurface.create_from_png(beautiful.awesome_icon)
    local sh = ic:get_width(),ic:get_height()
    local ratio =  sh / (beautiful.default_height)
    local matrix = cairo.Matrix()
    cairo.Matrix.init_scale(matrix,ratio,ratio)

    img2 = themeutils.compose({img2,{layer=ic,matrix=matrix},{layer=arr2,x=beautiful.default_height},{layer = arr,y=0,x=wdg_width+14+beautiful.default_height}})
    bgb:set_bgimage(img2)
    m:set_left(beautiful.default_height*1.5+3)

    bgb:connect_signal("mouse::enter", function()
        tt:showToolTip(true)
--         print("TEST",mouse.wibox_under_pointer(),"end")
--         for k,v in ipairs(mouse.wibox_under_pointer() or {}) do
--             print(k,v)
--         end
        if not focus_bg_img then
--             focus_bg_img  = themeutils.gen_button_bg(head_img,extents,true )
        end
        mylaunchertext.bg_image = focus_bg_img
    end)
    bgb:connect_signal("mouse::leave", function() tt:showToolTip(false);mylaunchertext.bg_image = normal_bg_img  end)

    bgb:buttons( util.table.join(
        button({ }, 1, function(geometry)
            tt:showToolTip(false)
            mymainmenu = mymainmenu or gen_menu(bgb)
            mymainmenu.parent_geometry = geometry
            mymainmenu.visible = not mymainmenu.visible
        end)
    ))
    return bgb
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })