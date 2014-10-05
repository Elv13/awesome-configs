local setmetatable = setmetatable
local string       = string
local io           = io
local os           = os
local util         = require( "awful.util"                 )
local menu         = require( "radical.context"            )
local separ        = require( "radical.widgets.separator"  )
local style        = require( "radical.style.classic"      )
local item_style   = require( "radical.item.style.classic" )
local filetree     = require("customMenu.filetree")
local fd_async = require("utils.fd_async")
local capi = { screen = screen }

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
            end

            if string.match(line,"</bookmark") and currentItem.title and currentItem.path then
                local item = m:add_item({text =  currentItem.title, icon = currentItem.icon, onclick = function() util.spawn("dolphin " .. currentItem.path) end})
                fd_async.icon.load(currentItem.icon,32):connect_signal("request::completed",function(icon)
                  item.icon = icon
                end)
                currentItem = {}
            end
            line = f:read("*line")
        end
        f:close()
    end
    m:add_widget(separ())
    m:add_item {text="Root",sub_menu=function() return filetree.path("/",{max_items=20,style=style,item_style=item_style}) end}
    m:add_item {text="Home",sub_menu=function() return filetree.path(os.getenv("HOME"),{max_items=20,style=style,item_style=item_style}) end}
    return m
end

function module.get_menu()
    data = data or read_kde_bookmark(offset)
--     data.visible = not data.visible
    return data
end


return setmetatable(module, { __call = function(_, ...) return get_menu(...) end })
