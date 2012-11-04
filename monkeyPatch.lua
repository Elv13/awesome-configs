-- This module monkey patch (http://en.wikipedia.org/wiki/Monkey_patch) awful to add features, improve performance
-- @author Emmanuel Lepage Vallee <elv1313@gmail.com>

local print = print
local ipairs = ipairs
local pairs = pairs
local type = type
local debug = debug
local rtable = table
local unpack = unpack
local awful = require("awful")
local capi = { screen = screen,
               mouse = mouse,
               key = key,
               widget = widget,
               client = client,
               awesome = awesome,
               wibox = wibox,
               button = button}
local wibox = require("awful.wibox")
local vertical2 = require("widgets.layout.vertical")
local awesome = require("awesome")

module("monkeyPatch")
awful.wibox.get_offset = function (position, wibox, screen)
  local offset = 0
  for _,wprop in ipairs(wiboxes)do
    if get_position(wprop.wibox) == position then
      if wprop.wibox.visible == true then
          if wprop.wibox ~= wibox then
            if wprop.wibox.screen == screen then
              offset = offset + wprop.wibox.height
            end
          end
      end
    end
  end
  return offset
end
awful.wibox.update_wiboxes_on_struts    = function () end
awful.wibox.update_all_wiboxes_position = function () end

awful.wibox.new = function (arg)
    local arg = arg or {}
    local position = arg.position or "top"
    local has_to_stretch = true
    -- Empty position and align in arg so we are passing deprecation warning
    arg.position = nil

    if position ~= "top" and position ~="bottom"
            and position ~= "left" and position ~= "right" and position ~= "free" then
        error("Invalid position in awful.wibox(), you may only use"
            .. " 'top', 'bottom', 'left' and 'right'")
    end

    -- Set default size
    if position == "left" or position == "right" then
        arg.width = arg.width or capi.awesome.font_height * 1.5
        if arg.height then
            has_to_stretch = false
            if arg.screen then
                --local hp = arg.height:match("(%d+)%%")
                if hp then
                    arg.height = capi.screen[arg.screen].geometry.height * hp / 100
                end
            end
        end
    else
        arg.height = arg.height or capi.awesome.font_height * 1.5
        if arg.width then
            has_to_stretch = false
            if arg.screen then
                local wp = arg.width:match("(%d+)%%")
                if wp then
                    --arg.width = 50 capi.screen[arg.screen].geometry.width * wp / 100
                end
            end
        end
    end

    local w = capi.wibox(arg)

    if position == "left" then
        w.orientation = "north"
    elseif position == "right" then
        w.orientation = "south"
    end

    w.screen = arg.screen or 1

    wibox.attach(w, position)
    if has_to_stretch then
        wibox.stretch(w)
    else
        wibox.align(w, arg.align)
    end

    wibox.set_position(w, position)

    return w
end

awful.wibox.wibox_update_strut = function (wibox)
    for _, wprop in ipairs(wiboxes) do
        if wprop.wibox == wibox then
            if not wibox.visible then
                wibox:struts { left = 0, right = 0, bottom = 0, top = 0 }
            elseif wprop.position == "top" then
                wibox:struts { left = 0, right = 0, bottom = 0, top = get_offset(wprop.position, nil, wprop.wibox.screen) }
            elseif wprop.position == "bottom" then
                wibox:struts { left = 0, right = 0, bottom = get_offset(wprop.position, nil, wprop.wibox.screen), top = 0 }
            elseif wprop.position == "left" then
                wibox:struts { left = get_offset(wprop.position,nil,wprop.wibox.screen), right = 0, bottom = 0, top = 0 }
            elseif wprop.position == "right" then
                wibox:struts { left = 0, right = get_offset(wprop.position, nil,wprop.wibox.screen), bottom = 0, top = 0 }
            end
            break
        end
    end
end

awful.widget.graph.properties = { "width", "height", "border_color", "offset",
                     "gradient_colors", "gradient_angle", "color",
                     "background_color", "max_value", "scale" }


awful.widget.graph.update = function (graph)
    -- Create new empty image
    local img = capi.image.argb32(data[graph].width, data[graph].height, nil)

    local border_width = 0
    if data[graph].border_color then
        border_width = 1
        
        if data[graph].offset then
            border_width = border_width + data[graph].offset
        end
    end

    local values = data[graph].values
    local max_value = data[graph].max_value

    if data[graph].scale then
        for _, v in ipairs(values) do
            if v > max_value then
                max_value = v
            end
        end
    end

    -- Draw background
    -- Draw full gradient
    if data[graph].gradient_colors then
        img:draw_rectangle_gradient(border_width, border_width,
                                    data[graph].width - (2 * border_width),
                                    data[graph].height - (2 * border_width),
                                    data[graph].gradient_colors,
                                    data[graph].gradient_angle or 270)
    else
        img:draw_rectangle(border_width, border_width,
                           data[graph].width - (2 * border_width),
                           data[graph].height - (2 * border_width),
                           true, data[graph].color or "red")
    end

    -- No value? Draw nothing.
    if #values ~= 0 then
        -- Draw reverse
        for i = 0, #values - 1 do
            local value = values[#values - i]
            if value >= 0 then
                value = value / max_value
                img:draw_line(data[graph].width - border_width - i - 1,
                              border_width + ((data[graph].height - 2 * border_width) * (1 - value)),
                              data[graph].width - border_width - i - 1,
                              border_width,
                              data[graph].background_color or "#000000aa")
            end
        end
    end

    -- If we did not draw values everywhere, draw a square over the last left
    -- part to set everything to 0 :-)
    if #values < data[graph].width - (2 * border_width) then
        img:draw_rectangle(border_width, border_width,
                           data[graph].width - (2 * border_width) - #values,
                           data[graph].height - (2 * border_width),
                           true, data[graph].background_color or "#000000aa")
    end

    -- Draw the border last so that it overlaps other stuff
    if data[graph].border_color then
        -- Draw border
        img:draw_rectangle(0, 0, data[graph].width, data[graph].height,
                           false, data[graph].border_color or "white")
    end

    -- Update the image
    graph.widget.image = img
end


--Elv13 (2012) rewrite for better performance http://trac.caspring.org/wiki/LuaPerformance #12 #10 #11
awful.util.table.join = function (...)
--     print(debug.traceback())
    local ret,count,param = {},1,{...}
    for i=1, #param do
        for k, v in pairs(param[i] or {}) do
            ret[count] = v
            count = count + 1
        end
    end
    return ret
end

--Elv13 (2012) do not use join to append, it is awfully expensive expodential operation
awful.util.table.append = function(t,t2)
    local cache,cache2 = #t,#t2
    for i=1,cache2 do
        t[cache+i] = t2[i]
    end
end

--Elv13 (2012) do not call table.join, avoid computing static value over and over
local ignore_modifiers = { "Lock", "Mod2" }
local subsets2 = awful.util.subsets(ignore_modifiers)
awful.button.new = function (mod, button, press, release)
    local ret = {}
    for i=1, 4 do
        local ss,cache = subsets2[i],#mod
        for j=1,#ss do
            mod[cache+j] = ss[j]
        end
        ret[#ret + 1] = capi.button({ modifiers = mod, button = button })
        if press then
            ret[#ret]:add_signal("press", function(bobj, ...) press(...) end)
        end
        if release then
            ret[#ret]:add_signal("release", function (bobj, ...) release(...) end)
        end
    end
    return ret
end

--Elv13 (2012) same as button
awful.key.new = function(mod, key, press, release)
    local ret = {}
    for i=1, 4 do
        local ss,cache = subsets2[i],#mod
        for j=1,#ss do
            mod[cache+j] = ss[j]
        end
        ret[#ret + 1] = capi.key({ modifiers = mod, key = key })
        if press then
            ret[#ret]:add_signal("press", function(kobj, ...) press(...) end)
        end
        if release then
            ret[#ret]:add_signal("release", function(kobj, ...) release(...) end)
        end
    end
    return ret
end

--Elv13 (2012) little differnces, but worth it
awful.key.match = function(key, pressed_mod, pressed_key)
    -- First, compare key.
    if pressed_key ~= key.key or #pressed_mod ~= #mod then return false end
    -- Then, compare mod
    local mod = key.modifiers
    -- For each modifier of the key object, check that the modifier has been
    -- pressed.
    for _, m in ipairs(mod) do
        -- Has it been pressed?
        if not util.table.hasitem(pressed_mod, m) then
            -- No, so this is failure!
            return false
        end
    end
    return true
end


awful.widget.layout.vertical.topbottom = vertical2.topbottom
awful.widget.layout.vertical.bottomtop = vertical2.bottomtop
