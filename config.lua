-- This module provide a basic register manager
-- It does not save anything yet, it could be added later
-- Author Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local loadstring   = loadstring
local table        = table
local io           = io
local rawset       = rawset
local type         = type
local ipairs       = ipairs
local string       = string
local pairs        = pairs
local print        = print
local util         = require( "awful.util"   )

-- C API
local capi         = { image  = image  ,
                       widget = widget ,
                       timer  = timer  }

module("config")

local data2 = nil
local autoSave = true
local mytimer = capi.timer({ timeout = 2 })

local data3 = {}
function settable_eventR (table, key)
    return data2[key]
end

function settable_eventLen (table)
    return #data2
end

local function startTimer()
    if mytimer.started == true or autoSave == false then return end
    mytimer:add_signal("timeout", function()
        if mytimer.started == true then
            mytimer:stop()
            print("Serializing data")
            save()
        end
    end)
    mytimer:start()
end

function settable_eventW (table, key,value)
    local function digg(val,parent,k2,realT)
        if type(val) == "table" then
            rawset(parent,k2,{["__real_table"]=realT[k2]})

            local function mirrorR(table2, key3)
                return realT[k2][key3]
            end

            local function mirrorLen(table2)
                return #realT[k2]
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

    if data2[key] ~= value then
        startTimer()
        data2[key] = value
        digg(value,data3,key,data2)
    end
    return data2[key]
end

setmetatable(data3, { __index = settable_eventR, __newindex = settable_eventW, __len = settable_eventLen })

function get_real(t)
    if t["__real_table"] ~= nil then
        return t["__real_table"]
    else
        print("Invalid table")
        return nil
    end
end

function set(args) 
    data2 = args
    rawset(data3,"__real_table",data2)
end

set({})

function data()
    return data3
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
    local currentData = currentData2 or data()
    local newData = newData2
    for k,v in pairs(newData) do
        if currentData[k] ~= nil and newData2[k] ~= nil then
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

function save()
     local f = io.open(util.getdir("config") .. "/serialized.lua",'w')
     if f then
        f:write("return " .. serialise(data2).." \n")
        f:close()
     end
end

function load()
    local f = io.open(util.getdir("config") .. "/serialized.lua",'r')
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

function disableAutoSave()
    autoSave = false
end

function enableAutoSave()
    autoSave = true
end

setmetatable(_M, { __call = function(_, ...) return data end })
