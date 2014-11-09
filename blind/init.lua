local setmetatable      = setmetatable
local pairs,ipairs,type = pairs,ipairs,type
local beautiful = require("beautiful")

local theme = {}

local function create_group(self,tab)
    tab.__blind = true
    return tab
end

local function new_idx(table,key,value)
    local t,p = type(value),(table.__name and table.__name.."_" or "") .. key
    if t ~= "table" or not value.__blind then
        rawset(theme,p,value)
    else
        for k,v in pairs(value) do
            new_idx({__name = p,__fl = table.__name == p},k,v)
        end
    end
end

return setmetatable({common = require("blind.common"),__name=false,theme=setmetatable(theme,{__newindex=new_idx})},{__newindex = new_idx, __call = create_group})