local setmetatable = setmetatable
local print = print
local math  = math
local beautiful = require( "beautiful"    )
local wibox     = require( "wibox"        )
local layout    = require( "wibox.layout" )
local color     = require( "gears.color"  )
local cairo     = require( "lgi"          ).cairo
local capi = { screen = screen ,
               mouse  = mouse  }
module("widgets.tooltip")

local function new(text, args)
  local args,data = args or  {},{}
  function data:showToolTip(show,args2)
     local args2 = args2 or {}
     if not data.wibox and show then
       local textw = wibox.widget.textbox()
       textw.align = "center"
       textw:set_markup("<b>".. text .."</b>")

       local w,width = wibox({position="free"}),textw._layout:get_pixel_extents().width + 60
       w.visible = false
       w.width   = width
       w.height  = 25
       w.ontop   = true
       w:set_bg(beautiful.tooltip_bg or beautiful.bg_normal or "")

       local x_padding,down = args.left and 5 or 0,args.down or args.left

        local img = cairo.ImageSurface(cairo.Format.A1, width, args.left and 20 or 25)
        local cr = cairo.Context(img)
        --Clear the surface
        cr:set_source_rgba( 0, 0, 0,0 )
        cr:paint()

        --Draw the corner
        cr:set_source_rgba( 1, 1, 1, 1 )
        if not args.left then
            cr:arc(20-(x_padding), 20/2 + (down and 0 or 5), 20/2 - 1,0,2*math.pi)
        end
        cr:arc(width-20+(2*x_padding), 20/2 + (down and 0 or 5), 20/2 - 1,0,2*math.pi)

        --Draw arrow
        if not args.left then
            for i=0,(5) do
                cr:rectangle(width/2 - 5 + i ,down and 20 or 5-i, 1, i)
                cr:rectangle(width/2 + 5 - i ,down and 20 or 5-i, 1, i)
            end
        else
            for i=0,(12) do
                cr:rectangle(i, (20/2) - i, i, i*2)
            end
        end
        cr:rectangle(20-(args.left and 5 or 0), down and 0 or 5, width-40+(args.left and 14 or 0 ), 20)
        cr:fill()
        w.shape_bounding  = img._native
        local l = wibox.layout.fixed.horizontal()
        local m = wibox.layout.margin(textw)
        m:set_left    ( 30              )
        m:set_right   ( 10              )
        m:set_top     ( args.left and 0 or down and 0 or 5 )
        m:set_bottom  ( args.left and 6 or down and 5 or 0 )
        l:add(m)
        l:fill_space(true)
        w:set_widget(l)
        w:set_fg(beautiful.fg_normal)
        w:connect_signal("mouse::leave",function() w.visible = false end)
        data.wibox = w
     end
     if data.wibox then
       data.wibox.x = args2.x or args.x or capi.mouse.coords().x - data.wibox.width/2 -5
       data.wibox.y = args2.y or args.y or (args.down and capi.screen[capi.mouse.screen].geometry.height - 16 - 25 or 16)
       data.wibox.visible = show
     end
     data.text = text
  end
  return data
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })