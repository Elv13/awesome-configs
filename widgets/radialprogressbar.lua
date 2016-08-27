local setmetatable = setmetatable
local base = require("wibox.widget.base")
local shape = require("gears.shape")
local util = require( "awful.util"        )
local color     = require( "gears.color"       )

local outline_width  = 2 --FIXME add config options
local progress_width = 3

local radialprogressbar = { mt = {} }

--FIXME handle DPI
--TODO support multiple values

local function ajust_workarea(self, context, cr, width, height)
    local padding = self._padding or {}

    -- Remove the padding
    if padding.left then
        cr:translate(padding.left, 0)
        width = width - padding.left
    end

    if padding.top then
        cr:translate(0, padding.top)
        height = height - padding.top
    end

    if padding.right then
        width = width - padding.right
    end

    if padding.bottom then
        height = height - padding.bottom
    end

    -- Make sure the border fit in the clip area
    local offset = math.max(outline_width, progress_width)/2
    cr:translate(offset, offset)
    width, height = width-2*offset, height-2*offset

    return width, height
end

-- Draw the radial outline and progress
function radialprogressbar:after_draw_children(context, cr, width, height)
    cr:save()
    cr:close_path() --TODO there is an issue elsewhere
    cr:stroke()

    width, height = ajust_workarea(self, context, cr, width, height)

    -- Draw the outline
    shape.rounded_bar(cr, width, height)
    cr:set_source(self._outline_color or color("#0000ff"))
    cr:set_line_width(outline_width)
    cr:stroke()

    -- Draw the progress
    cr:set_source(self._color or color("#ff00ff"))
    shape.radial_progress(cr, width, height, self._percent or 0)
    cr:set_line_width(progress_width)
    cr:stroke()
    cr:restore()
end

-- Set the clip
function radialprogressbar:before_draw_children(context, cr, width, height)
--     width, height = ajust_workarea(self, context, cr, width, height)
--     shape.rounded_bar(cr, width, height)
--     cr:clip()
end

--- Layout this layout
function radialprogressbar:layout(context, width, height)
    if self.widget then
        return { base.place_widget_at(self.widget, 0, 0, width, height) }
    end
end

--- Fit this layout into the given area
function radialprogressbar:fit(context, width, height)
    local w, h = 0, 0

    if self.widget then
        w, h = base.fit_widget(self, context, self.widget, width, height)
    end

    return math.max(w, self._width or 80), h
end

--- Set the widget that this layout radialprogressbars.
function radialprogressbar:set_widget(widget)
    if widget then
        base.check_widget(widget)
    end
    self.widget = widget
    self:emit_signal("widget::layout_changed")
end

--- Get the number of children element
-- @treturn table The children
function radialprogressbar:get_children()
    return {self.widget}
end

--- Replace the layout children
-- This layout only accept one children, all others will be ignored
-- @tparam table children A table composed of valid widgets
function radialprogressbar:set_children(children)
    self.widget = children and children[1]
    self:emit_signal("widget::layout_changed")
end

--- Reset this layout. The widget will be removed and the rotation reset.
function radialprogressbar:reset()
    self:set_widget(nil)
end

function radialprogressbar:set_width(w)
    self._width = w
    self:emit_signal("widget::redraw_needed")
end

for k,v in ipairs {"left", "right", "top", "bottom"} do
    radialprogressbar["set_"..v.."_padding"] = function(self, val)
        self._padding = self._padding or {}
        self._padding[v] = val
        self:emit_signal("widget::redraw_needed")
    end
end

function radialprogressbar:set_padding(val)
    self._padding = {
        left   = val,
        right  = val,
        top    = val,
        bottom = val,
    }
    self:emit_signal("widget::redraw_needed")
end

function radialprogressbar:set_value(val)
    if not val then self._percent = 0; return end

    if val > self._max_value then
        self:set_max_value(val)
    elseif val < self._min_value then
        self:set_min_value(val)
    end

    local delta = self._max_value - self._min_value

    self._percent = val/delta
    self:emit_signal("widget::redraw_needed")
end

--TODO max/min value

function radialprogressbar:set_max_value(val)
    self._max_value = val
    self:emit_signal("widget::redraw_needed")
end

function radialprogressbar:set_min_value(val)
    self._min_value = val
    self:emit_signal("widget::redraw_needed")
end

function radialprogressbar:set_outline_color(col)
    self._outline_color = color(col)
    self:emit_signal("widget::redraw_needed")
end

function radialprogressbar:set_color(col)
    self._color = color(col)
    self:emit_signal("widget::redraw_needed")
end

--- Returns a new radialprogressbar layout. A radialprogressbar layout radialprogressbars a given widget. Use
-- :set_widget() to set the widget and :set_direction() for the direction.
-- The default direction is "north" which doesn't change anything.
-- @param[opt] widget The widget to display.
-- @param[opt] dir The direction to radialprogressbar to.
local function new(widget, dir)
    local ret = base.make_widget()

    util.table.crush(ret, radialprogressbar)
    ret._max_value = 1
    ret._min_value = 0

    ret:set_widget(widget)

    return ret
end

function radialprogressbar.mt:__call(...)
    return new(...)
end

return setmetatable(radialprogressbar, radialprogressbar.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
-- kate: space-indent on; indent-width 4; replace-tabs on;
