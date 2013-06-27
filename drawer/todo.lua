local setmetatable = setmetatable
local tonumber = tonumber
local loadstring = loadstring
local ipairs = ipairs
local table = table
local io = io
local util = require("awful.util")
local button = require("awful.button")
local vicious = require("extern.vicious")
local tag = require("awful.tag")
local wibox = require("awful.wibox")
local widget2 = require("awful.widget")
local beautiful = require("beautiful")
local util = require("awful.util")
local naughty = require("naughty")
--local shifty = require("shifty")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
              tag = tag}

module("drawer.todo")

local data = {}
local alsaInfo = {}
local widgetTable = {}

local function update()

end

local function new()
  data.todo = {}
  data.wibox = wibox({ position = "left", screen = s})
  data.wibox.ontop = true
  data.wibox.visible = false
  data.wibox:geometry({y = 20, x = 0, width = 240, height = 300})
  
  todoWidget = capi.widget({ type = 'textbox', name = 'volumewidget', align='right' })
  todoWidget.text = "TODO"


  todoWidget:buttons( util.table.join(
     button({ }, 1, function()
          data.wibox.visible = not data.wibox.visible
      end)
  ))
  
  addTodo = capi.widget({ type = 'textbox', name = 'volumewidget', align='right' })
  addTodo.text = "| + |"

  function data.todo:add()
    local state = capi.widget({ type = 'textbox', name = 'volumewidget', align='right' })
    local name = capi.widget({ type = 'textbox', name = 'volumewidget', align='right' })
    name.text = "aName"
    data.todo[name.text] = 0
    state:buttons( util.table.join(
     button({ }, 1, function()
          state.text = state.text .. "#"
          data.todo[name.text] = data.todo[name.text] + 1
      end)
    ))
    table.insert(data.wibox.widgets, {state,name,layout = widget2.layout.horizontal.leftright})
  end
  
  addTodo:buttons( util.table.join(
    button({ }, 1, function() data.todo:save() end)
  ))
  
  function data.todo:save()
    local toSave = "function getTodo() local toReturn = {"
    for k,v in pairs(data.todo) do
      toSave = toSave .. k .. "='" .. v"',"
    end
    toSave = toSave .. "}; return toReturn end"
    util.spawn("echo \""..toSave.."\" > ~/todo.lua")
  end
  
  data.wibox.widgets = {
    addTodo,
    layout = widget2.layout.vertical.flex,
  }

  return todoWidget
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
