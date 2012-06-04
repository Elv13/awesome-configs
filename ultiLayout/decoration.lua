local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local print        = print
local type         = type
local ipairs       = ipairs
local object_model = require( "ultiLayout.object_model" )

module("ultiLayout.decoration")

local function add_decoration(list,cg,wb, args)--{class, position, index, ontop, absolute}
    if not wb then return end
    local deco = args or {}
    deco.position = args.position or "top"
    deco.ontop = args.ontop or false
    deco.align = args.align or "ajust"
    deco.update_callback = args.update_callback or nil
    local wb = (type(wb) == "function") and wb(cg) or wb
    deco.wibox = wb
    return deco
end

local function string_to_pos(cg,string)
    if string == "top" then
        return cg.y
    elseif string == "bottom" then
        return cg.y+cg.height
    elseif string == "left" then
        return cg.x
    elseif string == "right" then
        return cg.x+cg.width
    end
end

local function string_to_center(cg,string,length)
    if string == "top" or string == "bottom" then
        return (cg.width/2) - (length/2)
    elseif string == "left" or string == "right" then
        return (cg.height/2) - (length/2)
    end
end

-- local function update_decorations(list)
--     for k,v in pairs(list) do
--         print("updating class",k)    if type(position) == "function" then
--         for k2,v2 in ipairs(v) do
--             local x,y,w,h
--                 x,y,w,h = position(cg)
--                 w,h = w or wb.width,h or wb.height
--             elseif type(position) == "string" then
--                  then
--                 
--                 local arr = {
--                     bottom = {x = cg.x,y=cg.y+cg.height-v2.wibox.height},
--                     left,
--                     right,
--                     topleft,
--                     topright,
--                     bottomleft,
--                     bottomright,
--                     lefttop,
--                     righttop,
--                     leftbottom,
--                     rightbottom
--                 }
--                 
--             elseif type(position) == "array" then
--                 
--             end
--         end
--     end
-- end
local s2xy = {
    top    = "x",
    bottom = "x",
    left   = "y",
    right  = "y"
}

local s2xy_inv = {
    top    = "y",
    bottom = "y",
    left   = "x",
    right  = "x"
}
    
local s2hw = {
    top    = "width"  ,
    bottom = "width"  ,
    left   = "height" ,
    right  = "height"
}

local s2hw_inv = {
    top    = "height"  ,
    bottom = "height"  ,
    left   = "width" ,
    right  = "width"
}
    
local side_align = {
    ajust     = function(deco,cg) return cg[s2xy[deco.position]]                                                   end,
    center    = function(deco,cg) return cg[s2xy[deco.position]] + (cg[s2hw[deco.position]]/2) - (deco.wibox[s2hw[deco.position]]/2) end,
    beginning = function(deco,cg) return cg[s2xy[deco.position]]                                                   end,
    ["end"]   = function(deco,cg) return cg[s2xy[deco.position]] + cg[s2hw[deco.position]] - wb[s2hw[deco.position]]                 end,
}

local function ajust_pos(deco,cg) 
    local ret = {}
    --print("Align",deco.align,side_align[deco.align])
    ret[s2xy[deco.position]]     = side_align[deco.align](deco,cg)
    ret[s2hw[deco.position]]     = (deco.align == "ajust") and cg[s2hw[deco.position]] or deco.wibox[s2hw[deco.position]]
    ret[s2hw_inv[deco.position]] = (deco.align == "ajust") and deco.wibox[s2hw_inv[deco.position]] or cg[s2hw[deco.position]]
    ret[s2xy_inv[deco.position]] = cg[s2xy_inv[deco.position]]
    return ret
end

function decoration(cg)
    if not cg then return end
    local data = {}
    local decolist = {}
    
    local get_map = { }
    local set_map = { }
    object_model(data,get_map,set_map,private_data,{
        autogen_getmap      = false ,
        autogen_signals     = false ,
        auto_signal_changed = false ,
        other_get_callback  = function(name) return decolist[name] end
    })
    
    --local args = args or {}
    function data:add_decoration(wb,args)
        local deco = add_decoration(decolist,cg,wb,args)
        --print("\n\nPOS",deco.position,"WIB",deco.wibox)
        local class = args.class or "other"
        decolist[class] = decolist[class] or {}
        table.insert(decolist[class],deco)
        return deco
    end
    
    function data:remove_decoration(list_or_class,w)
        if type(list_or_class) == "string" then
            if decolist[list_or_class] ~= nil then
                for k,v in ipairs(decolist[list_or_class]) do
                    if v.wibox then
                        v.wibox.visible = false
                    end
                    decolist[list_or_class][v] = nil
                end
            end
        else
            for k,v in pairs(list) do
                for k2,v2 in ipairs(v) do
                    if v2.wibox == w then
                        table.remove(v,v2)
                        if #v == 0 then
                            list[k] = nil
                        end
                    end
                end
            end
        end
    end
    
    local padding = {}

    local ajust_workarea = {
        top    = function(wb,wa) return { x= wa.x           , y= wa.y+wb.height , width = wa.width          , height = wa.height - wb.height } end,
        bottom = function(wb,wa) return { x= wa.x           , y= wa.y           , width = wa.width          , height = wa.height - wb.height } end,
        left   = function(wb,wa) return { x= wa.x+wb.width  , y= wa.y           , width = wa.width-wb.width , height = wa.height                    } end,
        right  = function(wb,wa) return { x= wa.x           , y= wa.y           , width = wa.width-wb.width , height = wa.height                    } end,
    }
        

    function data:update()
        local workarea = {width = cg.width, height = cg.height, x = cg.x, y = cg.y}
        for k,v in pairs(decolist) do
            for k2,v2 in ipairs(v) do
                if v2.wibox then
                    local geo = ajust_pos(v2,workarea)
                    for k3,v3 in ipairs({"width","height","x","y"}) do
                        if not ((v3 == "width" or v3 == "height") and geo[v3] == 0) then
                            v2.wibox[v3] = geo[v3] or 2
                        end
                    end
                    if type(v2.update_callback) == "function" then
                        v2.update_callback()
                    end
                end
                if not v2.ontop then
                    workarea = ajust_workarea[v2.position](v2.wibox,workarea)
                end
            end
        end
        return workarea
    end
    
    function data:work_area()
        
    end
    
    return data
end
--function