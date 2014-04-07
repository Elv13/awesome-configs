local setmetatable = setmetatable
local print = print
local ipairs = ipairs
local button       = require( "awful.button" )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )
-- local shifty       = require( "shifty"       )
local beautiful    = require( "beautiful"    )
local utils        = require( "utils.tools"  )
local menu         = require( "radical.context" )
local tooltip2   = require( "radical.tooltip" )
local themeutils = require( "blind.common.drawing"    )
local color = require("gears.color")
local wibox = require("wibox")

local capi = { screen = screen ,
               mouse  = mouse  }

local module = {}


local data = {}
local screenMenu = nil

local function btn1(id,addOrSub)
    if data[id].selected ~= nil then
        local screen2 = tag.getscreen(data[id].selected) + addOrSub
        if screen2 > capi.screen.count() then
            screen2 = 1
        elseif screen2 == 0 then
            screen2 = capi.screen.count()
        end
        tag.setscreen(data[id].selected,screen2)
        tag.viewonly(data[id].selected)
        data[id].selected = tag.selected(screen)
    end
end
local function btn3(id,addOrSub)
        if not screenMenu then
        screenMenu = menu()
        for i=1,capi.screen.count() do
            screenMenu:add_item({text=i, button1 = function()
                local t = tag.selected(capi.mouse.screen)
                local screen2 = tag.getscreen(t) + addOrSub
                if screen2 > capi.screen.count() then
                    screen2 = 1
                elseif screen2 == 0 then
                    screen2 = capi.screen.count()
                end
                tag.setscreen(t,screen2)
                tag.viewonly(t)
                screenMenu.visible = not screenMenu.visible
            end})
        end
        end
        screenMenu.id = id
        screenMenu.visible = not screenMenu.visible
end
local function btn4(id,addOrSub)
    if data[id].selected ~= nil then
        local screen2 = tag.getscreen(data[id].selected) + addOrSub
        if screen2 > capi.screen.count() then
            screen2 = 1
        end
--         utils.tag_to_screen(data[id].selected, screen2)
        tag.setscreen(data[id].selected,screen2)
    end
end
local function btn5(id,addOrSub)
    if data[id].selected ~= nil then
        local screen2 = tag.getscreen(data[id].selected) - addOrSub
        if screen2 == 0 then
            screen2 = capi.screen.count()
        end
--         utils.tag_to_screen(data[id].selected, screen2)
        tag.setscreen(data[id].selected,screen2)
    end
end

--Screen the screen number
--args:
--     -direction (left or right) [REUQIRED]
--     -icon an icon [optional]
local function new(screen, args)
    local screen     = screen            or 1
    local direction  = args.direction    or "left"
    local icon       = args.icon         or nil
    local id         = screen..direction --
    local addOrSub   = 0                 --

    if direction == "left" then
      addOrSub = -1
    elseif direction == "right" then
      addOrSub =  1
    else
      return nil
    end

    data[id] = {}
    if icon ~= nil then
      data[id].widget       = wibox.widget.imagebox()
      tooltip2(data[id].widget ,"Move Tag Screen to the "..args.direction,{})
      if direction == "left" and screen == 1 then
        return data[id].widget
      elseif direction == "right" and screen == capi.screen.count() then
        return data[id].widget
      end
      data[id].widget.visible = false
      data[id].widget:set_image(color.apply_mask(icon))
    else
      data[id].widget       = wibox.widget.textbox()
      data[id].widget:set_text(direction)
    end
    data[id].widget.bg = beautiful.bg_alternate

    if direction == "left" and screen == 1 then
      data[id].widget.visible = false
    elseif direction == "right" and screen == capi.screen.count() then
      data[id].widget.visible = false
    else
      data[id].widget.visible = true
    end

    data[id].screen = screen
    data[id].direction = direction

    data[id].widget:connect_signal("mouse::enter", function ()
                                                  data[id].selected = tag.selected()
                                                  data[id].widget.bg = beautiful.bg_normal
                                                end)
    data[id].widget:connect_signal("mouse::leave", function ()
                                                  data[id].selected = nil
                                                  data[id].widget.bg = beautiful.bg_alternate
                                                end)

    data[id].widget:buttons( util.table.join(
      button({ }, 1, function() btn1(id,addOrSub) end),
      button({ }, 3, function() btn3(id,addOrSub) end),
      button({ }, 4, function() btn4(id,addOrSub) end),
      button({ }, 5, function() btn5(id,addOrSub) end)
    ))

    return data[id].widget
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
