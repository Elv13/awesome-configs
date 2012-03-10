local capi = { mouse = mouse }
local setmetatable = setmetatable
local wibox        = require( "awful.wibox"  )

module("ultiLayout.widgets.splitter")

local function create_splitter(cg,args)
    local args = args or {}
    local aWb = wibox({position="free"})
    aWb.width  = 48
    aWb.height = 48
    aWb.x = args.x or (capi.mouse.coords().x+10)
    aWb.y = args.y or (capi.mouse.coords().y+10)
    aWb.ontop = true
    aWb.visible = false
    return aWb
end
setmetatable(_M, { __call = function(_, ...) return create_splitter(...) end })