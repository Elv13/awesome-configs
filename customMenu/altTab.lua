local setmetatable = setmetatable
local table = table
local print = print
local ipairs = ipairs
local button = require("awful.button")
local beautiful = require("beautiful")
local naughty = require("naughty")
local tag = require("awful.tag")
local menu = require("customMenu.menu2")
local util = require("awful.util")
local capi = { image = image,
               widget = widget,
               client = client,
               mouse = mouse,
               screen = screen}

module("customMenu.altTab")

local currentMenu = {}
local isVisible = false
local currentIndex = 1
local itemCount = 0

function new(screen, args) 
    local numberStyle = "<span size='large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span> "

    if isVisible == false then
        local function createMenu()
            local menu3 = { data = menu() }
            return menu3
        end
    
        mainMenu = createMenu()
        mainMenu["data"]:set_width(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)
        
        itemCount = 0
        for k,v in ipairs(capi.client.get(screen)) do
            mainMenu["data"]:addItem(numberStyle.."[F".. itemCount .."]"..numberStyleEnd ..v.name,nil,function() capi.client.focus = v end,nil,{icon = v.icon})
            itemCount = itemCount + 1
        end
        
        mainMenu["data"]:toggle(true)    
        --mainMenu["data"]:set_coords(((screen or capi.screen[capi.mouse.screen]).geometry.x - 300)/2,)

        local menuX = ((screen or capi.screen[capi.mouse.screen]).geometry.width)/4
        local menuY = ((screen or capi.screen[capi.mouse.screen]).geometry.height - (beautiful.menu_height*#capi.client.get(screen)))/2
        mainMenu["data"]:set_coords(menuX,menuY)
        
        mainMenu["data"]:clear_highlight()
        mainMenu["data"]:highlight_item(currentIndex)
        isVisible = true
    else
        if currentIndex + 1 > itemCount then
            currentIndex = 1
        else
            currentIndex = currentIndex + 1
        end
        mainMenu["data"]:clear_highlight()
        mainMenu["data"]:highlight_item(currentIndex)
    end
    
    return mainMenu["data"]
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
