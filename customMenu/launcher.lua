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
local fkeymap = {}

local function save(command)
    local file = io.open(util.getdir("cache") .. "/history", "a")
    file:write("\n"..command)
    file:close()
end

function createMenu(center)
    
    local numberStyle = "<span size='large' color='".. beautiful.bg_normal .."'><tt><b>"
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
  
    mainMenu = menu({filter = true, showfilter = true, filterprefix = "<b>Run: </b>", y = capi.screen[1].geometry.height - 18, x = 147})
    mainMenu:set_width(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)
    
    mainMenu:add_key_hook({}, "Return", "press", function(menu)
        util.spawn(menu.filterString)
        save(menu.filterString)
        menu:toggle(false)
        return false
    end)
    
    for i=1,15 do
        mainMenu:add_key_hook({}, "F"..i, "press", function(menu)
            if fkeymap[i] ~= nil then
                util.spawn(fkeymap[i].text)
                save(fkeymap[i].text)
            end
            menu:toggle(false)
            return false
        end)
    end
    
   
    
    -- Fill the menu
    local counter = 1
    for k,v in pairs(commandArray2) do
        local function onclick()
            util.spawn(v[2])
            save(v[2])
        end
       local item = mainMenu:add_item({prefix = numberStyle.."[F".. counter .."]"..numberStyleEnd, prefixbg = beautiful.fg_normal,prefixwidth = 45, text =  v[2], onclick = onclick})
       item.fkey = "F"..counter
       fkeymap[counter] = item
       counter = counter + 1
    end
    
    mainMenu:add_signal("menu::hide", function() currentMenu = nil end)
    
    mainMenu:add_signal("menu::changed",  function(menu) 
        local counter = 1
        fkeymap = {}
        for k, v in pairs(menu.items) do
            if v.hidden ~= true then
                v.widgets.prefix.text = numberStyle.."[F".. counter .."]"..numberStyleEnd
                fkeymap[counter] = v
                counter = counter + 1
            end
        end
    end)
    
    mainMenu:toggle(true)
    
    return mainMenu
end

function new(screen, args)
    local launcherText = capi.widget({ type = "textbox", align = "left" })
    launcherText.text  = "      Launch  |"
    launcherText.bg_image = capi.image(config.data.iconPath .. "gearA2.png")
    launcherText.bg_resize = true
    
    launcherText:add_signal("mouse::enter", function()
        launcherText.bg = beautiful.bg_highlight
    end)
    launcherText:add_signal("mouse::leave", function() 
        launcherText.bg = beautiful.bg_normal 
    end)
    
    launcherText:buttons( util.table.join(
    button({ }, 1, function()
        if currentMenu ~= nil then
            currentMenu:toggle(false)
        else
            currentMenu = createMenu()
        end
    end)
    ))
    return launcherText
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
