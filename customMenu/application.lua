local setmetatable = setmetatable
local pairs = pairs
local print = print
local ipairs = ipairs
local button       = require( "awful.button"             )
local beautiful    = require( "beautiful"                )
local util         = require( "awful.util"               )
local menu         = require( "radical.context"          )
local tooltip2      = require( "widgets.tooltip2"          )
local mouse        = require( "awful.mouse"              )
local fdutils      = require( "extern.freedesktop.utils" )
local themeutils   = require( "blind.common.drawing"              )
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


local categories = {AudioVideo=true,Development=true,Education=true,Game=true,Graphics=true,Network=true,Office=true,Settings=true,System=true,Utility=true,Other}

local programs = {}
local parse_init,cats = false,{}
local function parse_files()
    local dirs = all_menu_dirs
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
                        if categories[category] then
                            target_category = category
                            break
                        end
                    end
                end
                target_category = target_category or 'Other'
                program.Name = program.Name:gsub('&',"&amp;")
                local arr = cats[target_category]
                if not arr then
                    cats[target_category] = {}
                    arr = cats[target_category]
                end
                arr[#arr+1] = {text = program.Name, icon = program.icon_path,onclick = function() util.spawn(program.cmdline,true) end}
            end
        end
    end
    parse_init = true
end

local program2 = {}
local function gen_category_menu(cat)
    if program2[cat] then return program2[cat] end
    if not parse_init then parse_files() end
    local m = menu({has_decoration=false,style=style,item_style=item_style})
    for k,v in ipairs(cats[cat] or {}) do
        m:add_item(v)
    end
    program2[cat] = m
    return m
end

local function gen_menu(parent)
    local config = arg or {}

    local m = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, 
    autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,maxvisible=20,style=style,item_style=item_style,
    show_filter=true})
    local item = m:add_item({text = "System Tools", icon = fdutils.lookup_icon({ icon = 'applications-system.png'     , icon_size='22x22' }), sub_menu = function() return gen_category_menu('System'      ) end })
    local item = m:add_item({text = "Settings"    , icon = fdutils.lookup_icon({ icon = 'preferences-desktop.png'     , icon_size='22x22' }), sub_menu = function() return gen_category_menu('Settings'    ) end })
    local item = m:add_item({text = "Other"       , icon = fdutils.lookup_icon({ icon = 'applications-other.png'      , icon_size='22x22' }), sub_menu = function() return gen_category_menu('Other'       ) end })
    local item = m:add_item({text = "Office"      , icon = fdutils.lookup_icon({ icon = 'applications-office.png'     , icon_size='22x22' }), sub_menu = function() return gen_category_menu('Office'      ) end })
    local item = m:add_item({text = "Multimedia"  , icon = fdutils.lookup_icon({ icon = 'applications-multimedia.png' , icon_size='22x22' }), sub_menu = function() return gen_category_menu('AudioVideo'  ) end })
    local item = m:add_item({text = "Internet"    , icon = fdutils.lookup_icon({ icon = 'applications-internet.png'   , icon_size='22x22' }), sub_menu = function() return gen_category_menu('Network'     ) end })
    local item = m:add_item({text = "Graphics"    , icon = fdutils.lookup_icon({ icon = 'applications-graphics.png'   , icon_size='22x22' }), sub_menu = function() return gen_category_menu('Graphics'    ) end })
    local item = m:add_item({text = "Games"       , icon = fdutils.lookup_icon({ icon = 'applications-games.png'      , icon_size='22x22' }), sub_menu = function() return gen_category_menu('Game'        ) end })
    local item = m:add_item({text = "Education"   , icon = fdutils.lookup_icon({ icon = 'applications-science.png'    , icon_size='22x22' }), sub_menu = function() return gen_category_menu('Education'   ) end })
    local item = m:add_item({text = "Development" , icon = fdutils.lookup_icon({ icon = 'applications-development.png', icon_size='22x22' }), sub_menu = function() return gen_category_menu('Development' ) end })
    local item = m:add_item({text = "Accessories" , icon = fdutils.lookup_icon({ icon = 'applications-accessories.png', icon_size='22x22' }), sub_menu = function() return gen_category_menu('Utility'     ) end })

    return m
end



local function new(screen, args)
    local bgb = wibox.widget.background()
    local tt = tooltip2(bgb,"Classic application menu",{down=true})
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

    local ic = themeutils.apply_color_mask(beautiful.awesome_icon)
    local sh = ic:get_width(),ic:get_height()
    local ratio =  sh / (beautiful.default_height)
    local matrix = cairo.Matrix()
    cairo.Matrix.init_scale(matrix,ratio,ratio)

    img2 = themeutils.compose({img2,{layer=ic,matrix=matrix},{layer=arr2,x=beautiful.default_height},{layer = arr,y=0,x=wdg_width+14+beautiful.default_height}})
    bgb:set_bgimage(img2)
    m:set_left(beautiful.default_height*1.5+3)

    bgb:connect_signal("mouse::enter", function()
        if not focus_bg_img then
--             focus_bg_img  = themeutils.gen_button_bg(head_img,extents,true )
        end
        mylaunchertext.bg_image = focus_bg_img
    end)
    bgb:connect_signal("mouse::leave", function()mylaunchertext.bg_image = normal_bg_img  end)

    bgb:buttons( util.table.join(
        button({ }, 1, function(geometry)
            mymainmenu = mymainmenu or gen_menu(bgb)
            mymainmenu.parent_geometry = geometry
            mymainmenu.visible = not mymainmenu.visible
        end)
    ))
    return bgb
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })