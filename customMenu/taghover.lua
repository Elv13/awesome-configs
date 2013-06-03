local setmetatable = setmetatable
local io           = io
local ipairs       = ipairs
local print = print
local button    = require( "awful.button"    )
local beautiful = require( "beautiful"       )
local tag       = require( "awful.tag"       )
local util      = require( "awful.util"      )
local config    = require( "config"          )
local radical   = require( "radical" )
local awful = require("awful")
local capi = { image  = image  ,
               widget = widget ,
               mouse  = mouse  ,
               screen = screen }

local module = {}

local aTagMenu = nil

function new(screen, args)
  mainMenu = radical.context({layout=radical.layout.horizontal,item_width=140,item_height=140,icon_size=100})
  for k,v in ipairs(module.tag:clients()) do
      print("CONTENT",v.content,v.get_content)
--     mainMenu:add_item({text = "<b>"..v.name.."</b>",icon="/home/lepagee/Graphisme/avatar4.png"})
    mainMenu:add_item({text = "<b>"..v.name.."</b>",icon=v.content})
  end
  
  return mainMenu
end

function module.getMenu()
    if not aTagMenu then
        aTagMenu = new()
    end
    return aTagMenu
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
