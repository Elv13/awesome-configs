local capi = {tag=tag}
local setmetatable = setmetatable
local print = print
local button     = require( "awful.button"        )
local util       = require( "awful.util"          )
local tag        = require( "awful.tag"           )
local config     = require( "forgotten"           )
local themeutils = require( "blind.common.drawing")
local wibox      = require( "wibox"               )
local color = require("gears.color")

local data = {}

local function toggleVisibility(t)
  if not t or not t.selected or not data[tag.getscreen(t)] then return end
  local w = data[tag.getscreen(t)]
  if w and t.selected then
    local locked = tag.getproperty(t,"exclusive")
    w:set_image(color.apply_mask(locked and config.iconPath .. "tags/locked.png" or config.iconPath .. "tags/unlocked.png"))
  end
end

local function new(screen)
  local screen = screen or 1
  if data[screen] then return data[screen] end

  local lockTag,t  = wibox.widget.imagebox(),tag.selected(scree)
  local locked = t and tag.getproperty(t,"exclusive") or false
  lockTag:set_image(color.apply_mask(locked and config.iconPath .. "tags/locked.png" or config.iconPath .. "tags/unlocked.png"))

  local function btn()
    local t = tag.selected(scree)
    local locked = not tag.getproperty(t,"exclusive")
    lockTag:set_image(color.apply_mask(locked and config.iconPath .. "tags/locked.png" or config.iconPath .. "tags/unlocked.png"))
    tag.setproperty(t,"exclusive", locked)
  end

  lockTag:buttons( util.table.join(
    button({ }, 1,btn),
    button({ }, 4,btn),
    button({ }, 5,btn)
  ))

  lockTag:set_tooltip("Lock tag")
  data[screen] = lockTag
  return lockTag
end

capi.tag.connect_signal("property::selected" , toggleVisibility)
capi.tag.connect_signal("property::activated",toggleVisibility)


return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;