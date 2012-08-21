---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-rc3
---------------------------------------------------------------------------

-- Grab environment we need
local math = math
local type = type
local ipairs = ipairs
local setmetatable = setmetatable
local capi = { widget = widget, button = button,image = image }

--- Common widget code
module("common")

-- Private structures
tagwidgets = setmetatable({}, { __mode = 'k' })

local wNb = 2
local img = capi.image.argb32(9, 16, nil)
  img:draw_rectangle(0, 0, 9, 16, true, "#1577D3")
  for i=0,(8) do
    img:draw_rectangle(0,i, i, 1, true, "#0A1535")
    img:draw_rectangle(0,16- i,i, 1, true, "#0A1535")
  end

local right_arrow_normal = nil
local function get_right_arrow_normal()
    if not right_arrow_normal then
        right_arrow_normal = capi.widget({ type = "imagebox" })
        right_arrow_normal.image = img
    end
    return right_arrow_normal
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

            w[i] = ib
            w[i + 1] = tb
            --w[i + 1]:margin({ left = widgets.textbox.margin.left, right = widgets.textbox.margin.right })
            w[i + 1].bg_resize = widgets.textbox.bg_resize or false
            w[i + 1].bg_align = widgets.textbox.bg_align or ""
            if wNb >= 3 then
                w[i+2] = get_right_arrow_normal()
            end

            if type(objects[math.floor(i / wNb) + 1]) == "tag" then
                tagwidgets[ib] = objects[math.floor(i / wNb) + 1]
                tagwidgets[tb] = objects[math.floor(i / wNb) + 1]
            end
        end
    -- Remove widgets
    elseif len > #objects then
        for i = #objects * wNb + 1, len * wNb, wNb do
            w[i] = nil
            w[i + 1] = nil
            if wNb >=3 then
                w[i + 2] = nil
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
            w[k]:buttons(data[o])
            w[k + 1]:buttons(data[o])
        end

        local text, bg, bg_image, icon, ib_bg, text_bg = label(o)
        w[k + 1].text, w[k + 1].bg, w[k + 1].bg_image = text, text_bg or bg, bg_image
        w[k].bg, w[k].image = ib_bg or bg, icon
        if not w[k + 1].text then
            w[k+1].visible = false
        else
            w[k+1].visible = true
        end
        if not w[k].image then
            w[k].visible = false
        else
            w[k].visible = true
        end
   end
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
