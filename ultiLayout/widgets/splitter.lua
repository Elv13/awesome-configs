local capi = { mouse = mouse,image=image }
local setmetatable = setmetatable
local print = print
local type = type
local ipairs = ipairs
local wibox        = require( "awful.wibox"  )
local common       = require( "ultiLayout.common" )
local beautiful    = require( "beautiful" )
--local object_model = require( "ultiLayout.object_model" )

module("ultiLayout.widgets.splitter")

local dir = {}
local init = false

local function gen_top(width, height)
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle(0, (width/2), 10, (width/2), true, "#ffffff")
    img:draw_rectangle(width-10, (width/2), 10, (width/2), true, "#ffffff")
    for i=0,(width/2) do
        img:draw_rectangle(i, 0, 1, (width/2)-i, true, "#ffffff")
        img:draw_rectangle(width-i, 0, 1, (width/2)-i, true, "#ffffff")
    end
    return img
end

local function gen_bottom(width, height)
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle(0, 0, 10, (width/2), true, "#ffffff")
    img:draw_rectangle(width-10, 0, 10, (width/2), true, "#ffffff")
    for i=0,(width/2) do
        img:draw_rectangle((width/2)+i, height-i, 1, i, true, "#ffffff")
        img:draw_rectangle((width/2)-i, height-i, 1, i, true, "#ffffff")
    end
    return img
end

local function gen_right(width, height)
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle(0, 0, (width/2), 10, true, "#ffffff")
    img:draw_rectangle(0, height-10, (width/2), 10, true, "#ffffff")
    for i=0,(width/2) do
        img:draw_rectangle(width-i, (width/2)+i, i, 1, true, "#ffffff")
        img:draw_rectangle(width-i, (width/2)-i, i, 1, true, "#ffffff")
    end
    return img
end

local function gen_left(width, height)
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle((width/2), 0, (width/2), 10, true, "#ffffff")
    img:draw_rectangle((width/2), height-10, (width/2), 10, true, "#ffffff")
    for i=0,(width/2) do
        img:draw_rectangle(0, i, (width/2)-i, 1, true, "#ffffff")
        img:draw_rectangle(0, (width/2)+i, i, 1, true, "#ffffff")
    end
    return img
end

local function init_shape(width, height)
    dir.left,dir.right,dir.top,dir.bottom=gen_left(width, height),gen_right(width, height),gen_top(width, height),gen_bottom(width, height)
    init = true
end

local function create_splitter(cg,args)
    local args = args or {}
    local data = {x=args.x,y=args.y}
    local aWb = wibox({position="free"})
    local visible = false
    data.wibox = aWb
    aWb.width  = 48
    aWb.height = 48
    aWb.bg = beautiful.fg_normal
    aWb.ontop = true
    aWb.visible = false
    common.register_wibox(aWb, cg, function(new_cg)
        if cg.get_layout().add_child_orig ~= nil then
            local tmp = cg.get_layout().add_child
            cg.get_layout().add_child = cg.get_layout().add_child_orig
            cg:attach(new_cg,args.index)
            cg.get_layout().add_child = tmp
        else
            cg:attach(new_cg,args.index)
        end
    end)
    if init == false then
        init_shape(aWb.width, aWb.height)
    end
    aWb.shape_clip = dir[args.direction or "left"]
    aWb.shape_bounding = dir[args.direction or "left"]
    
    function data:update()
        if common.are_splitter_visible() == false and visible == false then return end
        if visible ~= common.are_splitter_visible() or visible ~= cg.visible then
            visible = cg.visible and common.are_splitter_visible()
            aWb.visible = visible
        end
        if visible == true then
            for k,v in ipairs({"x","y"}) do
                if data[v] == nil then
                    aWb[v] = capi.mouse.coords().x+10
                elseif type(data[v]) == "function" then
                    aWb[v] = data[v]()
                else
                    aWb[v] = data[v]
                end
            end
        end
    end
    data:update()
    return data
end
setmetatable(_M, { __call = function(_, ...) return create_splitter(...) end })