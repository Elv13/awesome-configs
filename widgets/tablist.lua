---------------------------------------------------------------------------
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-rc3
---------------------------------------------------------------------------

-- Grab environment we need
local capi = { screen       =      screen ,
               image        =      image  ,
               client       =      client ,
               wibox        =      wibox  ,
               mouse        =      mouse  ,
               widget       =      widget ,
               mousegrabber = mousegrabber}
local ipairs       = ipairs
local pairs        = pairs
local type         = type
local print        = print
local setmetatable = setmetatable
local table        = table
local common       = require( "awful.widget.common" )
local beautiful    = require( "beautiful"           )
local client       = require( "awful.client"        )
local wibox        = require( "awful.wibox"         )
local util         = require( "awful.util"          )
local tag          = require( "awful.tag"           )
local layout       = require( "awful.widget.layout" )
local awButtons    = require( "awful.button"        )
local config       = require( "config"              )
--local titlebar = require("widgets.titlebar")

--- Tasklist widget module for awful
module("widgets.tablist")

-- Public structures
label = {}

function widget_tasklist_label_common(tab, w)
    local numberStyle = "<span size='x-large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span> "
    local suffix, prefix = "",""
    if w.focus == true then
      if tab.selected == false then
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_normal).."'>"
        bg = beautiful.bg_highlight
        suffix = "</span>"
      else
        bg = beautiful.bg_focus
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_focus).."'>"
        suffix = "</span>"
      end
    else
      if tab.selected == false then
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_focus).."'>"
        bg = beautiful.bg_focus
        suffix = "</span>"
      else
        bg = beautiful.bg_normal
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_normal).."'>"
        suffix = "</span>"
      end
    end
    
    if not args then args = {} end
    local theme = beautiful.get()
    return prefix..((tab.clientgroup and tab.clientgroup.title) or (tab.client and tab.client.name) or "N/A3")..suffix, bg, nil, nil, bg
end

local function tasklist_update(tabs, w, buttons, label, data, widgets, tab)
  local numberStyle = "<span size='x-large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
  local numberStyleEnd = "</b></tt></span> "
  
  common.list_update(w, buttons, label, data, widgets, tabs)
end

--- Create a new tasklist widget.
-- @param label Label function to use.
-- @param buttons A table with buttons binding to set.
function new(label, buttons,cg)
    local tabs = {}
    local w = {
        layout = layout.horizontal.flex
    }
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
    w.widgets = widgets
    
    function w:get_cg()
        return cg
    end
    
    local buttons2 = buttons or util.table.join(
                    awButtons({ }, 1, function (tab) 
                                        for kt, t in ipairs(tabs) do
                                          t.selected = false
                                        end
                                        
                                        tab.selected = true 
                                        cg:set_active(tab.clientgroup)
--                                         util.spawn('dbus-send --type=method_call --dest=org.schmorp.urxvt /term/'..(tab.title or 0)..'/control org.schmorp.urxvt.selectTab int32:'..tab.index)
                                        
                                        tasklist_update(tabs, w, buttons2, label2, data, widgets,tab)
                                      end),
                    awButtons({ }, 2, function (tab) 
                                          local xpos  = capi.mouse.coords().x
                                          local ypos  = capi.mouse.coords().y
                                          local wb     = wibox({position="free",width=200,height=18,x=xpos-100,y=ypos-9,ontop=true})
                                          local textb = capi.widget({type="textbox"})
                                          textb.text  = cg.title or  "N/A2"
                                          wb.widgets   = {textb, layout = layout.horizontal.leftright}
                                          capi.mousegrabber.run(function(mouse)
                                              if mouse.buttons[2] == false then 
                                                  wb.visible = false
                                                  wb = nil
                                                  local obj = capi.mouse.object_under_pointer()
                                                  if type(obj) == "wibox" then
                                                      if obj.position ~= nil then
                                                        if config.data().titlebars[obj] ~= nil then
                                                           w:remove_tab(tab)
                                                           config.data().titlebars[obj]:get_cg():attach(tab.clientgroup)
                                                           --config.data().titlebars[obj]:add_tab_cg(tab.clientgroup)
                                                        end
                                                      end
                                                  end
                                                  capi.mousegrabber.stop()
                                                  return false 
                                              end
                                              wb:geometry({width=200,height=18,x=mouse.x-100,y=mouse.y-9})
                                              return true
                                          end,"fleur")--What is the second args beside flowers?
                                      end)
                    )
    local u = function () tasklist_update(tabs, w, buttons2, label2, data, widgets) end
    for s = 1, capi.screen.count() do
        tag.attached_add_signal(s, "property::selected", u)
        capi.screen[s]:add_signal("tag::attach", u)
        capi.screen[s]:add_signal("tag::detach", u)
    end
--     capi.client.add_signal("new", function (c)
--         c:add_signal("property::urgent", u)
--         c:add_signal("property::floating", u)
--         c:add_signal("property::maximized_horizontal", u)
--         c:add_signal("property::maximized_vertical", u)
--         c:add_signal("property::name", u)
--         c:add_signal("property::icon_name", u)
--         c:add_signal("property::skip_taskbar", u)
--         c:add_signal("property::hidden", u)
--         c:add_signal("tagged", u)
--         c:add_signal("untagged", u)
--     end)
--     capi.client.add_signal("unmanage", u)
--     capi.client.add_signal("list", u)
--     capi.client.add_signal("focus", u)
--     capi.client.add_signal("unfocus", u)
    function w:add_tab(c)
      if not c then return end
      local aTab = {client = c, selected = false}
      table.insert(tabs, aTab)
      tasklist_update(tabs, w, buttons2, label2, data, widgets)
      return aTab
    end
    
    function w:add_tab_cg(new_cg, no_focus)
      if not new_cg then return end
      local aTab = {clientgroup = new_cg, selected = no_focus or true}
      table.insert(tabs, aTab)
      
      --cg:attach(new_cg)
      tasklist_update(tabs, w, buttons2, label2, data, widgets)
      return aTab
    end
    
    function w:remove_tab(tab)
        for k,v in pairs(tabs) do
            if v == tab then
                tabs[k] = nil
                if k > 1 then
                    tabs[k-1].selected = true
                elseif k+1 < #tabs then
                    tabs[k+1].selected = true
                end
                tasklist_update(tabs, w, buttons2, label2, data, widgets)
                return
            end
        end
    end
    
    function w:focus2()
      w.focus = true
      tasklist_update(tabs, w, buttons2, label2, data, widgets)
    end
    
    function w:unfocus2()
      w.focus = false
      tasklist_update(tabs, w, buttons2, label2, data, widgets)
    end
    
    function w:update()
      tasklist_update(tabs, w, buttons2, label2, data, widgets)
    end
    u()
    return w
end




function label.allscreen(c, screen, args)
    return widget_tasklist_label_common(c, args)
end

function label.alltags(c, screen, args)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return end
    return widget_tasklist_label_common(c, args)
end

function label.currenttags(c, screen, args)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return end
    -- Include sticky client too
    if c.sticky then return widget_tasklist_label_common(c, args) end

    for k, t in ipairs(capi.screen[screen]:tags()) do
        if t.selected then
            local ctags = c:tags()
            for _, v in ipairs(ctags) do
                if v == t then
                    return widget_tasklist_label_common(c, args)
                end
            end
        end
    end
end

function label.focused(c, screen, args)
    -- Only print client on the same screen as this widget
    if c.screen == screen and capi.client.focus == c then
        return widget_tasklist_label_common(c, args)
    end
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
