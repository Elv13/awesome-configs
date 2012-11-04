local setmetatable = setmetatable
local button       = require( "awful.button"             )
local beautiful    = require( "beautiful"                )
local util         = require( "awful.util"               )
local menu         = require( "widgets.menu"             )
local tooltip      = require( "widgets.tooltip"          )
local fdutils      = require( "extern.freedesktop.utils" )
local themeutils   = require( "utils.theme"              )
local capi = { image  = image  ,
               screen = screen ,
               widget = widget }

module("customMenu.application")
fdutils.icon_theme = 'oxygen'

all_menu_dirs = { '/usr/share/applications/', '/usr/local/share/applications/',
    '~/.local/share/applications/', '/home/kde-devel/kde/share/applications/' }

show_generic_name = false

fdutils.add_base_path ( "/home/kde-devel/kde/share/icons/"         )
fdutils.add_theme_path( "/home/kde-devel/kde/share/icons/hicolor/" )
local function gen_menu(arg)
    local programs,config = {},arg or {}

    local categories = {'AudioVideo','Development','Education','Game','Graphics','Network','Office','Settings','System','Utility','Other'}
    for i=1,#categories do
        programs[categories[i]] = menu({has_decoration=false})
    end

    local m = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,maxvisible=20})
    local item = m:add_item({text = "System Tools", icon = fdutils.lookup_icon({ icon = 'applications-system.png'     , icon_size='22x22' }), subMenu = programs[ 'System'      ] })
    local item = m:add_item({text = "Settings"    , icon = fdutils.lookup_icon({ icon = 'preferences-desktop.png'     , icon_size='22x22' }), subMenu = programs[ 'Settings'    ] })
    local item = m:add_item({text = "Other"       , icon = fdutils.lookup_icon({ icon = 'applications-other.png'      , icon_size='22x22' }), subMenu = programs[ 'Other'       ] })
    local item = m:add_item({text = "Office"      , icon = fdutils.lookup_icon({ icon = 'applications-office.png'     , icon_size='22x22' }), subMenu = programs[ 'Office'      ] })
    local item = m:add_item({text = "Multimedia"  , icon = fdutils.lookup_icon({ icon = 'applications-multimedia.png' , icon_size='22x22' }), subMenu = programs[ 'AudioVideo'  ] })
    local item = m:add_item({text = "Internet"    , icon = fdutils.lookup_icon({ icon = 'applications-internet.png'   , icon_size='22x22' }), subMenu = programs[ 'Network'     ] })
    local item = m:add_item({text = "Graphics"    , icon = fdutils.lookup_icon({ icon = 'applications-graphics.png'   , icon_size='22x22' }), subMenu = programs[ 'Graphics'    ] })
    local item = m:add_item({text = "Games"       , icon = fdutils.lookup_icon({ icon = 'applications-games.png'      , icon_size='22x22' }), subMenu = programs[ 'Game'        ] })
    local item = m:add_item({text = "Education"   , icon = fdutils.lookup_icon({ icon = 'applications-science.png'    , icon_size='22x22' }), subMenu = programs[ 'Education'   ] })
    local item = m:add_item({text = "Development" , icon = fdutils.lookup_icon({ icon = 'applications-development.png', icon_size='22x22' }), subMenu = programs[ 'Development' ] })
    local item = m:add_item({text = "Accessories" , icon = fdutils.lookup_icon({ icon = 'applications-accessories.png', icon_size='22x22' }), subMenu = programs[ 'Utility'     ] })

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
                programs[target_category]:add_item({text = program.Name, icon = program.icon_path,onclick = function() util.spawn(program.cmdline,true) end})
            end
        end
    end
    return m
end



function new(screen, args)
    local tt = tooltip("Classic application menu",{down=true})


    local mylaunchertext     = capi.widget({ type = "textbox" })
    mylaunchertext:margin({ left = 30,right=17})
    mylaunchertext.text      = "Apps"
    mylaunchertext.bg_resize = false

    local head_img      = capi.image(beautiful.awesome_icon)
    local extents       = mylaunchertext:extents()
    extents.height      = 16
    local normal_bg_img = themeutils.gen_button_bg(head_img,extents,false)
    local focus_bg_img  --= themeutils.gen_button_bg(head_img,extents,true )

    mylaunchertext.bg_image  = normal_bg_img

    mylaunchertext:add_signal("mouse::enter", function()
        tt:showToolTip(true)
        if not focus_bg_img then 
            focus_bg_img  = themeutils.gen_button_bg(head_img,extents,true )
        end
        mylaunchertext.bg_image = focus_bg_img
    end)
    mylaunchertext:add_signal("mouse::leave", function() tt:showToolTip(false);mylaunchertext.bg_image = normal_bg_img  end)

    mylaunchertext:buttons( util.table.join(
        button({ }, 1, function()
            tt:showToolTip(false)
            mymainmenu = mymainmenu or gen_menu()
            mymainmenu:toggle()
        end)
    ))
    return mylaunchertext
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })