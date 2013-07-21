--------------------------------------------------------------------------
-- @author Emmanuel Lepage <elv1313@gmail.com>                          --
--                                                                      --
-- Port of my old "monkeypatch" module from Awesome 3.5                 --
-- As my config is more complex than Gnome 3, some additional           --
-- Optimizations are required to make it run fast enough                --
-- LGI also need proper caching support, so I have to bypass            --
-- it everytime I can.                                                  --
--                                                                      --
-- @warning Some of these changes are not fully compatible with         --
-- the "vanilla" Awesome 3.5 libraries                                  --
--                                                                      --
--------------------------------------------------------------------------

local gears = require("gears")
local type = type
local string = string
local print = print
local cairo =require( "lgi" ).cairo


local color_cache = {}
gears.color.create_pattern = function(col)
    -- If it already is a cairo pattern, just leave it as that
    if cairo.Pattern:is_type_of(col) then
        return col
    end
    if type(col) == "string" then
        local cached = color_cache[col]
        if cached then
            return cached
        end
        local t = string.match(col, "[^:]+")
        if gears.color.types[t] then
            local pos = string.len(t)
            local arg = string.sub(col, pos + 2)
            local res = gears.color.types[t](arg)
            color_cache[col] = res
            return res
        else
            local res = gears.color.create_solid_pattern(col)
            color_cache[col] = res
            return res
        end
    elseif type(col) == "table" then
        local t = col.type
        if gears.color.types[t] then
            return gears.color.types[t](col)
        end
    end
    return gears.color.create_solid_pattern(col)
end
