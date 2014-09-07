local radical  = require("radical")
local fd_async = require("utils.fd_async")
local util     = require("awful.util")

local module = {}

local function load_folder(parent,path,args,item_args)
  fd_async.directory.scan(path,{attributes={"FILE_ATTRIBUTE_STANDARD_NAME","FILE_ATTRIBUTE_STANDARD_TYPE"}}):connect_signal("request::completed",function(list)
    for k,v in ipairs(list) do
      local ftype,name,m = v["FILE_ATTRIBUTE_STANDARD_TYPE"],v["FILE_ATTRIBUTE_STANDARD_NAME"],nil
      if ftype == "2" then
        m = radical.context( util.table.join({},args) )
      end
      parent:add_item(util.table.join({text=name,sub_menu= m and (function() load_folder(m,path.."/"..name,args,item_args);return m end) or nil},item_args))
    end
  end)
end

function module.path(path,args,item_args)
  local m = radical.context( util.table.join({},args) )
  load_folder(m,path,args,item_args)
  return m
end

return module
-- kate: space-indent on; indent-width 2; replace-tabs on;