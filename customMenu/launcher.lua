local setmetatable = setmetatable
local table        = table
local print        = print
local ipairs       = ipairs
local pairs        = pairs
local io           = io
local type         = type
local tooltip2     = require( "radical.tooltip" )
local button       = require( "awful.button"    )
local beautiful    = require( "beautiful"       )
local naughty      = require( "naughty"         )
local tag          = require( "awful.tag"       )
local menu         = require( "radical.context"            )
local util         = require( "awful.util"      )
local config       = require( "forgotten"          )
local themeutils   = require( "blind.common.drawing"     )
local wibox        = require( "wibox"           )
local style        = require( "radical.style.classic"      )
local item_style   = require( "radical.item.style.classic" )
local color = require("gears.color")
local cairo = require("lgi").cairo

local capi = { image  = image  ,
               widget = widget ,
               client = client ,
               mouse  = mouse  ,
               screen = screen }

local module = {}

local currentMenu = nil

local function save(command)
    local file = io.open(util.getdir("cache") .. "/history", "a")
    file:write("\n"..command)
    file:close()
end

function createMenu(offset)
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

    mainMenu = menu({filter = true, show_filter = true, y = capi.screen[1].geometry.height - 18, x = offset, 
    autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,style=style,item_style=item_style,
    show_filter=true,auto_resize=true,fkeys_prefix=true,filter_prefix="Run:",max_items=20})

    mainMenu:add_key_hook({}, "Return", "press", function(menu)
        util.spawn(menu.filterString)
        save(menu.filterString)
        menu:toggle(false)
        return false
    end)

    -- Fill the menu
    local counter = 1
    for k,v in pairs(commandArray2) do
        local function onclick()
            util.spawn(v[2])
            save(v[2])
        end
        local str = v[2]:gsub(" ", "_"):gsub("-", "_")
--         print(str)
-- print("her",config.is_set(config.launcsher3[str].counter))
--        local count = config.is_set(config.launcsher3[str].counter) and config.launcsher3[str].counter or 0
--        if count == 0 then
        if str ~= "" then
--         print("ICI2","'"..str.."'","meh",config.launcsher3,config.launcsher3[str])
--             local tmp = config.launcsher3 and config.launcsher3[str].counter
            if type(tmp) ~= "number" then
                tmp = 0
            end
--            config.launcsher3[str].counter = tmp + 1
--            print("NOW IS",config.launcsher3[str].counter)
        end
           count = 1
--        end
       local item = mainMenu:add_item({prefixbg = beautiful.fg_normal, text =  v[2], button1 = onclick,underlay=count.."x"})
       counter = counter + 1
    end

mainMenu:connect_signal("visible::changed", function() currentMenu = nil end)
    
    return mainMenu
end

function module.get_menu()
    currentMenu = currentMenu or createMenu(offset)
    return currentMenu
end


return setmetatable(module, { __call = function(_, ...) return module.get_menu(...) end })
