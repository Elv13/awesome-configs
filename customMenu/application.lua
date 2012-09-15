local setmetatable = setmetatable
local table        = table
local print        = print
local pairs        = pairs
local ipairs       = ipairs
local button       = require( "awful.button"               )
local beautiful    = require( "beautiful"                  )
local util         = require( "awful.util"                 )
local menu2        = require( "awful.menu"                 )
local menu         = require( "widgets.menu"               )
local tooltip      = require( "widgets.tooltip"            )
local fdutils      = require( "extern.freedesktop.utils"   )
local fdmenu       = require( "extern.freedesktop.menu"    )
local fddesktop    = require( "extern.freedesktop.desktop" )
local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               mouse  = mouse  }

module("customMenu.application")
fdutils.icon_theme = 'oxygen'

local data = {}

all_menu_dirs = {
    '/usr/share/applications/',
    '/usr/local/share/applications/',
    '~/.local/share/applications/',
    '/home/kde-devel/kde/share/applications/'
}

show_generic_name = false

--- Create menus for applications
-- @param menu_dirs A list of application directories (optional).
-- @return A prepared menu w/ categories
fdutils.add_base_path("/home/kde-devel/kde/share/icons/")
fdutils.add_theme_path("/home/kde-devel/kde/share/icons/hicolor/")
local function gen_menu(arg)
    -- the categories and their synonyms where shamelessly copied from lxpanel
    -- source code.
    local programs = {}
    local config = arg or {}

    programs[ 'AudioVideo'  ] = menu({has_decoration=false})
    programs[ 'Development' ] = menu({has_decoration=false})
    programs[ 'Education'   ] = menu({has_decoration=false})
    programs[ 'Game'        ] = menu({has_decoration=false})
    programs[ 'Graphics'    ] = menu({has_decoration=false})
    programs[ 'Network'     ] = menu({has_decoration=false})
    programs[ 'Office'      ] = menu({has_decoration=false})
    programs[ 'Settings'    ] = menu({has_decoration=false})
    programs[ 'System'      ] = menu({has_decoration=false})
    programs[ 'Utility'     ] = menu({has_decoration=false})
    programs[ 'Other'       ] = menu({has_decoration=false})

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
        local dir = dirs[i]
        local entries = fdutils.parse_desktop_files({dir = dir,size='22x22',category='apps'})
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
                if not target_category then
                    target_category = 'Other'
                end
                if target_category then
                    local m2 = programs[target_category]
                    m2:add_item({text = program.Name, icon = program.icon_path,onclick = function() util.spawn(program.cmdline,true) end})
                end
            end
        end
    end

    return m
end

local function create_menu()
    return gen_menu()
end

function new(screen, args)
    local tt = tooltip("Classic application menu",{down=true})
    local mylaunchertext     = capi.widget({ type = "textbox" })
    mylaunchertext:margin({ left = 30,right=7})
    mylaunchertext.text      = "Apps"
    mylaunchertext.bg_image  = capi.image(beautiful.awesome_icon)
    mylaunchertext.bg_align  = "left"
    mylaunchertext.bg_resize = false

    mylaunchertext:add_signal("mouse::enter", function() tt:showToolTip(true) ;mylaunchertext.bg = beautiful.bg_highlight end)
    mylaunchertext:add_signal("mouse::leave", function() tt:showToolTip(false);mylaunchertext.bg = beautiful.bg_normal    end)

    mylaunchertext:buttons( util.table.join(
        button({ }, 1, function()
            tt:showToolTip(false)
            mymainmenu = mymainmenu or create_menu()
--             mymainmenu:toggle({x=0,coords={x=0,y=capi.screen[capi.mouse.screen].geometry.height}},{x=0},{x=0})
            mymainmenu:toggle()
        end)
    ))

    return mylaunchertext
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
