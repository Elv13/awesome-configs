local setmetatable = setmetatable
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local naughty = require("naughty")
local tag = require("awful.tag")
local util = require("awful.util")
local capi = { image = image,
               widget = widget}

local data = {}
local module = {}

local function update()

end

function module.helper() 
    if #widgets > 0 then
        local timer_fade = capi.timer { timeout = 0.0333 } --30fps
        timer_fade:add_signal("timeout", function () 
            for k, w in ipairs(widgets) do
                if (w.opacity < 100 and w.opacity ~= nil) then
                local newTitle = string.gsub(title, "\n", " - ")
                local newText = string.gsub(text, "\n", " - ")
                w.widget.text = string.format('<span rise="%s" font_desc="%s"><b>%s</b>%s</span>', 0-(w.opacity*100), font, newTitle, newText)
                w.opacity = w.opacity + 3
                elseif timer_fade then
                w.widget.text = ""
                timer_fade:stop()
                timer_fade = nil
                end
            end
            end)
        timer_fade:start()
    end
end

local function new(screen, args) 
  local desktopPix       = capi.widget({ type = "imagebox", align = "left" })
  desktopPix.image = capi.image(util.getdir("config") .. "/theme/darkBlue/Icon/tags/desk2.png")
  
  desktopPix:buttons( util.table.join(
    button({ }, 1, function()
      tag.viewnone()
    end)
  ))
  
  desktopPix:add_signal("mouse::enter", function() desktopPix.bg = beautiful.bg_highlight end)
  desktopPix:add_signal("mouse::leave", function() desktopPix.bg = beautiful.bg_normal end)
  
  return desktopPix
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
