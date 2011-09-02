local setmetatable = setmetatable
local table        = table
local print        = print
local ipairs       = ipairs
local pairs        = pairs
local io           = io
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local menu         = require( "widgets.menu" )
local util         = require( "awful.util"   )
local config       = require( "config"       )

local capi = { image  = image  ,
               widget = widget ,
               client = client ,
               mouse  = mouse  ,
               screen = screen }

module("customMenu.launcher")

local currentMenu = nil

function createMenu(center)
    
    local numberStyle = "<span size='large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span> "
    
     -- Read the history and sort them by use (most used first)
    local aFile = io.open(util.getdir("cache") .. "/history")
    local commandArray = {}
    if aFile then
        while true do
            local line = aFile:read("*line")
            if line == nil then break end
            if commandArray[line] == nil then
                commandArray[line] = 1
            else
                commandArray[line] = commandArray[line] + 1
            end
        end
        aFile:close()
    end
    
    local commandArray2 = {}
    
    for k,v in pairs(commandArray) do
        table.insert(commandArray2,{v,k})
    end
    
    function compare(a,b)
        return a[1] > b[1]
    end

    table.sort(commandArray2, compare)
  
    mainMenu = menu({filter = true, showfilter = true, filterprefix = "<b>Run: </b>"})
    mainMenu:set_width(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)
    
    mainMenu:add_filter_hook({}, "Return", "press", function(menu)
        util.spawn(menu.filterString)
        menu:toggle(false)
        return false
    end)
    
    -- Fill the menu
    local counter = 1
    for k,v in pairs(commandArray2) do
       mainMenu:addItem({prefix = numberStyle.."[F".. counter .."]"..numberStyleEnd,  text =  v[2], onclick = function() util.spawn(v[2]) end})
       counter = counter + 1
    end
    
    mainMenu:add_signal("menu::hide", function() currentMenu = nil end)
    
    mainMenu:toggle(true)
    
    return mainMenu
end

function new(screen, args) 
    
    
   
    
    -- Create the menu icon
    local launcherPix = capi.widget({ type = "imagebox", align = "left" })
    launcherPix.image = capi.image(config.data.iconPath .. "gearA2.png")
    
    launcherPix:add_signal("mouse::enter", function() launcherPix.bg = beautiful.bg_highlight end)
    launcherPix:add_signal("mouse::leave", function() launcherPix.bg = beautiful.bg_normal end)
    
    launcherPix:buttons( util.table.join(
    button({ }, 1, function()
        if currentMenu ~= nil then
            currentMenu:toggle(false)
        else
            currentMenu = createMenu()
        end
    end)
    ))
    return launcherPix
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
