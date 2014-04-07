local setmetatable = setmetatable
local ipairs       = ipairs
local print = print
local radical   = require( "radical" )
local capi = { client = client }

local aTagMenu = nil

local function show_menu(t,geo,visible)
    if not aTagMenu then
        aTagMenu = radical.context({layout=radical.layout.horizontal,item_width=140,item_height=140,icon_size=100,enable_keyboard=false,item_style=radical.item.style.rounded})
    end
    if (not t) and (not visible) then aTagMenu.visible=false;return end
    if not visible then return end
    local tags = t:clients()
    if not tags or #tags == 0 then return end
    aTagMenu:clear()
    for k,v in ipairs(t:clients()) do
        aTagMenu:add_item({text = "<b>"..v.name.."</b>",icon=v.content,button1=function() print("her"); capi.client.focus = v end})
    end
    aTagMenu.parent_geometry = geo
    aTagMenu.visible = true
    return aTagMenu
end

return setmetatable({}, { __call = function(_, ...) return show_menu(...) end })
