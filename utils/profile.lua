-- Source: https://github.com/Elv13/awesome-configs/awesome3.4/utils/profile.lua

local io = io
local debug = debug
local tostring = tostring
local table = table
local assert = assert
local ipairs = ipairs
local pairs = pairs
local type = type

local module = {}

--[[

Copyright 2007 Jan Kneschke (jan@kneschke.de)

Licensed under the same license as Lua 5.1

$ lua lua-callgrind.lua <lua-script> [outputfile]

--]]
function module.start()
    callstack = { }
    instr_count = 0
    last_line_instr_count = 0
    current_file = nil
    tracefile = io.open("/tmp/awesome_profile___send_to_elv1313_at_gmail_com___.debug", "w+")
    tracefile:write("events: Instructions\n")

    mainfunc = nil

    function getfuncname(f)
            return ("%s"):format(tostring(f.func))
    end

    functions = { }
    methods = { }
    method_id = 1
    call_indent = 0
end

local function trace(class)
    -- print("calling tracer: "..class)
    if class == "count" then
            instr_count = instr_count + 1
    elseif class == "line" then
            -- check if we know this function already
            local f = debug.getinfo(2, "lSf")

            if not functions[f.func] then
                    functions[f.func] = {
                            meta = f,
                            lines = { }
                    }
            end
            local lines = functions[f.func].lines
            lines[#lines + 1] =("%d %d"):format(f.currentline, instr_count - last_line_instr_count)
            functions[f.func].last_line = f.currentline

            if not mainfunc then mainfunc = f.func end

            last_line_instr_count = instr_count 
    elseif class == "call" then
            -- add the function info to the stack
            --
            local f = debug.getinfo(2, "lSfn")
            callstack[#callstack + 1] = {
                    short_src   = f.short_src,
                    func        = f.func,
                    linedefined = f.linedefined,
                    name        = f.name,
                    instr_count = instr_count
            }

            if not functions[f.func] then
                    functions[f.func] = {
                            meta = f,
                            lines = { }
                    }
            end

            if not functions[f.func].meta.name then
                    functions[f.func].meta.name = f.name
            end

            -- is this method already known ?
            if f.name then
                    methods[tostring(f.func)] = { name = f.name }
            end

            -- print((" "):rep(call_indent)..">>"..tostring(f.func).." (".. tostring(f.name)..")")
            call_indent = call_indent + 1
    elseif class == "return" then
            if #callstack > 0 then
                    -- pop the function from the stack and
                    -- add the instr-count to the its caller
                    local ret = table.remove(callstack)

                    local f = debug.getinfo(2, "lSfn")
                    -- if lua wants to return from a pcall() after a assert(),
                    -- error() or runtime-error we have to cleanup our stack
                    if ret.func ~= f.func then
                            -- print("handling error()")
                            -- the error() is already removed
                            -- removed every thing up to pcall()
                            while callstack[#callstack].func ~= f.func do
                                    table.remove(callstack)

                                    call_indent = call_indent - 1
                            end
                            -- remove the pcall() too
                            ret = table.remove(callstack)
                            call_indent = call_indent - 1
                    end


                    local prev

                    if #callstack > 0 then
                            prev = callstack[#callstack].func
                    else
                            prev = mainfunc
                    end

                    local lines = functions[prev].lines
                    local last_line = functions[prev].last_line

                    call_indent = call_indent - 1

                    -- in case the assert below fails, enable this print and the one in the "call" handling
                    -- print((" "):rep(call_indent).."<<"..tostring(ret.func).." "..tostring(f.func).. " =? " .. tostring(f.func == ret.func))
                    assert(ret.func == f.func)

                    lines[#lines + 1] = ("cfl=%s"):format(ret.short_src)
                    lines[#lines + 1] = ("cfn=%s"):format(tostring(ret.func))
                    lines[#lines + 1] = ("calls=1 %d"):format(ret.linedefined)
                    lines[#lines + 1] = ("%d %d"):format(last_line and last_line or -1, instr_count - ret.instr_count)
            end
            -- tracefile:write("# --callstack: " .. #callstack .. "\n")
    else
            -- print("class = " .. class)
    end
end


local function func2name(m, tbl, prefix)
        prefix = prefix and prefix .. "." or ""

        -- print(prefix)

        for name, func in pairs(tbl) do
                if func == glob then
                        -- ignore
                elseif m[tostring(func)] and type(m[tostring(func)]) == "table" and m[tostring(func)].id then
                        -- already mapped
                elseif type(func) == "function" then
                        -- remove the package.loaded. prefix from the loaded methods
                        if type(name) == "string" then
                            m[tostring(func)] = { name = (prefix..name):gsub("^package\\.loaded\\.", ""), id = method_id }
                        else
                            --print("HERE",name())
                        end
                        method_id = method_id + 1
                elseif type(func) == "table" and type(name) == "string" then
                        -- a package, class, ...
                        --
                        -- make sure we don't look endlessly
                        if m[tostring(func)] ~= "*stop*" then
                                m[tostring(func)] = "*stop*"
                                func2name(m, func, prefix..name)
                        end
                end
        end
end

function module.stop(glob)
    -- resolve the function pointers
    func2name(methods, glob)

    for key, func in pairs(functions) do
            local f = func.meta

            if (not f.name) and f.linedefined == 0 then
                    f.name = "(test-wrapper)"
            end

            local func_name = getfuncname(f)
            if methods[tostring(f.func)] then
                    func_name = methods[tostring(f.func)].name
            end

            tracefile:write("fl="..f.short_src.."\n")
            tracefile:write("fn="..func_name.."\n")

            for i, line in ipairs(func.lines) do
                    if line:sub(1, 4) == "cfn=" and methods[line:sub(5)] then
                            tracefile:write("cfn="..(methods[line:sub(5)].name).."\n")
                    else
                            tracefile:write(line.."\n")
                    end
            end
            tracefile:write("\n")
    end

    tracefile:close()
end

return module