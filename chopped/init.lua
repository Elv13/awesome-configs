local wibox = require("wibox")

local module = {}


module.direction = {
    LEFT  = 1,
    RIGHT = 2,
}

module.weight = {
    THIN = 1,
    FULL = 2,
}

local current = {[module.direction.LEFT] = {}, [module.direction.RIGHT] = {}}

function module.get_separator(args)
    local weight      = args.weight or module.weight.THIN
    local direction   = args.direction or module.direction.RIGHT
    local left_color  = args.left_color
    local right_color = args.right_color
    local sep_color   = args.sep_color
    local margin      = args.margin
    local fs = current[direction][weight]
    local w = wibox.widget.base.make_widget()
    w.left_color  = left_color
    w.right_color = right_color
    w.sep_color   = sep_color

    w.draw        = margin and function(self, w, cr, width, height)
        local real_width = width-margin
        cr:save()
        cr:reset_clip()
        cr:translate(margin,0)
        cr:rectangle(0,0,real_width,height)
        cr:clip()
        fs.draw(self, w, cr, real_width, height)
        cr:restore()
    end or fs.draw

    w.fit         = margin and function(self,width,height)
        local w,h = fs.fit(self,width,height)
        return w+margin>0 and w+margin or 0,h
    end or fs.fit
    return w
end

function module.register_separator_draw(weight,direction,draw,fit)
    current[direction][weight] = {draw=draw,fit=fit}
end


return module