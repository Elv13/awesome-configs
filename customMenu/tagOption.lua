local setmetatable = setmetatable
local table = table
local io = io
local button = require("awful.button")
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local next = next
local ipairs = ipairs
local type = type
local tag = require("awful.tag")
local util = require("awful.util")
local wibox = require("awful.wibox")
local shifty = require("shifty")
local menu2 = require("customMenu.menu2")
local capi = { image = image,
               widget = widget,
               mouse = mouse,
               screen = screen}

module("customMenu.tagOption")

local function hightlight(aWibox, value)
  aWibox.bg = (value == true) and beautiful.bg_focus or beautiful.bg_normal
end

--By bios007
local function tag_to_screen(t, scr)
    local ts = t or tag.selected()
    tag.history.restore(ts.screen,1)
    shifty.set(ts, { screen = scr or
                    awful.util.cycle(capi.screen.count(), ts.screen + 1)})
    tag.viewonly(ts)
    --capi.mouse.screen = ts.screen //Move the mouse the the screen

    if #ts:clients() > 0 then
        local c = ts:clients()[1]
        capi.client.focus = c
        c:raise()
    end
end

local aTag

function new(screen, args) 
  local function createMenu()
    local menu3 = { data = menu2() }
    
    function menu3:toggle(aTag2)
      aTag = aTag2
      menu3["data"]:toggle()
    end
    return menu3
  end
  
  mainMenu = createMenu()
  
  mainMenu["data"]:addItem("Visible",true,function() aTag.selected = not aTag.selected end)
  mainMenu["data"]:addItem("Rename",nil,function() shifty.rename(aTag) end)
  
  mainMenu["data"]:addItem("Close applications and remove",nil, function() 
								  for i=1, #aTag:clients() do
								    aTag:clients()[i]:kill() 
								  end
								  shifty.del(aTag)
								end)
  
  if capi.screen.count() > 1 then
    local screenMenu = createMenu()
    mainMenu["data"]:addItem("Screen",nil,nil,screenMenu["data"])
    
    for i=1,capi.screen.count() do
      screenMenu["data"]:addItem(i,nil,function() tag_to_screen(aTag,i) end,nil)
    end
  end
  
  local screenMenuMerge = createMenu()
  mainMenu["data"]:addItem("Merge With",nil,nil,screenMenuMerge["data"])

  function createTagList(aScreen)
    local tagList = createMenu()
    local count = 0
    for _, v in ipairs(capi.screen[aScreen]:tags()) do
       tagList["data"]:addItem(v.name)
       count = count + 1
    end
    return tagList["data"]
  end
  
  for i=1,capi.screen.count() do
    screenMenuMerge["data"]:addItem("Screen " .. i,nil,nil,function() return createTagList(i) end)
  end
  
  mainMenu["data"]:addItem("<b>Save settings</b>",nil,nil)
  
  local mainMenu2 = createMenu()
  
  local f = io.popen('find '..util.getdir("config") .. "/Icon/tags/ -maxdepth 1 -iname \"*.png\" -type f","r")
  local counter = 0
  while true do
    local file = f:read("*line")
    if (file == "END" or nil) or (counter > 30) then
      break
    end
    mainMenu2["data"]:addItem("",nil,function() tag.seticon(file,aTag) end,nil,{icon = file})
    counter = counter +1
  end
  f:close()
  mainMenu["data"]:addItem("Set Icon",nil,nil,mainMenu2["data"])
  
  --mainMenu["data"]:addItem("Advanced",nil,nil,mainMenu2["data"])
  
  return mainMenu
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })
