local capi = {
  client       = client,
  mousegrabber = mousegrabber,
  mouse        = mouse,
  screen       = screen,
}
local math = math
local wibox = require("wibox")
local awful = require("awful")
local cairo = require("lgi"  ).cairo

local module = {}
local w = nil

local function set_device(input_ids,geometry)
  for k,v in ipairs(type(input_ids) == "table" and input_ids or {input_ids}) do
    awful.util.spawn("xsetwacom --set "..v.." MapToOutput "..geometry.width.."x"..geometry.height.."+"..geometry.x.."+"..geometry.y)
  end
end

function module.focussed_client(input_ids)
  if capi.client.focus then
    set_device(input_ids,capi.client.focus:geometry())
  end
end

function module.select_rect(input_ids)
  w = w or wibox({})
  w:set_bg("#ff0000")
  w.visible = true
  w.ontop = true
  local start = capi.mouse.coords()
  w.x = start.x
  w.y = start.y
  local is_set = nil

  local rect = cairo.ImageSurface(cairo.Format.ARGB32, capi.screen[capi.mouse.screen].geometry.width, capi.screen[capi.mouse.screen].geometry.height)
  local cr = cairo.Context(rect)

  capi.mousegrabber.run(function(mouse)
    local coords = capi.mouse.coords()
    local dx, dy = math.abs(coords.x - start.x),math.abs(coords.y - start.y)
    local sx,sy = coords.x < start.x and coords.x or start.x,coords.y < start.y and coords.y or start.y
    if not mouse.buttons[1] and is_set ~= nil then
      w.visible = false
      set_device(input_ids,{x=sx,y=sy,width=dx,height=dy})
      return false
    elseif is_set == nil and mouse.buttons[1] then
      is_set = mouse.buttons[1] and true or false
    end

    w.x = sx
    w.y = sy

    if dy > 0 then
      w.height = dy
      w.visible = true
    end
    if dx > 0 then
      w.width = dx
    end

    cr:set_source_rgba(1,0,0,1)
    cr:set_operator(cairo.Operator.CLEAR)
    cr:paint()
    cr:set_operator(cairo.Operator.SOURCE)
    cr:set_source_rgba(1,0,0,1)
    cr:rectangle(2,2,dx-4,dy-4)
    cr:set_line_width(3)
    cr:stroke()
    w.shape_bounding = rect._native

    print("Mouse")
    return true
  end,"fleur")
end

return setmetatable(module, { __call = function(_, ...) return module.listTags(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;