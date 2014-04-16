local capi = {tag=tag}
local setmetatable = setmetatable
local button     = require( "awful.button"        )
local util       = require( "awful.util"          )
local tag        = require( "awful.tag"           )
local config     = require( "forgotten"           )
local themeutils = require( "blind.common.drawing")
local wibox      = require( "wibox"               )
local color      = require( "gears.color"         )

local data = {}


local function get_icon(state)
  if state == "locked" then
    return config.iconPath .. "tags/locked.png"
  elseif state == "exclusive" then
    return config.iconPath .. "tags/exclusive.png"
  elseif state == "fallback" then
    return config.iconPath .. "tags/fallback.png"
  elseif state == "intrusive" then
    return config.iconPath .. "tags/unlocked.png"
  end
end

local function get_state(t)
  local locked    = tag.getproperty(t,"locked") and "locked"
  local exclusive = tag.getproperty(t,"exclusive") and "exclusive"
  local fallback  = tag.getproperty(t,"fallback") and "fallback"
  return fallback or locked or exclusive or "intrusive"
end

local function toggleVisibility(t,state)
  if not t or not t.selected or not data[tag.getscreen(t)] then return end
  local w = data[tag.getscreen(t)]
  if w and t.selected then
    w:set_image(color.apply_mask(get_icon(state or get_state(t))))
  end
end

local function next_state(t)
  local state = get_state(t)
  if state == "locked" then
    tag.setproperty(t,"locked"   ,false )
    tag.setproperty(t,"exclusive",true  )
    tag.setproperty(t,"fallback" ,false )
  elseif state == "exclusive" then
    tag.setproperty(t,"locked"   ,false )
    tag.setproperty(t,"exclusive",false )
    tag.setproperty(t,"fallback" ,true  )
  elseif state == "fallback" then
    tag.setproperty(t,"locked"   ,false )
    tag.setproperty(t,"exclusive",false )
    tag.setproperty(t,"fallback" ,false )
  elseif state == "intrusive" then
    tag.setproperty(t,"locked"   ,true  )
    tag.setproperty(t,"exclusive",false )
    tag.setproperty(t,"fallback" ,false )
  end
  toggleVisibility(t)
end

local function new(screen)
  local screen = screen or 1
  if data[screen] then return data[screen] end

  local lockTag,t  = wibox.widget.imagebox(),tag.selected(screen)
  toggleVisibility(t)

  local function btn()
    local t = tag.selected(screen)
    next_state(t)
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
capi.tag.connect_signal("property::activated", toggleVisibility)


return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;