local chopped =  require("chopped"     )
local cairo   = require( "lgi"         ).cairo
local color   = require( "gears.color" )
local math = math

local rad  = 3

--
--Thin
--

local function fit_thin_right(self,context,width,height)
    return height/2+2,height
end
local function draw_thin_right(self, context, cr, width, height)
    cr:rectangle(0,0,2,height)
    cr:fill()
end
local function draw_thin_left(self, context, cr, width, height)
    cr:rectangle(width -2,0,2,height)
    cr:fill()
end
chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.RIGHT,draw_thin_right,fit_thin_right)
chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.LEFT ,draw_thin_left ,fit_thin_right)


--
-- FULL
--

local function fit_heavy_right(self,context,widget,height)
    return height/2+2,height
end
local function draw_heavy_right(self, context, cr, width, height)
--     cr:rectangle(0,0,2,height)
--     cr:fill()
end
local function draw_heavy_left(self, context, cr, width, height)
--     cr:rectangle(width -2,0,2,height)
--     cr:fill()
end
chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.RIGHT,draw_heavy_right,fit_heavy_right)
chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.LEFT ,draw_heavy_left ,fit_heavy_right)
