local setmetatable = setmetatable
local object_model = require( "ultiLayout.object_model" )
local border       = require( "ultiLayout.widgets.border" )

module("ultiLayout.edge")
local auto_display_border = true

local function create_edge(args)
    local data      = {}
    local p_data    = { wibox       = args.wibox          ,
                        orientation = args.orientation    ,
                        cg          = args.cg             ,
                        x           = args.x              ,
                        y           = args.y              ,
                        visible     = args.visible or true}
    
    local get_map = {
        length      = function () return (data.orientation == "horizontal") and p_data.cg.width or p_data.cg.height          end,
        width       = function () return p_data.wibox.width                                                                  end,
        height      = function () return p_data.wibox.height                                                                 end,
        visible     = function () return (p_data.cg and (p_data.cg.parent:cg_to_idx(p_data.cg) or 0) > 1) and p_data.visible end,
    }
    
    local set_map = {
        wibox       = false,
        orientation = false,
        cg          = function (value) p_data.cg = value                                     end,
        x           = function (value) p_data.x,p_data.wibox.x = value,value                 end,
        y           = function (value) p_data.y,p_data.wibox.y = value,value                 end,
        width       = function (value) p_data.wibox.width = value                            end,
        height      = function (value) p_data.wibox.height = value                           end,
        visible     = function (value) p_data.visible = value; p_data.wibox.visible = value and data.visible  end,
    }
    
    object_model(data,get_map,set_map,p_data,{autogen_getmap = true,autogen_signals = true})
    
    if p_data.wibox == nil and auto_display_border == true then
        p_data.wibox = border.create(data)
    end
    function data:update()
        local idx = (p_data.cg.parent) and p_data.cg.parent:cg_to_idx(p_data.cg) or 0
        p_data.wibox.visible = (p_data.cg and p_data.cg.parent ~= nil and idx and idx > 1) and p_data.cg.visible and p_data.visible
    end
    p_data.cg:add_signal("parent::changed"     ,function(...)       data:update()        end)
    return data
end
setmetatable(_M, { __call = function(_, ...) return create_edge(...) end })