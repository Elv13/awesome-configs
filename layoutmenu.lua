local setmetatable = setmetatable
local ipairs = ipairs
local table = table
local r_widget = require("awful.widget")
local button = require("awful.button")
local layout = require("awful.layout")
local tag = require("awful.tag")
local titlebar = require("awful.titlebar")
local util = require("awful.util")
local beautiful = require("beautiful")
local wibox = require("awful.wibox")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("layoutmenu")

local function update(w, screen)
    local layout = layout.getname(layout.get(screen))
    if layout and beautiful["layout_" ..layout.."_s"] then
        w.image = capi.image(beautiful["layout_" ..layout.."_s"])
    else
        w.image = nil
    end
end

function new(screen, layouts)
    local screen = screen or 1
    local w = capi.widget({ type = 'imagebox', height = 10 })
    local titleBarWidget = capi.widget({ type = 'textbox', height = 10 })
    local menu = create(screen,layouts,titleBarWidget)
    local showTitleBar = {}
    update(w, screen)
    
    w:buttons( util.table.join(
      button({ }, 1, function()
	  menu:geometry({x = w:extents(screen).x or capi.mouse.coords().x, y = w:extents(screen).y or capi.mouse.coords().y})
	  menu.visible = not menu.visible
      end),
      button({ }, 4, function()
	  layout.inc(layouts, 1)
      end),
      button({ }, 5, function()
	  layout.inc(layouts, -1)
      end)
    ))
    
    local showTitleBar = {}
    titleBarWidget:buttons( util.table.join(
      button({ }, 1, function()
	  showTitleBar[tag.selected()] = showTitleBar[tag.selected()] or false
	  menu.visible = false
	  showTitleBar[tag.selected()] = not showTitleBar[tag.selected()]
	  
	  if showTitleBar[tag.selected()] == true then
	    titleBarWidget.bg = beautiful.bg_focus
	  else
	    titleBarWidget.bg = beautiful.bg_normal
	  end
	  
	  enableTitleBar(showTitleBar[tag.selected()])
      end),
      button({ }, 3, function()
	  menu.visible = false
      end)
    ))
  

    local function update_on_tag_selection(new_tag)
	if showTitleBar[tag.selected()] == true then
	  titleBarWidget.bg = beautiful.bg_focus
	else
	  titleBarWidget.bg = beautiful.bg_normal
	end
        return update(w, new_tag.screen)
    end

    tag.attached_add_signal(screen, "property::selected", update_on_tag_selection)
    tag.attached_add_signal(screen, "property::layout", update_on_tag_selection)

    return w
end

function enableTitleBar(value)
  if tag.selected() ~= nil then
    for i, client in ipairs(tag.selected():clients()) do
      if value == true or awful.client.floating.get(client) == true then
	titlebar.add(client)
      else
	titlebar.remove(client)
      end
    end
  end
end


function create(s,layouts,titleBarWidget)
  if menuWibox == nil then
    menuWibox = {}
  end
  menuWibox[s] = wibox({ position = "free", screen = s})
  menuWibox[s].visible = false
  menuWibox[s].ontop = true
  layoutArray = {}
  local counter = 0
  local currentRow = {}
  
  for i, layout_real in ipairs(layouts) do
    local layout2 = layout.getname(layout_real)
    
    if layout2 and beautiful["layout_" ..layout2] then
	local tmp = capi.widget({type = "imagebox"})
        tmp.image = capi.image(beautiful["layout_" ..layout2])
	r_widget.layout.margins[tmp] = { right = 10}
	tmp:buttons( util.table.join(
	  button({ }, 1, function()
	      menuWibox[s].visible = false
	      layout.set(layout_real)
	  end),
	  button({ }, 3, function()
	      menuWibox[s].visible = false
	  end)
	))
	
	if counter ~= 0 then 
	  if counter % 3 == 0 then
	    currentRow["layout"] = r_widget.layout.horizontal.leftright
	    table.insert(layoutArray, currentRow)
	    currentRow = {}
	  end
	end
	table.insert(currentRow, tmp)
	counter = counter +1
    end
  end
  if #currentRow > 0 then
    currentRow["layout"] = r_widget.layout.horizontal.leftright
    table.insert(layoutArray, currentRow)
  end
  
  titleBarWidget.text = "Titlebar"
  titleBarWidget.height = 10
  titleBarWidget.align = "center"
  table.insert(layoutArray, {titleBarWidget, layout= r_widget.layout.horizontal.flex})
  
  menuWibox[s]:geometry({ width = 90, height = (30*#layoutArray)})
  
  layoutArray["layout"] = r_widget.layout.vertical.flex
  
  menuWibox[s].widgets = layoutArray
  return menuWibox[s]
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })
