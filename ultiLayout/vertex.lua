local capi = { image        = image        ,
               widget       = widget       ,
               mouse        = mouse        ,
               screen       = screen       ,
               root         = root         ,
               client       = client       ,
               mousegrabber = mousegrabber }

local setmetatable = setmetatable
local table        = table
local type         = type
local ipairs       = ipairs
local print        = print
local math         = math
local rawset       = rawset
local rawget       = rawget
local pairs        = pairs
local debug        = debug
local button       = require( "awful.button"           )
local beautiful    = require( "beautiful"              )
local wibox        = require( "awful.wibox"            )
local tag          = require( "awful.tag"              )
local clientGroup  = require( "ultiLayout.clientGroup" )
local util         = require( "awful.util"             )
local client       = require( "awful.client"           )

module("ultiLayout.vertex")
local auto_display_border = true


--BEGIN vertex
local function update_wibox(vertex)
    if vertex.wibox ~= nil then
        vertex.wibox.x = vertex.x
        vertex.wibox.y = vertex.y
        if vertex.orientation == "vertical" then
            vertex.wibox.width  = 3
            print(vertex.length)
            vertex.wibox.height = vertex.length
        else
            print(vertex.length)
            vertex.wibox.width  = vertex.length
            vertex.wibox.height = 3
        end
    end
end

local function resize(vertex,axe,length,mouse)
    local d = mouse[axe] - (vertex.cg1[length]+vertex.cg1[axe])
    if vertex.cg1 then
        vertex.cg1[ length ] = vertex.cg1[ length ] + d
        vertex.cg1:repaint()
    end
    if vertex.cg2 then
        vertex.cg2[ length ] = vertex.cg2[ length ] - d
        vertex.cg2[ axe    ] = vertex.cg2[ axe    ] + d
        vertex.cg2:repaint()
    end
--                 w[axe] = mouse[axe]
end

local function create_border(vertex)
    local w = wibox({position = "free"})
    w.ontop = true
    w.bg = "#ff0000"
    w:buttons(util.table.join(
        button({ }, 1 ,function (tab)
            capi.mousegrabber.run(function(mouse)
                if mouse.buttons[1] == false then
                    return false
                end
                if vertex.orientation == "horizontal" then
                    --resize(vertex,"y","height",mouse)
                    vertex.y = mouse.y
                else --Handle any other value, even if vertical should be the only one
                    --resize(vertex,"x","width",mouse)
                    vertex.x = mouse.x
                end
                update_wibox(vertex)
                return true
            end,"fleur")
    end)))
    
    w:add_signal("mouse::enter", function ()
        --capi.root.cursor("left_ptr")
        --if v.orientation == "vertical" then
        --    capi.root.cursor("sb_h_double_arrow") --double_arrow
        --else
        --    capi.root.cursor("sb_v_double_arrow")
        --end
        
        w.bg = "#00ffff"
    end)

    w:add_signal("mouse::leave", function ()
        --capi.root.cursor("left_ptr")
        w.bg = "#ff00ff"
    end)
    vertex.wibox = w
    --update_wibox(vertex)
    return w
end

function create_vertex(args)
    local data            = {}
    local attached_cg     = {}
    data.orientation      = args.orientation or "horizontal"
    local private_data    = {}
    private_data.x        = args.x           or 0
    private_data.y        = args.y           or 0
    private_data.length   = args.length      or 2
    private_data.wibox    = args.wibox       or nil
    data.cg1              = args.cg1         or nil
    data.cg2              = args.cg2         or nil
    
    function data:attach(cg)
        table.insert(attached_cg,cg)
    end
    
    function data:attached() return attached_cg end
        
    local signals = {}
    
    function data:add_signal(name,func)
        if not signals[name] then
            signals[name] = {}
        end
        table.insert(signals[name],func)
    end
    
    function data:remove_signal(name,func)
        for k,v in pairs(signals[name] or {}) do
            if v == func then
                signals[name][k] = nil
                return true
            end
        end
        return false
    end
    
    function data:raw_set(args)
        private_data = {x = args.x or private_data.x, y= args.y or private_data.y, length = args.length or private_data.length, wibox = args.wibox or private_data.wibox}
    end
    
    local function emit_signal(name,...)
        for k,v in pairs(signals[name] or {}) do
            v(data,...)
        end
    end
    
    function return_data(table, key)
        if key == "x" then
            return private_data.x
        elseif key == "y" then
            return private_data.y
        elseif key == "length" then
            if private_data.length < 2 then
                return 2
            end
            return private_data.length
        elseif key == "wibox" then
            return private_data.wibox
        else
            return rawget(table,key)
        end
    end
    
    local function catchGeoChange(table, key,value)
        print("In geo change",key,value)
        if key == "x" and value ~= private_data.x then
            local delta = value - private_data.x
            private_data.x = value
            print("sdfsdfsdf")
            emit_signal("x::changed",delta)
            emit_signal("changed")
            if data.orientation == "vertical" then
                emit_signal("distance::changed",delta)
            end
        elseif key == "y" and value ~= private_data.y then
            print("cvbcvbcbcvb")
            local delta = value - private_data.y
            private_data.y = value
            emit_signal("y::changed",delta)
            emit_signal("changed")
            if data.orientation == "horizontal" then
                emit_signal("distance::changed",delta)
            end
        elseif key == "length" and value ~= private_data.length then
            print("456456456")
            if type(value) == "number" and value >= 1 then
                private_data.length = value
            else
                print("Invalid height")
                private_data.length = 2
            end
            --emit_signal("length::changed") --TODO needed?
            emit_signal("changed")
        elseif key == "wibox" and value ~= private_data.wibox then
            private_data.wibox = value
        elseif key ~= "x" and key ~= "y" and key ~= "length" and key ~= "wibox" then
            rawset(data,key,value)
        end
    end
    data:add_signal("changed",update_wibox)
    setmetatable(data, { __index = return_data, __newindex = catchGeoChange, __len = function() return #data + #private_data end})
    
    if private_data.wibox == nil and auto_display_border == true then
        create_border(data)
    end
    return data
end
--END vertex
setmetatable(_M, { __call = function(_, ...) return create_vertex(...) end })