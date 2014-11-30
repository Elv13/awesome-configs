-- Allow pango markup
-- Convert key to string
-- allow sections
-- quit on escape
-- never show again button
--round corner
-- beautiful support
-- fix all themes
local setmetatable = setmetatable
local awful        = require "awful"
local wibox        = require( "wibox"       )
local beautiful    = require( "beautiful"   )
local glib         = require( "lgi"         ).GLib
local cairo        = require( "lgi"         ).cairo
local color        = require( "gears.color" )
local capi         = {root=root,screen=screen}

local shorter = {__real = {}, __pretty={}}
local font = nil
local other_sections,other_text_sections = {},{}

local function limit_fit(l,w)
    l._fit = l.fit
    l.fit = function(self,w3,h3)
        local w2,h2 = l._fit(self,w3,h3)
        return w+15,h2
    end
end

local function draw_rounded(cr,x,y,w,h,radius)
    cr:save()
    cr:translate(x,y)
    cr:move_to(0,radius)
    cr:arc(radius,radius,radius,math.pi,3*(math.pi/2))
    cr:arc(w-radius,radius,radius,3*(math.pi/2),math.pi*2)
    cr:arc(w-radius,h-radius,radius,math.pi*2,math.pi/2)
    cr:arc(radius,h-radius,radius,math.pi/2,math.pi)
    cr:close_path()
    cr:restore()
end

local function create_wibox()
    local geo = capi.screen[1].geometry
    local w = wibox {x=geo.x + 50,y=geo.y+50,width=geo.width-100,height=geo.height-100}
    local left = geo.width-150
    w.visible = true
    w:set_fg(color(beautiful.shorter_fg or beautiful.fg_normal))

    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, geo.width, geo.height)
    local cr  = cairo.Context(img)
    cr:set_source_rgba(0,0,0,0)
    cr:paint()
    cr:set_source_rgb(1,1,1)
    draw_rounded(cr,0,0,geo.width-100,geo.height-100,15)
    cr:fill()
    w.shape_bounding = img._native

    local bg = cairo.ImageSurface.create(cairo.Format.ARGB32, geo.width, geo.height)
    local cr  = cairo.Context(bg)
    cr:set_source(color(beautiful.shorter_border_color or beautiful.border_color or beautiful.fg_normal))
    cr:paint()
    draw_rounded(cr,3,3,geo.width-100-6,geo.height-100-6,14)
    cr:set_source(color(beautiful.shorter_bg or beautiful.bg_normal))
    cr:fill()

    w:set_bg(cairo.Pattern.create_for_surface(bg))

    return w, left,geo.height
end

local function gen_group(gr)
    local cat_keys,cat_desc="",""
    for k,v in ipairs(gr) do
        cat_keys = cat_keys .. "\n" .. v.key
        cat_desc = cat_desc .. "\n -- " .. v.desc
    end
    return cat_keys,cat_desc
end

local function gen_group2(gr)
    local cat_keys,cat_desc="",""
    for k,v in pairs(gr) do
        cat_keys = cat_keys .. "\n" .. k
        cat_desc = cat_desc .. "\n -- " .. v
    end
    return cat_keys,cat_desc
end

local function gen_groups()
    local ret = {}
    for name,section in pairs(shorter.__pretty) do
        local cat_keys,cat_desc= gen_group(section)
        ret[name] = {cat_keys,cat_desc}
    end
    return ret
end

local function gen_group_label(name)
    local tb3 = wibox.widget.textbox("<tt>"..name:upper().."</tt>")
    tb3:set_align("center")
    tb3:set_valign("bottom")
    local hw,hh = tb3:fit(99999,99999)
    tb3.fit = function(self,w,h) return wibox.widget.textbox.fit(self,w,h),hh+20 end
    return tb3,hh
end

local function gen_groups_widget(name,content)
    local tb3,hh = gen_group_label(name)

    local tb1 = wibox.widget.textbox("<b>"..content[1].."</b>")
    local tb2 = wibox.widget.textbox("<i>"..content[2].."</i>")
    tb1:set_font(font)
    tb2:set_font(font)
    local l2 = wibox.layout.fixed.horizontal()
    l2:add(tb1)
    l2:add(tb2)

    local w1,h1 = tb1:fit(999999,999999)
    local w2,h2 = tb2:fit(999999,999999)
    local width = w1+w2+15

    local l = wibox.layout.fixed.vertical()
    l:add(tb3)
    l:add(l2)
    limit_fit(l,width)
    l.width = width
    l.height = math.max(h1,h2) + hh+20
    return l
end

local function gen_groups_widgets()
    -- Remove the bold if the theme use it
    if not font then
        font = (beautiful.font or ""):gsub("( [Dd]emi[Bb]old)",""):gsub("( [Bb]old)","")
    end
    local groups,ret = gen_groups(),{}
    for name,content in pairs(groups) do
        local l = gen_groups_widget(name,content)
        ret[#ret+1] = l
    end

    table.sort(ret, function(a,b) return a.width > b.width end)

    return ret
end

local function wrap_button(wdg)
    local bg = wibox.widget.background()
    bg:set_bg(color(beautiful.shorter_fg or beautiful.fg_normal))
    bg:set_fg(color(beautiful.shorter_bg or beautiful.bg_normal))
    bg:set_widget(wdg)
    return bg
end

local function create_header(w)
    local l = wibox.layout.align.horizontal()
    local close = wibox.widget.textbox("<tt> CLOSE [X] </tt>")
    close:buttons(awful.util.table.join(
        awful.button({ }, 1, function (c) w.visible = false end)
    ))
    l:set_right(wrap_button(close))

    local ll = wibox.layout.fixed.horizontal()
    ll:add(wrap_button(wibox.widget.textbox("<tt> SHORTCUTS </tt>")))
    ll:add(wibox.widget.textbox(" "))
    ll:add(wrap_button(wibox.widget.textbox("<tt> KEYBOARD </tt>")))
    l:set_left(ll)
    return l
end

local function get_best(cols,width,height,group)
    local best,dx = nil,99999
    for k,v in ipairs(cols) do
        local cw = v.width
        if cw > width and (width-cw) < dx and v.height + group.height < height - 100 then
            dx = width-cw
            best = v
        end
    end
    return best
end

local function show()
    local w,left,height = create_wibox()

    local margins = wibox.layout.margin()
    margins:set_top   (5)
    margins:set_bottom(20)
    margins:set_left  (20)
    margins:set_right (20)
    left,height = left-40,height-50

    local la = wibox.layout.fixed.vertical()

    local l = wibox.layout.fixed.horizontal()
    la:add(create_header(w))
    la:add(l)
    margins:set_widget(la)

    local cols = {}

    local groups = gen_groups_widgets()
    for _,group in ipairs(groups) do
        local width = group.width

        if left > width then
            table.insert(l.widgets, 1, group)
            group:connect_signal("widget::updated", l._emit_updated)
            l._emit_updated()
            cols[#cols+1] = group
        else
            local best = get_best(cols,width,height,group)
            if best then
                best:add(group)
                best.height = best.height + group.height
            end
        end

        left = left - width
    end

    for section,group in pairs(other_sections) do
        local r1,r2 = gen_group2(group)
        local wdg = gen_groups_widget(section,{r1,r2})
        local col = get_best(cols,wdg.width,height,wdg)
        col:add(wdg)
        col.height = col.height + wdg.height
    end

    for section,text in pairs(other_text_sections) do
        local lbl,hh = gen_group_label(section)
        local col = get_best(cols,150,height,{height=150})
        col:add(lbl)
        local tb = wibox.widget.textbox(text)
        tb:set_font(font)
        local w,h = tb:fit(col.width,99999)
        col.height = col.height + h + hh
        col:add(tb)
    end

    w:set_widget(margins)
end

glib.idle_add(glib.PRIORITY_HIGH_IDLE, function()
    local real = shorter.__real
    capi.root.keys(real)
    show()
end)

function shorter.toMarkDown()
    
end

function shorter.toManPage()
    
end

function shorter.print()
    
end

function shorter.register_section_widget(section,w)
    
end

function shorter.register_section(section,content)
    other_sections[section] = content
end

function shorter.register_section_text(section,text)
    other_text_sections[section] = text
end

return setmetatable(shorter,{__newindex=function(self,key,value)
    local name,section_desc=key,value.desc
    local real,pretty = self.__real,self.__pretty
    for k,v in ipairs(value) do
        local key,desc,fct,key_name = v.key,v.desc,v.fct,""
        for k2,v2 in ipairs(key[1]) do
            key_name=key_name..v2.."+"
        end

        key_name=key_name..key[2]
        local sec = pretty[name]
        if not sec then
            sec = {}
            pretty[name] = sec
        end
        sec[#sec+1] = {key=key_name,desc=desc}
        local awkey = awful.key(key[1],key[2],fct)

        -- Do as util.join, but avoid the N^2 complexity
        local index = #real
        for k2,v2 in ipairs(awkey) do
            real[index+k2] = v2
        end
    end
end})
