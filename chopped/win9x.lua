local chopped =  require("chopped"     )
local cairo   = require( "lgi"         ).cairo
local color   = require( "gears.color" )
local math = math

local rad  = 3
local btn_c1 = color("#808080")
local btn_c2 = color("#FCFCFC")

--
--Thin
--

local function fit_thin_right(self,context,width,height)
    return 12, height
end
local function draw_thin_right(self, context, cr, width, height)
    -- Add 2px padding on both sides
    width = width - 4
    cr:translate(2,0)

    -- Draw the main separator
    cr:set_source(btn_c1)
    cr:rectangle(1,4,1,height-6)
    cr:fill()
    cr:set_source(btn_c2)
    cr:rectangle(2,4,1,height-6)
    cr:fill()

    -- Draw the handle
    cr:set_source_rgb(1,1,1)
    cr:rectangle(width-3, 6, 1, height-4-6)
    cr:rectangle(width-3, 6, 3, 1)
    cr:fill()
    cr:set_source(btn_c1)
    cr:rectangle(width-1, 7, 1, height-4-6)
    cr:rectangle(width-3, height-4, 3, 1)
    cr:fill()
end

chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.RIGHT,draw_thin_right,fit_thin_right)
chopped.register_separator_draw(chopped.weight.THIN,chopped.direction.LEFT ,draw_thin_right ,fit_thin_right)

chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.RIGHT,draw_thin_right,fit_thin_right)
chopped.register_separator_draw(chopped.weight.FULL,chopped.direction.LEFT ,draw_thin_right ,fit_thin_right)
