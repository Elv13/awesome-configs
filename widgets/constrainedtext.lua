local color      = require( "gears.color" )
local pango      = require( "lgi"         ).Pango
local pangocairo = require( "lgi"         ).PangoCairo
local wibox      = require( "wibox"       )
local beautiful  = require( "beautiful"   )

local pl, desc

local function init_pl(height)
    if not pl then
        local pango_crx = pangocairo.font_map_get_default():create_context()
        pl = pango.Layout.new(pango_crx)
        desc = pango.FontDescription()
        desc:set_family("Verdana")
        desc:set_weight(pango.Weight.ULTRABOLD)
    end
end

local function fit(self,context,width,height)
    if not self._text or self._text == "" then return 0,0 end

    local extents = nil

    init_pl()

    desc:set_absolute_size((height - 2*self._padding) * pango.SCALE)
    pl:set_font_description(desc)

    pl.text = self._text

    local extents = pl:get_pixel_extents()

    return extents.width+2, height
end

local function draw(self, context, cr, width, height)
    if not self._text or self._text == "" then return end

    init_pl()

    desc:set_absolute_size((height - 2*self._padding) * pango.SCALE)
    pl:set_font_description(desc)

    local text_fit = pl:get_pixel_extents()

    pl.text =  self._text

    cr:translate (
        - math.ceil ((width - text_fit.width)   /2 ),
        - math.floor((height - text_fit.height) / 2) + self._padding + self._top_margin
    )

    cr:show_layout(pl)

end

local function set_text(self, text)
    self._text = text
    self:emit_signal("widget::redraw_needed")
end

local function set_padding(self, padding)
    self._padding = padding or 0
    self:emit_signal("widget::redraw_needed")
end

local function set_top_margin(margin)
    self._top_margin = margin or 0
    self:emit_signal("widget::redraw_needed")
end

local function new(text, padding, top_margin)
    local ib          = wibox.widget.base.empty_widget()
    ib.set_text       = set_text
    ib.draw           = draw
    ib.set_padding    = set_padding
    ib.set_top_margin = set_top_margin
    ib.fit            = fit
    ib._text          = text
    ib._padding       = padding or 0
    ib._top_margin    = top_margin or 0

    return ib
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })