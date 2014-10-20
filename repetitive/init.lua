local unpack = unpack
local aw_button = require( "awful.button"    )
local aw_util   = require( "awful.util"      )
local aw_key    = require( "awful.key"       )
local tag       = require( "awful.tag"       )
local macro     = require( "repetitive.macro")
local shortcut  = require( "repetitive.shortcut")
local common    = require( "repetitive.common")

local capi = {timer = timer,root=root,client=client,mouse=mouse}

local module = {}
local coords_cache = setmetatable({}, { __mode = 'k' })

local function gen_delta_cache(c)
    local mc,geo = capi.mouse.coords(),c:geometry()
    if not (mc.x>=geo.x and mc.x<=geo.x+geo.width and mc.y>=geo.y and mc.y<=geo.y+geo.height) then
        return coords_cache[c]
    else
        return {x=mc.x-geo.x,y=mc.y-geo.y} --Relative position
    end
end

-- Generate setters keybindings
local function generate_key_binding()
    local bindings = {}
    for i=1,12 do
        -- Bind clients
        local fk = "F"..i
        bindings[#bindings+1] = aw_key({ "Mod4" }, fk, function ()
            common.hook_key(fk)
            local c = capi.client.focus --TODO manage "unmanage" signal
            if not c then return end
            coords_cache[c] = gen_delta_cache(c)
            -- Try to get a favorite tag
            local fav_tag = setmetatable({}, { __mode = 'v' })
            local c_tags = c:tags()
            for k,t in ipairs(c_tags) do
                if t.selected then
                    fav_tag[#fav_tag+1] = t
                end
            end
            common.fav[fk] = function()
                -- Update the delta cache
                local cur_c = capi.client.focus
                if cur_c and coords_cache[cur_c] then
                    coords_cache[cur_c] = gen_delta_cache(cur_c)
                end
                local tags = c:tags()
                -- Check if one of the tag is not already selected
                local selected = false
                for k,t in ipairs(tags) do
                    for k2,t2 in ipairs(tag.selectedlist(c.screen)) do
                        selected = t==t2
                        if selected then break end
                    end
                    if selected then break end
                end
                if not selected then
                    -- Try to see if the favorite tag(s) is still available
                    if fav_tag[1] then
                        tag.viewonly(fav_tag[1])
                    else
                        -- Too bad, history is not accessible from here anyway
                        tag.viewonly(tags[1])
                    end
                end
                capi.client.focus = c
                local geo = c:geometry()
                if coords_cache[c] then
                    -- this will correctly restore the cursor when switching between 2 places
                    -- does not work very well when a client have multiple sizes at once
                    capi.mouse.coords({x=geo.x+coords_cache[c].x,y=geo.y+coords_cache[c].y})
                end
            end
        end)

        -- Bind tags
        bindings[#bindings+1] = aw_key({ "Mod1" }, fk, function ()
            common.hook_key(fk)
            local t = tag.selected(capi.client.focus and capi.client.focus.screen or capi.mouse.screen)
            common.fav[fk] = function() --TODO manage "deleted" signal
                tag.viewonly(t)
            end
        end)

        -- Bind macros TODO
        bindings[#bindings+1] = aw_key({ "Control" }, fk, function ()
            common.hook_key(fk)
            print("Set Macro")
            local m = nil
            macro.record(function(aMacro) m = aMacro; print("setting macro") end)
            common.fav[fk] = function()
                if m then
                    macro.play(m)
                else
                    print("Nothing to playback")
                end
            end
        end)
    end
    return bindings
end


-- This will ensure this code is executed after rc.lua is fully parsed
local t = capi.timer({timeout=0})
t:connect_signal("timeout",function()
    capi.root.keys(aw_util.table.join(capi.root.keys(),unpack(generate_key_binding())))
    t:stop()
end)
t:start()

return module