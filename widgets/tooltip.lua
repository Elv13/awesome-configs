local setmetatable = setmetatable
local print = print
local beautiful = require( "beautiful"           )
local wibox     = require( "awful.wibox"         )
local layout    = require( "awful.widget.layout" )

local capi = { image  = image  ,
               widget = widget }

module("widgets.tooltip")

function new(text, args)
  local args = args or  {}
  local textw = capi.widget({ type = "textbox" })
  textw.align = "center"
  textw.text = "<b>".. text .."</b>"

  local w = wibox({position="free"})
  local width = textw:extents().width + 40
  w.width = width
  w.height = 25
  w.ontop = true

  local img = capi.image.argb32(width, 25, nil)
  img:draw_rectangle(0, args.down and 20 or 0, width, 5, true, "#ffffff")
  img:draw_rectangle(0, args.down and 0  or 5, 20, 20, true, "#ffffff")
  img:draw_rectangle(width-20, args.down and 0  or 5, 20, 20, true, "#ffffff")
  img:draw_circle(20, 20/2 + (args.down and 0 or 5), 20/2 - 1, 20/2 - 1,true, "#000000")
  img:draw_circle(width-20, 20/2 + (args.down and 0 or 5), 20/2 - 1, 20/2 - 1,true, "#000000")
  for i=0,(5) do
    img:draw_rectangle(width/2 - 5  + i,args.down and 20 or 5-i, 1, i, true, "#000000")
    img:draw_rectangle(width/2 + 5 - i,args.down and 20 or 5-i,1, i, true, "#000000")
  end
  w.shape_bounding  = img
  w.widgets = {textw,layout = layout.horizontal.flex  }
  return w
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
