local capi = { mouse        = mouse        ,
               screen       = screen       ,
               client       = client       ,
               mousegrabber = mousegrabber }

local setmetatable = setmetatable
local table        = table
local type         = type
local ipairs       = ipairs
local print        = print
local math         = math
local pairs        = pairs
local button       = require( "awful.button"           )
local wibox        = require( "awful.wibox"            )
local tag          = require( "awful.tag"              )
local clientGroup  = require( "ultiLayout.clientGroup" )
local client       = require( "awful.client"           )
local thumbnail    = require( "ultiLayout.widgets.thumbnail")

module("ultiLayout.common")

local layouts             = {} -- tag -> layout name -> top level CG
local cur_layout_name     = {} -- tag -> name
local top_level_cg        = {} -- tag -> cg
local layout_list         = {} -- string -> layout func
local currentTag          = {} -- screen -> cg
local wibox_to_cg         = {}
local vertices            = {}
local splitter_visible    = false

function add_new_layout(name, func)
    layout_list[name] = func
end

-- function merge_client_groups(cg1,cg2,layout,args)
--     local newCg = ultiLayout.clientGroup()
--     newCg:set_layout(layout)
--     for _k,cg in ipairs({cg1,cg2}) do
--         for k,v in pairs(cg:clients()) do
--             newCg:add_client(v)
--         end
--     end
-- end

function register_wibox(w, cg, on_drop_f)
    if not w then return end
    wibox_to_cg[w] = {cg=cg,on_drop_f=on_drop_f}
end

local function abstract_drag(cg,on_drag_f,on_drop_f,on_click_f,args)
    local cur = capi.mouse.coords()
    local args = args or {}
    local moved = false
    capi.mousegrabber.run(function(mouse)
        if mouse.buttons[args.button or 1] == false then
            if not moved and type(on_click_f) == "function" then
                on_click_f()
            end
            if type(on_drop_f) == "function" then
                on_drop_f(mouse,cur)
            end
            capi.mousegrabber.stop()
            return false
        end
        if mouse.x ~= cur.x and mouse.y ~= cur.y then
            if not moved and type(args.on_first_move) == "function" then
                args.on_first_move(mouse,cur)
            end
            moved = true
            if type(on_drag_f) == "function" then
                on_drag_f(mouse,cur)
            end
            cur.x,cur.y = mouse.x,mouse.y
        end
        return true
    end,"fleur")
end

function drag_cg(cg,on_click_f,args)
    local args = args or {}
    args.on_first_move = args.on_first_move or function() toggle_splitters(true) end
    if cg.floating == true then
        abstract_drag(cg,function(mouse,cur)
            cg.x = cg.x + (mouse.x-cur.x)
            cg.y = cg.y + (mouse.y-cur.y)
            cg:repaint()
        end,nil,on_click_f)
    else
        local aWb = args.wibox or thumbnail(cg)
        abstract_drag(cg,function(mouse,cur)
            aWb.visible = true
            aWb.x = mouse.x+10
            aWb.y = mouse.y+10
        end,
        function(mouse,cur)
            aWb.visible = false
            aWb = nil
            local obj = capi.mouse.object_under_pointer()
            if type(obj) == "client" then
                local possibilities = clientGroup.get_cg_from_client(obj)
                if possibilities ~= nil then
                    swap_client_group(cg,possibilities[1])
                end
            elseif type(obj) == "wibox" and wibox_to_cg[obj] ~= nil and type(wibox_to_cg[obj].on_drop_f) == "function" then
                wibox_to_cg[obj].on_drop_f(cg)
            end
            toggle_splitters(false)
        end, on_click_f,args)
    end
end

function drag_cg_under_cursor(c)
    local cg = clientGroup.get_cg_from_client(c, top_level_cg[tag.selected(capi.mouse.screen)])
    drag_cg(cg)
end

function swap_client_group(cg1,cg2,force)
    if force == true then
        cg1:swap(cg2)
    else
        local swapable1, swapable2 = cg1,cg2
        
        while swapable1 ~= nil and swapable1.swapable == false do
            swapable1 = swapable1.parent
        end
        
        while swapable2 ~= nil and swapable2.swapable == false do
            swapable2 = swapable2.parent
        end
        
        if swapable1 ~= nil and swapable2 ~= nil then
            swapable1:swap(swapable2)
        else
            print("Clients can not be swapped",swapable1,swapable2)
        end
    end
end

function get_closest_vertex(point)
    
end

function resize_closest()
    local v      = get_closest_vertex()
    local coords = capi.mouse.coords
    local vx1    = v.x1
    local vy1    = v.y1
    capi.mousegrabber.run(function(mouse)
        if mouse.buttons[1] == false and mouse.buttons[3] == false then
            return false
        end
        if v.orientation == "v" then
            local dx = coords.x - mouse.x
        elseif v.orientation == "h" then
            local dy = coords.y - mouse.y
        end
        return true
    end,"fleur")
    
end

function get_layout_list()
    return layout_list
end

function toggle_splitters(value)
    splitter_visible = (value == nil) and not splitter_visible or value
    if top_level_cg[tag.selected(capi.mouse.screen)] ~= nil then
        top_level_cg[tag.selected(capi.mouse.screen)]:repaint()
    end
end

function are_splitter_visible()
    return splitter_visible
end

function wrap_client(c)
    local aCG = clientGroup()
    aCG:geometry(c:geometry())
    aCG:set_layout(layout_list.unit,c)
    
    if client.floating.get(c) == false then
        return aCG
    elseif client.floating.get(c) == true then
        local aStack = clientGroup()
        aStack:geometry(c:geometry())
        aStack:set_layout(layout_list.stack)
        aStack:attach(aCG)
        aStack.floating = true
        return aStack
    end
end

function wrap_stack(new_cg)
    local stack = clientGroup()
    stack:set_layout(get_layout_list().stack)
    stack:attach(new_cg)
    return stack
end

local function get_layout_name_list()
    local list = {}
    for k,v in pairs(layout_list) do
        table.insert(list,k)
    end
    return list
end

local function layout_name_to_idx(name)
    local layout_array = ordered or get_layout_name_list()
    for k,v in pairs(layout_array) do
        if v == name then
            return k
        end
    end
    return nil
end

function set_layout_by_name(name,t)
    local t = t or tag.selected(capi.mouse.screen)
    if not layouts[t] then layouts[t] = {} end
    if layout_list[name] ~= nil and (not layouts[t][name]) then
        if top_level_cg[t] == nil or (top_level_cg[t] ~= nil and cur_layout_name[t] ~= name) then
            local aCG = clientGroup()
            local coords = capi.screen[t.screen].workarea
            aCG:set_layout( layout_list[name])
            cur_layout_name[t] = name
            layouts[t][name] = aCG
            clientGroup.lock()
            for k,v in ipairs(t:clients()) do
                local unit = wrap_client(v)
                aCG:attach(unit)
            end
            for k,v in ipairs({"x","y","width","height"}) do
                aCG[v] = coords[v]
            end
            clientGroup.unlock()
            if top_level_cg[t] then
                top_level_cg[t].visible = false
            end
            top_level_cg[t] = aCG
            aCG.visible = true
            aCG:repaint()
        end
    elseif layouts[t][name] then
        print("Using existing ".. name .." layout")
        top_level_cg[t].visible = false
        local aCG = layouts[t][name]
        top_level_cg[t] = aCG
        clientGroup.lock()
        for k,v in pairs(t:clients()) do
            if not aCG:has_client(v) then
                local unit = wrap_client(v)
                aCG:attach(unit)
            end
        end
        clientGroup.unlock()
        aCG.visible = true
        cur_layout_name[t] = name
        layouts[t][name]:repaint()
    else
        print("layout".. name .. " not found")
    end
    if t.selected then
        currentTag[t.screen] = top_level_cg[t]
    end
end

function rotate_layout(inc,t)
    local inc = inc or 1
    local t = t or tag.selected(capi.mouse.screen)
    local layout_array = ordered or get_layout_name_list()
    local current_index = layout_name_to_idx(cur_layout_name[t]) or 1
    local new_index = (current_index+inc > #layout_array) and current_index+inc-#layout_array or current_index+inc
    if layout_array[new_index] == "unit" then
        rotate_layout(inc+(inc/math.abs(inc)),t)
    else
        set_layout_by_name(layout_array[new_index],t)
    end
end

function get_current_layout_name(s)
    return cur_layout_name[tag.selected(s or capi.mouse.screen)]
end

local function switch_on_tag_change(t)
    local t,cg = t or tag.selected(capi.mouse.screen),top_level_cg[t]
    if t.selected == false then return end
    if currentTag[t.screen] ~= nil and currentTag[t.screen] ~= cg then
        currentTag[t.screen].visible = false
    end
    if cg then
        cg.visible = true
    else
        --set_layout_by_name("righttile",t)
    end
    currentTag[t.screen] = cg
end

tag.attached_add_signal(screen, "property::selected", switch_on_tag_change)
-- tag.attached_add_signal(screen, "property::layout", switch_on_tag_change)

capi.client.add_signal("unmanage", function (c, startup) 
    local units = clientGroup.get_cg_from_client(c)
    for k,v in pairs(units) do
        v.parent:detach(v)
    end
end)

capi.client.add_signal("manage", function (c, startup)
    local t = t or tag.selected(capi.mouse.screen)
    local cg = top_level_cg[t]
    if cg then
        local unit = wrap_client(c)
        cg:attach(unit)
        cg:repaint()
    end
end)

setmetatable(_M, { __call = function(_, ...) return new(...) end })