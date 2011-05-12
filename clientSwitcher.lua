--Switch client with the keybpard by assigning a number to every client in a tag
--Requier fork of tasklist.lua to work (this is the backend)
--Author: Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local print = print
local tag = require("awful.tag")
local wibox = require("awful.wibox")
local capi = { screen = screen,
               mouse = mouse,
               widget = widget,
               client = client}

module("clientSwitcher")

local data = {client = {}, index = {}, wibox = {}, fav = {}}

function new(screen, args) 
  return --Nothing to do
end

function assign(client, index)
  if client:tags()[1] == capi.screen[capi.mouse.screen]:tags()[1] then
    data.client[index] = client
    data.index[client.pid] = index
  end
end

function switchTo(i)
  if data.client[i] ~= nil then
    capi.client.focus = data.client[i]
  else
    print("client not set")
  end
end

function getIndex(c)
  if data.index[c.pid] ~= nil then
    return data.index[c.pid]
  else
    print("client not set")
    return nil
  end
end

function setFavClient(idx,c)
  data.fav[idx] = c
end

function selectFavClient(idx)
  if data.fav[idx] ~= nil then
    if data.fav[idx]:tags()[1] ~= tag.selected(data.fav[idx].screen) then
      tag.viewonly(data.fav[idx]:tags()[1])
    end
    capi.client.focus = data.fav[idx]
  end
end

function addCornerWibox(c,i)
  data.wibox[i] = wibox({ position = "free", screen = capi.screen.count() })
  data.wibox.ontop = true
  data.wibox.visible = false
  createDrawer() 
  data.wibox:geometry({ width = 147, height = 994, x = capi.screen[capi.mouse.screen].geometry.width*2 -  147, y = 20})
end

function reset()
  --data.client = {} --TODO restore this
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
