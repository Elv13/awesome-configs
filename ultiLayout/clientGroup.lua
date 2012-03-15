local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local print        = print
local ipairs       = ipairs
local object_model = require( "ultiLayout.object_model" )

module("ultiLayout.clientGroup")

local client_to_cg          = {}

function new(parent)
    local data              = { swapable = false }
    local layout            = nil
    local focus             = false
    local client            = nil
    local parent            = parent or nil
    local childs_cg         = {}
    local show_splitters    = false
    local title             = nil
    local private_data = {
        floating = false,
        height   = 0    ,
        width    = 0    ,
        x        = 0    ,
        y        = 0    ,
        visible  = true,
    }
    
    function data:childs()
        return childs_cg
    end
    
    function data:visible_childs()
        local to_return = {}
        for k,v in pairs(self:childs()) do
            if v.visible == true and (#v:visible_childs() > 0 or client ~= nil) then
                table.insert(to_return,v)
            end
        end
        return to_return
    end
    
    function data:all_childs()
        local to_return = {}
        for k,v in pairs(self:childs()) do
            local child_childs = v:all_childs()
            for k2,v2 in pairs(child_childs) do
                table.insert(to_return,v2)
            end
            table.insert(to_return,v)
        end
        return to_return
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
    
    function data:has_client(c)
        if not c then
            return (client ~= nil) and true or false
        end
        local clients = data:all_clients()
        for k,v in pairs(clients) do
            if v == c then
                return true
            end
        end
        return false
    end

    function data:geometry(new,relative)
        if new ~= nil then
            for k,v in ipairs({"x","y","width","height"}) do
                data[v] = new[v] or 0
            end
        end
        return {width = private_data.width or 0, height = private_data.height or 0, x = private_data.x or 0, y = private_data.y or 0}
    end

    function data:set_client(c)
        client = c
        client_to_cg[c] = client_to_cg[c] or {}
        table.insert(client_to_cg[c],self)
    end
    
    function data:has_indirect_parent(cg)
        local current_depth = data
        while current_depth ~= nil do
            if current_depth == cg then return true end
            current_depth = current_depth.parent
        end
        return false
    end
    
    function get_cg_from_client(c,parent)
        --TODO find a way to check  if it is check of parent
        if not parent then
            return client_to_cg[c]
        else
            for k,v in pairs(client_to_cg[c]) do
                if data:has_indirect_parent(parent) == true then
                    return v
                end
            end
        end
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
    
    function data:get_layout()
        return layout
    end

    function data:detach(child)
        for k,v in pairs(childs_cg) do
            if v == child then
                table.remove(childs_cg,k)
            end
        end
        if parent ~= nil and #childs_cg == 0 then
            data:emit_signal("destroyed")
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
        if old_cg.parent ~= new_cg.parent then
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
                data:emit_signal("cg::swapped",other_cg,old_parent)
                self:repaint()
            end
        end
    end
    
    function data:swap(new_cg)
        if parent ~= nil and new_cg.parent ~= nil then
            local cur_parent   = parent
            local other_parent = new_cg.parent
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
        --Check if the CG is not already a child of self
        for k,v in pairs(data:all_childs()) do
            if v == cg then
                print("Trying to add a clientgroup that is already a child of self")
                return 
            end
        end
        if cg.parent == self or cg == self then return end
        if cg.parent ~= nil then
            cg.parent:detach(cg)
        end
        cg:set_parent(data)
        --self:add_signal("geometry::changed",function() print("test",debug.traceback());cg:repaint() end)
        if cg ~= self then --TODO dead code?
            cg:add_signal("geometry::changed",function() data:emit_signal("geometry::changed") end)
        end
        
        if layout and cg.floating == false then
            cg = layout:add_child(cg)
            if cg then
                table.insert(childs_cg,cg)
            end
        else
            table.insert(childs_cg,cg)
        end
        --table.insert(childs_cg,cg)
        data:emit_signal("client::attached")
        self:repaint()
        return cg
    end
    
    function data:raise()
        --TODO
    end
    
    function data:set_active(sub_cg)
        for k,v in pairs(childs_cg) do
            if v == sub_cg and  layout and layout.set_active then
                layout:set_active(sub_cg)
                sub_cg.focus = true
                return
            end
        end
        print("Child client group not found")
    end
    
    function data:set_parent(new_parent,emit_swapped,other_cg)
        if new_parent ~= parent then
            local old_parent = parent
            parent = new_parent
            if old_parent ~= nil then
                old_parent:emit_signal("detached",data)
            end
        end
        if emit_swapped == true then
            data:emit_signal("cg::swapped",other_cg,old_parent)
        end
    end
    
    function data:gen_edge(edge_list)
        if layout then
            return layout:gen_edge(edge_list)
        else
            print("layout not set")
        end
    end
    
    function data:repaint()
        if layout then
            layout:update()
        end
    end
    
    local function change_visibility(value)
        for k,v in pairs(childs_cg) do
            v.visible = value
        end
        private_data.visible = value
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
    
    local function set_focus(value)
        if value == focus then return end
        focus = value
        if parent ~= nil then
            parent.focus = value
        end
        data:emit_signal("focus::changed",value)
    end
    
    local function change_geo(var,new_value)
        if new_value < 0 then return end --It can be normal, but avoid it anyway
        local prev = private_data[var]
        private_data[var] = new_value
        data:emit_signal(var.."::changed",new_value-prev)
        data:emit_signal("geometry::changed")
    end
    
    local set_map = {
        floating = function(value) private_data.floating = value end,
        parent   = function(value) data:set_parent(value) end,
        visible  = function(value) change_visibility(value); data:emit_signal("visibility::changed",value) end,
        title    = function(value) title = value; data:emit_signal("title::changed",value) end,
        focus    = set_focus,
    }
    for k,v in pairs({"height", "width","y","x"}) do
        set_map[v] =  function (value) change_geo(v,value) end
    end
    
    local get_map = {
        parent = function() return parent end,
        title  = function() return get_title() end,
        focus  = function() return focus end,
    }
    
    object_model(data,get_map,set_map,private_data,{always_handle = {visible = true},autogen_getmap = true})
    return data
end

setmetatable(_M, { __call = function(_, ...) return new(...) end , __index = return_data, __newindex = catchGeoChange, __len = function() return #data +4 end})