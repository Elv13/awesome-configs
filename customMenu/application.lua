local setmetatable = setmetatable
local io = io
local loadstring = loadstring
local button = require("awful.button")
local beautiful = require("beautiful")
local util = require("awful.util")
local menu = require("awful.menu")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse}

module("customMenu.application")

local data = {}

function update()

end

function new(screen, args) 
  local f = io.open(util.getdir("config") .. "/menu.lua",'r')
  local text3 = f:read("*all")
  f:close()
  local afunction = loadstring(text3)
  local myMenu = afunction()

  local mylaunchertext = capi.widget({ type = "textbox" })
  mylaunchertext.text = "      Apps  "
  mylaunchertext.bg_image = capi.image(beautiful.awesome_icon)
  mylaunchertext.bg_align = "left"
  mylaunchertext.bg_resize = false
  
  mylaunchertext:add_signal("mouse::enter", function() mylaunchertext.bg = beautiful.bg_highlight end)
  mylaunchertext:add_signal("mouse::leave", function() mylaunchertext.bg = beautiful.bg_normal end)
  
  mylaunchertext:buttons( util.table.join(
    button({ }, 1, function()
      myMenu:toggle()
  end)
  ))
  
  return mylaunchertext
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
