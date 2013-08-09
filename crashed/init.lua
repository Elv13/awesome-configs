--------------------------------------------------------------------------
-- @author Emmanuel Lepage <elv1313@gmail.com>                          --
--                                                                      --
-- Port of my old "monkeypatch" module from Awesome 3.5                 --
-- As my config is more complex than Gnome 3, some additional           --
-- Optimizations are required to make it run fast enough                --
-- LGI also need proper caching support, so I have to bypass            --
-- it everytime I can.                                                  --
--                                                                      --
-- @warning Some of these changes are not fully compatible with         --
-- the "vanilla" Awesome 3.5 libraries                                  --
--                                                                      --
--------------------------------------------------------------------------

local gears = require("gears")
local type = type
local string = string
local print = print
local cairo =require( "lgi" ).cairo
local Pango =require( "lgi" ).Pango
local wibox = require("wibox")
local awful = require("awful")

-- Let it crash
function gears.object:add_signal(name)
    if not self._signals[name] then
        self._signals[name] = {}
    end
end

-- Skip the check, if it was really necessary, it would print an error anyway
function gears.object:connect_signal(name, func)
    self._signals[name][func] = func
end

-- Skip the check, if it was really necessary, it would print an error anyway
function gears.object:disconnect_signal(name, func)
    self._signals[name][func] = nil
end

-- Same as above
function gears.object:emit_signal(name, ...)
    local sig = self._signals[name] or {}
    for func in pairs(sig) do
        func(self, ...)
    end
end

-- Nil data can happen only once, so this avoid the hash call (it took 10% of the non-LGI calls)
local tags = {}
function awful.tag.getproperty(_tag, prop)
    local data = tags[_tag]
    if not data then
        data = awful.tag.getdata(_tag)
        if not data then return nil end
        tags[_tag] = data
    end
    return data[prop]
end

-- Cache the colors, calling LGI 100x per second is expensive
local color_cache = {}
gears.color.create_pattern = function(col)
    -- If it already is a cairo pattern, just leave it as that
    if cairo.Pattern:is_type_of(col) then
        return col
    end
    if type(col) == "string" then
        local cached = color_cache[col]
        if cached then
            return cached
        end
        local t = string.match(col, "[^:]+")
        if gears.color.types[t] then
            local pos = string.len(t)
            local arg = string.sub(col, pos + 2)
            local res = gears.color.types[t](arg)
            color_cache[col] = res
            return res
        else
            local res = gears.color.create_solid_pattern(col)
            color_cache[col] = res
            return res
        end
    elseif type(col) == "table" then
        local t = col.type
        if gears.color.types[t] then
            return gears.color.types[t](col)
        end
    end
    return gears.color.create_solid_pattern(col)
end

-- Cache fixed layout size
function wibox.layout.fixed:fit(orig_width, orig_height)
    if not self._has_cache then
        self._cache,self._cache2 = {},{}
        self._has_cache = true
        self:connect_signal("widget::updated",function()
            self._cache,self._cache2 = {},{}
        end)
    end
    local hash = orig_height*10000+orig_width
    if self._cache[hash] then
        return self._cache[hash],self._cache2[hash]
    end
    local width, height = orig_width, orig_height
    local used_in_dir, used_max = 0, 0

    for k, v in pairs(self.widgets) do
        local w, h = v:fit(width, height)
        local in_dir, max
        if self.dir == "y" then
            max, in_dir = w, h
            height = height - in_dir
        else
            in_dir, max = w, h
            width = width - in_dir
        end
        if max > used_max then
            used_max = max
        end
        used_in_dir = used_in_dir + in_dir

        if width <= 0 or height <= 0 then
            if self.dir == "y" then
                used_in_dir = orig_height
            else
                used_in_dir = orig_width
            end
            break
        end
    end

    if self.dir == "y" then
        return used_max, used_in_dir
    end
    self._cache[hash],self._cache2[hash] = used_in_dir,used_max
    return used_in_dir, used_max
end

-- Use fixed layout cache if available
function wibox.layout.align:draw(wibox2, cr, width, height)
    local size_first = 0
    local size_third = 0
    local size_limit = self.dir == "y" and height or width

    if self.first then
        local w, h, _ = width, height, nil
        if self.dir == "y" then
            if self.first.cache2 and self.first.cache2[h*10000+w] then
                h = self.first._cache2[h*10000+w]
            else
                _, h = self.first:fit(w, h)
            end
            size_first = h
        else
            if self.first._cache and self.first._cache[h*10000+w]  then
                w = self.first._cache[h*10000+w]
            else
                w, _ = self.first:fit(w, h)
            end
            size_first = w
        end
        wibox.layout.base.draw_widget(wibox2, cr, self.first, 0, 0, w, h)
    end

    if self.third and size_first < size_limit then
        local w, h, x, y, _
        if self.dir == "y" then
            w, h = width, height - size_first
            if self.third._cache  and self.third._cache2[h*10000+w] then
                h = self.third._cache2[h*10000+w]
            else
                _, h = self.third:fit(w, h)
            end
            x, y = 0, height - h
            size_third = h
        else
            w, h = width - size_first, height
            if self.third._cache  and self.third._cache[h*10000+w] then
                w = self.third._cache[h*10000+w]
            else
                w, _ = self.third:fit(w, h)
            end
            x, y = width - w, 0
            size_third = w
        end
        wibox.layout.base.draw_widget(wibox2, cr, self.third, x, y, w, h)
    end

    if self.second and size_first + size_third < size_limit then
        local x, y, w, h
        if self.dir == "y" then
            w, h = width, size_limit - size_first - size_third
            local real_w, real_h = self.second:fit(w, h)
            x, y = 0, size_first + h / 2 - real_h / 2
            h = real_h
        else
            w, h = size_limit - size_first - size_third, height
            local real_w, real_h = self.second:fit(w, h)
            x, y = size_first + w / 2 - real_w / 2, 0
            w = real_w
        end
        wibox.layout.base.draw_widget(wibox2, cr, self.second, x, y, w, h)
    end
end

-- Setup layout doesn't seem to be required
-- Add caching
function wibox.widget.textbox:fit(width, height)
    if not self.cache_fit then
        self.cache_fit,self.cache_fith = {},{}
        self.cached_text = self._layout.text
        self:connect_signal("widget::updated",function()
--             if self._layout.text ~= self.cached_text then
                self.cache_fit = {}
                self.cache_fith = {}
                self.cached_text = self._layout.text
--             end
        end)
    end
    local hash = width+10000*height
    if self.cache_fit[hash] then
        return self.cache_fit[hash],self.cache_fith[hash]
    end
    local layout = self._layout
    layout.width = Pango.units_from_double(width)
    layout.height = Pango.units_from_double(height)
    local ink, logical = self._layout:get_pixel_extents()

    if logical.width == 0 or logical.height == 0 then
        return 0, 0
    end
    self.cache_fit[hash],self.cache_fith[hash] =logical.width, logical.height
    
    return logical.width, logical.height
end

local function matt(cr)
    return cr:get_matrix()
end

local function dr(widget, wibox2, cr, width, height)
    local success, msg = pcall(widget.draw, widget, wibox2, cr, width, height)
    if not success then
        print("Error while drawing widget: " .. msg)
    end
end

-- Cache the x,y,width,height position of the widget
function wibox.layout.base.draw_widget(wibox2, cr, widget, x, y, width, height)
    -- Use save() / restore() so that our modifications aren't permanent
    cr:save()

    -- Move (0, 0) to the place where the widget should show up
    cr:translate(x, y)

    -- Make sure the widget cannot draw outside of the allowed area
    cr:rectangle(0, 0, width, height)
    cr:clip()

    -- Let the widget draw itself
    dr(widget, wibox2, cr, width, height)

    -- Register the widget for input handling
    if not widget.rect_cache then
        widget.rect_cache = {}
        widget:connect_signal("widget::updated",function()
            widget.rect_cache = {}
        end)
    end
    local mat  = matt(cr)
    local hash = (x+mat.x0)*17+1053*(y+mat.y0)+30050*width+707003*height*9999
    ca = widget.rect_cache[hash]
    if ca then
        wibox2:widget_at(widget,ca.x, ca.y, ca.width, ca.height)
    else
        local x2, y2, width2, height2 = wibox.layout.base.rect_to_device_geometry(cr, 0, 0, width, height)
        widget.rect_cache[hash] = {x=x2,y=y2,width=width2,height=height2}
        wibox2:widget_at(widget,x2, y2, width2, height2)
    end

    cr:restore()
end
-- wibox.layout.fixed._horizontal = wibox.layout.fixed.horizontal
-- function wibox.layout.fixed.horizontal()
--     local self = wibox.layout.fixed._horizontal()
--     if not self.notifychildcache then
--         self.notifychildcache = true
--         self:connect_signal("widget::updated",function()
--             for k, v in pairs(self.widgets) do
--                 if v.rect_cache then v.rect_cache ={} end
--             end
--         end)
--     end
--     return self
-- end
-- 
-- wibox.layout.fixed._vertical = wibox.layout.fixed.vertical
-- function wibox.layout.fixed.vertical()
--     local self = wibox.layout.fixed._vertical()
--     if not self.notifychildcache then
--         self.notifychildcache = true
--         self:connect_signal("widget::updated",function()
--             for k, v in pairs(self.widgets) do
--                 if v.rect_cache then v.rect_cache ={} end
--             end
--         end)
--     end
--     return self
-- end

-- Cannot work unless the widget_at code can be untangled from draw. It would be very nice

-- local base = wibox.layout.base
-- local count = 1
-- function wibox.layout.base.draw_widget(wibox, cr, widget, x, y, width, height)
--     print("here",count)
--     if not widget.cache then
--         widget.cache = {}
--         widget:connect_signal("widget::updated",function()
--             widget.cache = {}
--         end)
--     end
--     count = count +1
--     -- Use save() / restore() so that our modifications aren't permanent
--     cr:save()
-- 
--     -- Move (0, 0) to the place where the widget should show up
--     cr:translate(x, y)
--     local cached = widget.cache[width+10000*height]
--     if cached then
--         print("use cache")
--         cr:set_source_surface(cached)
--         cr:paint()
--         cr:restore()
--         return
--     end
-- 
--     -- Make sure the widget cannot draw outside of the allowed area
--     cr:rectangle(0, 0, width, height)
--     cr:clip()
-- 
--     -- Let the widget draw itself
--     local success, msg = pcall(widget.draw, widget, wibox, cr, width, height)
--     if not success then
--         print("Error while drawing widget: " .. msg)
--     end
-- 
--     -- Register the widget for input handling
--     wibox:widget_at(widget, base.rect_to_device_geometry(cr, 0, 0, width, height))
--     
--     local img  = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)--target:create_similar(target:get_content(),width,height) 
--     local cr2 = cairo.Context(img)
--     cr2:set_source_surface(cr:get_target(),-x,-y)
--     cr2:translate(x,y)
--     cr2:paint()
--     widget.cache[width+10000*height] = img
-- 
--     cr:restore()
-- end