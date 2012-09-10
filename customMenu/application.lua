local setmetatable = setmetatable
local table        = table
local print        = print
local pairs        = pairs
local ipairs       = ipairs
local button       = require( "awful.button"               )
local beautiful    = require( "beautiful"                  )
local util         = require( "awful.util"                 )
local menu         = require( "awful.menu"                 )
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
    '~/.local/share/applications/'
}

show_generic_name = false

--- Create menus for applications
-- @param menu_dirs A list of application directories (optional).
-- @return A prepared menu w/ categories
local function gen_menu(arg)
    -- the categories and their synonyms where shamelessly copied from lxpanel
    -- source code.
    local programs = {}
    local config = arg or {}

    programs[ 'AudioVideo' ] = {}
    programs[ 'Development'] = {}
    programs[ 'Education'  ] = {}
    programs[ 'Game'       ] = {}
    programs[ 'Graphics'   ] = {}
    programs[ 'Network'    ] = {}
    programs[ 'Office'     ] = {}
    programs[ 'Settings'   ] = {}
    programs[ 'System'     ] = {}
    programs[ 'Utility'    ] = {}
    programs[ 'Other'      ] = {}

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
                    local t = programs[target_category]
                    t[#t+1] = { program.Name, program.cmdline, program.icon_path }
--                     print("HERE",program.Name,#t)
                end
            end
        end
    end

    -- sort each submenu alphabetically case insensitive --Too slow
--     for k, v in pairs(programs) do
--         table.sort(v, function(a, b) return a[1]:lower() < b[1]:lower() end)
--     end

    local menu = {
        { "Accessories", programs["Utility"], fdutils.lookup_icon({ icon = 'applications-accessories.png', icon_size='22x22' }) },
        { "Development", programs["Development"], fdutils.lookup_icon({ icon = 'applications-development.png', icon_size='22x22' }) },
        { "Education", programs["Education"], fdutils.lookup_icon({ icon = 'applications-science.png', icon_size='22x22' }) },
        { "Games", programs["Game"], fdutils.lookup_icon({ icon = 'applications-games.png', icon_size='22x22' }) },
        { "Graphics", programs["Graphics"], fdutils.lookup_icon({ icon = 'applications-graphics.png', icon_size='22x22' }) },
        { "Internet", programs["Network"], fdutils.lookup_icon({ icon = 'applications-internet.png', icon_size='22x22' }) },
        { "Multimedia", programs["AudioVideo"], fdutils.lookup_icon({ icon = 'applications-multimedia.png', icon_size='22x22' }) },
        { "Office", programs["Office"], fdutils.lookup_icon({ icon = 'applications-office.png', icon_size='22x22' }) },
        { "Other", programs["Other"], fdutils.lookup_icon({ icon = 'applications-other.png', icon_size='22x22' }) },
        { "Settings", programs["Settings"], fdutils.lookup_icon({ icon = 'preferences-desktop.png', icon_size='22x22' }) },
        { "System Tools", programs["System"], fdutils.lookup_icon({ icon = 'applications-system.png', icon_size='22x22' }) },
    }

    --Removing empty entries from menu
    local cleanedMenu  = {}
    for index=1, #menu do
        local item = menu[index]
        itemTester = item[2]
        if itemTester[1] then
            cleanedMenu[#cleanedMenu+1] = item
        end
    end

    return cleanedMenu
end

local function create_menu()
    local menu_items = gen_menu()
    return menu.new({ items = menu_items, width = 150 })
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
            mymainmenu:toggle({x=0,coords={x=0,y=capi.screen[capi.mouse.screen].geometry.height}},{x=0},{x=0})
        end)
    ))

    return mylaunchertext
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
