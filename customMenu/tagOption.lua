local setmetatable = setmetatable
local io           = io
local ipairs       = ipairs
local button    = require( "awful.button"  )
local beautiful = require( "beautiful"     )
local tag       = require( "awful.tag"     )
local util      = require( "awful.util"    )
-- local shifty    = require( "shifty"        )
local config    = require( "forgotten"        )
local menu      = require( "radical.context"  )
local awful = require("awful")
local capi = { image  = image  ,
               widget = widget ,
               mouse  = mouse  ,
               screen = screen }

local module = {}

local aTagMenu = nil

--By bios007
-- local function tag_to_screen(t, scr)
--     local ts = t or tag.selected()
--     tag.history.restore(ts.screen,1)
--     shifty.set(ts, { screen = scr or
--                     awful.util.cycle(capi.screen.count(), ts.screen + 1)})
--     tag.viewonly(ts)
--     --capi.mouse.screen = ts.screen //Move the mouse the the screen
-- 
--     if #ts:clients() > 0 then
--         local c = ts:clients()[1]
--         capi.client.focus = c
--         c:raise()
--     end
-- end

local aTag

local function new(screen, args)
  
  mainMenu = menu()
  
  mainMenu:add_item({text = "Visible", checked = true,button1 = function() aTag.selected = not aTag.selected end})
  mainMenu:add_item({text = "Rename", button1 = function() shifty.rename(aTag) end})
  
  mainMenu:add_item({text = "Close applications and remove", button1 = function() 
                                                                                    for i=1, #aTag:clients() do
                                                                                        aTag:clients()[i]:kill() 
                                                                                    end
                                                                                    shifty.del(aTag)
                                                                                end})
  
  if capi.screen.count() > 1 then
    local screenMenu = menu()
    mainMenu:add_item({text = "Screen",sub_menu = screenMenu})
    
    for i=1,capi.screen.count() do
      screenMenu:add_item({text = "Screen "..i, button1 = function() tag_to_screen(aTag,i) end})
    end
  end
  
  local screenMenuMerge = menu()
  mainMenu:add_item({text = "Merge With", sub_menu = screenMenuMerge})

  function createTagList(aScreen)
    local tagList = menu()
    local count = 0
    for _, v in ipairs(awful.tag.gettags(aScreen)) do
       tagList:add_item({text = v.name})
       count = count + 1
    end
    return tagList
  end
  
  for i=1,capi.screen.count() do
    screenMenuMerge:add_item({text = "Screen " .. i, sub_menu = function() return createTagList(i) end})
  end
  
  mainMenu:add_item({text = "<b>Save settings</b>"})
  
  local mainMenu2 = menu()
  
  local f = io.popen('find '..config.iconPath .. "tags/ -maxdepth 1 -iname \"*.png\" -type f","r")
  local counter = 0
  while true do
    local file = f:read("*line")
    if (file == "END" or nil) or (counter > 30) then
      break
    end
    mainMenu2:add_item({"Text", button1 = function() tag.seticon(file,aTag) end, icon = file})
    counter = counter +1
  end
  f:close()
  mainMenu:add_item({text= "Set Icon", sub_menu = mainMenu2})
  
  mainMenu:add_item({text= "Layout", sub_menu = function()
  
  end})
  
  mainMenu:add_item({text= "Flags", sub_menu = function()
  
  end})
  
  
  --mainMenu:add_item("Advanced",nil,nil,mainMenu2)
  
  return mainMenu
end

function getMenu()
    if not aTagMenu then
        aTagMenu = new()
    end
    return aTagMenu
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
