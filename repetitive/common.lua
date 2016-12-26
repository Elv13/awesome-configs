local capi = {timer = timer,root=root,client=client,mouse=mouse}
local aw_util   = require( "awful.util"      )
local aw_key    = require( "awful.key"       )
local glib      = require( "lgi"             ).GLib

-- Store shared variables
local module = {fav={},already_set={},other_shortcuts=setmetatable({}, { __mode = 'k' })}

local to_be_applied = {}

function module.delated_hook_key(key,mods,fct,fav_hash)
    if #to_be_applied == 0 then
        glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
            --TODO
        end)
    end
    table.insert(to_be_applied, nil)
end

-- Add a new keybinding to 'key' if not already set
function module.hook_key(key,mods,fct,fav_hash)
    if not module.already_set[fav_hash or key] then --TODO handle replacment for shortcuts
        capi.root.keys(aw_util.table.join(capi.root.keys(),aw_key(mods or {}, key, function ()
            local f = ((fct) or (module.fav[key]))
            f()
        end)))
        module.already_set[fav_hash or key] = true
    end
end

return module
