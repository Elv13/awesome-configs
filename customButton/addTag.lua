
local capi = { image = image,
               widget = widget,
               mouse = mouse}
local setmetatable = setmetatable
local next = next
local unpack = unpack
local print = print
local button = require("awful.button")
local beautiful = require( "beautiful"       )
local util      = require( "awful.util"      )
local tag       = require( "awful.tag"       )
local mouse     = require( "awful.mouse"     )
local config    = require( "config"          )
local menu      = require( "widgets.menu"    )
local tooltip2  = require( "widgets.tooltip2" )
local wibox = require("wibox")

module("customButton.addTag")

local data = {}

function update()

end

function new(screen, args)
  local addTag  = wibox.widget.imagebox()
  addTag:set_image(config.data().iconPath .. "tags/cross2.png")
  addTag.bg     = beautiful.bg_alternate
  local tagMenu = nil
  local init = false

   local wiboxes = {}
   local orig_wibox = wibox
   wibox = function(...)
    local res = orig_wibox(...)
    wiboxes[res._drawable] = res
    return res 
  end
  
  addTag:buttons( util.table.join(
    button({ }, 1, function()
      tag.add("NewTag",{screen=capi.mouse.screen})
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
  
--   addTag:connect_signal("mouse::enter", function(self,geometry)
--     (tt or showToolTip()):showToolTip(true);
--     print("HER@@@",geometry.x,geometry.y,geometry.width,geometry.height)
-- --     print("WIBOX",mouse.wibox_under_pointer(),capi.mouse.screen,capi.mouse.coords().x)
-- --     mouse.wibox_under_pointer()._drawable:find_widgets(unpack(capi.mouse.coords()))
-- --     addTag.bg = beautiful.bg_normal
--   end)

--   addTag:connect_signal("mouse::leave", function() (tt or showToolTip()):showToolTip(false);addTag.bg = beautiful.bg_alternate end)
  
  tooltip2(addTag,"Add Tag")
  
  return addTag
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;