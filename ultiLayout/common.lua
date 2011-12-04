local setmetatable = setmetatable
local table        = table
local type         = type
local ipairs       = ipairs
local print        = print
local pairs        = pairs
local debug        = debug
local button       = require( "awful.button"           )
local beautiful    = require( "beautiful"              )
local naughty      = require( "naughty"                )
local wibox        = require( "awful.wibox"            )
local tag          = require( "awful.tag"              )
local clientGroup  = require( "ultiLayout.clientGroup" )
local util         = require( "awful.util"             )

local capi = { image  = image  ,
               widget = widget,
               mouse = mouse,
               screen = screen,
               root = root,
               mousegrabber = mousegrabber}

module("ultiLayout.common")

local layouts         = {} -- tag -> layout instance
local top_level_cg    = {} -- tag -> cg
local layout_list_idx = {} -- int -> layout func
local layout_list     = {} --string -> layout func
local titlebars       = {} --cg -> titlebar
local vertices        = {}

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
        widgets.titlebar.create(cg)
    end
end

function create_client_group(c,args)
    local cg = ultiLayout.clientGroup()
    local l  = args.layout or args.layout_idx or layout_list_idx[1]
    cg:add_client(c)
    cg:set_layout(l)
    return cg
end

function merge_client_group(cg1,cg2,layout,args)
    local newCg = ultiLayout.clientGroup()
    newCg:set_layout(layout)
    for _k,cg in ipairs({cg1,cg2}) do
        for k,v in pairs(cg:clients()) do
            newCg:add_client(v)
        end
    end
end

function move_client_group(cg,new_host,args)
    cg:get_parent():detach(cg)
    new_host:reparent(cg)
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
    local v = match_closest_vertex()
    local coords = capi.mouse.coords
    local vx1 = v.x1
    local vy1 = v.y1
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
        local w = wibox({position="free"})
        w.ontop = true
        w.width  = 60
        w.height = 60
        w.bg = "#00ff00"
        local geo = v:geometry()
        w.x = geo.x + geo.width  -60
        w.y = geo.y + geo.height/2
    end
end

function display_border(t)
    local t = t or tag.selected(capi.mouse.screen)
    print("Showing border")
    if top_level_cg[t] then
        local vertex = {}
        top_level_cg[t]:gen_vertex(vertex)
        for k,v in ipairs(vertex) do
            local w = wibox({position = 'free'})
            local curName = nil
            w.x = v.x
            w.y = v.y
            --v.cg2:add_signal("x::changed", function(cg,delta)w.x = 100 end)
            --v.cg2:add_signal("y::changed", function(cg,delta)w.y = 100 end)
            if v.orientation == "horizontal" then
                w.width = v.length
                w.height = 2
                curName = "sb_v_double_arrow"
                v.cg2:add_signal("width::changed", function(cg,delta)w.width = v.cg2.width;print('test2 '..delta,w.width) end)
                v.cg2:add_signal("x::changed", function(cg,delta)
                    v.x = v.x+delta
                    w.x = v.x;print('test3 '..delta,w.x) 
                    w.bg="#00ff00"
                end)
                v.cg2:add_signal("y::changed", function(cg,delta)
                    v.y = v.y+delta
                    w.y = v.y;print('test4 '..delta,w.y) 
                    w.bg="#00ff00"
                end)
            else --Handle any other value, even if vertical should be the only one
                w.height = v.length
                w.width = 2
                curName = "sb_h_double_arrow"
                v.cg2:add_signal("height::changed", function(cg,delta)w.height = v.cg2.height;print("test "..delta,w.height) end)
            end
            w.ontop = true
            w.bg = "#ff0000"
            
            local function resize(axe,length,mouse)
                local d = (mouse[axe] - (v.cg1[length]+v.cg1[axe]))
                if w[axe] ~= mouse[axe] and v.cg1 then
                    v.cg1[length] = v.cg1[length] + d
                    v.cg1:repaint()
                end
                if w[axe] ~= mouse[axe] and v.cg2 then
                    v.cg2[length] = v.cg2[length] - d
                    v.cg2[axe] = v.cg2[axe] + d
                    v.cg2:repaint()
                end
                w[axe] = mouse[axe]
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
                --w.bg = "#00ff00"
            end)

            w:add_signal("mouse::leave", function ()
                capi.root.cursor("left_ptr")
                w.bg = "#ff0000"
            end)
                    end
        print("size",#vertex)
    else
        print("No layout")
    end
end

function display_resize_handle(s)
    for k,v in ipairs(t:clients()) do
        local w = wibox({position="free"})
        w.ontop = true
        w.width  = 10
        w.height = 10
        w.bg = "#ff0000"
        local geo = v:geometry()
        w.x = geo.x + geo.width  -10
        w.y = geo.y + geo.height -10
        
        w:buttons(util.table.join(
        button({ }, 1 ,function (tab)
                                local curX = capi.mouse.coords().x
                                local curY = capi.mouse.coords().y
                                local moved = false
                                capi.mousegrabber.run(function(mouse)
                                    if mouse.buttons[1] == false then 
                                        if moved == false then
                                            wdgSet.button1()
                                        end
                                        capi.mousegrabber.stop()
                                        return false 
                                    end
                                    if mouse.x ~= curX and mouse.y ~= curY then
                                        local height = w:geometry().height
                                        local width  = w:geometry().width
                                        w.x = mouse.x-(5)
                                        w.y = mouse.y-(5)
                                        v:geometry({width=mouse.x-geo.x,height=mouse.y-geo.y})
                                        moved = true
                                    end
                                    return true
                                end,"fleur")
                        end)))
    end
end

function wrap_client(c)
    local aCG = clientGroup()
    aCG:geometry(c:geometry())
    aCG:set_layout(layout_list["unit"](aCG,c))
    return aCG
end

function set_layout_by_name(name,t)
    local t = t or tag.selected(capi.mouse.screen)
    if layout_list[name] ~= nil then
        if top_level_cg[t] == nil then
            local aCG = clientGroup()
            local coords = capi.screen[t.screen].geometry
            for k,v in ipairs(t:clients()) do
                local unit = wrap_client(v)
                aCG:attach(unit)
            end
            aCG.width  = coords.width
            aCG.height = coords.height
            top_level_cg[t] = aCG
            aCG:repaint()
        end
        top_level_cg[t]:set_layout( layout_list[name](top_level_cg[t]))
    else
        print("layout not found")
    end
end

function set_layout_by_id(t,id)
    
end

function get_current_layout_name(s)
    
end

function get_current_layout_id(s)
    
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })