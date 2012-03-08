local capi = { mouse = mouse }
local setmetatable = setmetatable
local wibox        = require( "awful.wibox"  )

module("ultiLayout.widgets.thumbnail")

local function create_thumb(cg,args)
    local args = args or {}
    local aWb = wibox({position="free"})
    aWb.width  = 200
    aWb.height = 200
    aWb.x = args.x or (capi.mouse.coords().x+10)
    aWb.y = args.y or (capi.mouse.coords().y+10)
    aWb.ontop = true
    aWb.visible = false
    return aWb
end
setmetatable(_M, { __call = function(_, ...) return create_thumb(...) end })