local setmetatable = setmetatable
local table        = table
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

local function create_menu()
    local menu_items = fdmenu.new()
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
