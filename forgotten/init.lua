-- This module provide a basic register manager
-- It does not save anything yet, it could be added later
-- Author Emmanuel Lepage Vallee <elv1313@gmail.com> (2011-2013)

local setmetatable = setmetatable
local loadstring   = loadstring
local table        = table
local io           = io
local rawset,rawget= rawset,rawget
local type         = type
local ipairs       = ipairs
local string       = string
local pairs        = pairs
local print        = print
local next         = next
local debug = debug
local util         = require( "awful.util"   )

-- C API
local capi         = { image  = image  ,
                       widget = widget ,
                       timer  = timer  }

local module = {}

local data2 = nil
local auto_save = true
local mytimer = capi.timer({ timeout = 2 })

local interface = {}
local data_ext = {}
local settable_eventW,startTimer

local function mirrorLen(table2)
    local realT = rawget(table,"__real_table")
    return #realT
end

local function mirrorW(table, key,value)
--     print("writing",key,value)
    local realT = rawget(table,"__real_table")
    if realT[key] ~= value then
        realT[key] = value
        startTimer()
        return realT[key]
    end
end

local function settable_eventLen (table)
    return #(rawget(table,"__real_table")[key])
end

local function settable_eventR (table, key)
    if key == "auto_save"then
        return auto_save
    end
    local ret = rawget(table,"__real_table")
--     print("in read",key,ret,(ret[key]),type(ret[key]))
    if ret[key] then return ret[key] end
    ret[key] = {}
    rawset(table,key,{["__real_table"]=ret[key]})
    setmetatable(table[key],{ __index = settable_eventR, __newindex = mirrorW, __len = settable_eventLen})
    return table[key]
end

startTimer = function()
    if mytimer.started == true or auto_save == false then return end
    mytimer:connect_signal("timeout", function()
        if mytimer.started == true then
            mytimer:stop()
            print("Serializing data")
            module.save()
        end
    end)
    mytimer:start()
end

settable_eventW = function(table, key,value)
    if key == "auto_save" and type(value) == "boolean" then
        auto_save = value
    end
    local function digg(val,parent,k2,realT)
        if type(val) == "table" then
            rawset(parent,k2,{["__real_table"]=realT[k2]})

            local function mirrorR(table2, key3)
                return realT[k2][key3]
            end

            local function mirrorW(table, key,value)
                if realT[k2][key] ~= value then
                    realT[k2][key] = value
                    startTimer()
                    digg(value,parent[k2],key,realT[k2])
                    return realT[k2][key]
                end
            end

            setmetatable(parent[k2], { __index = mirrorR, __newindex = mirrorW, __len =  mirrorLen})
            for k,v in pairs(val) do
                if type(v) == "table" then
                    digg(v,parent[k2],k,realT[k2])
                end
            end
        end
    end

    local real_data = rawget(filename and data_ext[filename] or interface,"__real_table")
    if real_data[key] ~= value then
        startTimer()
        real_data[key] = value
        digg(value,table,key,real_data)
    end
    return real_data[key]
end

setmetatable(interface, { __index = settable_eventR, __newindex = settable_eventW, __len = settable_eventLen })

function module.get_real(t)
    if t["__real_table"] ~= nil then
        return t["__real_table"]
    else
        print("Invalid table")
        return nil
    end
end

local real_data2 = {}
rawset(interface,"__real_table",real_data2)
rawset(module,"__real_table",real_data2)

function module.data(filename)
    if filename then
        if not data_ext[filename] then
            local rd,int = {},{}
            setmetatable(int, { __index = settable_eventR, __newindex = settable_eventW, __len = settable_eventLen})
            data_ext[filename] = { real_data = rd, interface=int}
        end
    end
    return interface
end

local function genValidKey(key)
    if type(key) == "number" then
        return '['..key..']'
    elseif type(key) == "string" then
        return key
    end
end

local function serialise(data)
    local serialisedData = ""
    if type(data) == "nil"          then
        serialisedData = serialisedData .. "nil"
    elseif type(data) == "boolean"  then
        if data ==  true then
            serialisedData = serialisedData .. "true"
        else
            serialisedData = serialisedData .. "false"
        end
    elseif type(data) == "number"   then
        serialisedData = serialisedData .. data
    elseif type(data) == "string"   then
        serialisedData = serialisedData .. string.format("%q", data)
    elseif type(data) == "function" then
        -- ?
    elseif type(data) == "userdata" then
        -- ?
    elseif type(data) == "thread"   then
        -- ?
    elseif type(data) == "table"    then
        serialisedData = "{\n"
        for k, v in pairs(data) do
            local serKey = genValidKey(k)
            if serKey ~= nil then
                serialisedData = serialisedData .. "  " ..serKey .. " = " .. serialise(v) .. ",\n"
            end
        end
        serialisedData = serialisedData.."\n}"
    end
    return serialisedData
end

local function unserialise(newData2,currentData2)
    if not newData2 then return end
    local currentData = currentData2 or module.data()
    local newData = newData2
    for k,v in pairs(newData) do
        if rawget(currentData,k) ~= nil and rawget(newData2,k) ~= nil then
            if type(newData2[k]) == "table" then
                unserialise(newData2[k],currentData[k])
            else
                currentData[k] = newData2[k]
            end
        elseif newData2[k] ~= nil then
            currentData[k] =  newData2[k]
        end
    end
end

function module.save(filename)
     local real_data = rawget(filename and data_ext[filename] or interface,"__real_table")
     local f = io.open(util.getdir("cache") .. "/" .. (filename or "serialized.lua"),'w')
     if f then
        f:write("return " .. serialise(real_data).." \n")
        f:close()
     end
end

function module.load(filename)
    local f = io.open(util.getdir("cache") .. "/" .. (filename or "serialized.lua"),'r')
    if f then
        local text    = f:read("*all")
        local func    = loadstring(text)
        if not func then
            return
        end
        local newData = func()
        unserialise(newData)
        f:close()
    end
end

function module.is_set(path)
    if not path then return false end
    local t = type(path)
    if t ~= "table" then return true end
    local rt = rawget(path,"__real_table")
    local k,v,k2,v2 = next(rt or {}),next(path)
--     print("keys",k,k2)
    return k ~= nil or type(k2) == "string"
end

function module.disableAutoSave()
    auto_save = false
end

function module.enableAutoSave()
    auto_save = true
end

return setmetatable(module, { __call = function(_, ...) return module.data end,__newindex = settable_eventW, __index = settable_eventR })
