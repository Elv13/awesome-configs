local setmetatable = setmetatable
local io           = io
local ipairs       = ipairs
local button    = require( "awful.button"  )
local beautiful = require( "beautiful"     )
local tag       = require( "awful.tag"     )
local util      = require( "awful.util"    )
local shifty    = require( "shifty"        )
local config    = require( "config"        )
local menu      = require( "widgets.menu"  )
local capi = { image  = image  ,
               widget = widget ,
               mouse  = mouse  ,
               screen = screen }

module("customMenu.tagOption")

local aTagMenu = nil

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
    local menu = { data = menu() }
    
    function menu:toggle(aTag2)
      aTag = aTag2
      menu["data"]:toggle()
    end
    return menu
  end
  
  mainMenu = createMenu()
  
  mainMenu["data"]:add_item({text = "Visible", checked = true,onclick = function() aTag.selected = not aTag.selected end})
  mainMenu["data"]:add_item({text = "Rename", onclick = function() shifty.rename(aTag) end})
  
  mainMenu["data"]:add_item({text = "Close applications and remove", onclick = function() 
                                                                                    for i=1, #aTag:clients() do
                                                                                        aTag:clients()[i]:kill() 
                                                                                    end
                                                                                    shifty.del(aTag)
                                                                                end})
  
  if capi.screen.count() > 1 then
    local screenMenu = createMenu()
    mainMenu["data"]:add_item({text = "Screen",subMenu = screenMenu["data"]})
    
    for i=1,capi.screen.count() do
      screenMenu["data"]:add_item({text = "Screen "..i, onclick = function() tag_to_screen(aTag,i) end})
    end
  end
  
  local screenMenuMerge = createMenu()
  mainMenu["data"]:add_item({text = "Merge With", subMenu = screenMenuMerge["data"]})

  function createTagList(aScreen)
    local tagList = createMenu()
    local count = 0
    for _, v in ipairs(capi.screen[aScreen]:tags()) do
       tagList["data"]:add_item({text = v.name})
       count = count + 1
    end
    return tagList["data"]
  end
  
  for i=1,capi.screen.count() do
    screenMenuMerge["data"]:add_item({text = "Screen " .. i, subMenu = function() return createTagList(i) end})
  end
  
  mainMenu["data"]:add_item({text = "<b>Save settings</b>"})
  
  local mainMenu2 = createMenu()
  
  local f = io.popen('find '..config.data().iconPath .. "tags/ -maxdepth 1 -iname \"*.png\" -type f","r")
  local counter = 0
  while true do
    local file = f:read("*line")
    if (file == "END" or nil) or (counter > 30) then
      break
    end
    mainMenu2["data"]:add_item({"Text", onclick = function() tag.seticon(file,aTag) end, icon = capi.image(file)})
    counter = counter +1
  end
  f:close()
  mainMenu["data"]:add_item({text= "Set Icon", subMenu = mainMenu2["data"]})
  
  mainMenu["data"]:add_item({text= "Layout", subMenu = function()
  
  end})
  
  mainMenu["data"]:add_item({text= "Flags", subMenu = function()
  
  end})
  
  
  --mainMenu["data"]:add_item("Advanced",nil,nil,mainMenu2["data"])
  
  return mainMenu
end

function getMenu()
    if not aTagMenu then
        aTagMenu = new()
    end
    return aTagMenu
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
