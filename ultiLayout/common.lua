local capi = { image        = image        ,
               widget       = widget       ,
               mouse        = mouse        ,
               screen       = screen       ,
               root         = root         ,
               client       = client       ,
               mousegrabber = mousegrabber }

local setmetatable = setmetatable
local table        = table
local type         = type
local ipairs       = ipairs
local print        = print
local math         = math
local rawset       = rawset
local rawget       = rawget
local pairs        = pairs
local debug        = debug
local button       = require( "awful.button"           )
local beautiful    = require( "beautiful"              )
local wibox        = require( "awful.wibox"            )
local tag          = require( "awful.tag"              )
local clientGroup  = require( "ultiLayout.clientGroup" )
local util         = require( "awful.util"             )
local client       = require( "awful.client"           )

module("ultiLayout.common")

local layouts             = {} -- tag -> layout name -> top level CG
local cur_layout_name     = {} -- tag -> name
local top_level_cg        = {} -- tag -> cg
local layout_list         = {} -- string -> layout func
local titlebars           = {} -- cg -> titlebar
local vertices            = {}
local borderW             = {}
local active_splitters    = {}
local auto_display_border = true


function add_new_layout(name, func)
    layout_list[name] = func
end

function get_titlebar(cg)
    if not titlebars[cg] then
        titlebars[cg] = widgets.titlebar.create(cg)
    end
    return titlebars[cg]
end

function add_splitter_box(x,y,direction,on_drop,on_hover)
    local w  =  wibox({position = "free"})
    w.x      = x
    w.y      = y
    w.width  = 50
    w.height = 50
    w.ontop  = true
    w.bg     = "#00ff00"
    table.insert(active_splitters,w)
end

function clear_splitter_box()
    for k,v in pairs(active_splitters) do
        v.visible = false
    end
    active_splitters = {}
end

-- function create_client_group(c,args)
--     local cg = ultiLayout.clientGroup()
--     local l  = args.layout or args.layout_idx or layout_list_idx[1]
--     cg:add_client(c)
--     cg:set_layout(l)
--     return cg
-- end

-- function merge_client_groups(cg1,cg2,layout,args)
--     local newCg = ultiLayout.clientGroup()
--     newCg:set_layout(layout)
--     for _k,cg in ipairs({cg1,cg2}) do
--         for k,v in pairs(cg:clients()) do
--             newCg:add_client(v)
--         end
--     end
-- end

-- function move_client_group(cg,new_host,args)
--     cg.parent:detach(cg)
--     new_host:reparent(cg)
-- end

function drag_cg_under_cursor(c)
    local cg = (clientGroup.get_cg_from_client(c) or {})[1]
    if cg == nil then return end
    if cg.floating == true then
        local cur = capi.mouse.coords()
        local moved = false
        capi.mousegrabber.run(function(mouse)
            if mouse.buttons[1] == false then
                --if not moved then
                --    
                --end
                capi.mousegrabber.stop()
                return false
            end
            if mouse.x ~= cur.x and mouse.y ~= cur.y then
                --moved = true
                cg.x = cg.x + (mouse.x-cur.x)
                cg.y = cg.y + (mouse.y-cur.y)
                cur = {x=mouse.x,y=mouse.y}
                cg:repaint()
            end
            return true
        end,"fleur")
    else
    print("I am here4")
        local cur = capi.mouse.coords()
        local moved = false
        local aWb = wibox({position="free"})
        aWb.width  = 200
        aWb.height = 200
        aWb.x = cur.x+10
        aWb.y = cur.y+10
        
        aWb.ontop = true
        capi.mousegrabber.run(function(mouse)
            if mouse.buttons[1] == false then
                --if not moved then
                --    
                --end
                aWb.visible = false
                aWb = nil
                local obj = capi.mouse.object_under_pointer()
                if type(obj) == "client" then
                    local possibilities = clientGroup.get_cg_from_client(obj)
                    if possibilities ~= nil then
                        swap_client_group(cg,possibilities[1])
                    end
                end
                capi.mousegrabber.stop()
                return false
            end
            if mouse.x ~= cur.x and mouse.y ~= cur.y then
                --moved = true
                aWb.x = mouse.x+10
                aWb.y = mouse.y+10
                cur = {x=mouse.x,y=mouse.y}
                --cg:repaint()
            end
            return true
        end,"fleur")
    end
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

function match_closest_vertex()
    
end

function resize_closest()
    local v      = match_closest_vertex()
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

function display_visual_hits(s)
    for k,v in ipairs(t:clients()) do
        local w   = wibox({position="free"})
        w.ontop   = true
        w.width   = 60
        w.height  = 60
        w.bg      = "#00ff00"
        local geo = v:geometry()
        w.x       = geo.x + geo.width  -60
        w.y       = geo.y + geo.height/2
    end
end

function toggle_visibility(t,value)
    local t = t or tag.selected(capi.mouse.screen)
    if top_level_cg[t] then
        local cg = top_level_cg[t]
        cg.visible =  not cg.visible
    else
        print("No layout")
    end
end
--tag.attached_add_signal(1, "property::selected",toggle_visibility )

local function repaint_border(t)
    if not auto_display_border then return end
    local t = t or tag.selected(capi.mouse.screen)
    if top_level_cg[t] then
        local vertex = {}
        top_level_cg[t]:gen_vertex(vertex)
        for k,v in ipairs(vertex) do
            local w = borderW[v]
            if w then
                w.x = v.x
                w.y = v.y
                if v.orientation == "horizontal" then
                    w.width = v.length
                    w.height = 2
                else
                    w.height = v.length
                    w.width = 2
                end
            end
        end
    end
end

local function display_border_real(t)
    if not auto_display_border then return end
    local t = t or tag.selected(capi.mouse.screen)
    if top_level_cg[t] then
        local vertex = {}
        top_level_cg[t]:gen_vertex(vertex)
    else
        print("No layout")
    end
end

---This is to make sure it is not called from a signal
function display_border(t)
    auto_display_border = true
    display_border_real(t)
end

function display_resize_handle(s)
    if not auto_display_border then return end
    local t = t or tag.selected(capi.mouse.screen)
    if top_level_cg[t] then
        local vertexH = {}
        local vertexV = {}
        top_level_cg[t]:gen_vertex(vertex)
        for k,v in ipairs(vertex) do
            if v.orientation == "horizontal" then
                table.insert(vertexH,v)
            else
                table.insert(vertexV,v)
            end
        end
        --for k,v in ipairs(vertexV) do
            
        --end
    end
--     for k,v in ipairs(t:clients()) do
--         local w = wibox({position="free"})
--         w.ontop = true
--         w.width  = 10
--         w.height = 10
--         w.bg = "#ff0000"
--         local geo = v:geometry()
--         w.x = geo.x + geo.width  -10
--         w.y = geo.y + geo.height -10
--         
--         w:buttons(util.table.join(
--         button({ }, 1 ,function (tab)
--                                 local curX = capi.mouse.coords().x
--                                 local curY = capi.mouse.coords().y
--                                 local moved = false
--                                 capi.mousegrabber.run(function(mouse)
--                                     if mouse.buttons[1] == false then 
--                                         if moved == false then
--                                             wdgSet.button1()
--                                         end
--                                         capi.mousegrabber.stop()
--                                         return false 
--                                     end
--                                     if mouse.x ~= curX and mouse.y ~= curY then
--                                         local height = w:geometry().height
--                                         local width  = w:geometry().width
--                                         w.x = mouse.x-(5)
--                                         w.y = mouse.y-(5)
--                                         v:geometry({width=mouse.x-geo.x,height=mouse.y-geo.y})
--                                         moved = true
--                                     end
--                                     return true
--                                 end,"fleur")
--                         end)))
--     end
end

function toggle_splitters(t)
    local t = t or tag.selected(capi.mouse.screen)
    if top_level_cg[t] ~= nil then
        top_level_cg[t]:toggle_splitters(true,true)--horizontal,vertical
    end
end

function wrap_client(c)
    local aCG = clientGroup()
    aCG:geometry(c:geometry())
    aCG:set_layout(layout_list.unit(aCG,c))
    
    if client.floating.get(c) == false then
        return aCG
    elseif client.floating.get(c) == true then
        local aStack = clientGroup()
        aStack:geometry(c:geometry())
        aStack:set_layout(layout_list.stack(aStack))
        aStack:attach(aCG)
        aStack.floating = true
        return aStack
    end
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
        aCG:set_layout( layout_list[name](aCG))
        cur_layout_name[t] = name
        layouts[t][name] = aCG
            for k,v in ipairs(t:clients()) do
                local unit = wrap_client(v)
                aCG:attach(unit)
            end
            aCG.width  = coords.width
            aCG.height = coords.height
            aCG.x      = coords.x
            aCG.y      = coords.y
            aCG:add_signal("geometry::changed",function () repaint_border(t) end)
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
        for k,v in pairs(t:clients()) do
            if not aCG:has_client(v) then
                local unit = wrap_client(v)
                aCG:attach(unit)
            end
        end
        top_level_cg[t].visible = true
        cur_layout_name[t] = name
        --top_level_cg[t]:repaint()
        layouts[t][name]:repaint()
    else
        print("layout".. name .. " not found")
    end
end

function rotate_layout(inc,t)
    local inc = inc or 1
    local t = t or tag.selected(capi.mouse.screen)
    local layout_array = ordered or get_layout_name_list()
    local current_index = layout_name_to_idx(cur_layout_name[t]) or 1
    local new_index = (current_index+inc > #layout_array) and current_index+inc-#layout_array or current_index+inc
    --print("old idx",current_index,new_index,cur_layout_name[t],layouts[t][name])
    if layout_array[new_index] == "unit" then
        rotate_layout(inc+(inc/math.abs(inc)),t)
    else
        set_layout_by_name(layout_array[new_index],t)
    end
end

-- function set_layout_by_id(t,id)
--     
-- end

function get_current_layout_name(s)
    
end

-- function get_current_layout_id(s)
--     
-- end

local currentTag = nil
local function switch_on_tag_change(t)
    local t = t or tag.selected(capi.mouse.screen)
    if currentTag ~= nil then
        currentTag.visible = false
    end
    if top_level_cg[t] then
        top_level_cg[t].visible = true
        top_level_cg[t]:repaint()
    else
        --set_layout_by_name("righttile",t)
    end
    currentTag = top_level_cg[t]
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