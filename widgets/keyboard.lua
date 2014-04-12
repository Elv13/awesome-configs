local print = print
local io = io
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

local module = {}
local menu,ready,checked,sub_item = nil,false,nil,nil
local widget = nil

local glob = nil
local layouts = {}


local quick_switch = nil

local function save_to_disk()
  --TODO
end

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
  widget:set_image(i.icon)
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
  fd_async.exec_command_async('setxkbmap -query'):connect_signal("request::completed",function(ret)
    local layout  = ""
    local variant = nil
    for k,v in string.gmatch(ret, "layout:([ ]*)([^\n]+)\n?") do
      layout = v
    end
    for k,v in string.gmatch(ret, "variant:([ ]*)([^\n]+)\n?") do
      variant = v
    end

    -- Set the icon
    local flag = get_flag(layout)
    widget:set_image(flag)

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

    widget:emit_signal("widget::updated")
  end)
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
  fd_async.load_file_async("/usr/share/X11/xkb/symbols/"..country):connect_signal("request::completed",function(content)
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
  fd_async.list_files_async("/usr/share/X11/xkb/symbols/",{match = "^%w*"}):connect_signal("request::completed",function(content)
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

-- How much space will the flag take
local function fit(self,w,h)
  return h,h
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

-- 
local function select_layout()
end


-- Create a keyboard switched widget
local function new()
  if not widget then
    widget = wibox.widget.imagebox()
  end
--   widget.draw = draw
  widget.fit = fit
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
        glob:add_embeded_menu(menu)
        glob:add_item({text="<b>[Add]</b>",style=radical.item.style.arrow_single,layout=radical.item.layout.centerred,button1=function()
          if checked then
            add_layout(checked.text,sub_item.text)
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
  add_layout("us","")
  add_layout("ca","fr")

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

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;