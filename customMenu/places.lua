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
local config       = require( "forgotten"                     )
local tooltip2     = require( "radical.tooltip"           )
local fdutil       = require( "extern.freedesktop.utils"   )
local themeutils   = require( "blind.common.drawing"                )
local wibox        = require( "wibox"                      )
local style        = require( "radical.style.classic"      )
local item_style   = require( "radical.item.style.classic" )
local color        = require( "gears.color"                )
local cairo        = require( "lgi"                        ).cairo
local capi = { image  = image  ,
               screen = screen ,
               widget = widget ,
               mouse  = mouse  }

local module = {}
local data = nil

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

function module.get_menu()
    data = data or read_kde_bookmark(offset)
--     data.visible = not data.visible
    return data
end


return setmetatable(module, { __call = function(_, ...) return get_menu(...) end })
