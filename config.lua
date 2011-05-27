-- This module provide a basic register manager
-- It does not save anything yet, it could be added later
-- Author Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local naughty = require("naughty")
local tag = require("awful.tag")
local util = require("awful.util")
local capi = { image = image,
               widget = widget}

module("config")

data = {}

function update()

end

function set(args) 
  data = args
end


setmetatable(_M, { __call = function(_, ...) return data end })
