--This is the smallest component of a layout. It handle titlebars and (optionally) some other goodies
local common       = require( "ultiLayout.common" )
local clientGroup  = require( "ultiLayout.clientGroup" )
local print = print

local capi = { image  = image,
               widget = widget,
               client = client,
               mouse  = mouse,
               root   = root}

module("ultiLayout.modules.keybpard_handling")

local function move_left_real(tabs_too)
    print("finding")
    local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
    print("unit",unit,capi.client.focus,unit.client,common.tag_to_cg())
    if unit then
        local current_level,prev = unit.parent
        print("starting",current_level,unit.parent,current_level.orientation)
        while current_level ~= nil and current_level.orientation ~= "vertical" do
            prev,current_level = current_level,current_level.parent
            print("new parent",current_level.orientation)
        end
        if current_level then
            local index = current_level:cg_to_idx(prev)
            print("IT WORK!!!",index,current_level.orientation)
        end
    end
end

function move_left(count,tabs_too)
    move_left_real(tabs_too)
end

function resize_h_inc()
    
end

function resize_h_dec()
    
end

function resize_w_int()
    
end

function resize_w_dec()
    
end