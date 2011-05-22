-- This module monkey patch (http://en.wikipedia.org/wiki/Monkey_patch) awful to add features
-- @author Emmanuel Lepage Vallee <elv1313@gmail.com>

local awful = require("awful")

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

    attach(w, position)
    if has_to_stretch then
        stretch(w)
    else
        align(w, arg.align)
    end

    set_position(w, position)

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