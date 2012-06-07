local capi = { mouse = mouse,image=image,widget=widget }
local setmetatable = setmetatable
local print = print
local math = math
local type = type
local ipairs = ipairs
local util = require("awful.util")
local wibox        = require( "awful.wibox"  )
local common       = require( "ultiLayout.common" )
local clientGroup  = require( "ultiLayout.clientGroup" )
local beautiful    = require( "beautiful" )
local object_model = require( "ultiLayout.object_model" )

module("ultiLayout.widgets.splitter")

local dir = {}
local init = false

local function gen_arrow_top(width, height)
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle(0, (width/2), 10, (width/2), true, "#ffffff")
    img:draw_rectangle(width-10, (width/2), 10, (width/2), true, "#ffffff")
    for i=0,(width/2) do
        img:draw_rectangle(i, 0, 1, (width/2)-i, true, "#ffffff")
        img:draw_rectangle(width-i, 0, 1, (width/2)-i, true, "#ffffff")
    end
    return img
end

local function gen_arrow_bottom(width, height)
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle(0, 0, 10, (width/2), true, "#ffffff")
    img:draw_rectangle(width-10, 0, 10, (width/2), true, "#ffffff")
    for i=0,(width/2) do
        img:draw_rectangle((width/2)+i, height-i, 1, i, true, "#ffffff")
        img:draw_rectangle((width/2)-i, height-i, 1, i, true, "#ffffff")
    end
    return img
end

local function gen_arrow_right(width, height)
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle(0, 0, (width/2), 10, true, "#ffffff")
    img:draw_rectangle(0, height-10, (width/2), 10, true, "#ffffff")
    for i=0,(width/2) do
        img:draw_rectangle(width-i, (width/2)+i, i, 1, true, "#ffffff")
        img:draw_rectangle(width-i, (width/2)-i, i, 1, true, "#ffffff")
    end
    return img
end

local function gen_arrow_left(width, height)
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
    dir.left,dir.right,dir.top,dir.bottom=gen_arrow_left(width, height),gen_arrow_right(width, height),gen_arrow_top(width, height),gen_arrow_bottom(width, height)
    init = true
end

local function gen_y(direction,cg)
    local dir_to_y = {
        left   =cg.y+cg.height/2,
        right  =cg.y+cg.height/2,
        top    =cg.y+cg.height-48,
        bottom =cg.y
    }
    return dir_to_y[direction]
end

local function gen_x(direction,cg)
    local dir_to_x = {
        left   =cg.x+cg.width-48,
        right  =cg.x,
        top    =cg.x+cg.width/2,
        bottom =cg.x+cg.width/2
    }
    return dir_to_x[direction]
end

local function create_splitter(cg,args)
    local args = args or {}
    local private_data = {x=args.x,y=args.y,direction=args.direction}
    local data = {}
    local aWb = wibox({position="free"})
    local visible = false
    
    local get_map = {
        x = function() return (type(private_data.x) == "function") and private_data.x() or private_data.x or gen_x(private_data.direction,cg)  end,
        y = function() return (type(private_data.y) == "function") and private_data.y() or private_data.y or gen_y(private_data.direction,cg)  end,
        visible = function() return aWb.visible end
    }
    local set_map = {
        x = false,
        y = false,
    }
    object_model(data,get_map,set_map,private_data,{
        autogen_getmap      = true ,
        autogen_signals     = true ,
        auto_signal_changed = true ,
        force_private       = {
            selected        = true ,
            title           = true }
    })
    
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

local img = {"","arrowLeft","arrowUp","arrowDown","arrowRight",""}
local right_bar,left_bar
local function gen_splitter_bar_mask(i_mul, start_pos)
    local img2 = capi.image.argb32(16, 16, nil)
    for i=0,16 do
        print(i,math.floor(math.sin( (math.pi/32)*i )*16)  )
        img2:draw_rectangle(start_pos+(i*i_mul), 0, 1, 16-math.floor(math.sin((math.pi/32)*i)*16), true, "#ffffff")
    end
    return img2
end
function create_splitter_bar(cg)
    local wbs = {}
    local data = {}
    local visible = false
    local x,y = 0,0
    
    for i=1,6 do
        local w = wibox({position="free"})
        w.width = 16
        w.height = 16
        w.ontop = true
        w.bg = beautiful.fg_normal
        w.visible = false
        if img[i] ~= "" then
            local wd = capi.widget({type="imagebox"})
            wd.image = capi.image(util.getdir("config") .. "/theme/darkBlue/Icon/".. img[i] .."_dark.png")
            w.widgets = {wd} 
        end
        wbs[i] = w
    end
    
    local function split_tab(new_cg,layout,idx)
        local new,old = clientGroup(),cg.active
        old.decorations:remove_decoration("titlebar")
        new:set_layout(common.get_layout_list()[layout])
        new:attach(new_cg)
        cg:attach(new)
        new:attach(old,idx)
        cg:repaint()
        new.visible = false --TODO find why it work only with that, it should work without
        new.visible = true
    end
    
    common.register_wibox(wbs[2], cg2, function(new_cg) split_tab(new_cg,"vertical"  ,nil ) end)
    common.register_wibox(wbs[3], cg2, function(new_cg) split_tab(new_cg,"horizontal",1   ) end)
    common.register_wibox(wbs[4], cg2, function(new_cg) split_tab(new_cg,"horizontal",nil ) end)
    common.register_wibox(wbs[5], cg2, function(new_cg) split_tab(new_cg,"vertical"  ,1   ) end)
    
    right_bar = right_bar or gen_splitter_bar_mask(-1,16)
    left_bar  = left_bar or gen_splitter_bar_mask(1,0)
    wbs[1].shape_clip     = left_bar
    wbs[1].shape_bounding = left_bar
    wbs[6].shape_clip     = right_bar
    wbs[6].shape_bounding = right_bar
    
    function data:update()
        if (common.are_splitter_visible() == false and wbs[1].visible == false) or not wbs then return end
        if wbs[1].visible ~= common.are_splitter_visible() or visible ~= cg.visible then
            for i=1,6 do
                wbs[i].visible = cg.visible and common.are_splitter_visible()
            end
        end
        if wbs[1].visible == true then
            for i=1,6 do
                wbs[i].x = cg.x + ((i-1)*16)
                wbs[i].y = cg.y-16
            end
        end
    end
    cg:add_signal("destroyed",function()
        for i=1,6 do
            wbs[i].visible = false
            wbs[i] = nil
        end
        wbs = nil
        data = nil
    end)
    
--     local get_map = {
--         x = function() return x end,
--         y = function() return y end
--     }
--     local set_map = {}
--     object_model(tab,get_map,set_map,private_data,{
--         autogen_getmap      = true ,
--         autogen_signals     = true ,
--         auto_signal_changed = true ,
--         force_private       = {
--             selected        = true ,
--             title           = true }
--     })
    return data
end

setmetatable(_M, { __call = function(_, ...) return create_splitter(...) end })