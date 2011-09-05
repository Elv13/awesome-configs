---------------------------------------------------------------------------
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @copyright 2011 Emmanuel Lepage Vallee
-- @release v4.0
---------------------------------------------------------------------------

-- Grab environment we need
local math         = math
local image        = image
local pairs        = pairs
local type         = type
local setmetatable = setmetatable
local print        = print
local table        = table
local type         = type
local capi = {
    awesome = awesome ,
    wibox   = wibox   ,
    image   = image   ,
    widget  = widget  ,
    client  = client  ,
    dbus    = dbus    ,
    timer   = timer   }
    
local abutton        = require( "awful.button"         )
local beautiful      = require( "beautiful"            )
local button         = require( "awful.button"         )
local util           = require( "awful.util"           )
local widget         = require( "awful.widget"         )
local mouse          = require( "awful.mouse"          )
local client         = require( "awful.client"         )
local layout         = require( "awful.widget.layout"  )
local clientSwitcher = require( "utils.clientSwitcher" )
local tabList        = require( "widgets.tablist"      )

module("widgets.titlebar")

-- Privata data
local data = setmetatable({}, { __mode = 'k' })

local idxWdg = {}

local numbers = {'①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳'}

-- Predeclaration for buttons
local button_groups

local function button_callback_focus_raise_move(w, t)
    capi.client.focus = t.client
    t.client:raise()
    mouse.client.move(t.client)
end

local function button_callback_move(w, t)
    return mouse.client.move(t.client)
end

local function button_callback_resize(w, t)
    return mouse.client.resize(t.client)
end

--- Create a standard titlebar.
-- @param c The client.
-- @param args Arguments.
-- modkey: the modkey used for the bindings.
-- fg: the foreground color.
-- bg: the background color.
-- fg_focus: the foreground color for focused window.
-- fg_focus: the background color for focused window.
-- width: the titlebar width
function add(c, args)
  if c.titlebar == nil then
    create(c,args)
  else
    c.titlebar.visible = true
    if idxWdg[c.titlebar] then
      local theme = beautiful.get()
      local numberStyle = "<span size='large' bgcolor='".. theme.fg_normal .."'color='".. theme.bg_normal .."'><tt><b>"--"<span size='x-large' bgcolor='".. theme.fg_normal .."'color='".. theme.bg_normal .."'><tt><b>"
      local numberStyleEnd = "</b></tt></span>"--"</b></tt></span> "
      idxWdg[c.titlebar].text = numberStyle .. (numbers[clientSwitcher.getIndex(c)] or "N/A") .. numberStyleEnd
    end
  end
end

function create(c, args)
    local theme = beautiful.get()
    local numberStyle = "<span  size='large'bgcolor='".. theme.fg_normal .."'color='".. theme.bg_normal .."'><tt><b>"--"<span size='x-large' bgcolor='".. theme.fg_normal .."'color='".. theme.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span>"--"</b></tt></span> "
    if not c or (c.type ~= "normal" and c.type ~= "dialog") then return end
    if not args then args = {} end
    if not args.height then args.height = capi.awesome.font_height * 1.5 end

    if not args.widget then customwidget = {} else customwidget = args.widget end
    -- Store colors
    data[c] = {}
    data[c].fg       = args.fg       or theme.titlebar_fg_normal or theme.fg_normal
    data[c].bg       = args.bg       or theme.titlebar_bg_normal or theme.bg_normal
    data[c].fg_focus = args.fg_focus or theme.titlebar_fg_focus  or theme.fg_focus
    data[c].bg_focus = args.bg_focus or theme.titlebar_bg_focus  or theme.bg_focus
    data[c].font     = args.font     or theme.titlebar_font      or theme.font
    data[c].width    = args.width
    
    --Buttons creation
    function data[c]:button_group(args)
        local c          = args.client or nil--will explode
        local field      = args.field  or "" --will explode
        local focus      = args.focus  or false
        local checked    = args.checked or false
        local widget     = nil
        local onclick    = args.onclick or args.button1 or nil
        local buttons    = {}
        local wdgprop    = {}
        wdgprop["width"] = args.width or 0
        wdgprop["bg"]    = args.bg or nil
        buttons[1]       = args.button1 or args.onclick or nil
        for i=2, 10 do
            buttons[i]   = args["button"..i]
        end
        
        local function setImage(hover)
            local curfocus  = (hover == true) and "hover" or ((((type(focus) == "function") and focus() or focus) == true) and "focus" or "normal")
            local curactive = ((((type(checked) == "function") and checked() or checked) == true) and "active" or "inactive")
            widget.image    = capi.image( config.data.themePath.. "Icon/titlebar/" .. field .."_"..curfocus .."_"..curactive..".png"  )
        end
        
        local function createWidget()
            local wdg = capi.widget({type="imagebox"})
            for k,v in pairs(wdgprop) do
                wdg[k] = v
            end
            wdg:buttons( util.table.join(
                button({ }, 1 , buttons[1])
            ))
            return wdg
        end
        widget = wdg or createWidget()
        setImage()
        return widget
    end
    
--     local close     = button_group({client = v, width=5, field = "close",     focus = false, checked = false                            , onclick = function() v:kill() end                      })
--     local ontop     = button_group({client = v, width=5, field = "ontop",     focus = false, checked = function() return v.ontop end    , onclick = function() v.ontop = not v.ontop end         })
--     local floating  = button_group({client = v, width=5, field = "floating",  focus = false, checked = function() return v.floating end , onclick = function() v.floating = not v.floating end   })
--     local sticky    = button_group({client = v, width=5, field = "sticky",    focus = false, checked = function() return v.sticky end   , onclick = function() v.sticky = not v.sticky end       })
--     local maximized = button_group({client = v, width=5, field = "maximized", focus = false, checked = function() return v.maximized end, onclick = function() v.maximized = not v.maximized end })
--     fkeyMapping[itemCount] = currentMenu:add_item({
--         prefix  = numberStyle.."[F".. itemCount .."]"..numberStyleEnd, 
--         text    = v.name, 
--         onclick = function() capi.client.focus = v end, 
--         icon    = v.icon,
--         addwidgets = {
--                         close,
--                         ontop, 
--                         maximized,
--                         sticky,
--                         floating,
--                         layout = widget2.layout.horizontal.rightleft
--                         }
--     })
--     fkeyMapping[itemCount].c = v
--     itemCount = itemCount + 1

    --if not args.height then
      args.height = 16
    --end
    local tb = capi.wibox(args)

    local title = capi.widget({ type = "textbox" })
    if c.name then
        title.text = "<span font_desc='" .. data[c].font .. "'> " ..
                     util.escape(c.name) .. " </span>"
    end

    -- Redirect relevant events to the client the titlebar belongs to
    local bts = util.table.join(
        abutton({ }, 1, button_callback_focus_raise_move),
        abutton({ args.modkey }, 1, button_callback_move),
        abutton({ args.modkey }, 3, button_callback_resize))
    title:buttons(bts)

    idxWdg[tb]       = capi.widget({ type = "textbox" })
    idxWdg[tb].text  = numberStyle .. (numbers[clientSwitcher.getIndex(c)] or "N/A") .. numberStyleEnd
    
    -- for each button group, call create for the client.
    -- if a button set is created add the set to the
    -- data[c].button_sets for late updates and add the
    -- individual buttons to the array part of the widget
    -- list
    local widget_list = {
        layout = layout.horizontal.rightleft
    }
    local iw = 1
    local is = 1
    data[c].button_sets = {}
    for i = 1, #button_groups do
        local set = button_groups[i].create(c, args.modkey, theme)
        if (set) then
            data[c].button_sets[is] = set
            is = is + 1
            for n,b in pairs(set) do
                widget_list[iw] = b
                iw = iw + 1
            end
        end
    end
    
    local aTabList = tabList.new(nil,nil)
    aTabList:add_tab(c.window).selected = true
    
    tb.widgets = {
        widget_list,
        {
          appicon,
          idxWdg[tb],
          layout = layout.horizontal.leftright
        },
        layout = layout.horizontal.rightleft,
        aTabList,
    }
    
    capi.client.add_signal("focus", function(c2)
      if c == c2 then
        aTabList:focus2()
      end
    end)
    
    capi.client.add_signal("unfocus",  function(c2)
      if c == c2 then
        aTabList:unfocus2()
      end
    end)

    c.titlebar = tb

    c:add_signal("property::icon"                 , update)
    c:add_signal("property::name"                 , update)
    c:add_signal("property::sticky"               , update)
    c:add_signal("property::floating"             , update)
    c:add_signal("property::ontop"                , update)
    c:add_signal("property::maximized_vertical"   , update)
    c:add_signal("property::maximized_horizontal" , update)
    update(c)
end

--- Update a titlebar. This should be called in some hooks.
-- @param c The client to update.
-- @param prop The property name which has changed.
function update(c)
     if c.titlebar and data[c] then
        local widgets = c.titlebar.widgets
        if widgets[3].title then
            widgets[3].title.text = "<span font_desc='" .. data[c].font ..
            "'> ".. util.escape(c.name or "<unknown>") .. " </span>"
        end
        if widgets[3].appicon then
            widgets[3].appicon.image = c.icon
        end
        
        c.titlebar.fg = (capi.client.focus == c) and data[c].fg_focus or data[c].fg
        c.titlebar.bg = (capi.client.focus == c) and data[c].bg_focus or data[c].bg

        -- iterated of all registered button_sets and update
--         local sets = data[c].button_sets
--         for i = 1, #sets do
--             sets[i].update(c,prop)
--         end
    end
end

--- Remove a titlebar from a client.
-- @param c The client.
function remove(c)
    c.titlebar.visible = false
    --c.titlebar = nil --No more of that please
    --data[c] = nil
end

button_groups = { close_buttons,
                  ontop_buttons,
                  sticky_buttons,
                  maximized_buttons,
                  floating_buttons }

-- Register standards hooks
capi.client.add_signal("focus"   , update)
capi.client.add_signal("unfocus" , update)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
