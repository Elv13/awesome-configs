local capi = {tag=tag,mouse=mouse}
local setmetatable = setmetatable
local button     = require( "awful.button"        )
local util       = require( "awful.util"          )
local tag        = require( "awful.tag"           )
local config     = require( "forgotten"           )
local themeutils = require( "blind.common.drawing")
local wibox      = require( "wibox"               )
local color      = require( "gears.color"         )
local radical    = require( "radical"             )

local data = {}

local aTagMenu = nil
local items = {}

local function get_icon(state)
  if state == "locked" then
    return config.iconPath .. "tags/locked.png"
  elseif state == "exclusive" then
    return config.iconPath .. "tags/exclusive.png"
  elseif state == "fallback" then
    return config.iconPath .. "tags/fallback.png"
  elseif state == "inclusive" then
    return config.iconPath .. "tags/unlocked.png"
  end
end

local function get_state(t)
  local locked    = tag.getproperty(t,"locked") and "locked"
  local exclusive = tag.getproperty(t,"exclusive") and "exclusive"
  local fallback  = tag.getproperty(t,"fallback") and "fallback"
  return fallback or locked or exclusive or "inclusive"
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
  if state == "locked" then  --Exclusive
    tag.setproperty(t,"locked"   ,false )
    tag.setproperty(t,"exclusive",true  )
    tag.setproperty(t,"fallback" ,false )
  elseif state == "exclusive" then --Fallback
    tag.setproperty(t,"locked"   ,false )
    tag.setproperty(t,"exclusive",false )
    tag.setproperty(t,"fallback" ,true  )
  elseif state == "fallback" then -- Inclusive
    tag.setproperty(t,"locked"   ,false )
    tag.setproperty(t,"exclusive",false )
    tag.setproperty(t,"fallback" ,false )
  elseif state == "inclusive" then -- Locked
    tag.setproperty(t,"locked"   ,true  )
    tag.setproperty(t,"exclusive",false )
    tag.setproperty(t,"fallback" ,false )
  end
  toggleVisibility(t)
end

local function select_next()
  local t = tag.selected(capi.mouse.screen)
  next_state(t)
  local state = get_state(t)
  items[state].selected = true
  return true
end

local function hide(m)
  m.visible = false
  return false
end

local function show_menu(t)
  local t = t or tag.selected(capi.mouse.screen)
  if not aTagMenu then
    aTagMenu = radical.box({layout=radical.layout.horizontal,item_width=140,item_height=140,icon_size=100,item_style=radical.item.style.rounded})
    items.locked    = aTagMenu:add_item({text = "<b>Locked</b>"   ,icon =config.iconPath .. "locked.png",button1=function() capi.client.focus = v end})
    items.exclusive = aTagMenu:add_item({text = "<b>Exclusive</b>",icon =config.iconPath .. "exclusive.png",button1=function() capi.client.focus = v end})
    items.fallback  = aTagMenu:add_item({text = "<b>Fallback</b>" ,icon =config.iconPath .. "fallback.png",button1=function() capi.client.focus = v end})
    items.inclusive = aTagMenu:add_item({text = "<b>Inclusive</b>",icon =config.iconPath .. "inclusive.png",button1=function() capi.client.focus = v end})
    aTagMenu:add_key_hook({}, "Tab", "press", select_next)
    aTagMenu:add_key_hook({}, "Control_L", "release", hide)
    aTagMenu:add_key_hook({}, "Mod4", "release", hide)
  end

  local state = get_state(t)
  items[state].selected = true

  aTagMenu.visible = true
  return aTagMenu
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


return setmetatable({show_menu=show_menu}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;