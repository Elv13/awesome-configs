local capi = { mouse = mouse,image=image,widget=widget }
local setmetatable = setmetatable
local print        = print
local math         = math
local type         = type
local ipairs       = ipairs
local util         = require("awful.util")
local wibox        = require( "awful.wibox"  )
local common       = require( "ultiLayout.common" )
local clientGroup  = require( "ultiLayout.clientGroup" )
local beautiful    = require( "beautiful" )
local widget2 = require("awful.widget")

module("widgets.overlay")

local function gen_top(width, height)
    local aWb = wibox({position="free"})
    aWb.x = 500
    aWb.y =100
    aWb.width  = 100
    aWb.height = 100
    aWb.ontop = true
    aWb.opacity = 0.5
--     aWb.bg = beautiful.fg_normal
    local img = capi.image.argb32(100, 100, nil)
    img:draw_rectangle(0, 0, 100, 100, true, "#FFFFFF")
--     for i=0,(50/2) do
--         img:draw_rectangle(width-70+i, 25-i, 1, i, true, "#000000")
--         img:draw_rectangle(width-20-i, 25-i, 1, i, true, "#000000")
--     end
--     img:draw_rectangle(10, 15, width-25, 10, true, "#000000")
    img:draw_circle (50, 50, 45, 45, true, "#000000")
    img:draw_circle (50, 50, 40, 40, true, "#FFFFFF")
    img:draw_circle (50, 50, 35, 35, true, "#000000")
    img:draw_circle (50, 50, 30, 30, true, "#FFFFFF")
    --img:draw_rectangle(30, 35, 40, 30, true, "#000000")
    aWb.shape_clip = img
    aWb.shape_bounding = img
    
    local tb = capi.widget({type="textbox"})
    tb.text = "12:34"
    aWb.widgets = {tb,layout = widget2.layout.horizontal.flex}
    return aWb
end

local function create_splitter(cg,args)
    local args = args or {}
    local data = {x=args.x,y=args.y}

    gen_top(200)
    
    function data:update()
        
    end
    data:update()
    return data
end

setmetatable(_M, { __call = function(_, ...) return create_splitter(...) end })