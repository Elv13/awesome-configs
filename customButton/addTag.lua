local setmetatable = setmetatable
local next = next
local print = print
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
  addTag.bg     = beautiful.bg_alternate
  local tagMenu = nil
  local tt = nil
  local init = false

  local function showToolTip()
     if not tt then
       tt = tooltip("Add Tag",{})
     end
     return tt
  end

  
  
  addTag:buttons( util.table.join(
    button({ }, 1, function()
      shifty.add({name = "NewTag"})
      --delTag[capi.mouse.screen].visible = true
    end),
    button({ }, 3, function()
      if not init then
          tagMenu = menu()
            for v, i in next, shifty.config.tags do
                tagMenu:add_item({text=v,onclick= function()
                    shifty.add({name = v})
                    tagMenu:toggle(false)
                    delTag[capi.mouse.screen].visible = true
                end})
            end
          init = true
      end
      tagMenu:toggle()
    end)
  ))
  
  addTag:add_signal("mouse::enter", function() (tt or showToolTip()):showToolTip(true) ;addTag.bg = beautiful.bg_normal    end)
  addTag:add_signal("mouse::leave", function() (tt or showToolTip()):showToolTip(false);addTag.bg = beautiful.bg_alternate end)
  
  return addTag
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
