local setmetatable = setmetatable
local menu2 = require("widgets.menu")
local print = print

module("customMenu.clientMenu")

-- local function hightlight(aWibox, value)
--   aWibox.bg = (value == true) and beautiful.bg_focus or beautiful.bg_normal
-- end

local aClient
local mainMenu

function new(screen, args)
  
  mainMenu = menu2()
  itemVisible    = mainMenu:add_item({text="Visible"     , checked=true , onclick = function()  end})
  itemVSticky    = mainMenu:add_item({text="Sticky"      , checked=true , onclick = function()  end})
  itemVFloating  = mainMenu:add_item({text="Floating"    , checked=true , onclick = function()  end})
  itemMaximized  = mainMenu:add_item({text="Maximized"   , checked=true , onclick = function()  end})
  itemMaster     = mainMenu:add_item({text="Master"      , checked=true , onclick = function()  end})
  itemMoveToTag  = mainMenu:add_item({text="Move to tag" , checked=true , onclick = function()  end})
  itemClose      = mainMenu:add_item({text="Close"       , checked=true , onclick = function()  end})
  itemSendSignal = mainMenu:add_item({text="Send Signal" , checked=true , onclick = function()  end})
  itemRenice     = mainMenu:add_item({text="Renice"      , checked=true , onclick = function()  end})
  
    

  return mainMenu
end

function menu()
    return mainMenu or new()
end

function toggle(c)
    local mainMenu2 = menu2()
    mainMenu2:add_existing_item(itemVisible    )
    mainMenu2:add_existing_item(itemSticky     )
    mainMenu2:add_existing_item(itemFloating   )
    mainMenu2:add_existing_item(itemMaximized  )
    mainMenu2:add_existing_item(itemMaster     )
    mainMenu2:add_existing_item(itemMoveToTag  )
    mainMenu2:add_existing_item(itemClose      )
    mainMenu2:add_existing_item(itemSendSignal )
    mainMenu2:add_existing_item(itemRenice     )
    if mainMenu then
        function createTagList(aScreen)
            local tagList = menu()
            local count = 0
            for _, v in ipairs(capi.screen[aScreen]:tags()) do
                tagList:add_item({text = v.name})
                count = count + 1
            end
            return tagList
        end
        
        function classMenu(c)
            local classM = menu2()
            classM:add_item({text = c.name})
            classM:add_item({text = "Match to Tags"})
            classM:add_item({text = "Flags"})
            return classM
        end
        
        mainMenu2.settings.x = c:geometry().x
        mainMenu2.settings.y = c:geometry().y+16
        mainMenu2:add_item({text = c.class, subMenu = function() return classMenu(c) end, fg="#880000"})
        mainMenu2:toggle(true)
    end
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
