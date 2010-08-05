local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local naughty = require("naughty")
local vicious = require("vicious")
local tag = require("awful.tag")
local util = require("awful.util")
local shifty = require("shifty")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("downInfo")

local data = {}

function update()

end

function new(screen, args)
    
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
