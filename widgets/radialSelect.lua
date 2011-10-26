local setmetatable = setmetatable
local ipairs       = ipairs
local pairs        = pairs
local table        = table
local print        = print
local math         = math
local string       = string
local button       = require( "awful.button"        )
local beautiful    = require( "beautiful"           )
local naughty      = require( "naughty"             )
local wibox        = require( "awful.wibox"         )
local tag          = require( "awful.tag"           )
local util         = require( "awful.util"          )
local button       = require( "awful.button"        )
local layout       = require( "awful.widget.layout" )

local default = {width=90,height=30}

local capi = { image  = image  ,
               widget = widget ,
               client = client ,
               screen = screen }

module("widgets.radialSelect")

local margin  = nil
local to_hide = {}
local used    = {}
local color   = {}

local function reset()
    --top,right,bottom,left,counter
    margin  = {0,1,0,0,1}
    to_hide = {         }
end

local function gen_color(class)
    if not color[class] then
        color[class] = {}
        color[class].bg = "#"
        local nb = 0
        for i=1,3 do
            local tmp = math.random(0,15)
            nb = nb + tmp
            color[class].bg = color[class].bg..string.format("%X", tmp)..string.format("%X", math.random(0,15))
        end
        color[class].fg = (nb < 22) and "#000000" or "#FFFFFF" or ""
    end
    return color[class]
end

local function hide_everything()
    for k,v in pairs(to_hide) do
        v.visible=false
        table.insert(used,v)
    end
end

local function get_wibox()
    if #used > 0 then
        local tmp = used[#used]
        used[#used] = nil
        return tmp
    else
        return wibox({position="free"})
    end
end

function new(screen, args) 
  --Nothing to do
end

local function add_item(w,s)
    if math.ceil(margin[5]/2)%2 == 0 then margin[1+(margin[5]%2)] = margin[1+(margin[5]%2)]+1 end
    w.x = (capi.screen[1].geometry.width /2)+((margin[5]%2 == 0) and margin[1]*w.width  * ((-1)^(math.ceil(margin[5]/2)%2)) or 0)
    w.y = (capi.screen[1].geometry.height/2)+((margin[5]%2 == 1) and margin[2]*w.height * ((-1)^(math.ceil(margin[5]/2)%2)) or 0)
    margin[5] = margin[5]+1
end

function radial_client_select(args)
    --Settings
    local args = args or {}
    local screen = args.screen or capi.client.focus.screen
    local height = args.height or default.height
    local width  = args.widget or default.width
    
    local function create_wibox(text,c)
        local w    = get_wibox()
        local item = {}
        w.width    = width
        w.height   = height
        local tb   = capi.widget({type="textbox" })
        local ib   = capi.widget({type="imagebox"})
        ib.image   = c.icon
        w.widgets  = {ib,tb,layout=layout.horizontal.leftright}
        w.ontop    = true
        w.visible  = true
        table.insert(to_hide,w)
        w:buttons( util.table.join(
            button({ }, 1 , function() 
                                if c:tags()[1].selected == false then
                                    tag.viewonly(c:tags()[1])
                                end
                                capi.client.focus = c 
                            end),
            button({ }, 3 , function() hide_everything() end)
        ))
        function item:select()
            w.bg    = beautiful.bg_normal
            tb.text = text
        end

        function item:unselect()
            w.bg       = gen_color(c.class).bg
            tb.text    = "<span color='".. gen_color(c.class).fg .."'>"..text.."</span>"
        end
        w:add_signal("mouse::enter", function() item:select()   end)
        w:add_signal("mouse::leave", function() item:unselect() end)
        item:unselect()
        return w
    end
    
    --Data
    local seedC  = capi.client.focus or nil
    
    reset()
    
    for k,v in pairs(capi.client.get(screen)) do
        add_item(create_wibox(v.name,v),screen)
    end
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })