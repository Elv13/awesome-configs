local chopped =  require("chopped"     )
local cairo   = require( "lgi"         ).cairo
local color   = require( "gears.color" )

local function arrow_draw_sides(self, w, cr, width, height,offset)
    if self.right_color then
        cr:set_source(color(self.right_color))
        cr:move_to(height/2,-offset)
--         cr:line_to(height/2,height/2)
--         cr:line_to(0,height+offset)
        cr:line_to(0,height)
        cr:line_to(height/2,height)
        cr:close_path()
        cr:fill()
    end
    if self.left_color then
        cr:set_source(color(self.left_color))
--         cr:move_to(0,-offset)
        cr:move_to(height/2,0)
        cr:line_to(0,height)
        cr:line_to(0,0)
        cr:close_path()
        cr:fill()
    end
end

--
--Thin
--

local function fit_thin_right(self,width,height)
    return height/2+2+5,height
end
local function draw_thin_right(self, w, cr, width, height)
    arrow_draw_sides(self, w, cr, width, height,2)
    cr:set_source(color(self.sep_color))
    cr:move_to(width,0)
    cr:line_to(5,height)
    cr:line_to(0,height)
    cr:line_to(width-5,0)
    cr:close_path()
    cr:fill()
end
local function draw_thin_left(self, w, cr, width, height)
    cr:save()
    cr:scale(-1,1)
    cr:translate(-width,0)
    draw_thin_right({right_color=self.left_color,left_color=self.right_color,sep_color=self.sep_color}, w, cr, width, height)
    cr:restore()
end
chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.RIGHT,draw_thin_right,fit_thin_right)
chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.LEFT ,draw_thin_left ,fit_thin_right)


--
-- FULL
--

local function fit_heavy_right(self,widget,height)
    return height/2,height
end
local function draw_heavy_right(self, w, cr, width, height)
    arrow_draw_sides(self, w, cr, width, height,0)
end
local function draw_heavy_left(self, w, cr, width, height)
    cr:save()
    cr:scale(-1,1)
    cr:translate(-width,0)
    arrow_draw_sides({right_color=self.left_color,left_color=self.right_color,sep_color=self.sep_color}, w, cr, width, height,0)
    cr:restore()
end
chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.RIGHT,draw_heavy_right,fit_heavy_right)
chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.LEFT ,draw_heavy_left ,fit_heavy_right)
