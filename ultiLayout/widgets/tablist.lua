---------------------------------------------------------------------------
-- @copyright 2011-2012 Emmanuel Lepage Vallee <elv1313@gmail.com>         
-- @copyright 2008-2009 Julien Danjou                                      
-- @release v3.4-rc3                                                       
---------------------------------------------------------------------------

-- Grab environment we need
local capi = { mouse        =      mouse  ,
               widget       =      widget }
local ipairs       = ipairs
local pairs        = pairs
local setmetatable = setmetatable
local table        = table
local common       = require( "awful.widget.common" )
local beautiful    = require( "beautiful"           )
local wibox        = require( "awful.wibox"         )
local util         = require( "awful.util"          )
local layout       = require( "awful.widget.layout" )
local awButtons    = require( "awful.button"        )
local ultilayoutC  = require( "ultiLayout.common"   )

module("ultiLayout.widgets.tablist")

local function gen_style(fg,bg)
    return "<span color='"..util.color_strip_alpha(beautiful[fg]).."'>",beautiful[bg]
end

function widget_tasklist_label_common(tab,w)
    local suffix, prefix = "</span>",""
    if w.focus == true then
      if tab.selected == false then
          prefix,bg = gen_style("fg_normal","bg_highlight")
      else
          prefix,bg = gen_style("fg_focus","bg_focus")
      end
    else
      if tab.selected == false then
          prefix,bg = gen_style("fg_focus","bg_focus")
      else
          prefix,bg = gen_style("fg_normal","bg_normal")
      end
    end
    
    return prefix..((tab.clientgroup and tab.clientgroup.title) or (tab.client and tab.client.name) or "N/A3")..suffix, bg, nil, nil, bg
end

local function create_dnd_widget(title)
    local xpos  = capi.mouse.coords().x
    local ypos  = capi.mouse.coords().y
    local wb    = wibox({position="free",width=200,height=18,x=xpos-100,y=ypos-9,ontop=true})
    local textb = capi.widget({type="textbox"})
    textb.text  = title
    wb.widgets  = {textb, layout = layout.horizontal.leftright}
    wb.visible  = false
    return wb
end

local function tasklist_update(tabs, w, buttons, label, data, widgets, tab)
  common.list_update(w, buttons, label, data, widgets, tabs)
end

--- Create a new tasklist widget.
-- @param label Label function to use.
-- @param buttons A table with buttons binding to set.
function new(label, buttons,cg)
    local tabs = {}
    local w = {}
    local data = setmetatable({}, { __mode = 'k' })
    local label2 = label or function (tab) 
                                        return widget_tasklist_label_common(tab,w)
                                      end
    local widgets = { }
    widgets.imagebox = { }
    widgets.textbox  = { margin    = { left  = 2,
                                       right = 2 },
                         bg_resize = true,
                         bg_align  = "right"
                       }
    
    w.widgets_real = {layout = layout.horizontal.flex}
    
    local u = function () tasklist_update(tabs, w.widgets_real, buttons2, label2, data, widgets) end
    
    local buttons2 = buttons or util.table.join(
                    awButtons({ }, 1, function (tab)
                                        cg:set_active(tab.clientgroup)
                                        ultilayoutC.drag_cg(cg)
                                      end),
                    awButtons({ }, 2, function (tab)
                                          local wb = create_dnd_widget(cg.title or  "N/A2")
                                          ultilayoutC.drag_cg(tab.clientgroup,nil,{wibox = wb, button = 2})
                                      end)
                    )
    cg:add_signal("active::changed",u)
    
    function w:add_tab_cg(new_cg, no_focus)
      if not new_cg then return end
      local aTab = {clientgroup = new_cg, selected = no_focus or true}
      table.insert(tabs, aTab)
      tasklist_update(tabs, w.widgets_real, buttons2, label2, data, widgets)
      return aTab
    end
    
    function w:remove_tab(tab)
        for k,v in pairs(tabs) do
            if v == tab then
                tabs[k] = nil
                tasklist_update(tabs, w.widgets_real, buttons2, label2, data, widgets)
                return
            end
        end
    end
    
    function w:focus2()
      w.focus = true
      tasklist_update(tabs, w.widgets_real, buttons2, label2, data, widgets)
    end
    
    function w:unfocus2()
      w.focus = false
      tasklist_update(tabs, w.widgets_real, buttons2, label2, data, widgets)
    end
    
    function w:update()
      tasklist_update(tabs, w.widgets_real, buttons2, label2, data, widgets)
    end
    u()
    return w
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
