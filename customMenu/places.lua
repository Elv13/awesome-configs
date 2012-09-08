local setmetatable = setmetatable
local string       = string
local io           = io
local os           = os
local table        = table
local button       = require( "awful.button"             )
local beautiful    = require( "beautiful"                )
local util         = require( "awful.util"               )
local menu         = require( "widgets.menu"             )
local config       = require( "config"                   )
local tooltip      = require( "widgets.tooltip"          )
local fdutil       = require( "extern.freedesktop.utils" )
local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               mouse  = mouse  }

module("customMenu.places")

local function read_kde_bookmark(offset)
    local m = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, autodiscard = true,has_decoration=false})
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
    local tt = tooltip("Folder shortcut",{down=true})

    local mylauncher2text = capi.widget({ type = "textbox" })
    mylauncher2text:margin({ left = 30,right=7})
    mylauncher2text.text = "Places"
    mylauncher2text.bg_image = capi.image(config.data().iconPath .. "tags/home2.png")
    mylauncher2text.bg_align = "left"
    mylauncher2text.bg_resize = true

    mylauncher2text:add_signal("mouse::enter", function() tt:showToolTip(true) ;mylauncher2text.bg = beautiful.bg_highlight end)
    mylauncher2text:add_signal("mouse::leave", function() tt:showToolTip(false);mylauncher2text.bg = beautiful.bg_normal end)

    mylauncher2text:buttons( util.table.join(
        button({ }, 1, function()
        tt:showToolTip(false)
        data = data or read_kde_bookmark(offset)
        data:toggle()
    end)
    ))

    return mylauncher2text
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
