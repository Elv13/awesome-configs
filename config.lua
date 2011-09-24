-- This module provide a basic register manager
-- It does not save anything yet, it could be added later
-- Author Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local loadstring   = loadstring
local table        = table
local io           = io
local type         = type
local ipairs       = ipairs
local string       = string
local pairs        = pairs
local print        = print
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

-- C API
local capi         = { image  = image  , 
                       widget = widget , }

module("config")

data = {}

function update()

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
            serialisedData = serialisedData .. "  " .. genValidKey(k) .. " = " .. serialise(v) .. ",\n"
        end
        serialisedData = serialisedData.."\n}"
    end
    return serialisedData
end

local function unserialise(newData2,currentData2)
    if not newData2 then return end
    local currentData = currentData2 or data
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
     f:write("return " .. serialise(data).." \n")
     f:close()
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
    end
    f:close()
end

function set(args) 
  data = args
end


setmetatable(_M, { __call = function(_, ...) return data end })