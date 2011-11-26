local setmetatable = setmetatable
local table = table
local pairs = pairs
local print = print
local debug = debug
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
    local data              = {width=0,height=0,x=0,y=0}
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
    
    local width_changed = {}
    local height_changed = {}
    local x_changed = {}
    local y_changed = {}
    
    function data:add_signal(name,func)
    
    end
    
    function data:height2(val)
        if val ~= nil then
            height = val
        end
        return height
    end
    
    function data:width2(val)
        if val ~= nil then
            width = val
        end
        return width
    end
    
    function data:x2(val)
        if val ~= nil then
            x = val
        end
        return x
    end
    
    function data:y2(val)
        if val ~= nil then
            y = val
        end
        return y
    end
    
    return data
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })