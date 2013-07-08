local setmetatable = setmetatable
local ipairs = ipairs
local table = table
local print = print
local math = math
local r_widget = require("awful.widget")
local button = require("awful.button")
local layout = require("awful.layout")
local client2 = require("awful.client")
local tag = require("awful.tag")
-- local titlebar = require("widgets.titlebar")
local util = require("awful.util")
local config = require("forgotten")
local beautiful = require("beautiful")
local wibox = require("wibox")
local tooltip2   = require( "widgets.tooltip2" )
local themeutils = require( "blind.common.drawing"    )
local menu2 = require("widgets.menu")
local color = require("gears.color")
local cairo = require("lgi").cairo
local radical = require("radical")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

local module = {}
local menu = {}

local function update(w, screen)
    local layout = layout.getname(layout.get(screen))
    if layout and beautiful["layout_" ..layout.."_s"] then
        w:set_image(themeutils.apply_color_mask(beautiful["layout_" ..layout.."_s"]))
    else
        w:set_image()
    end
end

local showTitleBar = {}
local bg_img = {}

local function enableTitleBar(value)
  if tag.selected() ~= nil and config.advTermTB == true then
    for i, client in ipairs(tag.selected():clients()) do
      if value == true or client2.floating.get(client) == true then
	titlebar.add(client)
      else
	titlebar.remove(client)
      end
    end
  end
end

local function showTitle(aTag)
  return showTitleBar[aTag] or false
end

local function gen_bg(width,corner_radius)
    if bg_img[width] then return bg_img[width] end
    local img5 = cairo.ImageSurface(cairo.Format.ARGB32, width,width)
    local cr = cairo.Context(img5)
    local rad = corner_radius or 3
    cr:set_source(color(beautiful.bg_alternate))
    cr:arc(rad,rad,rad,0,2*math.pi)
    cr:arc(width-rad,rad,rad,0,2*math.pi)
    cr:arc(rad,width-rad,rad,0,2*math.pi)
    cr:arc(width-rad,width-rad,rad,0,2*math.pi)
    cr:fill()
    cr:rectangle(0,rad, width, width-2*rad)
    cr:rectangle(rad,0, width-2*rad, width)
    cr:fill()
    bg_img[width] = img5
    return img5
end

local function create(s,layouts,rect,colcount,noarrow,corner_radius)
  local noarrow = noarrow or false
  local colcount = colcount or 3
  local btns = {}
  local menuWibox = wibox({ position = "free", screen = s,bg = beautiful.menu_bg})
  local menu3 = menu2({x= rect.x, y= rect.y,width=rect.width,height=rect.height, filter = false, showfilter=false, autodiscard = false,noarrow=noarrow})
  menuWibox.ontop = true
  local layoutArray = wibox.layout.flex.vertical()
  local counter,currentRow,nrow,data = 0, wibox.layout.flex.horizontal(),0,{}
  
  for i, layout_real in ipairs(layouts) do
    local layout2 = layout.getname(layout_real)
    if layout2 and beautiful["layout_" ..layout2] then
        local m = wibox.layout.margin(arrow)
        m:set_margins(3)
        local bgb = wibox.widget.background()
        local tmp = wibox.widget.imagebox()
        tmp:set_image(beautiful["layout_" ..layout2])
        bgb:connect_signal("mouse::enter", function() bgb:set_bgimage(gen_bg(rect.width/colcount,corner_radius)) end)
        bgb:connect_signal("mouse::leave", function() bgb:set_bgimage(          ) end)

        m:set_widget(tmp)
        bgb:set_widget(m)

        tmp:buttons( util.table.join(
          button({ }, 1, function()
              menu3:toggle(false)
              layout.set(layout_real)
          end),
          button({ }, 3, function()
              menu3:toggle(false)
          end)
        ))

        if counter ~= 0 then 
          if counter % colcount == 0 then
            layoutArray:add(currentRow)
            currentRow = wibox.layout.flex.horizontal()
            nrow = nrow+1
          end
        end
        currentRow:add(bgb)
        bgb.l_real = layout_real
        btns[#btns+1] = bgb
        counter = counter +1
    end
  end
  layoutArray:add(currentRow)
  menuWibox:set_widget(layoutArray)
  rect.height = (nrow+1)*rect.width/colcount
  menu3.settings.nrow = nrow
  menu3.settings.btns = btns
  menu3:add_wibox(menuWibox,rect)
  return menu3
end

local centered = nil
local function nextL(menu,mod)
    centered.settings.btns_idx = (centered.settings.btns_idx or 0)+(mod[1] == "Shift" and -1 or 1)
    if centered.settings.btns_idx > #centered.settings.btns then
        centered.settings.btns_idx = 1
    elseif centered.settings.btns_idx < 1 then
        centered.settings.btns_idx = #centered.settings.btns
    end
    if centered.settings.btns_cur then
        centered.settings.btns_cur:set_bgimage()
    end
    centered.settings.btns_cur = centered.settings.btns[centered.settings.btns_idx]
    centered.settings.btns_cur:set_bgimage(gen_bg(50,7))
    layout.set(centered.settings.btns_cur.l_real,tag.selected())
    return true
end

local centered = nil

module.centered_menu = function(layouts,backward)
    
    local cur = layout.get(tag.getscreen(tag.selected()))

    if not centered then
        centered = radical.box({item_style=radical.item_style.rounded,item_height=45,column=6,layout=radical.layout.grid})
        for i, layout_real in ipairs(layouts) do
            local layout2 = layout.getname(layout_real)
            if layout2 and beautiful["layout_" ..layout2] then
                centered:add_item({icon=beautiful["layout_" ..layout2],button1 = function(_,mod)
                    centered[mod[1] == "Shift" and "previous_item" or "next_item"].selected = true
                    layout.set(layouts[centered.current_index] or layouts[1],tag.selected())
                end, selected = (layout_real == cur)})
            end
        end
        centered:add_key_hook({}, " ", "press", function(_,mod) centered._current_item.button1(_,mod) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "press",   function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_L", "release", function(menu) end)
        centered:add_key_hook({"Mod4"}, "Shift_R", "release", function(menu) end)
        centered:add_key_hook({}, "Mod4", "release", function(menu) centered.visible = false end)
    end
    centered.visible = true
end

local function new(screen, layouts)
    local screen = screen or 1
    local w = wibox.widget.imagebox()
    local titleBarWidget = wibox.widget.textbox()
    tooltip2(w,"Change Layout",{})
    w.bg = beautiful.bg_alternate
    update(w, screen)
    
    local function btn(geo)
        local menu = radical.context({item_style=radical.item_style.rounded,item_height=30,column=3,layout=radical.layout.grid,arrow_type=radical.base.arrow_type.CENTERED})
        for i, layout_real in ipairs(layouts) do
            local layout2 = layout.getname(layout_real)
            if layout2 and beautiful["layout_" ..layout2] then
                menu:add_item({icon=beautiful["layout_" ..layout2]})
            end
        end
        menu.parent_geometry = geo
        menu.visible = true
    end

    w:buttons( util.table.join(
      button({ }, 1, btn),
      button({ }, 3, btn),
      button({ }, 4, function()
	  layout.inc(layouts, 1)
      end),
      button({ }, 5, function()
	  layout.inc(layouts, -1)
      end)
    ))

    titleBarWidget:buttons( util.table.join(
      button({ }, 1, function()
	  showTitleBar[tag.selected()] = showTitleBar[tag.selected()] or false
	  menu:visible(false)
	  showTitleBar[tag.selected()] = not showTitleBar[tag.selected()]
	  
	  if showTitleBar[tag.selected()] == true then
	    titleBarWidget.bg = beautiful.bg_focus
	  else
	    titleBarWidget.bg = beautiful.bg_normal
	  end
	  
	  enableTitleBar(showTitleBar[tag.selected()])
      end),
      button({ }, 3, function()
	  menu:visible(false)
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

    tag.attached_connect_signal(screen, "property::selected", update_on_tag_selection)
    tag.attached_connect_signal(screen, "property::layout", update_on_tag_selection)

    return w
end





return setmetatable(module, { __call = function(_, ...) return new(...) end })
