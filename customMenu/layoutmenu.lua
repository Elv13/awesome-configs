local radical  = require("radical")
local tag_menu = require( "radical.impl.common.tag" )

local capi = {client = client,mouse=mouse}

local module = {}

local centered = nil

module.centered_menu = function(layouts,backward)
    local screen = capi.client.focus and capi.client.focus.screen or capi.mouse.screen
    if not centered then

        centered = radical.box {
            filter      = false,
            item_style  = radical.item.style.rounded,
            item_height = 45,
            column      = 6,
            layout      = radical.layout.grid,
            screen      = screen
        }

        tag_menu.layouts(centered,layouts)
        centered:add_key_hook({}, " ", "press", function(_,mod) centered._current_item.button1(_,mod) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "release", function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "release", function(menu) end)
        centered:add_key_hook({}, "Mod4", "release", function(menu) centered.visible = false end)
    end
    centered.screen = screen
    centered.visible = true
    centered._current_item.button1(centered,backward and {"Shift"} or {})
end

return module
