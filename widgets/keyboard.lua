local print = print
local io,table = io,table
local setmetatable  = setmetatable
local string,ipairs = string,ipairs
local wibox        = require("wibox"          )
local cairo        = require("lgi"            ).cairo
local color        = require("gears.color"    )
local button       = require( "awful.button"  )
local fd_async     = require("utils.fd_async" )
local util         = require("awful.util"     )
local radical      = require("radical"        )
local beautiful    = require("beautiful"      )
local surface      = require("gears.surface"  )
local glib         = require("lgi").GLib
local filetree     = require("customMenu.filetree")
local keylayout    = require("awful.widget.keyboardlayout")
local constrainedtext = require("radical.widgets.constrainedtext")

local capi = {awesome = awesome}

local module = {}
local menu,ready,checked,sub_item = nil,false,nil,nil
local widget = nil

local glob = nil
local layouts = {}
local cache_path = util.getdir("cache").."/keymaps"

local quick_switch = nil

-- Select the next layout
local function select_next(menu)
  local item = menu.next_item
  if not item then return end
  item.selected = true
  item.button1(menu,item)
  return true
end

local function set_keymap(m,i)
  glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
    util.spawn("setxkbmap".." "..i.text)
  end)
  widget.ib:set_image(i.icon)
  widget.tb:set_text (i.text)
end


-- Get the contry flag
local function get_flag(code)
  local path = util.getdir("config").."/data/flags-24x24/"..code..".png"
  local file = io.open(path)
    if file then
      file:close()
      return path
    end
end

-- Get the current keyboard layout
local function reload_widget(widget)
  local string  = capi.awesome.xkb_get_group_names()
  local layouts = keylayout.get_groups_from_group_names(string)
  local layout  = layouts[1].file
  local variant = layouts[1].section or ""

  -- Set the icon
  local flag = get_flag(layout)
  widget.ib:set_image(flag)

  -- Set the text
  widget.tb:set_text(layout)

  -- Check if the current layout is listed
  local full_layout_name = layout .. (variant and (" "..variant) or "")
  local found = false
  for k2,v2 in ipairs(layouts) do
    if full_layout_name == v2.name then
      found = true
      break
    end
  end
  if not found then
    layouts[#layouts+1] = {name = full_layout_name, icon = flag}
  end

  widget.ib:set_tooltip("<b>"..layout.."</b> "..variant, {is_markup=true})

  widget.ib:emit_signal("widget::updated")
end

-- While XKB does support multiple simultanious layouts, I don't
local function check(item)
  if checked then
    checked.checked = false
  end
  if item then
    item.checked = true
  end
  checked = item
end

-- Fetch asynchroniously all keyboard layouts for a country
local function fill_sub_menu(menu,country,parent)
  fd_async.file.load("/usr/share/X11/xkb/symbols/"..country):connect_signal("request::completed",function(content)
    for k,v in string.gmatch(content, "xkb_symbols[ ]*\"(.[^\"]+)\" {\n") do
      local item = nil
      item = menu:add_item({text=k,checkable=true,button1=function()
        check(parent)
        item.checked = not item.checked
        sub_item = item
        parent:set_selected(false,true)
      end})
    end
  end)
end

-- Asynchroniously get the list of supported countries
local function fill_menu(callback)
  fd_async.directory.list("/usr/share/X11/xkb/symbols/",{match = "^%w*"}):connect_signal("request::completed",function(content)
    table.sort(content)
    for k,v in ipairs(content) do
      local item = nil
      item = menu:add_item({text=v,checkable=true,
        sub_menu=function(m,i)
          if not item._internal.menu then
            local sub_menu = radical.context()
            fill_sub_menu(sub_menu,v,item)
            item._internal.menu = sub_menu
          end
          return item._internal.menu
        end,
        button1 = function(m,i)
          check(item)
        end
      })
    end
    ready = true
    callback()
  end)
end

-- 
local function add_layout(country,  full_name)
  local path = get_flag(country)
  local ib = wibox.widget.imagebox()
  ib:set_image(beautiful.titlebar_close_button_normal)
  local real_name = country..((full_name and full_name~="") and (" "..full_name) or "")
  if glob then
    glob:add_item({text=real_name,icon=path,suffix_widget=ib,bg_prefix=beautiful.bg_alternate,style=radical.item.style.arrow_prefix})
  end
  layouts[#layouts+1] = {name = real_name, icon = path}
  if quick_switch then
    quick_switch:add_item{text=real_name,icon=path,button1=set_keymap}
  end
end

-- Reload the disk cache
local function load_from_disk()
  fd_async.file.load(cache_path):connect_signal("request::completed",function(content)
    for country,full_name in string.gmatch(content, "([^\n^ ]*) ([^\n]*)\n") do
      add_layout(country, full_name)
    end
  end)
end

-- 
local function select_layout()
end


-- Create a keyboard switched widget
local function new()
  if not widget then
    widget    = wibox.layout.fixed.horizontal()
    widget:set_spacing(2)
    widget.ib = wibox.widget.imagebox()
    widget.tb = constrainedtext(nil, 2)
    widget:add(widget.ib, widget.tb)
  end

  function show(geometry)
    if ready then
      if geometry then
        glob.parent_geometry = geometry
      end
      glob.visible = not glob.visible
    end
  end
  widget:buttons( util.table.join(
    button({ }, 1, function(geometry)
      if not glob then
        glob = radical.context()
        menu = radical.embed({max_items=10})
        glob.parent_geometry = geometry
        glob:add_item {text="XModMap path", sub_menu = function() return filetree.path("/",{max_items=10},{checkable=true}) end}
        glob:add_embeded_menu(menu)
        glob:add_item({text="<b>[Add]</b>",style=radical.item.style.arrow_single,layout=radical.item.layout.centerred,button1=function()
          if checked then
            add_layout(checked.text,sub_item.text)
            -- Add to the cache
            fd_async.file.append(cache_path,checked.text.." "..sub_item.text.."\n")

            -- Unckeck
            check()

          end
        end})
        glob:add_widget(radical.widgets.separator())
        local ib = wibox.widget.imagebox()
        ib:set_image(beautiful.titlebar_close_button_normal)
        for k,v in ipairs(layouts) do
          glob:add_item({text=v.name,icon=v.icon,suffix_widget=ib,bg_prefix=beautiful.bg_alternate,style=radical.item.style.arrow_prefix,button1=set_keymap})
        end

        fill_menu(show)

      end
      show(geometry)
    end))
  )
  load_from_disk()

  reload_widget(widget)

  return widget
end

function module.quickswitchmenu()
  if not quick_switch then
    quick_switch = radical.box{item_height=40,filter=false}
    for k,v in ipairs(layouts) do
      quick_switch:add_item{text=v.name,icon=v.icon,button1=set_keymap}
    end
    quick_switch:add_key_hook({}, " ", "press", select_next)
    quick_switch:add_key_hook({}, "Mod1", "release", function(menu) quick_switch.visible = false end)
  end
  select_next(quick_switch)
  quick_switch.visible = true
end

capi.awesome.connect_signal("xkb::map_changed", function(a,b,c)
  local layouts = keylayout.get_groups_from_group_names(capi.awesome.xkb_get_group_names())
  print("KEY CHANGED", a,b,c, capi.awesome.xkb_get_group_names ())
                          for k,v in ipairs(layouts) do
                            for k2, v2 in pairs(v) do
                              -- Set the new flag and text
                              if widget and k2 == "file" then
                                widget.tb:set_text(v2)
                                widget.ib:set_image(get_flag(v2))
                              end
                            end
                          end
end)

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
