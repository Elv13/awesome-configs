local setmetatable = setmetatable
local pairs        = pairs
local print        = print
local type = type
local object_model = require( "ultiLayout.object_model" )
local border       = require( "ultiLayout.widgets.border" )

module("ultiLayout.edge")
local auto_display_border = true

local function create_edge(args)
    local data            = {}
    local private_data    = { wibox = args.wibox ,
                              orientation = args.orientation,
                              cg1   = args.cg1   ,
                              cg2   = args.cg2   ,
                              x     = args.x     ,
                              y     = args.y     }
    
    local get_map = {
        x           = function () return private_data.x                                                                           end,
        y           = function () return private_data.y                                                                           end,
        orientation = function () return private_data.orientation or ((not private_data.cg1 or private_data.cg1.x == private_data.cg2.x) and "horizontal" or "vertical") end,
        length      = function () return (data.orientation == "horizontal") and private_data.cg2.width or private_data.cg2.height end,
        wibox       = function () return private_data.wibox                                                                       end,
        width       = function () return private_data.wibox.width                                                                 end,
        height      = function () return private_data.wibox.height                                                                end,
        visible     = function () return private_data.cg1 and private_data.cg2 and private_data.wibox.visible                     end,
    }
    
    local set_map = {
        wibox   = false,
        cg1     = function (value) private_data.cg1 = value end,
        cg2     = function (value) private_data.cg2 = value end,
        x       = function (value) private_data.x,private_data.wibox.x = value,value end,
        y       = function (value) private_data.y,private_data.wibox.y = value,value end,
        width   = function (value) private_data.wibox.width = value end,
        height  = function (value) private_data.wibox.height = value end,
        visible = function (value) private_data.wibox.visible = ((private_data.cg1 and private_data.cg2) and value or false) end,
    }
    for k,v in pairs({"orientation"}) do
        set_map[v] = false
    end
    
    object_model(data,get_map,set_map,private_data,{autogen_getmap = true,autogen_signals = true})
    
    if private_data.wibox == nil and auto_display_border == true then
        private_data.wibox = border.create(data)
    end
    function data:update()
        if private_data.cg1 and private_data.cg2 then
            border.update_wibox(data)
            border.visible = true
        else
            border.visible = false
        end
    end
    return data
end
setmetatable(_M, { __call = function(_, ...) return create_edge(...) end })