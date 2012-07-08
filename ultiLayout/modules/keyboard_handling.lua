--This is the smallest component of a layout. It handle titlebars and (optionally) some other goodies
local common       = require( "ultiLayout.common" )
local clientGroup  = require( "ultiLayout.clientGroup" )
local print = print
local ipairs = ipairs
local sqrt = math.sqrt

local capi = { image  = image,
               widget = widget,
               client = client,
               mouse  = mouse,
               root   = root}

module("ultiLayout.modules.keybpard_handling")

-- local function move_left_real(tabs_too)
--     print("finding")
--     local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
--     print("unit",unit,capi.client.focus,unit.client,common.tag_to_cg())
--     if unit then
--         local current_level,prev = unit.parent
--         print("starting",current_level,unit.parent,current_level.orientation)
--         while current_level ~= nil and current_level.orientation ~= "vertical" do
--             prev,current_level = current_level,current_level.parent
--             print("new parent",current_level.orientation)
--         end
--         if current_level then
--             local index = current_level:cg_to_idx(prev)
--             prev:raise()
--             print("IT WORK!!!",index,current_level.orientation)
--         end
--     end
-- end

local function move_common(cg,h_or_v,next_or_prev)
    if cg then
        local current_level,old_current = cg.parent,cg
        while current_level do
            if current_level.orientation == h_or_v and #current_level:childs() > 1--[[and #current_level:childs() - current_level:cg_to_idx(old_current) > 0]] then
                local target
                if next_or_prev == "next" then
                    target = current_level:nextChild(old_current) or current_level:childs()[1]
                else
                    target = current_level:previousChild(old_current) or current_level:childs()[#current_level:childs()]
                end
                if target then
                    if target.client ~= nil then
                        target.focus = true
                    else
                        local closest,center,winner = nil,cg:center(),nil
                        for k,v in ipairs(target:all_childs()) do
                            if v.visible == true and v.client ~= nil and v.client ~= capi.client.focus then
                                local hyp = sqrt((center.x-v:center().x)^2+(center.y-v:center().y)^2)
                                if not closest or closest > hyp then
                                    closest = hyp
                                    winner = v
                                end
--                                 if not fartest or fartest < hyp then
--                                     fartest = hyp
--                                     loser = v
--                                 end
                                if winner then
                                    print("Sucess")
                                    capi.client.focus = winner.client
                                    return
                                end
                            end
                        end
                    end
                end
            end
            old_current = current_level
            current_level = current_level.parent
        end
    end
end

function move_left(count,tabs_too)
    local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
    move_common(unit,"vertical","prev")
end

function move_right(count,tabs_too)
    local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
    move_common(unit,"vertical","next")
end

function move_up(count,tabs_too)
    local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
    move_common(unit,"horizontal","prev")
end

function move_down(count,tabs_too)
    local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
    move_common(unit,"horizontal","next")
end

function resize_h(value)
    local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
    unit.parent:resize(unit,0,value)
end

function resize_w(value)
    local unit = clientGroup.get_cg_from_client(capi.client.focus,common.tag_to_cg())
    unit.parent:resize(unit,value,0)
end