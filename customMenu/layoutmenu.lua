local setmetatable = setmetatable
local ipairs = ipairs
local table = table
local r_widget = require("awful.widget")
local button = require("awful.button")
local layout = require("awful.layout")
local client2 = require("awful.client")
local tag = require("awful.tag")
local titlebar = require("widgets.titlebar")
local util = require("awful.util")
local config = require("config")
local beautiful = require("beautiful")
local wibox = require("awful.wibox")
local tooltip   = require( "widgets.tooltip" )
local menu2 = require("widgets.menu")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("customMenu.layoutmenu")

local function update(w, screen)
    local layout = layout.getname(layout.get(screen))
    if layout and beautiful["layout_" ..layout.."_s"] then
        w.image = capi.image(beautiful["layout_" ..layout.."_s"])
    else
        w.image = nil
    end
end

local showTitleBar = {}

local function enableTitleBar(value)
  if tag.selected() ~= nil and config.data().advTermTB == true then
    for i, client in ipairs(tag.selected():clients()) do
      if value == true or client2.floating.get(client) == true then
	titlebar.add(client)
      else
	titlebar.remove(client)
      end
    end
  end
end

function showTitle(aTag)
  return showTitleBar[aTag] or false
end

function new(screen, layouts)
    local screen = screen or 1
    local w = capi.widget({ type = 'imagebox', height = 10 })
    local titleBarWidget = capi.widget({ type = 'textbox', height = 10 })
    local menu = create(screen,layouts,titleBarWidget)
    local tt = tooltip("Change Layout",{})
    update(w, screen)
    
    w:buttons( util.table.join(
      button({ }, 1, function()
	  menu:geometry({x = w:extents(screen).x or capi.mouse.coords().x, y = w:extents(screen).y or capi.mouse.coords().y})
          tt:showToolTip(false);
	  menu:visible()
      end),
      button({ }, 3, function()
          menu:geometry({x = w:extents(screen).x or capi.mouse.coords().x, y = w:extents(screen).y or capi.mouse.coords().y})
          tt:showToolTip(false);
          menu:visible()
      end),
      button({ }, 4, function()
	  layout.inc(layouts, 1)
      end),
      button({ }, 5, function()
	  layout.inc(layouts, -1)
      end)
    ))
    
    w:add_signal("mouse::enter", function() tt:showToolTip(true) ;w.bg = beautiful.bg_highlight end)
    w:add_signal("mouse::leave", function() tt:showToolTip(false);w.bg = beautiful.bg_normal end)
    
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


function create(s,layouts,titleBarWidget)
  local menuWibox = wibox({ position = "free", screen = s})
  local top,bottom = menu2.gen_menu_decoration(90)
  menuWibox.visible = false
  menuWibox.ontop,top.ontop,bottom.ontop = true,true,true
  layoutArray = {}
  local counter,currentRow,data = 0, {},{}

  function data:geometry(geo)
    top:geometry({x=geo.x-30,y=geo.y})
    menuWibox:geometry({x=geo.x-30,y=geo.y+23})
    bottom:geometry({x=geo.x-30,y=geo.y+23+menuWibox.height})
  end

  function data:visible(vis)
    local vis = vis or not menuWibox.visible
    for k,v in ipairs({top,bottom,menuWibox}) do
      v.visible = vis
    end
  end
  
  for i, layout_real in ipairs(layouts) do
    local layout2 = layout.getname(layout_real)
    
    if layout2 and beautiful["layout_" ..layout2] then
	local tmp = capi.widget({type = "imagebox"})
        tmp.image = capi.image(beautiful["layout_" ..layout2])
	r_widget.layout.margins[tmp] = { right = 10}
	tmp:buttons( util.table.join(
	  button({ }, 1, function()
	      data:visible(false)
	      layout.set(layout_real)
	  end),
	  button({ }, 3, function()
	      data:visible(false)
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
  
  menuWibox:geometry({ width = 90, height = (30*#layoutArray)})

  --Add border on both side
  local img = capi.image.argb32(90, (30*#layoutArray) or 10, nil)
  img:draw_rectangle(0,0, 3, (30*#layoutArray), true, "#ffffff")
  img:draw_rectangle(87,0, 3, (30*#layoutArray), true, "#ffffff")

  menuWibox.shape_clip     = img
  menuWibox.border_color = beautiful.fg_normal
    --w2.shape_bounding = do_gen_menu_bottom(width,10,0)
  
  layoutArray["layout"] = r_widget.layout.vertical.flex
  
  menuWibox.widgets = layoutArray
  return data
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })
