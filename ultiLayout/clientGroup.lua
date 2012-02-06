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
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.clientGroup")


local client_to_cg          = {}


function new(parent)
    local data              = { swapable = false }
    local height            = 0
    local width             = 0
    local x                 = 0
    local y                 = 0
    local visible           = true
    local needRepaint       = false
    local layout            = nil
    --local client_group_list = {}
    local client            = nil
    local parent            = parent or nil
    local childs_cg         = {}
    local show_splitters    = false
    local title             = nil
    local floating          = false
    
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
        --client_to_cg[c] = self
        if not client_to_cg[c] then
            client_to_cg[c] = {}
        end
        table.insert(client_to_cg[c],self)
    end
    
    function get_cg_from_client(c)
        return client_to_cg[c]
    end

    function data:set_layout(l)
        if not l then
            print("No layout to be set")
        else
            layout = l
            for k,v in ipairs(self:childs()) do
                if not v.floating then
                    l:add_child(v)
                else
                    --TODO Is there something to do here? z-index?
                end
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
                table.remove(childs_cg,k)
                --childs_cg[k] = nil
            end
        end
        if parent ~= nil and #childs_cg == 0 then
            emit_signal("destroyed")
            parent:detach(self)
            self = nil
            return
        end
        self:repaint()
    end
    
    local function cg_to_idx(cg)
        for k,v in ipairs(childs_cg) do
            if v == cg then
                return k
            end
        end
        return nil
    end
    
    --It is not called swap because it only do half of the operation
    function data:replace(old_cg,new_cg)
        if old_cg:get_parent() ~= new_cg:get_parent() then
            for k,v in pairs(childs_cg) do
                if v == old_cg then
                    childs_cg[k] = new_cg
                    self:repaint()
                    return
                end
            end
        else --This avoid swaping CG back to original state if they are in the same parent CG
            local old_cg_idx, new_cg_idx = cg_to_idx(old_cg), cg_to_idx(new_cg)
            if old_cg_idx ~= nil and new_cg_idx ~= nil then
                childs_cg[ old_cg_idx ] = new_cg
                childs_cg[ new_cg_idx ] = old_cg
                emit_signal("cg::swapped",other_cg,old_parent)
                self:repaint()
            end
        end
    end
    
    function data:swap(new_cg)
        if parent ~= nil and new_cg:get_parent() ~= nil then
            local cur_parent   = parent
            local other_parent = new_cg:get_parent()
            if cur_parent ~= other_parent then
                parent:replace(self,new_cg)
                other_parent:replace(new_cg,self)
            else
                parent:replace(self,new_cg)
            end
            self:set_parent(other_parent,true,new_cg)
            new_cg:set_parent(cur_parent,true,self)
        end
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
        if cg:get_parent() == self then return end
        if cg:get_parent() ~= nil then
            cg:get_parent():detach(cg)
        end
        cg:set_parent(data)
        --self:add_signal("geometry::changed",function() print("test",debug.traceback());cg:repaint() end)
        if cg ~= self then
            cg:add_signal("geometry::changed",function() emit_signal("geometry::changed") end)
        end
        
        if layout and cg.floating == false then
            table.insert(childs_cg,layout:add_child(cg) or cg)
        else
            table.insert(childs_cg,cg)
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
    
    function data:set_parent(new_parent,emit_swapped,other_cg)
        if new_parent ~= parent then
            local old_parent = parent
            parent = new_parent
        end
        if emit_swapped == true then
            --print("\n\n\n\n\nHERE\n\n\n\n",self.title)
            emit_signal("cg::swapped",other_cg,old_parent)
        end
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
        for k,v in pairs(childs_cg) do
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
            emit_signal("visibility::changed",value)
        elseif key == "title" and value ~= title then
            title = value
        elseif key == "floating" and value ~= floating then
            floating = value
        elseif key ~= "width" and key ~= "height" and key ~= "y" and key ~= "x" and key ~= "visible" and key ~= "title" and key ~= "floating" then
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
        elseif key == "floating" then
            return floating
        else
            return rawget(table,key)
        end
    end
    setmetatable(data, { __index = return_data, __newindex = catchGeoChange, __len = function() return #data +4 end})
    return data
end


setmetatable(_M, { __call = function(_, ...) return new(...) end , __index = return_data, __newindex = catchGeoChange, __len = function() return #data +4 end})