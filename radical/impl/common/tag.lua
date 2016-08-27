local radical = require("radical")
local capi = { screen = screen, client=client}
local awful     = require( "awful"      )
local wibox = require("wibox")
local beautiful =  require("beautiful")
local surface     = require( "gears.surface")
local tag_list = nil

local module = {}

local function createTagList(aScreen,args)
  if not tag_list then
    tag_list = require("radical.impl.taglist")
  end
  local tagList = args.menu or radical.context {}
  local ret = {}
  for _, v in ipairs(capi.screen[aScreen].tags) do
    args.text,args.icon = v.name,v.icon
    local i = tagList:add_item(args)
    i._tag = v
    ret[v] = i
    i:connect_signal("mouse::enter",function()
      tag_list.highlight(v)
    end)
  end
  tagList:connect_signal("visible::changed",function()
    if not tagList.visible then
      tag_list.highlight(nil)
    end
  end)
  return tagList,ret
end

function module.listTags(args, menu)
  args = args or {}
  if capi.screen.count() == 1 or args.screen then
    return createTagList(args.screen or 1,args or {})
  else
    local screenSelect = radical.context {}
    for i=1, capi.screen.count() do
      screenSelect:add_item({text="Screen "..i , sub_menu = createTagList(i,args or {})})
    end
    return screenSelect
  end
end

function module.layouts(menu,layouts)
  local cur = awful.layout.get(capi.client.focus and capi.client.focus.screen)
  local screenSelect = menu or radical.context {}

  layouts = layouts or awful.layout.layouts

  for i, layout_real in ipairs(layouts) do
    local layout2 = awful.layout.getname(layout_real)
    local is_current = cur and ((layout_real == cur) or (layout_real.name == cur.name))
    if layout2 and beautiful["layout_" ..layout2] then
      screenSelect:add_item({icon=beautiful["layout_" ..layout2],button1 = function(_,mod)
        if mod then
          screenSelect[mod[1] == "Shift" and "previous_item" or "next_item"].selected = true
        end
        awful.layout.set(layouts[screenSelect.current_index ] or layouts[1], (capi.client.focus and capi.client.focus.screen.selected_tag))
      end, selected = is_current, item_layout = radical.item.layout.icon})
    end
  end
  return screenSelect
end

local function add_slider_row(sliders, text, max)
    sliders:add(wibox.widget { --HACK, this should go above
        text = text,
        widget = wibox.widget.textbox
    })

    local slider = wibox.widget { --HACK, this should go above
        {
            value   = 3,
            maximum = max,
            minimum = 1,
            widget  = wibox.widget.slider,
            id      = "slider",
        },
        strategy = "max",
        height   = 25,
        width    = 90,
        layout   = wibox.container.constraint
    }
    local real_slider = slider:get_children_by_id("slider")[1]

    local counter = wibox.widget { --HACK, this should go above
        text   = "  1  ",
        id     = "counter",
        widget = wibox.widget.textbox
    }

    real_slider:connect_signal("property::value",function()
        --counter.text = "  "..real_slider.value.."  "
    end)

    sliders:add(slider, counter)
end

-- Widget to replace the default awesome layoutbox
function module.layout_item(menu,args)
  args = args or {}
  local screen = args.screen or 1
  local sub_menu = nil
  local layout_menu = nil

  local function toggle()
    if not sub_menu then
      sub_menu = radical.embed {
        filter      = false                             ,
        item_style  = radical.item.style.rounded        ,
        item_height = 30                                ,
        column      = 5                                 ,
        layout      = radical.layout.grid               ,
        arrow_type  = radical.base.arrow_type.CENTERED  ,
      }
      module.layouts(sub_menu)

      layout_menu = radical.context{}

      layout_menu:add_widget(radical.widgets.header(layout_menu,"LAYOUTS")  , {height = 20})
      layout_menu:add_embeded_menu(sub_menu)
      layout_menu:add_widget(radical.widgets.header(layout_menu,"STATE")  , {height = 20})

      local bar_menu,bar_menu_w = radical.bar {
        item_style  = radical.item.style.rounded        ,
        item_height = 30                                ,
        item_layout = radical.item.layout.icon          ,
      }

      bar_menu:add_item {
        icon = surface(awful.util.getdir("config").. "blind/arrow/Icon/" .. "locked.png"),
      }

      bar_menu:add_item {
        icon = surface(awful.util.getdir("config").. "blind/arrow/Icon/" .. "exclusive.png"),
      }

      bar_menu:add_item {
        icon = surface(awful.util.getdir("config").. "blind/arrow/Icon/" .. "fallback.png"),
          selected = true,
      }

      bar_menu:add_item {
        icon = surface(awful.util.getdir("config").. "blind/arrow/Icon/" .. "inclusive.png"),
      }

      layout_menu:add_widget(bar_menu_w  , {height = 30})

      layout_menu:add_widget(radical.widgets.header(layout_menu,"CONTROLS")  , {height = 20})

      local sliders = wibox.widget {
        column_count = 3,
        layout = wibox.layout.grid
      }

      add_slider_row(sliders, " Gap:"     , 150)
      add_slider_row(sliders, " Factor:"  , 10 )
      add_slider_row(sliders, " Columns: ", 5  )
      add_slider_row(sliders, " Masters: ", 5  )
      add_slider_row(sliders, " Max:"     , 20 )

      layout_menu:add_widget(sliders)

      layout_menu:add_widget(radical.widgets.header(layout_menu,"PROPERTIES")  , {height = 20})

      layout_menu:add_item {
        text = "Volatile",
        checkable = true,
        checked = true,
      }

      layout_menu:add_item{text="<b>[Save]</b>"--[[,layout=radical.item.layout.centerred]]}

    end
    layout_menu.visible = not layout_menu.visible
  end

  --TODO button 4 and 5
  local item = menu:add_item{text=args.text,button1=toggle,tooltip=args.tooltip}

  local function update()
    local layout = awful.layout.getname(awful.layout.get(screen))
    local ic = beautiful["layout_" ..layout]
    item.icon = ic
  end
  update()

  awful.tag.attached_connect_signal(screen, "property::selected", update)
  awful.tag.attached_connect_signal(screen, "property::layout"  , update)



  

  return item
end

return setmetatable(module, { __call = function(_, ...) return module.listTags(...) end })
-- kate: space-indent on; indent-width 4; replace-tabs on;
