local setmetatable = setmetatable
local button = require("awful.button")
local tag = require("awful.tag")
local util = require("awful.util")
local shifty = require("shifty")
local beautiful = require("beautiful")
local menu2 = require("customMenu.menu2")
local capi = { image = image,
               screen = screen,
               widget = widget}

module("customButton.tagmover")

local data = {}


--Screen the screen number
--args:
--     -direction (left or right) [REUQIRED]
--     -icon an icon [optional]
function new(screen, args)
    local screen = screen or 1
    local direction = args.direction or "left"
    local icon = args.icon or nil
    local id = screen..direction
    local addOrSub = 0
    local screenMenu = menu2()
    
    
    if direction == "left" then
      addOrSub = -1
    elseif direction == "right" then
      addOrSub = 1
    else
      return nil
    end
    
    data[id] = {}
    if icon ~= nil then
      data[id].widget = capi.widget({ type = "imagebox", align = "left" })
      data[id].widget.image = capi.image(icon)
    else
      data[id].widget = capi.widget({ type = "textbox", align = "left" })
      data[id].widget.text = direction
    end
    
    if direction == "left" and screen == 1 then
      data[id].widget.visible = false
    elseif direction == "right" and screen == capi.screen.count() then
      data[id].widget.visible = false
    else
      data[id].widget.visible = true
    end
    
    for i=1,capi.screen.count() do
      screenMenu:addItem(i,nil,function() 
                                tag_to_screen(data[id].selected,i)
                                screenMenu:toggle()
                               end,nil)
    end
    
    data[id].screen = screen
    data[id].direction = direction
    
    data[id].widget:add_signal("mouse::enter", function () 
                                                  data[id].selected = tag.selected() 
                                                  data[id].widget.bg = beautiful.bg_highlight
                                                end)
    data[id].widget:add_signal("mouse::leave", function () 
                                                  data[id].selected = nil 
                                                  data[id].widget.bg = beautiful.bg_normal
                                                end)
    
    data[id].widget:buttons( util.table.join(
      button({ }, 1, function()
	  if data[id].selected ~= nil then
	    local screen2 = data[id].selected.screen + addOrSub
	    if screen2 > capi.screen.count() then
	      screen2 = 1
	    end
	    tag_to_screen(data[id].selected, screen2)
	    data[id].selected = tag.selected(screen)
	  end
      end),
      button({ }, 3, function()
          screenMenu:toggle()
      end),
      button({ }, 4, function()
	  if data[id].selected ~= nil then
	    local screen2 = data[id].selected.screen + addOrSub
	    if screen2 > capi.screen.count() then
	      screen2 = 1
	    end
	    tag_to_screen(data[id].selected, screen2)
	  end
      end),
      button({ }, 5, function()
	  if data[id].selected ~= nil then
	    local screen2 = data[id].selected.screen - addOrSub
	    if screen2 == 0 then
	      screen2 = capi.screen.count()
	    end
	    tag_to_screen(data[id].selected, screen2)
	  end
      end)
    ))
    

    return data[id].widget
end

--By bios007
function tag_to_screen(t, scr)
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

setmetatable(_M, { __call = function(_, ...) return new(...) end })
