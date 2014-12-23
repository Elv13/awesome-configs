local theme,path = ...
local color      = require( "gears.color"    )
local surface    = require( "gears.surface"  )
local radical    = require( "radical"        )

local function icn(image,data,item)
    local state = item.state or {}
    local current_state = state._current_key or nil
    local state_name = radical.base.colors_by_id[current_state] or "normal"
    return surface.tint(image,color(state_name == "normal" and theme.fg_normal or item["fg_"..state_name]  --[[theme.fg_normal]]),theme.default_height,theme.default_height)
end

return icn