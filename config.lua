-- This module provide a basic register manager
-- It does not save anything yet, it could be added later
-- Author Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local table        = table
local type         = type
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

-- C API
local capi         = { image  = image  , 
                       widget = widget , }

module("config")

data = {}

function update()

end

local function serialise(data)
    local serialisedData = ""
    if type(data) == "nil" then
        serialisedData = serialisedData .. "nil"
    elseif type(data) == "boolean" then
        if data ==  true then
            serialisedData = serialisedData .. "true"
        else
            serialisedData = serialisedData .. "false"
        end
    elseif type(data) == "number" then
        serialisedData = serialisedData .. data
    elseif type(data) == "string" then
        serialisedData = serialisedData .. '"' .. data .. '"'
    elseif type(data) == "function" then
        -- ?
    elseif type(data) == "userdata" then
        -- ?
    elseif type(data) == "thread" then
        -- ?
    elseif type(data) == "table" then
        serialisedData = "{\n"
        for k, v in ipairs(data) do
            serialisedData = serialisedData .. "  " .. k .. " = " .. serialise(v) .. ","
        end
        serialisedData = serialisedData.."\n}"
    end
    
end

function save(fileName)
    
end

function load(fileName)
    local f = io.open('/tmp/cpuStatistic.lua','r')
    local cpuStat = {}
    if f ~= nil then
        local data = f:read("*all")
        f:close()
        return serialise(data)
    end
    return nil
end

function set(args) 
  data = args
end


setmetatable(_M, { __call = function(_, ...) return data end })