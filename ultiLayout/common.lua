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

local layouts          = {} -- tag -> layout name -> top level CG
local cur_layout_name  = {} -- tag -> name
local top_level_cg     = {} -- tag -> cg
-- local layout_list_idx  = {} -- int -> layout func
local layout_list      = {} --string -> layout func
local titlebars        = {} --cg -> titlebar
local vertices         = {}
local borderW          = {}
local active_splitters = {}
local auto_display_border = false

function create_vertex(args)
    local data        = {}
    local attached_cg = {}
    data.orientation  = args.orientation or "horizontal"
    data.x            = args.x           or 0
    data.y            = args.y           or 0
    data.length       = args.length      or 0
    data.cg1          = args.cg1         or nil
    data.cg2          = args.cg2         or nil
    function data:set_x     (val) data.x      = val end
    function data:set_y     (val) data.y      = val end
    function data:set_length(val) data.length = val end
    function data:attach(cg)
        table.insert(attached_cg,cg)
    end
    function data:attached() return attached_cg end
    return data
end

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
--     cg:get_parent():detach(cg)
--     new_host:reparent(cg)
-- end

function swap_client_group(cg1,cg2,force)
    if force == true then
        cg1:swap(cg2)
    else
        print("in swap")
        local swapable1, swapable2 = cg1,cg2
        
        while swapable1 ~= nil and swapable1.swapable == false do
            swapable1 = swapable1:get_parent()
        end
        
        while swapable2 ~= nil and swapable2.swapable == false do
            swapable2 = swapable2:get_parent()
        end
        
        if swapable1 ~= nil and swapable2 ~= nil then
            print("Ready")
            swapable1:swap(swapable2)
        else
            print("Clients can not be swapped",swapable1,swapable2)
        end
    end
end

-- vertex = {orientation = "v" or "h", x1:x2,y1:y2, affected = {type="cg" or "c", item = nil}}

-- function compute_vertices(s)
--     vertices = {}
--     local by_item = {}
--     local cg = top_level_cg[tag.selected(s)]
--     --TODO if the cg host many more, then make vertex for the internal limits
--     if cg then
--         --for v,c in ipairs(cg:all_clients()) do
--             local vertex = {
--                 orientation = "v"
--                 
--             }
--         --end
--     end
-- end

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
        for k,v in ipairs(vertex) do
            local w = borderW[v] or wibox({position = 'free'})
            borderW[v] = w
            local curName = nil
            w.x = v.x
            w.y = v.y
--             v.cg2:add_signal("x::changed", function(cg,delta)w.x = 100 end)
--             v.cg2:add_signal("y::changed", function(cg,delta)w.y = 100 end)
            if v.orientation == "horizontal" then
                w.width  = v.length or 10
                w.height = 2
                curName  = "sb_v_double_arrow"
                v.cg2:add_signal("width::changed", function(cg,delta)w.width = v.cg2.width;print('test2 '..delta,w.width) end)
            else --Handle any other value, even if vertical should be the only one
                w.height = v.length
                w.width  = 2
                curName  = "sb_h_double_arrow"
                v.cg2:add_signal("height::changed", function(cg,delta)w.height = v.cg2.height;print("test "..delta,w.height) end)
            end
            
            v.cg2:add_signal("x::changed", function(cg,delta)
                v.x  = v.cg1.x+v.cg1.width
                w.x  = v.x
                w.bg ="#00ff00"
            end)
            v.cg2:add_signal("y::changed", function(cg,delta)
                v.y  = v.cg1.y+v.cg1.height
                w.y  = v.y
                w.bg ="#00ff00"
            end)
            
            w.ontop = true
            w.bg = "#ff0000"
            
            local function resize(axe,length,mouse)
                local d = mouse[axe] - (v.cg1[length]+v.cg1[axe])
                if v.cg1 then
                    v.cg1[ length ] = v.cg1[ length ] + d
                    v.cg1:repaint()
                end
                if v.cg2 then
                    v.cg2[ length ] = v.cg2[ length ] - d
                    v.cg2[ axe    ] = v.cg2[ axe    ] + d
                    v.cg2:repaint()
                end
--                 w[axe] = mouse[axe]
            end
            
            w:add_signal("mouse::enter", function ()
                capi.root.cursor("left_ptr")
                if v.orientation == "vertical" then
                    capi.root.cursor("sb_h_double_arrow") --double_arrow
                else
                    capi.root.cursor("sb_v_double_arrow")
                end
                w:buttons(util.table.join(
                    button({ }, 1 ,function (tab)
                        capi.mousegrabber.run(function(mouse)
                            if mouse.buttons[1] == false then
                                return false
                            end
                            if v.orientation == "horizontal" then
                                resize("y","height",mouse)
                            else --Handle any other value, even if vertical should be the only one
                                resize("x","width",mouse)
                            end
                            return true
                        end,curName)
                end)))
                w.bg = "#00ffff"
            end)

            w:add_signal("mouse::leave", function ()
                capi.root.cursor("left_ptr")
                w.bg = "#ff00ff"
            end)
                    end
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
        top_level_cg[t] = layouts[t][name]
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
        v:get_parent():detach(v)
    end
end)

setmetatable(_M, { __call = function(_, ...) return new(...) end })