local setmetatable = setmetatable
local io = io
local button = require("awful.button")
local beautiful = require("beautiful")
local util = require("awful.util")
local menu = require("awful.menu")
local config = require( "config")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse}

module("customMenu.recent")

local data = {}

function update()

end

function new(screen, args) 
  local aFile = io.popen(util.getdir("config") .. "/Scripts/awesomeTopExec.sh")
  local count = 0
  local commandArray = {}
  while true do
      local line = aFile:read("*line")
      if line == nil then break end
      commandArray[count] = {line,line}
      count = count + 1
  end
  aFile:close()
  mymainmenu3 = menu.new({ items = commandArray})


  mylauncher3text = capi.widget({ type = "textbox" })
  mylauncher3text.text = "       Recent |"
  mylauncher3text.bg_image = capi.image(config.data().iconPath .. "tags/star2.png")
  mylauncher3text.bg_align = "left"
  mylauncher3text.bg_resize = true
  
  mylauncher3text:add_signal("mouse::enter", function() mylauncher3text.bg = beautiful.bg_highlight end)
  mylauncher3text:add_signal("mouse::leave", function() mylauncher3text.bg = beautiful.bg_normal end)
  
  mylauncher3text:buttons( util.table.join(
    button({ }, 1, function()
      mymainmenu3:toggle()
  end)
  ))
  
  return mylauncher3text
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
