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
local print        = print
local setmetatable = setmetatable
local unpack       = unpack
local table        = table
local common       = require( "awful.widget.common"     )
local beautiful    = require( "beautiful"               )
local wibox        = require( "awful.wibox"             )
local util         = require( "awful.util"              )
local layout       = require( "awful.widget.layout"     )
local awButtons    = require( "awful.button"            )
local object_model = require( "ultiLayout.object_model" )

module("ultiLayout.widgets.tablist")

local function create_tab(no_focus,tabs)
    local tab = {}
    local private_data = {selected = no_focus or true,title="N/A",tabs = tabs}
    local get_map, set_map = {},{}
    object_model(tab,get_map,set_map,private_data,{
        autogen_getmap      = true ,
        autogen_signals     = true ,
        auto_signal_changed = true ,
        force_private       = {
            selected        = true ,
            title           = true }
    })
    return tab
end

function widget_tasklist_label_common(tab,w)
    local color = ((tab.selected == true) and "_active" or "_innactive") .. ((w.focus == true) and "_focus" or "_normal")
    local suffix,prefix,bg = "</span>",(w.count >1) and "<span color='"..w["fg"..color].."'>" or nil, (w.count >1) and w["bg"..color] or nil
    if tab.tabs and (#tab.tabs == 1) or (not tab.selected and #tab.tabs > 1) then
        bg = "#00000000"
    end
    return (prefix or "<span>")..tab.title..suffix, bg, nil, nil, bg
end

function create_dnd_widget(title)
    local wb    = wibox({position="free",width=200,height=18,x=capi.mouse.coords().x-100,y=capi.mouse.coords().y-9,ontop=true})
    local textb = capi.widget({type="textbox"})
    textb.text  = title
    wb.widgets  = {textb, layout = layout.horizontal.leftright}
    wb.visible  = false
    return wb
end

--- Create a new tasklist widget.
-- @param label Label function to use.
-- @param buttons A table with buttons binding to set.
function new(label, buttons)
    local tabs,w,private_data = {},{},{
        focus                      = false,
        bg_active_focus            = beautiful.bg_focus,
        fg_active_focus            = beautiful.fg_focus,
        bg_active_normal           = beautiful.bg_highlight or beautiful.bg_normal,
        fg_active_normal           = beautiful.fg_normal,
        bg_innactive_normal        = beautiful.bg_normal,
        fg_innactive_normal        = beautiful.fg_normal,
        bg_innactive_focus         = beautiful.bg_highlight or beautiful.bg_normal,
        fg_innactive_focus         = beautiful.fg_normal,
    }
    
    local data = setmetatable({}, { __mode = 'k' })
    local label2 = label or function(tab) return widget_tasklist_label_common(tab,w) end
    local widgets = { }
    widgets.imagebox = { }
    widgets.textbox  = { margin    = { left  = 2,
                                       right = 2 },
                         bg_resize = true,
                         bg_align  = "right"
                       }
    
    w.widgets_real = {layout = layout.horizontal.flex}
    
    object_model(w,{count=function() return #tabs end},{},private_data,{
        autogen_getmap      = true,
        autogen_signals     = true,
        auto_signal_changed = true,
        force_private       = {
            focus = true
        }
    })
    
    local buttons_t = {}
    for i=1,10 do
        table.insert(buttons_t,awButtons({ }, i , function(tab) w:emit_signal("button".. i .."::clicked",tab) end))
    end
    local buttons2 = buttons or util.table.join(unpack(buttons_t))
    
    local function tasklist_update()
        common.list_update(w.widgets_real, buttons2, label2, data, widgets, tabs)
    end
    
    function w:add_tab(no_focus)
        local aTab = create_tab(no_focus,tabs)
        aTab:add_signal( "changed"    ,tasklist_update)
        table.insert(tabs, aTab)
        tasklist_update()
        return aTab
    end
    
    function w:remove_tab(tab)
        for k,v in pairs(tabs) do
            if v == tab then
                table.remove(tabs,k)
                tasklist_update()
                return
            end
        end
    end
    
    w:add_signal("changed",tasklist_update)
    
    tasklist_update()
    return w
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })