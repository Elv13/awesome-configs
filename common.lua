---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-rc3
---------------------------------------------------------------------------

-- Grab environment we need
local math         = math
local type         = type
local ipairs       = ipairs
local print        = print
local setmetatable = setmetatable
local themeUtils   = require("utils.theme")
local beautiful    = require( "beautiful"    )
local capi = { widget = widget, button = button,image = image }

--- Common widget code
module("common")

local offset = 0

function list_update(w, buttons, label, data, widgets, objects,args)
    args = args or {}
    local label_index,widget_count =1,2
    if args.have_index then
        label_index,widget_count = label_index +1,widget_count + 1
    end
    if args.have_arrow then
        label_index,widget_count = label_index +1,widget_count + 2
    end
    -- Hack: if it has been registered as a widget in a wibox,
    -- it's w.len since __len meta does not work on table until Lua 5.2.
    -- Otherwise it's standard #w.
    local len = (w.len or #w) / widget_count
    -- Add more widgets
    if len < #objects then
        for i = len * widget_count + 1, #objects * widget_count, widget_count do
            local ib = capi.widget({ type = "imagebox", align = widgets.imagebox.align })
            local tb = capi.widget({ type = "textbox", align = widgets.textbox.align })

            if args.have_index then
                local txt = capi.widget({ type = "textbox" })
                w[i + 1 + offset] = txt
            end
            if args.have_arrow then
                local arr = capi.widget({ type = "imagebox" , align = widgets.imagebox.align})
                w[i + ((widget_count < 5) and 1 or 2) + offset] = arr
                local arr2 = capi.widget({ type = "imagebox" , align = widgets.imagebox.align})
                w[i+label_index+1+offset] = arr2
            end
            w[i+offset] = ib
            w[i + label_index + offset] = tb
            tb:margin({ left = widgets.textbox.margin.left, right = widgets.textbox.margin.right })
            tb.bg_resize = widgets.textbox.bg_resize or false
            tb.bg_align = widgets.textbox.bg_align or ""

        end
    -- Remove widgets
    elseif len > #objects then
        for i = #objects * widget_count + 1, len * widget_count, widget_count do
            for l=0, widget_count-1,1 do
                w[i+l] = nil
            end
        end
    end

    -- update widgets text and image
    for k = 1, #objects * widget_count, widget_count do
        local o = objects[(k + (widget_count-1)) / widget_count]
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
            for l=0, widget_count-1,1 do
                w[k+l]:buttons(data[o])
            end
        end

        local text, bg, bg_image, icon, ib_bg, text_bg,idx = label(o)
        local tb2,bg_image_orig = w[k + label_index+offset]
        tb2.text, tb2.bg = text, text_bg or bg
        local tbg = type(bg_image)
        local bg_is_grad    = tbg == "table" and not bg_image.pattern
        local bg_is_pattern = tbg == "table" and bg_image.pattern
        local bg_is_image   = tbg == "image"
        if bg_is_grad then
            local tb_width =tb2:extents().width
            local img = capi.image.argb32(tb_width, 16, nil)
            img:draw_rectangle_gradient(0, 0, tb_width, 16, bg_image,0)
            bg_image_orig = bg_image
            bg_image = img
        elseif bg_is_pattern and args.have_arrow then
            local tb_width =tb2:extents().width
            local img = capi.image.argb32(tb_width, 16, nil)
            img:insert(bg_image.image)
            bg_image_orig = bg_image
            bg_image = img--bg_image.image
        elseif bg_is_image and args.have_arrow then
            local tb_width =tb2:extents().width
            local img = capi.image.argb32(tb_width, 16, nil)
            img:insert(bg_image)
            bg_image_orig = bg_image
            bg_image = img
        end
        tb2.bg_image = bg_image
        w[k+offset].bg, w[k+offset].image = ib_bg or bg, icon

        if args.have_arrow then
            w[k + ((widget_count < 5) and 1 or 2) + offset].image = themeUtils.get_beg_arrow(bg_image_orig or text_bg or bg,nil,3)
        end
        if args.have_index then
            w[k + 1 + offset].text = idx or "[?]"
            w[k + 1 + offset].width = w[k + 1 + offset]:extents().width
        end
        if args.have_arrow then
            if not w[k+label_index+1+offset+1] then
                w[k+label_index+1+offset].image = themeUtils.get_end_arrow(bg_image_orig or text_bg or bg,beautiful.bg_alternate,3)
            else
                w[k+label_index+1+offset].image = themeUtils.get_end_arrow(bg_image_orig or text_bg or text_bg or bg,nil,3)
            end
        end

        for l=0, widget_count-1,1 do
            w[k+l].visible = w[k + label_index+offset].text ~= nil
        end
        w[k+offset].visible = w[k+offset].image ~= nil
   end
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
