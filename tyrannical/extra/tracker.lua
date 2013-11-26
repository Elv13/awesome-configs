local setmetatable   = setmetatable
local print  , pairs = print  , pairs
local ipairs , type  = ipairs , type
local string         = string
local awful = require("awful")

local capi = {client = client , tag    = tag    ,
              screen = screen , mouse  = mouse  }

local module = {}
local classes,signals = {},{}

local function emit_signal(name,...)
    if signals[name] then
        for k,v in ipairs(signals[name]) do
            v(...)
        end
    end
end

function module:connect_signal(name,func)
    local name = string.lower(name or "")
    signals[name] = signals[name] or {}
    signals[name][#signals[name]+1] = func
end

function module:get_instances(class)
    if not class then return end
    return classes[string.lower(class)] or {}
end

capi.client.connect_signal("manage", function (c, startup)
    local class = string.lower(c.class or "N/A")
    classes[class] = classes[class] or setmetatable({}, { __mode = "kv" })
    local tmp = classes[class]
    tmp[#tmp+1] = c
    emit_signal(class.."::created",c,tmp)
    emit_signal(class.."::instances",tmp)
--     emit_signal(c.class.."::created",c,tmp)
--     emit_signal(c.class.."::instances",tmp)
end)

capi.client.connect_signal("unmanage", function (c)
    local class = string.lower(c.class or "N/A") or ""
    local tmp = classes[class]
    if tmp then
        for k,v in ipairs(tmp) do
            if v == c then
                tmp[k] = nil
            end
        end
    end
--     emit_signal(c.class.."::destroyed",c,tmp)
--     emit_signal(c.class.."::instances",tmp)
    emit_signal(class.."::destroyed",c,tmp)
    emit_signal(class.."::instances",tmp)
end)

return setmetatable(module, { __call = function(_, ...) return end})
