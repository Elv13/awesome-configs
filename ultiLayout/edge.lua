local setmetatable = setmetatable
local pairs        = pairs
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
                    border.update_wibox(data)
                end,
    }
    for k,v in pairs({"x","y","length","orientation"}) do
        set_map[v] = warn_invalid
    end
    
    object_model(data,get_map,set_map,private_data)
    
    if private_data.wibox == nil and auto_display_border == true then
        border.create(data)
    end
    return data
end
setmetatable(_M, { __call = function(_, ...) return create_edge(...) end })