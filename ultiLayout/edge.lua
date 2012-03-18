local setmetatable = setmetatable
local pairs        = pairs
local print        = print
local object_model = require( "ultiLayout.object_model" )
local border       = require( "ultiLayout.widgets.border" )

module("ultiLayout.edge")
local auto_display_border = true

local function create_edge(args)
    local data            = {}
    local private_data    = { wibox = args.wibox ,
                              cg1   = args.cg1   ,
                              cg2   = args.cg2   }
    
    local get_map = {
        x           = function () return private_data.cg2.x                                                                       end,
        y           = function () return private_data.cg2.y                                                                       end,
        orientation = function () return (private_data.cg1.x == private_data.cg2.x) and "horizontal" or "vertical"                end,
        length      = function () return (data.orientation == "horizontal") and private_data.cg1.width or private_data.cg1.height end,
    }
    
    local set_map = {
        wibox = function (value) private_data.wibox = value end,
        cg1   = function (value) private_data.cg1 = value end,
        cg2   = function (value)
                    private_data.cg2 = value
                    value:add_signal("geometry::changed", function() border.update_wibox(data) end)
                    border.update_wibox(data)
                end,
    }
    for k,v in pairs({"x","y","length","orientation"}) do
        set_map[v] = false
    end
    
    object_model(data,get_map,set_map,private_data,{autogen_getmap = true,autogen_signals = true})
    
    if private_data.wibox == nil and auto_display_border == true then
        border.create(data)
    end
    function data:update()
        border.update_wibox(data)
    end
    return data
end
setmetatable(_M, { __call = function(_, ...) return create_edge(...) end })