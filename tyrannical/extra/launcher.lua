--
--This module try to match new clients to pre-defined arguments
--It can be used to override Tyrannical or set special rules 
--when spawning clients. It use both X11 clients and
--FreeDesktop.org Startup notifications for matching commands
--
-- 1) Spawn command, get the PID and SN_ID
-- 2) Wait and listen for SN events
-- 3) When manage come, see if it has an SN_ID
--   3.1) If yes, use it
--   3.2) If no, but the PID match, use the PID
--   3.3) TODO expose the WM_COMMAND property and use it to check recent startup id
-- 4) Wait for timeout, give up
-- 5) Have housekeeping timer to cleaup old SN
--
local print = print
local pairs = pairs
local awful = require("awful")
local tyrannical = require("tyrannical")
local capi = {awesome=awesome,client=client}

local module = {}

local by_pid,by_ns={},{}

local function on_callback(c,startup)
    if not c.startup_id then return false end
    local pid_data,sn_data = by_pid[c.pid],by_ns[c.startup_id]
    if not pid_data and not sn_data then return false end
    if sn_data then
--         c.ontop = true
        awful.client.floating.set(c,false)
    elseif pid_data then
        
    end
    return false
end

module.spawn = function(args)
    local args = args or {}
    local param = {
        command     = args.command    ,
        initiated_f = args.initiated_f,
        canceled_f  = args.canceled_f ,
        completed_f = args.completed_f,
        timeout_f   = args.timeout_f  ,
        screen      = args.screen     ,
    }
    local pid,snid = awful.util.spawn(param.command,true)
    print("HERE",snid)
    if pid then
        param.pid = pid
        by_pid[pid] = param
    end
    if snid then
        param.startup_id = snid
        by_ns[snid] = param
        tyrannical.sn_callback[snid] = on_callback
    end
    return 100
end

--------SN Callbacks------

-- local function on_initiated(sn)
--     print("on_initiated")
--     for k,v in pairs(sn) do print (k,v) end
-- end

local function on_canceled(sn)
    print("on_canceled")
    local param = by_ns[sn]
    if param then
        by_pid[param.pid] = nil
        param[sn] = nil
    end
end

local function on_completed(sn)
    print("on_completed")
    for k,v in pairs(sn) do print (k,v) end
    local param = by_ns[sn]
    if param then
        by_pid[param.pid] = nil
        param[sn] = nil
    end
end

local function on_timeout(sn)
    print("on_timeout")
    for k,v in pairs(sn) do print (k,v) end
    local param = by_ns[sn]
    if param then
        by_pid[param.pid] = nil
        param[sn] = nil
    end
end

-- local function on_change(sn)
--     print("on_change")
--     for k,v in pairs(sn) do print (k,v) end
-- end

local function on_manage(c)
    print("MANAGE",c,c.pid,c.screen,"STARTUP",c.startup_id)
    if c.startup_id and by_ns[c.startup_id] then
        local param = by_ns[c.startup_id]
        if param then
            by_pid[param.pid] = nil
            param[sn] = nil
        end
    elseif c.pid ~= 0 and by_pid[c.pid] then
        local param = by_pid[c.pid]
        if param then
            by_pid[param.pid] = nil
            param[sn] = nil
        end
    end
end

local function on_new(a1)
    print("NEW",a1)
end

-- capi.awesome.connect_signal("spawn::initiated", on_initiated )
-- capi.awesome.connect_signal("spawn::canceled" , on_canceled  )
-- capi.awesome.connect_signal("spawn::completed", on_completed )
-- capi.awesome.connect_signal("spawn::timeout"  , on_timeout   )
-- capi.awesome.connect_signal("spawn::change"   , on_change    )
-- capi.client.connect_signal ("manage"          , on_manage    )
-- capi.client.connect_signal ("new"             , on_new       )

return module
