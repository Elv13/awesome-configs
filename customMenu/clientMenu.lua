local setmetatable = setmetatable
local menu = require("widgets.menu")

module("customMenu.clientMenu")

-- local function hightlight(aWibox, value)
--   aWibox.bg = (value == true) and beautiful.bg_focus or beautiful.bg_normal
-- end

local aClient

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
setmetatable(_M, { __call = function(_, ...) return new(...) end })
