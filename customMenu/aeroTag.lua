local setmetatable = setmetatable
local table        = table
local print        = print
local ipairs       = ipairs
local button       = require("awful.button"     )
local beautiful    = require("beautiful"        )
local naughty      = require("naughty"          )
local tag          = require("awful.tag"        )
local menu         = require("widgets.menu"     )
local util         = require("awful.util"       )
local capi = { image      = image      ,
               widget     = widget     ,
               client     = client     ,
               mouse      = mouse      ,
               screen     = screen     ,
               keygrabber = keygrabber }

local module = {}

local currentMenu  = {}
local isVisible    = false
local currentMenu  = nil
local currentIndex = 1
local itemCount    = 1
local fkeyMapping  = {}

local function keyboardNavigation(leap)
    if currentMenu then
        if currentIndex + leap > itemCount then
            currentIndex = 1
        elseif currentIndex + leap < 1 then
            currentIndex = itemCount
        else
            currentIndex = currentIndex + leap
        end
        currentMenu:clear_highlight()
        currentMenu:highlight_item(currentIndex) 
    end
end

function new(screen, args) 
    local numberStyle = "<span size='large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span> "

    if isVisible == false then    

        local menuX = ((screen or capi.screen[capi.mouse.screen]).geometry.width)/4
        local menuY = ((screen or capi.screen[capi.mouse.screen]).geometry.height - (beautiful.menu_height*#capi.client.get(screen)))/2
        currentMenu = menu({x= menuX, y= menuY, filter = true, showfilter=true, noautohide =true,autodiscard = true})
        currentMenu:set_width(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)
        
        itemCount = 0
        for k,v in ipairs(capi.client.get(screen)) do
            fkeyMapping[itemCount] = currentMenu:add_item({
                prefix  = numberStyle.."[F".. itemCount .."]"..numberStyleEnd, 
                text    = v.name, 
                onclick = function(menu,item) item:check(not item.checked) end, 
                icon    = v.icon,
                checked = true,
            })
            fkeyMapping[itemCount].c = v
            itemCount = itemCount + 1
        end
        
        currentMenu:toggle(true)
        currentMenu:set_coords(menuX,menuY)
        currentMenu:add_signal("menu::hide",function()
            currentMenu = nil
            isVisible   = false
            --capi.keygrabber.stop()
        end)
        
        
        currentMenu:clear_highlight()
        currentMenu:highlight_item(currentIndex)
        isVisible = true
        
        local toFilter = ""
--         capi.keygrabber.run(function(mod, key, event)
--             if event == "release" then 
--                 return true 
--             end 
--             
--             for i = 1, #fkeyMapping do
--                 if key == 'F'..i  then 
--                     capi.client.focus = fkeyMapping[i].c
--                     capi.keygrabber.stop()
--                     return false
--                 end
--             end
--             
--             if key == 'Escape' or (key == 'Tab' and toFilter == "") then 
--                 currentMenu:toggle(false)
--                 currentMenu = nil
--                 capi.keygrabber.stop()
--                 return false
--             elseif key == 'Up' then 
--                 keyboardNavigation(-1)
--             elseif key == 'Down' then 
--                 keyboardNavigation(1)  
--             elseif (key == 'Backspace' or key == "Left") and toFilter ~= "" then --FAIL
--                 toFilter = toFilter:sub(1,-1)
--                 currentMenu:filter(toFilter:lower())
--             else 
--                 toFilter = toFilter .. key
--                 currentMenu:filter(toFilter:lower())
--             end
--             return true
--         end)
    else
        keyboardNavigation(1)
    end
    
    return currentMenu
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
