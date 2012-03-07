local capi = { root         = root         ,
               mousegrabber = mousegrabber }

local setmetatable = setmetatable
local table        = table
local print        = print
local pairs        = pairs
local button       = require( "awful.button" )
local wibox        = require( "awful.wibox"  )
local util         = require( "awful.util"   )
local object_model = require( "ultiLayout.object_model" )

module("ultiLayout.vertex")
local auto_display_border = true

local function update_wibox(vertex)
    if vertex.wibox ~= nil then
        vertex.wibox.x                                                           = vertex.x
        vertex.wibox.y                                                           = vertex.y
        vertex.wibox[vertex.orientation == "vertical" and "width"  or "height" ] = 3
        vertex.wibox[vertex.orientation == "vertical" and "height" or "width"  ] = vertex.length
    end
    vertex.wibox.visible=true
end

local function create_border(vertex)
    local w = wibox({position = "free"})
    w.ontop = true
    w.bg = "#ff0000"
    w:buttons(util.table.join(
        button({ }, 1 ,function (tab)
            capi.mousegrabber.run(function(mouse)
                if mouse.buttons[1] == false then
                    return false
                end
                local x_or_y = vertex.orientation == "horizontal" and "y" or "x"
                vertex:emit_signal("distance_change::request",mouse[x_or_y] - vertex[x_or_y])
                update_wibox(vertex)
                return true
            end,"fleur")
    end)))
    
    w:add_signal("mouse::enter", function ()
        --capi.root.cursor("left_ptr")
        --if v.orientation == "vertical" then
        --    capi.root.cursor("sb_h_double_arrow") --double_arrow
        --else
        --    capi.root.cursor("sb_v_double_arrow")
        --end
        
        w.bg = "#00ffff"
    end)

    w:add_signal("mouse::leave", function ()
        --capi.root.cursor("left_ptr")
        w.bg = "#ff00ff"
    end)
    vertex.wibox = w
    return w
end

function create_vertex(args)
    local data            = {}
    local private_data    = { wibox = args.wibox ,
                              cg1   = args.cg1   ,
                              cg2   = args.cg2   }
    
    local get_map = {
        x           = function () return private_data.cg2.x                                                                       end,
        y           = function () return private_data.cg2.y                                                                       end,
        cg1         = function () return private_data.cg1                                                                         end,
        cg2         = function () return private_data.cg2                                                                         end,
        orientation = function () return (private_data.cg1.x == private_data.cg2.x) and "horizontal" or "vertical"                end,
        length      = function () return (data.orientation == "horizontal") and private_data.cg1.width or private_data.cg1.height end,
        wibox       = function () return private_data.wibox                                                                       end,
    }
    
    local set_map = {
        wibox = function (value) private_data.wibox = value end,
        cg1   = function (value) private_data.cg1 = value end,
        cg2   = function (value) 
                    private_data.cg2 = value
                    private_data.cg2:add_signal("geometry::changed", dsfsdfdsfds)
                    update_wibox(data)
                end,
    }
    for k,v in pairs({"x","y","length","orientation"}) do
        set_map[v] = warn_invalid
    end
    
    object_model(data,get_map,set_map,private_data)
    
    if private_data.wibox == nil and auto_display_border == true then
        create_border(data)
    end
    return data
end
setmetatable(_M, { __call = function(_, ...) return create_vertex(...) end })