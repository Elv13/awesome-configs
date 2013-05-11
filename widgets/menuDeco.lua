local capi = { mouse = mouse,image=image,widget=widget }
local setmetatable = setmetatable
local print        = print
local math         = math
local type         = type
local ipairs       = ipairs
local util         = require("awful.util")
local wibox        = require( "awful.wibox"  )
-- local common       = require( "ultiLayout.common" )
-- local clientGroup  = require( "ultiLayout.clientGroup" )
local beautiful    = require( "beautiful" )

module("widgets.menuDeco")

local function gen_top(width, height)
    local aWb = wibox({position="free"})
    aWb.x = 100
    aWb.y =100
    aWb.width  = 200
    aWb.height = 25
    aWb.ontop = true
    aWb.bg = beautiful.fg_normal
    local img = capi.image.argb32(width, 25, nil)
    img:draw_rectangle(0, 0, width, 25, true, "#FFFFFF")
    for i=0,(50/2) do
        img:draw_rectangle(width-70+i, 25-i, 1, i, true, "#000000")
        img:draw_rectangle(width-20-i, 25-i, 1, i, true, "#000000")
    end
    img:draw_rectangle(10, 15, width-25, 10, true, "#000000")
    img:draw_circle (10, 26, 10, 10, true, "#000000")
    img:draw_circle (width-20, 26, 10, 10, true, "#000000")
    aWb.shape_clip = img
    aWb.shape_bounding = img
    return aWb
end

local function gen_bottom(width)
    local aWb = wibox({position="free"})
    aWb.bg = beautiful.fg_normal
    aWb.x = 100
    aWb.y = 200
    aWb.width  = width
    aWb.height = 10
    local img = capi.image.argb32(width, 10, nil)
    img:draw_rectangle(0, 0, width, 10, true, "#FFFFFF")
    img:draw_rectangle(10, 0, width-30, 10, true, "#000000")
    img:draw_circle (10, 0, 10, 10, true, "#000000")
    img:draw_circle (width-20, 0, 10, 10, true, "#000000")
    aWb.shape_clip = img
    aWb.shape_bounding = img
end

local function create_splitter(cg,args)
    local args = args or {}
    local data = {x=args.x,y=args.y}

    gen_top(200)
    
    function data:update()
        
    end
    data:update()
    gen_bottom(200)
    return data
end

setmetatable(_M, { __call = function(_, ...) return create_splitter(...) end })