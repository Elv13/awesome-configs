---------------------------------------------------------------------------
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.4-rc3
---------------------------------------------------------------------------

-- Grab environment we need
local capi = { screen = screen,
               image = image,
               client = client }
local ipairs = ipairs
local type = type
local print = print
local setmetatable = setmetatable
local table = table
local common = require("awful.widget.common")
local beautiful = require("beautiful")
local client = require("awful.client")
local util = require("awful.util")
local tag = require("awful.tag")
local layout = require( "wibox.layout" )
local awButtons = require("awful.button")

--- Tasklist widget module for awful
module("widgets.tablist_old")

-- Public structures
label = {}

function widget_tasklist_label_common(tab, w)
    local numberStyle = "<span size='x-large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span> "
    local suffix, prefix = "",""
    if w.focus == true then
      if tab.selected == false then
        bg = beautiful.bg_focus
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_focus).."'>"
        suffix = "</span>"
      else
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_normal).."'>"
        bg = beautiful.bg_normal
        suffix = "</span>"
      end
    else
      if tab.selected == false then
        bg = beautiful.bg_normal
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_normal).."'>"
        suffix = "</span>"
      else
        prefix = "<span color='"..util.color_strip_alpha(beautiful.fg_focus).."'>"
        bg = beautiful.bg_focus
        suffix = "</span>"
      end
    end
    
    if not args then args = {} end
    local theme = beautiful.get()
    return prefix..tab.pid.."["..tab.index.."]"..suffix, bg, nil, nil, bg
end

local function tasklist_update(tabs, w, buttons, label, data, widgets, tab)
  local numberStyle = "<span size='x-large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
  local numberStyleEnd = "</b></tt></span> "
  
  common.list_update(w, buttons, label, data, widgets, tabs)
end

--- Create a new tasklist widget.
-- @param label Label function to use.
-- @param buttons A table with buttons binding to set.
local function new(label, buttons)
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
    local buttons2 = buttons or util.table.join(
                    awButtons({ }, 1, function (tab) 
                                        
                                        for kt, t in ipairs(tabs) do
                                          t.selected = false
                                        end
                                        
                                        tab.selected = true 
                                        util.spawn('dbus-send --type=method_call --dest=org.schmorp.urxvt /term/'..(tab.pid or 0)..'/control org.schmorp.urxvt.selectTab int32:'..tab.index)
                                        
                                        tasklist_update(tabs, w, buttons2, label2, data, widgets,tab)
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
    local index =0
    function w:add_tab(pid)
      local aTab = {name = "test2", index = index, pid = pid, selected = false}
      table.insert(tabs, aTab)
      tasklist_update(tabs, w, buttons2, label2, data, widgets)
      index = index + 1
      return aTab
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
