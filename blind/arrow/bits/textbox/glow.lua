local theme,path = ...
local blind      = require( "blind"          )
local wibox_w    = require( "wibox.widget"   )
local cairo      = require( "lgi"            ).cairo
local pango      = require( "lgi"            ).Pango
local themeutils = require( "blind.common.drawing"    )

wibox_w.textbox._draw = wibox_w.textbox.draw
wibox_w.textbox.draw = function(self,w, cr, width, height,args)
    --Create the cache
    if not self.cache then
        self.cache = {}
        self.cached_text = self._layout.text
        self:connect_signal("widget::updated",function()
            if self._layout.text ~= self.cached_text then
                self.cache = {}
                self.cached_text = self._layout.text
            end
        end)
    end

    local cached = self.cache[(width+(10000*height))..self._layout.text]
    if cached then
        -- Use the cache
        cr:set_source_surface(cached)
        cr:paint()
        return
    end

    --Init the textbox layout
    self._layout.width = pango.units_from_double(width)
    self._layout.height = pango.units_from_double(height)
    local ink, logical = self._layout:get_pixel_extents()

    --Draw in the cache
    local img  = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)--target:create_similar(target:get_content(),width,height) 
    local cr2 = cairo.Context(img)
    cr2:set_source(cr:get_source())
    cr2:update_layout(self._layout)
    themeutils.draw_text(cr2,self._layout,x_offset,(height-logical.height)/2 - ink.y/4,theme.enable_glow or false,theme.glow_color)
    self.cache[width+(10000*height)..self._layout.text] = img

    --Use the cache
    cr:set_source_surface(img)
    cr:paint()
end