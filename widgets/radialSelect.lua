local setmetatable = setmetatable
local ipairs       = ipairs
local pairs        = pairs
local table        = table
local print        = print
local math         = math
local string       = string
local unpack       = unpack
local type         = type
local button       = require( "awful.button"        )
local beautiful    = require( "beautiful"           )
local naughty      = require( "naughty"             )
local wibox        = require( "wibox"               )
local tag          = require( "awful.tag"           )
local util         = require( "awful.util"          )
local button       = require( "awful.button"        )
-- local layout       = require( "awful.widget.layout" )
local color        = require( "gears.color"      )
local cairo        = require( "lgi"              ).cairo

local default = {width=90,height=30,radius=40,base_radius=60}

local capi = { client       = client       ,
               screen       = screen       ,
               mouse        = mouse        ,
               mousegrabber = mousegrabber }

local module={}

local margin  = nil
local to_hide = {}
local used    = {}

-- local function reset()
--     --top,right,bottom,left,counter
--     margin  = {0,1,0,0,1}
--     to_hide = {         }
-- end

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

-- local function hide_everything()
--     for k,v in pairs(to_hide) do
--         v.visible=false
--         table.insert(used,v)
--     end
-- end

local function get_wibox()
    if #used > 0 then
        local tmp = used[#used]
        used[#used] = nil
        return tmp
    else
        return wibox({})
    end
end

local function new(screen, args)
  --Nothing to do
end

-- local function add_item(w,s)
--     if math.ceil(margin[5]/2)%2 == 0 then margin[1+(margin[5]%2)] = margin[1+(margin[5]%2)]+1 end
--     w.x = (capi.screen[1].geometry.width /2)+((margin[5]%2 == 0) and margin[1]*w.width  * ((-1)^(math.ceil(margin[5]/2)%2)) or 0)
--     w.y = (capi.screen[1].geometry.height/2)+((margin[5]%2 == 1) and margin[2]*w.height * ((-1)^(math.ceil(margin[5]/2)%2)) or 0)
--     margin[5] = margin[5]+1
-- end

-- local test_color = {color("#0C2625"),color("#69A09C"),color("#27837B"),color("#3F5D57"),color("#123937"),color("#030E10")}
-- local function warpPath(cr, func)
--     first = true
-- 
--     cr:text_path("pycairo - ")
-- --     print(cr:copy_path().num_data)
--     local path = cr:copy_path()
-- --     for type2, points in pairs(cr:copy_path()) do
--     for i=1,path.num_data do
--         if type2 == cairo.PATH_MOVE_TO then
--             if first then
--                 cr:new_path()
--                 first = false
--             end
--             x, y = func(points)
--             cr:move_to(x, y)
--         elseif type2 == cairo.PATH_LINE_TO then
--             x, y = func(points)
--             cr:line_to(x, y)
--         elseif type2 == cairo.PATH_CURVE_TO then
--             x1, y1, x2, y2, x3, y3 = points
--             x1, y1 = func(x1, y1)
--             x2, y2 = func(x2, y2)
--             x3, y3 = func(x3, y3)
--             cr:curve_to(x1, y1, x2, y2, x3, y3)
--         elseif type == cairo.PATH_CLOSE_PATH then
--             cr:close_path()
--         end
--     end
-- end

local function curl(x, y)
    xn = x - Textwidth/2
    yn = y - Textheight/2
    xnew = xn
    ynew = y + xn * 3 / ((Textwidth/2)*3) * 70
    return xnew + Width/2, ynew + Height*2/5
end

function module.radial_client_select(args)
    --Settings
    local args = args or {}
    local data = {width=400,height=400,layers={},compose={}}
    local screen = args.screen or capi.client.focus and capi.client.focus.screen or 1
    local height = args.height or default.height
    local width  = args.widget or default.width

    local function position_indicator_layer()
        if not data.indicator or data.angle_cache ~= data.angle then
            local angle,tan = data.angle or 0,data.tan or 0
            if not data.indicator then
                data.indicator = {}
                data.indicator.img = cairo.ImageSurface(cairo.Format.ARGB32, data.width, data.height)
                data.indicator.cr = cairo.Context(data.indicator.img)
            else
                data.indicator.cr:set_operator(cairo.Operator.CLEAR)
                data.indicator.cr:paint()
                data.indicator.cr:set_operator(cairo.Operator.SOURCE)
            end
            data.indicator.cr:set_source_rgb(1,0,0)
            data.indicator.cr:arc             ( data.width/2 + (default.base_radius-20)*math.cos(angle),data.width/2 + (default.base_radius-20)*math.sin(angle),5,0,2*math.pi  )
            data.indicator.cr:close_path()
            data.indicator.cr:fill()
            data.indicator.cr:set_line_width(4)
            data.indicator.cr:arc( data.width/2,data.height/2,default.radius + default.base_radius ,angle-0.15,angle+0.15  )
            data.indicator.cr:stroke()
            data.indicator.cr:arc             ( data.width/2+170,data.height/2,10,0,2*math.pi  )
            data.indicator.cr:close_path()
            data.indicator.cr:fill()
            data.angle_cache = data.angle
        end
        return data.indicator.img
    end

    local function create_inner_circle()
        if not data.inner then
            data.inner = {}
            data.inner.img = cairo.ImageSurface(cairo.Format.ARGB32, data.width, data.height)
            data.inner.cr = cairo.Context(data.inner.img)
            data.inner.cr:set_line_width(3)
            data.inner.cr:set_source_rgb(0.9,0.9,0.9)

            data.inner.cr:arc             ( data.width/2,data.height/2,default.base_radius,0,2*math.pi  )
            data.inner.cr:close_path()
            data.inner.cr:stroke()
            data.inner.cr:arc             ( data.width/2,data.height/2,default.base_radius-20,0,2*math.pi  )
            data.inner.cr:close_path()
            data.inner.cr:set_dash({10,4},1)
            data.inner.cr:stroke()
        end
        return data.inner.img
    end

    local function init_img(layer)
        local dat_layer = data.layers[layer]
        dat_layer.cr:new_path        (           )
        dat_layer.cr:set_source_rgba (0, 0, 0 ,0 )
        dat_layer.cr:paint()
    end

    local function clear_center(layer)
        local dat_layer = data.layers[layer]
        local rad = default.base_radius+(layer-1)*default.radius
        dat_layer.cr:set_operator(cairo.Operator.CLEAR)
        dat_layer.cr:set_source_rgba ( 0  , 0  , 0,1                             )
        dat_layer.cr:move_to         ( data.width/2, data.height/2               )
        dat_layer.cr:arc             (data.width/2,data.height/2,rad,0,2*math.pi )
        dat_layer.cr:fill            (                                           )
    end


    local function gen_arc(layer)
        data.layers[layer].position = (data.layers[layer].position or 0) + 1
        local position = data.layers[layer].position
        local dat_layer = data.layers[layer]
        local outer_radius = layer*default.radius + default.base_radius
        local inner_radius = outer_radius - default.radius
        local start_angle  = ((2*math.pi)/(4*layer))*(position-1)
        local end_angle    = ((2*math.pi)/(4*layer))*(position)
        dat_layer.cr:set_operator(cairo.Operator.SOURCE)
        if data.layers[layer].selected == position then
            dat_layer.cr:set_source  ( color(beautiful.fg_focus)         )
        else
--             print((5+(21-5)/(4*layer)*position)/256,(21+(119-21)/(4*layer)*position)/256,(53+(209-53)/(4*layer)*position)/256)
            dat_layer.cr:set_source_rgb((5+(21-5)/(4*layer)*position)/256,(10+(119-10)/(4*layer)*position)/256,(27+(209-27)/(4*layer)*position)/256)
        end
        dat_layer.cr:move_to         ( data.width/2, data.height/2                             )
        dat_layer.cr:arc             ( data.width/2,data.height/2,outer_radius,start_angle,end_angle   )
        dat_layer.cr:fill_preserve   (                                      )
        dat_layer.cr:set_source_rgb(90/256,51/256,83/256)
        dat_layer.cr:close_path()
        dat_layer.cr:stroke()
        clear_center(layer)
    end

    local function repaint_layer(idx,content)
        local lay = data.layers[idx]
        if not lay then
            data.layers[idx] = {}
            lay = data.layers[idx]
            lay.img = cairo.ImageSurface(cairo.Format.ARGB32, data.width, data.height)
            lay.cr = cairo.Context(lay.img)
            lay.cr:set_line_width(3)
            init_img(idx)
        end
        local real_rad = data.angle or 0
        if real_rad >= 0 then
            real_rad = math.pi*2 - real_rad
        else
            real_rad = -real_rad
        end
        local new_selected = (idx*4 or 1) - math.floor(((real_rad*(idx*4 or 1))/2*math.pi)/10)
--         print("New select:",new_selected,lay.selected,(new_selected ~= lay.selected),#(lay.content or {}))
        if content or (lay.content and new_selected ~= lay.selected) then
            lay.content = content or lay.content
            lay.cr:set_operator(cairo.Operator.CLEAR)
            lay.cr:paint()
            lay.position = 0
            lay.selected = new_selected
            for k,v in ipairs(lay.content) do
                gen_arc(idx,v)
            end
            lay.count = #lay.content
        end
        return lay.img
    end
    
    local function draw_text(cr,text, start_angle, end_angle, layer)
        local text = "1234567890123456789012345678901234567890123456789012345678901234567890"
        local img2 = cairo.ImageSurface(cairo.Format.ARGB32, 20, 20)
        local cr2 = cairo.Context(img2)
        local level =0
        local step = (2*math.pi)/(((math.pi*2*(default.base_radius +  default.radius*layer - 3 - level*12))/4)*0.65) --relation between arc and char width
        local testAngle = start_angle + 0.05
        cr2:select_font_face("monospace")
        for i=1,text:len() do
            cr2:set_operator(cairo.Operator.CLEAR)
            cr2:paint()
            cr2:set_operator(cairo.Operator.SOURCE)
            cr2:set_source_rgb(1,1,1)
            cr2:move_to(0,10)
            cr2:text_path(text:sub(i,i))
            cr2:fill()
            local matrix12 = cairo.Matrix()
            cairo.Matrix.init_rotate(matrix12, -testAngle )
            matrix12:translate(-data.width/2+(default.base_radius + default.radius*layer - 3 - level*12)*(math.sin( - testAngle)),-data.height/2+(default.base_radius +  default.radius*layer - 3 - level*12)*(math.cos( -testAngle)))
            local pattern = cairo.Pattern.create_for_surface(img2,20,20)
            pattern:set_matrix(matrix12)
            cr:set_source(pattern)
            cr:paint()
            testAngle=testAngle+step
            if testAngle+step > end_angle - 0.05 then
                testAngle = start_angle+0.05
                level = level +1
                if level > 2 then
                    break
                end
            end
        end
    end

    local function compose()
        if not data.compose.img then
            data.compose.img = cairo.ImageSurface(cairo.Format.ARGB32, data.width, data.height)
            data.compose.cr  = cairo.Context(data.compose.img)
        else
            data.compose.cr:set_operator(cairo.Operator.CLEAR)
            data.compose.cr:paint()
            data.compose.cr:set_operator(cairo.Operator.OVER)
        end
        local cr = data.compose.cr
        for i=#data.layers,1,-1 do
            cr:set_source_surface(repaint_layer(i),0,0)
            cr:paint()
        end
        cr:set_source_surface(create_inner_circle(),0,0)
        cr:paint()
        cr:set_source_surface(position_indicator_layer(),0,0)
        cr:paint()
        draw_text(cr,"",math.pi,3*(math.pi/2),1)
    end

    local function create_wibox(text,c,idx)
        local w    = get_wibox()
        w.ontop    = true
        w.visible  = true
        local item = {}
        w.width    = data.width-- width
        w.height   = data.height
--         local tb   = wibox.widget.textbox()
--         local ib   = wibox.widget.imagebox()
--         ib:set_image(c.icon)
--         w.widgets  = {ib,tb,layout=layout.horizontal.leftright}
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
            tb:set_text(text)
        end

        function item:unselect()
--             w.bg       = gen_color(c.class).bg
--             tb:set_text("<span color='".. gen_color(c.class).fg .."'>"..text.."</span>")
        end
--         w:add_signal("mouse::enter", function() item:select()   end)
--         w:add_signal("mouse::leave", function() item:unselect() end)
        item:unselect()

        return w
    end

    function data:set_layer(idx,content)
        if not data.w then
            data.w = create_wibox("test",v,i)
            data.w.x = capi.mouse.coords().x - data.width/2
            data.w.y = capi.mouse.coords().y - data.height/2
            data.ib = data.ib or wibox.widget.imagebox()
            data.w:set_widget(data.ib)
        end
        repaint_layer(idx,content)
    end

    --Data
    local seedC  = capi.client.focus or nil

    data:set_layer(1,{
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
    })

    data:set_layer(2,{
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
        {name="test",icon="",func =  function(menu,...)  end },
    })

    local focal = nil
    capi.mousegrabber.run(function(mouse)
        if not focal then
            focal = {x= mouse.x,y=mouse.y}
        end
        if mouse.buttons[3] == true then
            capi.mousegrabber.stop()
            focal = nil
            return false
        end
        local angle = math.atan2((mouse.y-focal.y),(mouse.x-focal.x))
--         print(angle)
        data.tan   = (mouse.y-focal.y)/(mouse.x-focal.x)
        data.angle = angle
        compose()

        data.ib:set_image(data.compose.img)
        data.w.shape_bounding = data.compose.img._native
        return true
    end,"fleur")

    return data
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })