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
local cairo = require("lgi").cairo
local util = require("awful.util")
local gtk = nil

local module = {file={},command={},network={},outputstream={},directory={},exec={},ini={},icon={}}

---------------------------------------------------------------------
---                           HELPERS                             ---
---------------------------------------------------------------------

-- Emit can be daisy-chained
local function emit_signal(self,name,...)
  for k,v in ipairs(self._connections[name] or {}) do
    v(...)
  end
  return self
end

-- Signal conenctions can be daisy-chained
local function connect_signal(self,name,callback)
  self._connections[name] = self._connections[name] or {}
  self._connections[name][#self._connections[name]+1] = callback
  return self
end

local function create_request()
  local req = {_connections={}}
  req.emit_signal = emit_signal
  req.connect_signal = connect_signal
  return req
end

local function watch_common(path,method,prefix)
  local req = create_request()
  local file = gio.File.new_for_path(path)
  file[method](file,{}).on_changed:connect(function(self,file1,file2,type)
    local path1,path2 = file1 and file1:get_path() or "",file2 and file2:get_path() or ""
--     if type == "CHANGED" or  then
    if type == "CHANGES_DONE_HINT" then
      req:emit_signal(prefix.."::changed",path1,path2)
    elseif type == "DELETED" then
      req:emit_signal(prefix.."::deleted",path1,path2)
    elseif type == "CREATED" then
      req:emit_signal(prefix.."::created",path1,path2)
    elseif type == "ATTRIBUTE_CHANGED" then
      req:emit_signal(prefix.."::attribute",path1,path2)
    elseif type == "PRE_UNMOUNT" then
      req:emit_signal(prefix.."::unmount_request",path1,path2)
    elseif type == "UNMOUNTED" then
      req:emit_signal(prefix.."::unmount",path1,path2)
    elseif type == "MOVED" then
      req:emit_signal(prefix.."::moved",path1,path2)
    end
    print("")
  end)
  return req
end

---------------------------------------------------------------------
---                           DIRECTORY                           ---
---------------------------------------------------------------------

--- Scan a directory content
-- This function return multiple file sttributes, see:
-- https://developer.gnome.org/gio/stable/GFileInfo.html#G-FILE-ATTRIBUTE-STANDARD-TYPE:CAPS
-- for details. The list of requestion attributes can be passed in the args.attributes
-- argument. The default only return the file name. Use gears.async.directory.list for a more
-- basic file list.
function module.directory.scan(path,args)
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
    local content,error = file:enumerate_children_finish(task)
    local ret = {}
    if not content then req:emit_signal("scan::error",ret);return end
    content:next_files_async(99999,0,nil,function(file_enum,task2,c)
      local all_files = file_enum:next_files_finish(task2)
      for _,file in ipairs(all_files) do
        local ret_attr,has_attr = {},false
        for _,v in ipairs(args.attributes or {"FILE_ATTRIBUTE_STANDARD_NAME"}) do
          local attr,val = gio[v],nil
          local attr_type = file:get_attribute_type(attr)
          if attr_type == "OBJECT" then
            val = file:get_attribute_object(attr)
          else
            val = file:get_attribute_as_string(attr)
          end
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
function module.directory.list(path,args)
  if not path then return end
  local req,args = create_request(), args or {}
  module.directory.scan(path):connect_signal("request::completed",function(content)
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

--- Read all file from a directory
function module.directory.load(path,args)
  local args = args or {}
  local req = create_request()
  module.directory.scan(path,{attributes=args.attributes}):connect_signal("request::completed",function(files)
    local counter = #files
    for k,v in ipairs(files) do
      local name = v["FILE_ATTRIBUTE_STANDARD_NAME"]
      if not args.extention or name:find("[^%s].*".. args.extention .."$") then
        local ret = {}
        module.file.load(path..'/'..name):connect_signal("request::completed",function(content)
          req:emit_signal("file::content",path..'/'..name,content,v)
          ret[name] = content
          counter = counter - 1
          if counter == 0 then
            req:emit_signal("request::completed",ret)
          end
        end)
      end
    end
  end)
  return req
end

--- Get a notification when the directory change
-- @usage
-- <code>
--gears.async.file.watch("~/.config/awesome/"):connect_signal("file::changed",function(path1,path2)
--    print("file changed",path1,path2)
--end):connect_signal("file::created",function(path1,path2)
--    print("file created",path1,path2)
--end):connect_signal("file::deleted",function(path1,path2)
--    print("file deleted",path1,path2)
--end)
-- </code
function module.directory.watch(path)
  return watch_common(path,"monitor_directory","directory")
end

---------------------------------------------------------------------
---                          Streams                              ---
---------------------------------------------------------------------

-- Write to a stream
function module.outputstream.write(stream, content)
  local req = create_request()
  stream:write_async(content,content:len(),nil,function(file2,task2)
    local ret = file2:write_finish(task2)
    req:emit_signal("request::completed")
  end)
  return req
end

---------------------------------------------------------------------
---                           Files                               ---
---------------------------------------------------------------------

-- Read a file, then emit "request::completed"
function module.file.load(path)
  local req = create_request()
  gio.File.new_for_path(path):load_contents_async(nil,function(file,task,c)
      local content = file:load_contents_finish(task)
      if content then
        req:emit_signal("request::completed",tostring(content))
      end
  end)
  return req
end

-- Append to file
function module.file.append(path,content,auto_close)
  local req = create_request()
  gio.File.new_for_path(path):append_to_async({},0,nil,function(file,task,c)
      local stream = file:append_to_finish(task)
      req:emit_signal("stream::open",stream)
      module.outputstream.write(stream,content):connect_signal("request::completed",function()
        if auto_close ~= false then
          stream:close()
          req:emit_signal("stream::closed",stream)
        end
        req:emit_signal("request::completed")
      end)
  end,0)
  return req
end

-- Replace a file content or create a new one
function module.file.write(path,content,auto_close,stream)
  local req = create_request()
  gio.File.new_for_path(path):replace_contents_async(content,nil,function(file,task,c)
    local stream = file:replace_contents_finish(task)
    req:emit_signal("request::completed")
  end,0)
  return req
end

--- Get a notification when the file change
-- @usage
-- <code>
--gears.async.file.watch("~/.config/awesome/rc.lua"):connect_signal("file::changed",function(path1,path2)
--    print("file changed",path1,path2)
--end)
-- </code
function module.file.watch(path)
  return watch_common(path,"monitor_file","file")
end

--- Return the name of a file from a path
function module.file.name(path)
  return gio.File.new_for_path(path):get_basename()
end

--- Return the name of a file from a path
function module.file.exist(path)
  if not path then return end
  return gio.File.new_for_path(path):query_exists()
end

function module.file.copy(source_path,destination_path,overwirte --[[TODO]], backup --[[TODO]])
  -- gio.File.copy_async is not exposed by GObject introspection, so it cannot be used by LGI.
  -- This is why this function re-implement the copy logic.
  local req = create_request()

  local src  = gio.File.new_for_path( source_path      )
  local dest = gio.File.new_for_path( destination_path )

  src:read_async(glib.PRIORITY_DEFAULT,nil,function(file,task,c)
    local in_stream,err = file:read_finish(task)
    if not in_stream then
      req:emit_signal("source::error",err)
      return
    end
    dest:replace_async(nil,false,{},glib.PRIORITY_DEFAULT,nil,function(file2,task2,c2)
      local out_stream,err2 = file2:replace_finish(task2)
      if not out_stream then
        req:emit_signal("destination::error",err2)
        return
      end
      out_stream:splice_async(in_stream,{0,1,2},glib.PRIORITY_DEFAULT,nil,function(file3,task3,c3)
        local ret  = file3:splice_finish(task3)
        req:emit_signal("request::completed",ret)
      end)
    end)
  end)
  return req
end

---------------------------------------------------------------------
---                            Commands                           ---
---------------------------------------------------------------------

--- Execute a command and get the result either line by line or complete
-- This method should not be confused with awful.util.spawn. This one is
-- used to retreive the output rather than simply executing a command
-- and forgetting about it
-- 
-- @param command a shell command
-- @param cwd current working directory (optional)
-- @return A request handler
--
-- ###Signals:
--
-- * request::completed: When the command is over, return a stdout string
-- * new::error: A new stderr line
-- * new::line: A new  stdout line
function module.exec.command(command,cwd)
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
    if result or not errstream:is_closed() then
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
  errfilter:read_line_async(glib.PRIORITY_DEFAULT,nil,get_error_line)
  return req
end

--- Run LUA code when the event loop become idle
-- @param f function to execute
-- @return nothing
function module.exec.idle(f)
  if not f then return end
  glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, f)
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


-- Download a file using wget
-- This is done because Awesome does not depend of GVFS. We also want to avoid
-- forcing users to run a background daemon for downloading files.
function module.network.load(url)
  local req = create_request()
  print("starting",url)--glib.PRIORITY_DEFAULT
  gio.File.new_for_uri(url):read_async(glib.PRIORITY_DEFAULT,nil,function(file,task,c)
      local content,error = file:read_finish(task)
      print("called",content,foo)
      if error then
        req:emit_signal("request::error",tostring(error))
      elseif content then
        req:emit_signal("request::completed",tostring(content))
      end
  end)
  return req
end

---------------------------------------------------------------------
---                         Icon handling                         ---
---------------------------------------------------------------------

-- Note that this section require GTK

local default_theme = nil

--- Load an icon from the GTK theme
-- @note Set "gtk-icon-theme-name=oxygen" in .config/gtk-3.0/settings.ini for KDE
-- @param names A set of icon names, the first one is the best choice, the others are fallbacks. It can also be a GIcon
-- @param size The icon size (in pixel), 22px is the default
function module.icon.load(names,size)
  local req = create_request()

  if not names then return req end

  local size = size or 22

  -- Gtk is not needed until this function is called
  -- It gives an error if GTK is not installed. As we don't want to make it an
  -- hard dependency, not calling this from the default rc.lua and letting the
  -- user uncomment the line will allow the best of both world.
  if not gtk then
    gtk = require("lgi").Gtk
  end

  -- GIcon support is necessary to handle attributes
  local t = type(names)
  if t == "userdata" then
    names = names.names
  elseif t == "string" then
    names = {names}
  end

  -- Load the theme
  if not default_theme then
    default_theme = gtk.IconTheme.get_default()
  end

  -- Parse the names
  local icon_theme,icon_info,bar = gtk.IconTheme,default_theme:choose_icon(names,size,{})

  if not icon_info or not icon_info.load_icon_async then return req end --TODO error

  icon_info:load_icon_async(nil,function(file,task)
      local pix = file:load_icon_finish(task)
      if not pix then return end

      -- Convert to Cairo
      local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
      local cr = cairo.Context(img)
      cr:set_source_pixbuf(pix,0,0)
      cr:paint()
      req:emit_signal("request::completed",img,cr)
  end)

  return req
end

---------------------------------------------------------------------
---                     General file handling                     ---
---------------------------------------------------------------------

-- Parse a classical INI file format (used for .desktop and KDE config files)
function module.ini.parse(content)
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
function module.ini.load_dir(path,load_icon,icon_path)
  local req_in,req_out = module.directory.load(path,{extention="desktop",attributes={"FILE_ATTRIBUTE_STANDARD_NAME","FILE_ATTRIBUTE_STANDARD_ICON"}}),create_request()
  req_in:connect_signal("file::content",function(name,content,attrs)
    local ini = module.ini.parse(content)

    -- Replace "AWECFG" by the current config directory path
    if ini.Icon then
      ini.Icon=ini.Icon:gsub("AWECFG",icon_path or util.getdir("config"))
    end

    -- Split categories
    local cats = {}
    for category in (ini.Categories or ""):gmatch('[^;]+') do
      cats[#cats+1] = category
    end
    ini.Categories = cats

    req_out:emit_signal("file::content",name,ini,attrs)
  end)
  req_in:connect_signal("request::completed",function() req_out:emit_signal("request::completed")end)
  return req_out
end

-- Save an INI file
-- @param ini an array of key/value
-- @param path Where to save the file
function module.ini.write(ini,path)
  if (not ini) or (not path) then return end
  local ret = ""
  for k,v in pairs(ini) do
    local t = type(v)
    if t == "table" then
      local ret2 = ""
      for k2,v2 in pairs(v) do
        ret2 = ret2 .. v2 .. ";"
      end
      v = ret2
    elseif t ~= "string" then
      v = ini[k.."_orig"]
      ini[k.."_orig"] = nil
    end
    if v then
      ret = ret..k.."="..v.."\n"
    end
  end

  return module.file.write(path,ret)
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
