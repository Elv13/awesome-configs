local wibox,type,tb = require("wibox"),type,require("awful.titlebar")
local fixed,base    = wibox.layout.fixed.horizontal,wibox.widget.base

local align_elem = {"set_first","set_second","set_third"},getmetatable(tb)

local function add_element(layout,element,offset)
    if not element then return end
    local f = layout.set_widget or layout.add or layout[align_elem[offset]]
    f(layout,element)
end

local function drill(content)
    if not content then return end
    local layout = type(content.layout) == "function" and  content.layout() or content.layout or fixed()
    local l = layout._signals and layout or layout()
    for k = 1, #content do
        local v = content[k] --Can't use ipairs() with sparse tables
        if v then
            add_element(l,v._signals and v or drill(v),k)
        end
    end
    return l
end

wibox.set_widgets,base.__make_widget,tb.____call = function(self,widgets)
    local f = self.set_widget or self.add or self.set_right
    f(self,drill(widgets))
end,base.make_widget,getmetatable(tb).__call

for k,v in ipairs {{base,"make_widget",base},{tb,"__call",getmetatable(tb)}} do
    v[3][v[2]] = function(...)
        local ret = v[1]["__"..v[2]](...)
        ret.set_widgets = wibox.set_widgets
        return ret
    end
end