-- GIO async based file reading
-- @author Emmanuel Lepage Vallee  <elv1313@gmail.com>
--
-- This module should be faster than the "freedesktop" one used by the Awesome menubar (or the freedesktop module itself)

local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local gio = require("lgi").Gio
local gobject = require("lgi").GObject
local glib = require("lgi").GLib
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
function module.scan_dir_async(path,args)
  if not path then return end
  local args = args or {}
  local req = create_request()
  local attr = ""
  if args.attributes then
    for _,v in ipairs(args.attributes or {"FILE_ATTRIBUTE_STANDARD_NAME"}) do
      attr = attr..gio[v]..','
    end
  end
  gio.File.new_for_path(path):enumerate_children_async(attr,0,0,nil,function(file,task,c)
    local content,ret = file:enumerate_children_finish(task),{}
    content:next_files_async(99999,0,nil,function(file_enum,task2,c)
      local all_files = file_enum:next_files_finish(task2)
      for _,file in ipairs(all_files) do
        local ret_attr,has_attr = {},false
        for _,v in ipairs(args.attributes or {"FILE_ATTRIBUTE_STANDARD_NAME"}) do
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
      req:emit_signal("request::completed",ret or {})
    end)
  end)
  return req
end

--- Return a file list (name only)
function module.list_files_async(path,args)
  if not path then return end
  local req,args = create_request(), args or {}
  module.scan_dir_async(path):connect_signal("request::completed",function(content)
      local ret = {}
      for k,v in ipairs(content) do
        local name = v["FILE_ATTRIBUTE_STANDARD_NAME"]
        if args.match then
          if name:match(args.match) ~= "" then
            ret[#ret+1] = name
          end
        else
          ret[#ret+1] = name
        end
      end
      req:emit_signal("request::completed",ret)
  end)
  return req
end

---------------------------------------------------------------------
---                           Files                               ---
---------------------------------------------------------------------

-- Read a file, then emit "request::completed"
function module.load_file_async(path)
  local req = create_request()
  gio.File.new_for_path(path):load_contents_async(nil,function(file,task,c)
      local content = file:load_contents_finish(task)
      if content then
        req:emit_signal("request::completed",tostring(content))
      end
  end)
  return req
end

--- Read all file from a directory
function module.load_all_async(path,args)
  local args = args or {}
  local req = create_request()
  module.scan_dir_async(path,{attributes=args.attributes}):connect_signal("request::completed",function(files)
    local counter = 0
    for k,v in ipairs(files) do
      local name = v["FILE_ATTRIBUTE_STANDARD_NAME"]
      if not args.extention or name:find("[^%s].*".. args.extention .."$") then
        module.load_file_async(path..'/'..name):connect_signal("request::completed",function(content)
          req:emit_signal("file::content",path..'/'..name,content,v)
          counter = counter - 1
          if counter == 0 then
            req:emit_signal("request::completed")
          end
        end)
      end
    end
  end)
  return req
end

---------------------------------------------------------------------
---                            Commands                           ---
---------------------------------------------------------------------

-- Execute a command async
function module.exec_command_async(command,cwd)
  local req = create_request()
  local argv = glib.shell_parse_argv(command)
  if not argv then
    print("Command parsing failed",command)
    return req
  end

  local pid, stdin, stdout, stderr = glib.spawn_async_with_pipes(cwd,argv,nil,4,function() end)
  if not pid then
    print("Command execution failed",command,argv)
    return req
  end
  local stream = gio.UnixInputStream.new(stdout)
  local filter = gio.DataInputStream.new(stream)
  local errstream = gio.UnixInputStream.new(stderr)
  local errfilter = gio.DataInputStream.new(errstream)
  local ret = {}
  local function get_line(obj, res)
    local result, err = obj:read_line_finish_utf8(res)
    req:emit_signal("new::line",result)
    if (result and not filter:is_closed()) then
      ret[#ret+1] = result
      filter:read_line_async(glib.PRIORITY_DEFAULT,nil,get_line)
    else
      filter:close()
      stream:close()
      errfilter:close()
      errstream:close()
      req:emit_signal("request::completed",table.concat(ret,"\n"))
    end
  end
  local function get_error_line(obj,res)
    local result, err = obj:read_line_finish_utf8(res)
    req:emit_signal("new::error",result)
    if result or not errstream:is_open() then
      errfilter:read_line_async(glib.PRIORITY_DEFAULT,nil,get_error)
    else
      filter:close()
      stream:close()
      errfilter:close()
      errstream:close()
      req:emit_signal("request::completed",table.concat(ret,"\n"))
    end
  end
  filter:read_line_async(glib.PRIORITY_DEFAULT,nil,get_line)
  errfilter:read_line_async(glib.PRIORITY_DEFAULT,nil,get_error)
  return req
end

---------------------------------------------------------------------
---                            Sockets                            ---
---------------------------------------------------------------------

function module.download_binary_async(url)
--   local req = create_request()
--   print("starting",command)
--   gio.File.new_for_commandline_arg(command):load_contents_async(nil,function(file,task,c)
--       local content = file:load_contents_finish(task)
--       print("called",content)
--       if content then
--         req:emit_signal("request::completed",tostring(content))
--       end
--   end)
--   return req
end

function module.download_text_async(url)
--   local req = create_request()
--   print("starting",url)--glib.PRIORITY_DEFAULT
--   gio.File.new_for_uri(url):load_contents_async(nil,function(file,task,c)
--       local content = file:load_contents_finish(task)
--       print("called",content)
--       if content then
--         req:emit_signal("request::completed",tostring(content))
--       end
--   end)
--   return req
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

function module.eval_as_lua()
  --TODO
end

-- Load all desktop files from a path
function module.load_desktop_files(path,load_icon)
  local req_in,req_out = module.load_all_async(path,{attributes={"FILE_ATTRIBUTE_STANDARD_NAME","FILE_ATTRIBUTE_STANDARD_ICON"}}),create_request()
  req_in:connect_signal("file::content",function(name,content,attrs)
    local ini = module.parse_ini(content)

    -- Replace "AWECFG" by the current config directory path
    if ini.Icon then
      ini.Icon=ini.Icon:gsub("AWECFG",util.getdir("config"))
    end
    req_out:emit_signal("file::content",path,ini,attrs)
  end)
  req_in:connect_signal("request::completed",function() req_out:emit_signal("request::completed")end)
  return req_out
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;