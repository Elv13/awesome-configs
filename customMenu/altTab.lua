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

function new(screen, args) 
    local function createMenu()
        local menu3 = { data = menu() }
        return menu3
    end
  
    mainMenu = createMenu()
    mainMenu["data"]:set_width(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)
    
    
    for k,v in ipairs(capi.client.get(screen)) do
       mainMenu["data"]:addItem(v.name,nil,function() capi.client.focus = v end,nil,{icon = v.icon})
    end
    
    mainMenu["data"]:toggle(true)    
    --mainMenu["data"]:set_coords(((screen or capi.screen[capi.mouse.screen]).geometry.x - 300)/2,)

    local menuX = ((screen or capi.screen[capi.mouse.screen]).geometry.width)/4
    local menuY = ((screen or capi.screen[capi.mouse.screen]).geometry.height - (beautiful.menu_height*#capi.client.get(screen)))/2
    mainMenu["data"]:set_coords(menuX,menuY)
    
    return mainMenu["data"]
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
