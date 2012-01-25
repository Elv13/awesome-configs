local setmetatable = setmetatable
local table = table
local pairs = pairs
local print = print
local debug = debug
local rawset = rawset
local rawget = rawget
local ipairs = ipairs
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.clientGroup")


function new(parent)
    local data              = {}
    local height  = 0
    local width   = 0
    local x       = 0
    local y       = 0
    local visible = true
    local needRepaint = false
    local layout            = nil
    local client_group_list = {}
    local client            = nil
    local parent            = parent or nil
    local childs_cg         = {}
    local show_splitters    = false
    local title             = nil
    
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
    
--     function data:clients(list) --TODO That make no sense
--         if list ~= nil then
--             client_list = list
--         end
--         return client_list
--     end
    
    function data:childs()
        return childs_cg
    end

    function data:all_clients()
        if client ~= nil then
            return {client}
        end
        
        local all_c = {}
        for k,v in pairs(self:childs()) do
            for k2,v2 in pairs(v:all_clients()) do
                table.insert(all_c,v2)
            end
        end
        return all_c
    end

    function data:geometry(new,relative)
        --math.flgoor math.ce...
        if new ~= nil then
            width = new.width
            height = new.height
            x = new.x
            y = new.y
        end
        return {width = width or 0, height = height or 0, x = x or 0, y = y or 0}
    end

    function data:set_client(c)
        client = c
    end

    function data:set_layout(l)
        if not l then
            print("No layout to be set")
        else
            layout = l
            for k,v in ipairs(self:childs()) do
                l:add_child(v)
            end
            self:repaint()
        end
    end

--     function data:reparent(new_parent)
--         if parent --[[and needRepaint == true]] then
--             parent:detach(self)
--             parent = new_parent
--             parent:attach(self)
--         end
--         needRepaint = false
--     end

    function data:detach(child)
        for k,v in pairs(childs_cg) do
            if v == child then
                childs_cg[k] = nil
            end
        end
        if parent ~= nil and #childs_cg == 0 then
            parent:detach(self)
            self = nil
            return
        end
        self:repaint()
    end
    
    function data:show_splitters(horizontal,vertical)
        if layout and layout.show_splitters ~= nil then
            layout:show_splitters(show_splitters,horizontal,vertical)
        end
    end
    
    function data:toggle_splitters(horizontal,vertical)
        if layout and layout.show_splitters ~= nil then
            show_splitters = not show_splitters
            self:show_splitters(show_splitters,horizontal,vertical)
        end
    end
    
    function data:attach(cg)
        print("here",self)
        if cg:get_parent() == self then return end
        if cg:get_parent() ~= nil then
            cg:get_parent():detach(cg)
        end
        cg:set_parent(data)
        --self:add_signal("geometry::changed",function() print("test",debug.traceback());cg:repaint() end)
        if cg ~= self then
            cg:add_signal("geometry::changed",function() emit_signal("geometry::changed") end)
        end
        
        if layout then
            table.insert(childs_cg,layout:add_child(cg) or cg)
            print("Now host",#childs_cg,self,childs_cg)
        else
            table.insert(childs_cg,cg)
            print("Now host",#childs_cg,self,childs_cg)
        end
        --table.insert(childs_cg,cg)
        emit_signal("client::attached")
        self:repaint()
    end
    
    function data:raise()
        --TODO
    end
    
    function data:set_active(sub_cg)
        for k,v in pairs(childs_cg) do
            if v == sub_cg and  layout and layout.set_active then
                layout:set_active(sub_cg)
                return
            end
        end
        print("Child client group not found")
    end

    function data:get_parent()
        return parent
    end
    
    function data:set_parent(new_parent)
        parent = new_parent
    end
    
    function data:gen_vertex(vertex_list)
        if layout then
            return layout:gen_vertex(vertex_list)
        else
            print("layout not set")
        end
    end
    
    function data:repaint()
        --print("Repainting",self,layout)
        if layout then
            layout:update()
        end
    end
    
    local function change_visibility(value)
        print("In change_visibility",#childs_cg,data,childs_cg)
        for k,v in pairs(childs_cg) do
            print("In for")
            v.visible = value
        end
        visible = value
    end
    
    local function get_title()
        if title then
            return title
        else
            local allC = data:all_clients()
            if #allC == 1 then
                return allC[1].name
            else
                return #allC.." clients"
            end
        end
    end
    
    --This will catch attemps to change geometry
    local function catchGeoChange(table, key,value)
        if key == "width" and value ~= width then
            local prevWidth = width
            width = value
            needRepaint = true
            emit_signal("width::changed",value-prevWidth)
            emit_signal("geometry::changed")
        elseif key == "height" and value ~= height then
            local prevHeight = height
            height = value
            needRepaint = true
            emit_signal("height::changed",value-prevHeight)
            emit_signal("geometry::changed")
        elseif key == "x" and value ~= x then
            local prevX = x
            x = value
            needRepaint = true
            emit_signal("x::changed",value-prevX)
            emit_signal("geometry::changed")
        elseif key == "y" and value ~= y then
            local prevY = y
            y = value
            needRepaint = true
            emit_signal("y::changed",value-prevY)
            emit_signal("geometry::changed")
        elseif key == "visible" --[[and value ~= visible]] then
            change_visibility(value)
            needRepaint = true
            print("Changing visibility")
            emit_signal("visibility::changed",value)
        elseif key == "title" and value ~= title then
            title = value
        elseif key ~= "width" and key ~= "height" and key ~= "y" and key ~= "x" and key ~= "visible" and key ~= "title" then
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
        elseif key == "visible" then
            return visible
        elseif key == "title" then
            return get_title()
        else
            return rawget(table,key)
        end
    end
    setmetatable(data, { __index = return_data, __newindex = catchGeoChange, __len = function() return #data +4 end})
    return data
end


setmetatable(_M, { __call = function(_, ...) return new(...) end , __index = return_data, __newindex = catchGeoChange, __len = function() return #data +4 end})