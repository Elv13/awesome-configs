local setmetatable = setmetatable
local next = next
local button = require("awful.button")
local beautiful = require( "beautiful"       )
local util      = require( "awful.util"      )
local shifty    = require( "shifty"          )
local config    = require( "config"          )
local menu      = require( "widgets.menu"    )
local tooltip   = require( "widgets.tooltip" )
local capi = { image = image,
               widget = widget,
               mouse = mouse}

module("customButton.addTag")

local data = {}

function update()

end

function new(screen, args) 
  local addTag  = capi.widget({ type = "imagebox", align = "left" })
  addTag.image  = capi.image(config.data().iconPath .. "tags/cross2.png")
  addTag.bg     = beautiful.bg_highlight
  local tagMenu = menu()
  local tt = tooltip("Add Tag",{})

--   local function showToolTip(show)
--      if not tt then
--        tt = 
--      end
--      tt.x = capi.mouse.coords().x - tt.width/2 -5
--      tt.y = 16
--      tt.visible = show
--   end

  for v, i in next, shifty.config.tags do
    tagMenu:add_item({text=v,onclick= function() 
                                         shifty.add({name = v})
                                         tagMenu:toggle(false)
                                         delTag[capi.mouse.screen].visible = true
                                      end})
  end
  
  addTag:buttons( util.table.join(
    button({ }, 1, function()
      shifty.add({name = "NewTag"})
      --delTag[capi.mouse.screen].visible = true
    end),
    button({ }, 3, function()
      tagMenu:toggle()
    end)
  ))
  
  addTag:add_signal("mouse::enter", function() tt:showToolTip(true) ;addTag.bg = beautiful.bg_normal    end)
  addTag:add_signal("mouse::leave", function() tt:showToolTip(false);addTag.bg = beautiful.bg_highlight end)
  
  return addTag
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
