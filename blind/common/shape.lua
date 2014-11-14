local math = math

local module = {}

function module.draw_round_rect(cr,x,y,w,h,radius)
    cr:save()
    cr:translate(x,y)
    cr:move_to(0,radius)
    cr:arc(radius,radius,radius,math.pi,3*(math.pi/2))
    cr:arc(w-radius,radius,radius,3*(math.pi/2),math.pi*2)
    cr:arc(w-radius,h-radius,radius,math.pi*2,math.pi/2)
    cr:arc(radius,h-radius,radius,math.pi/2,math.pi)
    cr:close_path()
    cr:restore()
end

function module.draw_round_rect2(cr,x,y,w,h,rtl,rtr,rbl,rbr)
    cr:save()
    cr:translate(x,y)
    cr:move_to(0,rtl)
    cr:arc(rtl,rtl,rtl,math.pi,3*(math.pi/2))
    cr:arc(w-rtr,rtr,rtr,3*(math.pi/2),math.pi*2)
    cr:arc(w-rbl,h-rbl,rbl,math.pi*2,math.pi/2)
    cr:arc(rbr,h-rbr,rbr,math.pi/2,math.pi)
    cr:close_path()
    cr:restore()
end

function module.half_circle_delimited_rect(cr,x,y,width,height)
    cr:move_to(height/2,height)
    cr:arc(height/2, height/2, height/2, math.pi/2,3*(math.pi/2))
    cr:arc(width-height, height/2, height/2,3*(math.pi/2),math.pi/2)
end

return module