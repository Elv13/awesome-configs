local setmetatable = setmetatable
local print = print
local beautiful = require( "beautiful"           )
local wibox     = require( "awful.wibox"         )
local layout    = require( "awful.widget.layout" )

local capi = { image  = image  ,
               widget = widget ,
               screen = screen ,
               mouse  = mouse  }

module("widgets.tooltip")

function new(text, args)
  local args = args or  {}
  local data = {}
  function data:showToolTip(show,args2)
     local args2 = args2 or {}
     if not data.wibox and show then
       local textw = capi.widget({ type = "textbox" })
       textw.align = "center"
       textw.text = "<b>".. text .."</b>"

       local w = wibox({position="free"})
       local width = textw:extents().width + 40
       w.visible = false
       w.width = width
       w.height = 25
       w.ontop = true
       
       local x_padding = args.left and 5 or 0
       local down = args.down or args.left

       local img = capi.image.argb32(width, args.left and 20 or 25, nil)
       img:draw_rectangle(0, down and 20 or 0, width, 5, true, "#ffffff")
       img:draw_rectangle(0, down and 0  or 5, 20-(x_padding), 20, true, "#ffffff")
       img:draw_rectangle(width-20+(2*x_padding), down and 0  or 5, 20, 20, true, "#ffffff")
       img:draw_circle(20-(x_padding), 20/2 + (down and 0 or 5), 20/2 - 1, 20/2 - 1,true, "#000000")
       img:draw_circle(width-20+(2*x_padding), 20/2 + (down and 0 or 5), 20/2 - 1, 20/2 - 1,true, "#000000")
       if not args.left then
        for i=0,(5) do
            img:draw_rectangle(width/2 - 5  + i,down and 20 or 5-i, 1, i, true, "#000000")
            img:draw_rectangle(width/2 + 5 - i,down and 20 or 5-i,1, i, true, "#000000")
        end
      else
--           img:draw_rectangle(5,5, 3, 10, true, "#000000")
        local nb = 5
        for i=0,(5) do
            img:draw_rectangle(nb-i+1, 10-nb + i , i, 1, true, "#000000")
            img:draw_rectangle(nb-i+1, 10+nb - i , i, 1, true, "#000000")
        end
      end
       w.shape_bounding  = img
       w.widgets = {textw,layout = layout.horizontal.flex  }
       data.wibox = w
     end
     if data.wibox then
       data.wibox.x = args2.x or args.x or capi.mouse.coords().x - data.wibox.width/2 -5
       data.wibox.y = args2.y or args.y or (args.down and capi.screen[capi.mouse.screen].geometry.height - 16 - 25 or 16)
       data.wibox.visible = show
     end
  end
  return data
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
