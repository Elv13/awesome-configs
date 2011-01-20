--Simple yet effective way to switch (the cursor and focus) from screen to screen
--Author: Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local tag = require("awful.tag")
local print = print
local util = require("awful.util")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
               tag = tag}

module("mouseManager")

local data = {screen = {}}

function update()

end

function new(screen, args) 
  return --Nothing to do
end

function switchTo(s)
  data.screen[capi.mouse.screen] = capi.mouse.coords
  capi.mouse.screen = s
  --capi.mouse.coords(data.screen[s] or {x=0,y=0}) --TODO
end

function reset()
  data.screen = nil
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
