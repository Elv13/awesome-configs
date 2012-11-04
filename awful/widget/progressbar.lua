---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release v3.4-rc3
---------------------------------------------------------------------------

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local capi = { image = image,
               widget = widget }
local layout = require("awful.widget.layout")

--- A progressbar widget.
module("awful.widget.progressbar")

local data = setmetatable({}, { __mode = "k" })

--- Set the progressbar border color.
-- If the value is nil, no border will be drawn.
-- @name set_border_color
-- @class function
-- @param progressbar The progressbar.
-- @param color The border color to set.

--- Set the progressbar foreground color as a gradient.
-- @name set_gradient_colors
-- @class function
-- @param progressbar The progressbar.
-- @param gradient_colors A table with gradients colors. The distance between each color
-- can also be specified. Example: { "red", "blue" } or { "red", "green",
-- "blue", blue = 10 } to specify blue distance from other colors.

--- Set the progressbar foreground color.
-- @name set_color
-- @class function
-- @param progressbar The progressbar.
-- @param color The progressbar color.

--- Set the progressbar background color.
-- @name set_background_color
-- @class function
-- @param progressbar The progressbar.
-- @param color The progressbar background color.

--- Set the progressbar to draw vertically. Default is false.
-- @name set_vertical
-- @class function
-- @param progressbar The progressbar.
-- @param vertical A boolean value.

--- Set the progressbar to draw with offset from the border.
-- @name set_offset
-- @class function
-- @param progressbar The progressbar.
-- @param value The value.


local properties = { "width", "height", "offset", "border_color",
                     "gradient_colors", "color", "background_color",
                     "vertical", "value", "margin" }

local function update(pbar)
    local width = data[pbar].width or 100
    local height  = data[pbar].height or 20
    local value = data[pbar].value
    if data[pbar].prev_value == value then return end
    data[pbar].prev_value = value

    if data[pbar].width < 5 or data[pbar].height < 2 then return end
    
    local bg_color = data[pbar].background_color or "red"
    

    -- Create new empty image
    local img = capi.image.argb32(width, height, nil)
    img:draw_rectangle(0, 0,width,height,true,bg_color)

    local over_drawn_width = width
    local over_drawn_height = height
    local border_width = 0
    if data[pbar].border_color then
        -- Draw border
        img:draw_rectangle(0, 0 + (data[pbar].margin_top or 0), width, height- ((data[pbar].margin_top or 0)+(data[pbar].margin_bottom or 0)), false, data[pbar].border_color)
        over_drawn_width = width - 2 -- remove 2 for borders
        over_drawn_height = height - 2 -- remove 2 for borders
        border_width = 1
	
        if data[pbar].offset then
            border_width = border_width + data[pbar].offset
            over_drawn_width = over_drawn_width - (data[pbar].offset * 2)
            over_drawn_height = over_drawn_height - (data[pbar].offset * 2)
        end
	
    end

    local angle = 270
    if data[pbar].vertical then
        angle = 180
    end

    -- Draw full gradient
    if data[pbar].gradient_colors then
        img:draw_rectangle_gradient(border_width, border_width + (data[pbar].margin_top or 0),
                                    over_drawn_width, over_drawn_height - ((data[pbar].margin_bottom or 0)+(data[pbar].margin_top or 0)),
                                    data[pbar].gradient_colors, angle)
    elseif data[pbar].bg_image then
        local img2 = data[pbar].bg_image
        local img4 = img2:crop(0,0,over_drawn_width,over_drawn_height)
        img:insert(img4,border_width, border_width + (data[pbar].margin_top or 0))
    else
        img:draw_rectangle(border_width, border_width + (data[pbar].margin_top or 0),
                           over_drawn_width, over_drawn_height - ((data[pbar].margin_bottom or 0)+(data[pbar].margin_top or 0)),
                           true, data[pbar].color or "red")
    end

    -- Cover the part that is not set with a rectangle
    if data[pbar].vertical then
        local rel_height = math.floor(over_drawn_height * (1 - value))
        img:draw_rectangle(border_width,
                           border_width,
                           over_drawn_width,
                           rel_height,
                           true, bg_color or "#000000aa")
    else
        local rel_x = math.floor(over_drawn_width * value)
        img:draw_rectangle(border_width + rel_x,
                           border_width + (data[pbar].margin_top or 0),
                           over_drawn_width - rel_x,
                           over_drawn_height - ((data[pbar].margin_bottom or 0)+(data[pbar].margin_top or 0)),
                           true, bg_color or "#000000aa")
    end

    -- Update the image
    pbar.widget.image = img
end

-- Set the progressbar value.
-- @param pbar The progress bar.
-- @param value The progress bar value between 0 and 1.
function set_value(pbar, value)
    local value = value or 0
    data[pbar].value = math.min(1, math.max(0, value))
    update(pbar)
    return pbar
end

--- Set the progressbar height.
-- @param progressbar The progressbar.
-- @param height The height to set.
function set_height(progressbar, height)
    if height >= 5 then
        data[progressbar].height = height
        update(progressbar)
    end
    return progressbar
end

--- Set the progressbar width.
-- @param progressbar The progressbar.
-- @param width The width to set.
function set_width(progressbar, width)
    if width >= 5 then
        data[progressbar].width = width
        update(progressbar)
    end
    return progressbar
end

--- Set the progressbar width.
-- @param progressbar The progressbar.
-- @param width The width to set.
function get_width(progressbar)
    if data[progressbar] then
       return data[progressbar].width or 0
    end
    return 0
end

--- Set the progressbar width.
-- @param progressbar The progressbar.
-- @param width The width to set.
function set_offset(progressbar, offset)
    --if width >= 5 then
        data[progressbar].offset = offset
        update(progressbar)
    --end
    return progressbar
end

--- Set the progressbar width.
-- @param progressbar The progressbar.
-- @param width The width to set.
function set_margin(progressbar, margin)
    --if width >= 5 then
        data[progressbar].margin_top = margin["top"]
	data[progressbar].margin_bottom = margin["bottom"]
	data[progressbar].margin_left = margin["left"]
	data[progressbar].margin_right = margin["right"]
        update(progressbar)
    --end
    return progressbar
end
-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(pbar, value)
            data[pbar][prop] = value
            update(pbar)
            return pbar
        end
    end
end

--- Create a progressbar widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set progressbar geometry.
-- @return A progressbar widget.
function new(args)
    local args = args or {}
    local width = args.width or 100
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    args.type = "imagebox"

    local pbar = {}

    pbar.widget = capi.widget(args)
    pbar.widget.resize = false

    data[pbar] = { width = width, height = height, value = 0 }

    -- Set methods
    for _, prop in ipairs(properties) do
        pbar["set_" .. prop] = _M["set_" .. prop]
    end

    function pbar:set_bg_image(img)
        data[pbar].bg_image = img
    end

    pbar.layout = args.layout or layout.horizontal.leftright

    return pbar
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
