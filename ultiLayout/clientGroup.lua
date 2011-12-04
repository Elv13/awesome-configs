local setmetatable = setmetatable
local table = table
local pairs = pairs
local print = print
local debug = debug
local rawset = rawset
local ipairs = ipairs
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.clientGroup")


function new()
    local data              = {}
    local height = 0
    local width  = 0
    local x      = 0
    local y      = 0
    local layout            = nil
    local client_group_list = {}
    local client            = nil
    local parent            = nil
    local childs_cg         = {}
    
    

    function data:clients(list) --TODO That make no sense
        if list ~= nil then
            client_list = list
        end
        return client_list
    end

    function data:all_clients()
        local all_c = {}
        for k,v in pairs(client_list) do
            table.insert(all_c,v)
        end
        for k,v in pairs(childs()) do
            for k2,v2 in pairs(v:all_clients()) do
                table.insert(all_c,v2)
            end
        end
        return all_c
    end

    function data:geometry(new,relative)
        --math.flgoor math.ce...
        if new ~= nil then
            data.width = new.width
            data.height = new.height
            data.x = new.x
            data.y = new.y
        end
        return {width = data.width or 0, height = data.height or 0, x = data.x or 0, y = data.y or 0}
    end

    function data:add_client(c)
        
    end

    function data:set_layout(l)
        --TODO extract base cg from previous layout
        layout = l
        for k,v in ipairs(self:childs()) do
            l:add_child(v)
        end
        self:repaint()
    end

    function data:reparent(new_parent)
        if parent then
            parent:detach(self)
            parent = new_parent
            parent:attach(self)
        end
    end

    function data:detach(child)
        for k,v in pairs(childs_cg) do
            if v == child then
                childs_cg[k] = nil
            end
        end
        self:repaint()
    end
    
    function data:attach(cg)
        --self:add_signal("geometry::changed",function() cg:update() end)
        table.insert(childs_cg,cg)
        if layout then
            layout:add_child(cg)
        end
        self:repaint()
    end

    function data:get_parent()
        return parent
    end
    
    function data:gen_vertex(vertex_list)
        if layout then
            return layout:gen_vertex(vertex_list)
        else
            print("layout not set")
        end
    end

    function data:childs()
        return childs_cg
    end
    
    function data:repaint()
        if layout then
            layout:update()
        end
    end
    
    local signals = {}
    
    function data:add_signal(name,func)
        if not signals[name] then
            signals[name] = {}
        end
        table.insert(signals[name],func)
    end
    
    local function emit_signal(name,...)
        for k,v in pairs(signals[name] or {}) do
            v(data,...)
        end
    end
    
    --This will catch attemps to change geometry
    local function catchGeoChange(table, key,value)
        if key == "width" and value ~= width then
            local prevWidth = width
            width = value
            emit_signal("width::changed",value-prevWidth)
            emit_signal("geometry::changed")
        elseif key == "height" and value ~= height then
            local prevHeight = height
            height = value
            emit_signal("height::changed",value-prevHeight)
            emit_signal("geometry::changed")
        elseif key == "x" and value ~= x then
            print("setting x",data)
            local prevX = x
            x = value
            emit_signal("x::changed",data,value-prevX)
            emit_signal("geometry::changed")
        elseif key == "y" and value ~= y then
            local prevY = y
            y = value
            emit_signal("y::changed",data,value-prevY)
            emit_signal("geometry::changed")
        else
            rawset(data,key,value)
        end
    end
    
    --Emulate the geometry as part of data
    function return_data(table, key)
        if key == "width" then
            return width
        elseif key == "height" then
            return height
        elseif key == "x" then
            return x
        elseif key =="y" then
            return y
        else
            return data[key]
        end
    end
    setmetatable(data, { __index = return_data, __newindex = catchGeoChange, __len = function() return #data +4 end})
    return data
end


setmetatable(_M, { __call = function(_, ...) return new(...) end , __index = return_data, __newindex = catchGeoChange, __len = function() return #data +4 end})