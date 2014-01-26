-- GIO async based file reading
-- @author Emmanuel Lepage Vallee  <elv1313@gmail.com>
--
-- This module should be faster than the "freedesktop" one used by the Awesome menubar (or the freedesktop module itself)

local setmetatable = setmetatable
local ipairs = ipairs
local gio = require("lgi").Gio

local module = {}

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

--- Read all file from a directory
function module.read_all_async(path,callback)
  
end

-- gio.File.new_for_path('/sys/class/power_supply/'..(bat_name)..'/energy_now'):load_contents_async(nil,function(file,task,c)
--       local content = file:load_contents_finish(task)
--       if content then
--         local now = tonumber(tostring(content))
--         local percent = now/full_energy
--         percent = math.floor(percent* 100)/100
--         wdg:set_value(percent)
--       end
--   end)

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;