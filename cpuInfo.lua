local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local naughty = require("naughty")
local vicious = require("vicious")
local tag = require("awful.tag")
local util = require("awful.util")
local wibox = require("awful.wibox")
local shifty = require("shifty")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("cpuInfo")

local data = {}

local cpuInfo = {}
function createDrawer() 
  local f = io.open('/tmp/cpuStatus.txt','r')
  local text2 = f:read("*all")
  f:close()
    local mainText = capi.widget({type = "textbox"})
  mainText.text = text2
  
  data.wibox.widgets = { mainText }

  return mainText:extents().height
end

function update()

end

function new(screen, args)
  data.wibox = wibox({ position = "free", screen = capi.screen.count() })
  data.wibox.ontop = true
  data.wibox.visible = false
  local height = createDrawer() 
  data.wibox:geometry({ width = 212, height = height, x = capi.screen[capi.screen.count()].geometry.width - 240, y = 24})

  cpulogo       = capi.widget({ type = "imagebox", align = "right" })
  cpulogo.image = capi.image("/home/lepagee/Icon/brain.png")
  cpulogo:buttons( util.table.join(
    button({ }, 1, function()
      toggleSensorBar()
    end)
  ))

  -- cpulogo.mouse_enter = function () cpuStat() end
  -- cpulogo.mouse_leave = function () naughty.destroy(cpuInfo[3]) end

  cpulogo:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  cpulogo:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)

  cpuwidget = capi.widget({
	type = 'textbox',
	    name = 'cpuwidget',
	    align = "right"
	  })
  cpuwidget.width = 27
  cpuwidget:buttons( util.table.join(
    button({ }, 1, function()
      toggleSensorBar()
    end)
  ))
  
  vicious.register(cpuwidget, vicious.widgets.cpu,'$1%')

  -- cpuwidget.mouse_enter = function () cpuStat() end
  -- cpuwidget.mouse_leave = function () naughty.destroy(cpuInfo[3]) end

  cpuwidget:add_signal("mouse::enter", function ()
      data.wibox.visible = true
  end)

  cpuwidget:add_signal("mouse::leave", function ()
    data.wibox.visible = false
  end)
	      
  cpugraphwidget = widget2.graph({ layout = widget2.layout.horizontal.rightleft })
  --[[widget({
      type = 'graph',
      name = 'cpugraphwidget',
      align = "right"
  })]]
  -- cpugraphwidget:buttons({
  --   button({ }, 1, function()
  --     toggleSensorBar()
  --   end)
  -- })
  
  cpugraphwidget.height = 0.6
  cpugraphwidget.width = 45
  cpugraphwidget.grow = 'right'

  cpugraphwidget:set_width(40)
  cpugraphwidget:set_height(18)
  cpugraphwidget:set_offset(1)
  --membarwidget:set_gap(1)
  cpugraphwidget:set_height(14)
  --cpugraphwidget:set_min_value(0)
  --cpugraphwidget:set_max_value(100)
  --cpugraphwidget:set_scale(false)
  --cpugraphwidget:set_min_value(0)
  cpugraphwidget:set_background_color(beautiful.bg_normal)
  cpugraphwidget:set_border_color(beautiful.fg_normal)
  cpugraphwidget:set_color(beautiful.fg_normal)
  --awful.widget.layout.margins[cpugraphwidget] = { top = 4}


  -- cpugraphwidget:plot_properties_set('cpu', {
  --                                         fg = beautiful.fg_normal,
  -- 					fg_center = beautiful.fg_normal,
  -- 					--fg_end = '#CC0000',
  --                                         vertical_gradient = true
  -- })
  
  vicious.register(cpugraphwidget, vicious.widgets.cpu, '$1', 1)

  -- cpugraphwidget.mouse_enter = function () cpuStat() end
  -- cpugraphwidget.mouse_leave = function () naughty.destroy(cpuInfo[3]) end

  -- cpugraphwidget:add_signal("mouse::enter", function ()
  --     cpuStat()
  -- end)
  -- 
  -- cpugraphwidget:add_signal("mouse::leave", function ()
  --    cpuStat()
  -- end)
  
  return {logo = cpulogo, text = cpuwidget, graph = cpugraphwidget}
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
