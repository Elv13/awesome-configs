
local capi = { mouse = mouse}
local setmetatable = setmetatable
local next = next
local unpack = unpack
local print = print
local button = require("awful.button")
local beautiful = require( "beautiful"       )
local util      = require( "awful.util"      )
local tag       = require( "awful.tag"       )
local mouse     = require( "awful.mouse"     )
local config    = require( "forgotten"          )
local menu      = require( "radical.context"    )
local themeutils = require( "blind.common.drawing"    )
local tooltip2  = require( "radical.tooltip" )
local wibox = require("wibox")
local color = require("gears.color")

local module = {}


local data = {}

local function update()

end

local function new(screen, args)
  local addTag  = wibox.widget.imagebox()
  addTag:set_image(color.apply_mask(config.iconPath .. "tags/cross2.png"))
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
      tag.viewonly(tag.add("NewTag",{screen=capi.mouse.screen}))
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
  
  tooltip2(addTag,"Add Tag")
  
  return addTag
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;