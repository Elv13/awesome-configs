---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-rc3
---------------------------------------------------------------------------

-- Grab environment we need
local math = math
local type = type
local ipairs = ipairs
local print = print
local setmetatable = setmetatable
local capi = { widget = widget, button = button,image = image }

--- Common widget code
module("common")

local wNb = 2
local offset = 0
local tbIdx = 1

local function get_end_arrow(bg_color)
    local img = capi.image.argb32(9, 16, nil)
    img:draw_rectangle(0, 0, 9, 16, true, "#1577D3")
    for i=0,(8) do
        img:draw_rectangle(0,i, i, 1, true, bg_color)
        img:draw_rectangle(0,16- i,i, 1, true, bg_color)
    end
    return img
end

local function get_beg_arrow(bg_color)
    local img = capi.image.argb32(9, 16, nil)
    img:draw_rectangle(0, 0, 9, 16, true, bg_color)
    for i=0,(8) do
        img:draw_rectangle(0,i, i, 1, true, "#1577D3")
        img:draw_rectangle(0,16- i,i, 1, true, "#1577D3")
    end
    return img
end

function list_update(w, buttons, label, data, widgets, objects)
    -- Hack: if it has been registered as a widget in a wibox,
    -- it's w.len since __len meta does not work on table until Lua 5.2.
    -- Otherwise it's standard #w.
    local len = (w.len or #w) / wNb
    -- Add more widgets
    if len < #objects then
        for i = len * wNb + 1, #objects * wNb, wNb do
            local ib = capi.widget({ type = "imagebox", align = widgets.imagebox.align })
            local tb = capi.widget({ type = "textbox", align = widgets.textbox.align })

            w[i+offset] = ib
            if wNb >= 4 then
                local arr = capi.widget({ type = "imagebox" })
                w[i + 1 + offset] = arr
                tbIdx = 2
            end
            w[i + tbIdx + offset] = tb
            if wNb >= 3 then
                local arr = capi.widget({ type = "imagebox"})
                w[i+tbIdx+1+offset] = arr
            end
        end
    -- Remove widgets
    elseif len > #objects then
        for i = #objects * wNb + 1, len * wNb, wNb do
            w[i+offset] = nil --ib
            w[i + tbIdx+offset] = nil --tb
            if wNb >=3 then
                w[i + tbIdx+1+offset] = nil -->
            end
            if wNb >=4 then
                w[i+offset+1] = nil -->
            end
        end
    end

    -- update widgets text
    for k = 1, #objects * wNb, wNb do
        local o = objects[(k + (wNb-1)) / wNb]
        if buttons then
            if not data[o] then
                data[o] = { }
                for kb, b in ipairs(buttons) do
                    -- Create a proxy button object: it will receive the real
                    -- press and release events, and will propagate them the the
                    -- button object the user provided, but with the object as
                    -- argument.
                    local btn = capi.button { modifiers = b.modifiers, button = b.button }
                    btn:add_signal("press", function () b:emit_signal("press", o) end)
                    btn:add_signal("release", function () b:emit_signal("release", o) end)
                    data[o][#data[o] + 1] = btn
                end
            end
            for l=0, wNb-1,1 do
                w[k+l]:buttons(data[o])
            end
        end

        local text, bg, bg_image, icon, ib_bg, text_bg = label(o)
        w[k + tbIdx+offset].text, w[k + tbIdx+offset].bg, w[k + tbIdx+offset].bg_image = text, text_bg or bg, bg_image
        w[k+offset].bg, w[k+offset].image = ib_bg or bg, icon

        if wNb >= 4 then
            w[k + 1 + offset].image = get_beg_arrow(text_bg or bg  or "#0A1535")
        end
        if wNb >= 3 then
            w[k+tbIdx+1+offset].image = get_end_arrow(text_bg or bg or "#0A1535")
        end

        w[k+tbIdx+offset].visible = w[k + tbIdx+offset].text ~= nil
        w[k+offset].visible       = w[k+offset].image ~= nil
        if wNb >= 4 then
            w[k + 1 + offset].visible = w[k + tbIdx+offset].text ~= nil
        end
        if wNb >= 3 then
            w[k+tbIdx+1+offset].visible = w[k + tbIdx+offset].text ~= nil
        end
   end
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
