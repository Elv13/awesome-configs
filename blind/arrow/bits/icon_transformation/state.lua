local theme,path = ...
local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local radical    = require( "radical"        )

local function icn(image,data,item)
    if not item._state_transform_init then
        item:connect_signal("state::changed",function()
            if item._original_icon then
                item:set_icon(item._original_icon)
            end
        end)
        item._state_transform_init = true
    end
    local state = item.state or {}
    local current_state = state._current_key or nil
    local state_name = radical.base.colors_by_id[current_state] or "normal"
    return surface.tint(image,color(state_name == "normal" and theme.fg_normal or item["fg_"..state_name]  --[[theme.fg_normal]]),theme.default_height,theme.default_height)
end

return icn