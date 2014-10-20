local capi = {timer = timer,root=root,client=client,mouse=mouse}
local aw_util   = require( "awful.util"      )
local aw_key    = require( "awful.key"       )

-- Store shared variables
local module = {fav={},already_set={},other_shortcuts=setmetatable({}, { __mode = 'k' })}

-- Add a new keybinding to 'key' if not already set
function module.hook_key(key,mods,fct,fav_hash)
    if not module.already_set[fav_hash or key] then --TODO handle replacment for shortcuts
            print("cr")
        capi.root.keys(aw_util.table.join(capi.root.keys(),aw_key(mods or {}, key, function ()
            local f = ((fct) or (module.fav[key]))
            f()
        end)))
        module.already_set[fav_hash or key] = true
    end
end

return module