---------------------------------------------------
-- Vicious widgets for the awesome window manager
---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Setup environment
local type  = type
local pairs = pairs
local print = print
local tonumber = tonumber
local capi  = { timer = timer }
local os    = { time = os.time }
local table = {
    insert  = table.insert,
    remove  = table.remove
}

local helpers = require("extern.vicious.helpers")

-- Vicious: widgets for the awesome window manager
local vicious = {}
vicious.widgets = require("extern.vicious.widgets")
--vicious.contrib = require("extern.vicious.contrib")

-- Initialize tables
local timers       = {}
local timers2      = {}
local registered   = {}
local widget_cache = {}
-- }}}


-- {{{ Local functions
-- {{{ Update a widget
local count = 1
local function update(widget, reg, disablecache)
    -- Check if there are any equal widgets
    if not reg then
        local reg = registered[widget]
        if reg then
            for j=1,#reg do
                update(widget, reg[j], disablecache)
            end
        end
        return
    end

    local t = os.time()
    local data = nil

    -- Check for chached output newer than the last update
    local c = widget_cache[reg.wtype]
    if c and ((not c.time or c.time <= t-reg.timer) or disablecache) then
        c.time, c.data = t, reg.wtype(reg.format, reg.warg)
    end
    data = c and c.data or reg.wtype(reg.format, reg.warg)

    if not data then
        return ""
    end

    local ftype = type(reg.format)
--         print(data,ftype,reg.format)
    if ftype == "string" then
        data = helpers.format(reg.format, data)
    elseif ftype == "function" then
        data = reg.format(widget, data)
    end

    if widget.add_value then
        local number = tonumber(data)
        widget:add_value(number and number/100)
    elseif widget.set_value then
        local number = tonumber(data)
        widget:set_value(number and number/100)
    elseif widget.set_markup then
        widget:set_markup(data)
    else
        widget.text = data
    end

    return data
end
-- }}}

local function common_update(tm,...)
    local t = timers2[tm.timeout or -1]
    if t and t.widgets then
        local widgets = t.widgets
        for i=1,#widgets do
            widgets[i].update(tm,...)
        end
    end
end

-- {{{ Register from reg object
local function regregister(reg)
    if not reg.running and reg.timer > 0 then
        if registered[reg.widget] == nil then
            local t = {}
            registered[reg.widget] = t
            t[#t+1] = reg
        else
            local t,found = registered[reg.widget],false
            for j=1,#t do
                found = found or t[j] == reg
            end
            if not found then
                t[#t+1] = reg
            end
        end

        -- Start the timer
        if not timers2[reg.timer] and reg.update then
            local tm = capi.timer({ timeout = reg.timer })
            local t = {
                timer = tm,
                widgets = {}
            }
            timers[reg.update] = t
            timers2[reg.timer] = t

            if tm.connect_signal then
                tm:connect_signal("timeout", common_update)
            else
                tm:add_signal("timeout", common_update)
            end
            tm:start()

            -- Initial update
            tm:emit_signal("timeout")
        end
        if reg.update then
            local t = timers2[reg.timer]
            t.widgets[#t.widgets+1] = reg
            reg.running = true
            update(reg.widget,reg)
        end
    end
end
-- }}}
-- }}}


-- {{{ Global functions
-- {{{ Register a widget
function vicious.register(widget, wtype, format, timer, warg)
    local widget = widget
    local reg = {
        -- Set properties
        wtype  = wtype,
        format = format,
        timer  = timer,
        warg   = warg,
        widget = widget,

        -- Update function
        update = function ()
            update(widget, reg)
        end,
    }

    -- Default to 2s timer
    if reg.timer == nil then
        reg.timer = 2
    end

    -- Register a reg object
    regregister(reg)

    -- Return a reg object for reuse
    return reg
end
-- }}}

-- {{{ Unregister a widget
function vicious.unregister(widget, keep, reg)
    if reg == nil then
        for w, i in pairs(registered) do
            if w == widget then
                for _, v in pairs(i) do
                    reg = vicious.unregister(w, keep, v)
                end
            end
        end

        return reg
    end

    if not keep then
        for w, i in pairs(registered) do
            if w == widget then
                for k, v in pairs(i) do
                    if v == reg then
                        table.remove(registered[w], k)
                    end
                end
            end
        end
    end

    -- Stop the timer
    if timers[reg.update].timer.started then
        timers[reg.update].timer:stop()
    end
    reg.running = false

    return reg
end
-- }}}

-- {{{ Enable caching of a widget type
function vicious.cache(wtype)
    if wtype ~= nil then
        if widget_cache[wtype] == nil then
            widget_cache[wtype] = {}
        end
    end
end
-- }}}

-- {{{ Force update of widgets
function vicious.force(wtable)
    if type(wtable) == "table" then
        for _, w in pairs(wtable) do
            update(w, nil, true)
        end
    end
end
-- }}}

-- {{{ Suspend all widgets
function vicious.suspend()
    for w, i in pairs(registered) do
        for _, v in pairs(i) do
            vicious.unregister(w, true, v)
        end
    end
end
-- }}}

-- {{{ Activate a widget
function vicious.activate(widget)
    for w, i in pairs(registered) do
        if widget == nil or w == widget then
            for _, v in pairs(i) do
                regregister(v)
            end
        end
    end
end
-- }}}

return vicious

-- }}}
