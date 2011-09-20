local setmetatable = setmetatable
local menu = require("widgets.menu")
local print = print

module("customMenu.clientMenu")

-- local function hightlight(aWibox, value)
--   aWibox.bg = (value == true) and beautiful.bg_focus or beautiful.bg_normal
-- end

local aClient
local mainMenu

function new(screen, args)
  
  mainMenu = menu()
  mainMenu:add_item({text="Visible"     , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Sticky"      , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Floating"    , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Maximized"   , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Master"      , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Move to tag" , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Close"       , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Send Signal" , checked=true , onclick = function()  end})
  mainMenu:add_item({text="Renice"      , checked=true , onclick = function()  end})
  
    

  return mainMenu
end

function toggle(c)
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
            print("In classMenu")
            local classM = menu()
            classM:add_item({text = c.name})
            return classM
        end
        
        mainMenu:add_item({text = c.class, subMenu = function() print('here');return classMenu(c) end})
        mainMenu:toggle(true)
    end
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
