-- GIO async based file reading
-- @author Emmanuel Lepage Vallee  <elv1313@gmail.com>
--
-- This module should be faster than the "freedesktop" one used by the Awesome menubar (or the freedesktop module itself)

local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local gio = require("lgi").Gio
local util = require("awful.util")

local module = {}

---------------------------------------------------------------------
---                           HELPERS                             ---
---------------------------------------------------------------------
local function emit_signal(self,name,...)
  for k,v in ipairs(self._connections[name] or {}) do
    v(...)
  end
end

local function connect_signal(self,name,callback)
  self._connections[name] = self._connections[name] or {}
  self._connections[name][#self._connections[name]+1] = callback
end

local function create_request()
  local req = {_connections={}}
  req.emit_signal = emit_signal
  req.connect_signal = connect_signal
  return req
end

---------------------------------------------------------------------
---                           DIRECTORY                           ---
---------------------------------------------------------------------

--- Use Gio to scan a directory
function module.scan_dir_async(path,callback,attributes,extentions)
  if not callback or not path then return end
  local attr = ""
  if attributes then
    for _,v in ipairs(attributes or {"FILE_ATTRIBUTE_STANDARD_NAME"}) do
      attr = attr..gio[v]..','
    end
  end
  gio.File.new_for_path(path):enumerate_children_async(attr,0,0,nil,function(file,task,c)
    local content,ret = file:enumerate_children_finish(task),{}
    content:next_files_async(99999,0,nil,function(file_enum,task2,c)
      local all_files = file_enum:next_files_finish(task2)
      for _,file in ipairs(all_files) do
        local ret_attr,has_attr = {},false
        for _,v in ipairs(attributes or {"FILE_ATTRIBUTE_STANDARD_NAME"}) do
          local val = file:get_attribute_as_string(gio[v])
          if val then
            has_attr = true
            ret_attr[v] = val
          end
        end
        if has_attr then
          ret[#ret+1] = ret_attr
        end
      end
      content:close_async(0,nil)
      callback(ret or {})
    end)
  end)
end

---------------------------------------------------------------------
---                           Files                               ---
---------------------------------------------------------------------

-- Read a file, then call "callback" with content as first argument
function module.load_file_async(path,callback)
  gio.File.new_for_path(path):load_contents_async(nil,function(file,task,c)
      local content = file:load_contents_finish(task)
      if content then
        callback(tostring(content))
      end
  end)
end

--- Read all file from a directory
function module.load_all_async(path,args)
  local args = args or {}
  local req = create_request()
  module.scan_dir_async(path,function(files)
    local counter = 0
    for k,v in ipairs(files) do
      local name = v["FILE_ATTRIBUTE_STANDARD_NAME"]
      if not args.extention or name:find("[^%s].*".. args.extention .."$") then
        module.load_file_async(path..'/'..name,function(content)
          req:emit_signal("file::content",path..'/'..name,content,v)
          counter = counter - 1
          if counter == 0 then
            req:emit_signal("request::completed")
          end
        end)
      end
    end
  end,args.attributes)
  return req
end

---------------------------------------------------------------------
---                     General file handling                     ---
---------------------------------------------------------------------

-- Parse a classical INI file format
function module.parse_ini(content)
  local ret = {}
  for k,v in string.gmatch(content, "(%w+)=([^\n]+)\n?") do
    ret[k] = v
  end
  return ret
end

-- Load all desktop files from a path
function module.load_desktop_files(path,load_icon)
  local req_in,req_out = module.load_all_async(path,{attributes={"FILE_ATTRIBUTE_STANDARD_NAME","FILE_ATTRIBUTE_STANDARD_ICON"}}),create_request()
  req_in:connect_signal("file::content",function(name,content,attrs)
    local ini = module.parse_ini(content)
    if ini.Icon then
      ini.Icon=ini.Icon:gsub("AWECFG",util.getdir("config"))
    end
    req_out:emit_signal("file::content",path,ini,attrs)
  end)
  req_in:connect_signal("request::completed",function() req_out:emit_signal("request::completed")end)
  return req_out
end

module.load_desktop_files("/home/lepagee/.config/awesome/data/dock")

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;