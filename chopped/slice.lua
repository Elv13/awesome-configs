local chopped =  require("chopped"     )
local cairo   = require( "lgi"         ).cairo
local color   = require( "gears.color" )
local shape   = require( "gears.shape" )

local function arrow_draw_sides(self, context, cr, width, height,offset)
    if self.right_color and type(self.right_color) ~= "function" then
        cr:set_source(color(self.right_color))
        cr:move_to(height/2,-offset)
        cr:line_to(0,height)
        cr:line_to(height/2,height)
        cr:close_path()
        cr:fill()
    end
    if self.left_color and type(self.left_color) ~= "function" then
        cr:set_source(color(self.left_color))
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

local function fit_thin_right(self,context,width,height)
    return height/2+2+5,height
end
local function draw_thin_right(self, context, cr, width, height)
    arrow_draw_sides(self, context, cr, width, height,2)
    cr:set_source(color(self.sep_color))
    shape.parallelogram(cr, width, height, 5)
    cr:fill()
end
local function draw_thin_left(self, context, cr, width, height)
    cr:save()
    cr:scale(-1,1)
    cr:translate(-width,0)
    draw_thin_right({right_color=self.left_color,left_color=self.right_color,sep_color=self.sep_color}, context, cr, width, height)
    cr:restore()
end
chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.RIGHT,draw_thin_right,fit_thin_right)
chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.LEFT ,draw_thin_left ,fit_thin_right)


--
-- FULL
--

local function fit_heavy_right(self,context,widget,height)
    return height/2,height
end
local function draw_heavy_right(self, context, cr, width, height)
    arrow_draw_sides(self, context, cr, width, height,0)
end
local function draw_heavy_left(self, context, cr, width, height)
    cr:save()
    cr:scale(-1,1)
    cr:translate(-width,0)
    arrow_draw_sides({right_color=self.left_color,left_color=self.right_color,sep_color=self.sep_color}, context, cr, width, height,0)
    cr:restore()
end
chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.RIGHT,draw_heavy_right,fit_heavy_right)
chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.LEFT ,draw_heavy_left ,fit_heavy_right)
