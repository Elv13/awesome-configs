local radical  = require("radical")
local fd_async = require("utils.fd_async")
local util     = require("awful.util")

local dirs = { '/usr/share/applications/', '/usr/local/share/applications/',
  '~/.local/share/applications/', '/home/kde-devel/kde/share/applications/' }

-- TODO this can be extracted from /etc/xdg/menus/kde-4-applications.menu or the Gnome one
local categories = {
  AudioVideo ={icon="applications-multimedia" ,name="Multimedia"  }, Development={icon="applications-development",name="Development" },
  Education  ={icon="applications-science"    ,name="Education"   }, Game       ={icon="applications-games"      ,name="Games"       },
  Graphics   ={icon="applications-graphics"   ,name="Graphics"    }, Network    ={icon="applications-internet"   ,name="Internet"    },
  Office     ={icon="applications-office"     ,name="Office"      }, Settings   ={icon="preferences-desktop"     ,name="Settings"    },
  System     ={icon="applications-system"     ,name="System Tools"}, Utility    ={icon="applications-accessories",name="Accessories" },
  Other      ={icon="applications-other"      ,name="Other"       }, }

local categories_menu = {}

local function scan_dir(parent,path,sub_args,item_args)
  fd_async.directory.scan(path,{attributes={"FILE_ATTRIBUTE_STANDARD_NAME","FILE_ATTRIBUTE_STANDARD_TYPE"}}):connect_signal("request::completed",function(list)
    for k,v in ipairs(list) do
      local ftype,name = v["FILE_ATTRIBUTE_STANDARD_TYPE"],v["FILE_ATTRIBUTE_STANDARD_NAME"]

      if ftype == "2" then --Directory
        scan_dir(parent,path.."/"..name,sub_args,item_args)
      elseif ftype == "1" and name:match("[%d%a]*.desktop") then --File
        local new_path = path.."/"..name
        -- Read the file
        fd_async.file.load(new_path):connect_signal("request::completed",function(content)

          -- Get the content as an array, discard invalids TODO add yeilding
          local ini = fd_async.ini.parse(content)
          if not ini.Categories or not ini.Exec or not ini.Name then return end
          ini.Name = ini.Name:gsub('&',"&amp;")
          ini.Path = new_path

          -- Match the content to a valid category
          for category in ini.Categories:gmatch('[^;]+') do
            local cat = categories[category]
            if cat then

              -- Create the sub menu only if there is something in them
              if not parent._internal.categories_menu[category] then
                local m = radical.context(util.table.join(sub_args))
                parent._internal.categories_menu[category] = m
                local item = parent:add_item {text=category,sub_menu=function() return m end}

                -- Icons can be slow to load, use async methods
                fd_async.icon.load(cat.icon or "applications-"..category:lower(),32):connect_signal("request::completed",function(icon)
                  item.icon = icon
                end)

                m._internal.entries = {}

                -- Only create the items when the menu is visible, for speed
                m:connect_signal("visible::changed",function()
                  for k,ini in ipairs(m._internal.entries) do
                    local item = m:add_item({text=ini.Name,button1= item_args.button1 or function() parent.visible=false; return util.spawn(ini.Exec) end})
                    item._internal.desktop = ini
                    fd_async.icon.load(ini.Icon,32):connect_signal("request::completed",function(icon)
                      item.icon = icon
                    end)
                  end

                  -- Clear the entries, new ones may be added later
                  m._internal.entries = {}
                end)
              end

              -- Add to the right sub menu
              local m = parent._internal.categories_menu[category]
              m._internal.entries[#m._internal.entries+1] = ini
            end
          end
        end)
      end
    end
  end)
end

local function menu(main_args,sub_args,item_args)
  local m = radical.context (main_args or {})
  m._internal.categories_menu = {}
  local started = false
  -- Only do this when the menu if first shown, it is IO intensive
  m:connect_signal("visible::changed",function()
    if not started then
      for k,v in ipairs(dirs) do
        scan_dir(m,v,sub_args or {},item_args or {})
      end
      started = true
    end
  end)
  return m
end

return setmetatable({}, { __call = function(_, ...) return menu(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;