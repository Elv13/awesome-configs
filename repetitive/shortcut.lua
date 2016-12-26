-- This module allow tags to be associated with keyboard shortcuts
local capi   = {tag=tag,client=client,screen=screen,root=root}
local type   = type
local tag    = require ( "awful.tag"         )
local client = require ( "awful.client"      )
local common = require ( "repetitive.common" )
local glib   = require ( "lgi"               ).GLib

local function get_property(element,property)
  local ty = type(element)
  if ty == "tag" then
    return tag.getproperty(element,property)
  else
    return client.property.get(element,property)
  end
end

-- Apply the rules set by the properties to do the right action(s)
local function default_execution(element)
  local ty = type(element)
  local data = common.other_shortcuts[element]
  if ty == "tag" then
    if data.viewonly ~= false then -- true or nil
      tag.viewonly(element)
    else
      tag.viewtoggle(element)
    end
  else
    --TODO share the tag selection code from init.lua
    local tags = element:tags()
    tag.viewonly(tags[1])
  end
end

local function update_property(element,property)
  local value = get_property(element,property)
  local data = common.other_shortcuts[element]
  if not data then
    data = {}
    common.other_shortcuts[element] = data
  end
  data[property] = value
  if property == "shortcut" then
    --TODO check if there were one and remove it
    -- This need to be done later as there is a race condition going on
    -- with awesome initialisation. This create another race if multiple
    -- tags use the same keys, it is not currently handled, just don't do that
    glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
      data.key = common.hook_key(value[2],value[1],value[3] or function()
        default_execution(element)
      end)
    end)
  end
end

-- Create a callback for each properties so they can be changed at runtime
local callbacks = {
  rotate_shortcut    = function (elem) return update_property(elem,"rotate_shortcut"   ) end,
  exclusive_shortcut = function (elem) return update_property(elem,"exclusive_shortcut") end,
  relativ_shortcute  = function (elem) return update_property(elem,"relative_shortcut" ) end,
  viewonly           = function (elem) return update_property(elem,"viewonly"          ) end,
  shortcut           = function (elem) return update_property(elem,"shortcut"          ) end,
  move_to_current    = function (elem) return update_property(elem,"move_to_current"   ) end,
}

-- Register new properties
for _,sig in ipairs {
  "shortcut"          ,
  "rotate_shortcut"   ,
  "exclusive_shortcut",
  "relativ_shortcute" ,
  "viewonly"          ,
} do
    local prop_name = "property::"..sig
    capi.tag.connect_signal   (prop_name, callbacks[sig] )
    capi.client.connect_signal(prop_name, callbacks[sig] )
end
-- kate: space-indent on; indent-width 4; replace-tabs on;
