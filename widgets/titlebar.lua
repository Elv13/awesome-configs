---------------------------------------------------------------------------
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @copyright 2011 Emmanuel Lepage Vallee
-- @release v4.0
---------------------------------------------------------------------------
local math         = math
local image        = image
local pairs        = pairs
local type         = type
local setmetatable = setmetatable
local debug        = debug
local print        = print
local table        = table
local type         = type
local capi  = {
    awesome = awesome ,
    wibox   = wibox   ,
    image   = image   ,
    widget  = widget  ,
    client  = client  }
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
local config         = require( "config"               )

module("widgets.titlebar")

-- Privata data
local data = setmetatable({}, { __mode = 'k' })
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
  if config.data.titlebars == nil then
      config.data.titlebars = {}
  end
  if c.titlebar == nil then
    local retval = create(c,args)
    config.data.titlebars[retval.wibox] = retval.tablist
  else
    c.titlebar.visible = true
  end
end

function create(c, args)
    local theme = beautiful.get()
    local buttons = {}
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
    data[c].width    = args.width    --
    
    local holder = data[c]
    --Buttons creation
    function holder:button_group(args)
        local data = {
            field      = args.field   or ""                   , --will explode
            focus      = args.focus   or false                ,
            checked    = args.checked or false                ,
            widget     = nil                                  ,
            onclick    = args.onclick or args.button1 or nil  ,
            mbuttons    = {                                   --
                args.button1          or args.onclick or nil  ,
            }                                                 ,
            wdgprop    = {                                   --
                width    = args.width or 0                    ,
                bg       = args.bg    or nil                  ,
            }                                                 ,
        }
        
        for i=2, 10 do
            data.mbuttons[i]   = args["button"..i]
        end
        
        function data:setImage(hover)
            local curfocus    = (hover == true) and "hover" or ((((type(data.focus) == "function") and data.focus() or data.focus) == true) and "focus" or "normal")
            local curactive   = ((((type(data.checked) == "function") and data.checked() or data.checked) == true) and "active" or "inactive")
            data.widget.image = capi.image( config.data.themePath.. "Icon/titlebar/" .. data.field .."_"..curfocus .."_"..curactive..".png"  )
        end
        
        function data:createWidget()
            local wdg = capi.widget({type="imagebox"})
            for k,v in pairs(data.wdgprop) do
                wdg[k] = v
            end
            wdg:buttons( util.table.join(
                button({ }, 1 , data.mbuttons[1 ]),
                button({ }, 2 , data.mbuttons[2 ]),
                button({ }, 3 , data.mbuttons[3 ]),
                button({ }, 4 , data.mbuttons[4 ]),
                button({ }, 5 , data.mbuttons[5 ]),
                button({ }, 6 , data.mbuttons[6 ]),
                button({ }, 7 , data.mbuttons[7 ]),
                button({ }, 8 , data.mbuttons[8 ]),
                button({ }, 9 , data.mbuttons[9 ]),
                button({ }, 10, data.mbuttons[10])
            ))
            return wdg
        end
        data.widget = wdg or data:createWidget()
        data:setImage()
        return data
    end
    
    buttons.close     = data[c]:button_group({width=5, field = "close",     focus = false, checked = false                             , onclick = function() c:kill()                      end })
    buttons.ontop     = data[c]:button_group({width=5, field = "ontop",     focus = false, checked = function() return c.ontop     end , onclick = function() c.ontop     = not c.ontop     end })
    buttons.floating  = data[c]:button_group({width=5, field = "floating",  focus = false, checked = function() return c.floating  end , onclick = function() c.floating  = not c.floating  end })
    buttons.sticky    = data[c]:button_group({width=5, field = "sticky",    focus = false, checked = function() return c.sticky    end , onclick = function() c.sticky    = not c.sticky    end })
    buttons.maximized = data[c]:button_group({width=5, field = "maximized", focus = false, checked = function() return c.maximized end , onclick = function() c.maximized = not c.maximized end })
    
    if not args.height then
      args.height = 16
    end
    
    local tb = capi.wibox(args)
    local tl = tabList.new(nil,nil)

    -- Redirect relevant events to the client the titlebar belongs to
    local bts = util.table.join(
        abutton({             }, 1, function()  button_callback_focus_raise_move(nil,tb) end ),
        abutton({ args.modkey }, 1, function()  button_callback_move(nil,tb) end             ),
        abutton({ args.modkey }, 3, function()  button_callback_resize(nil,tb) end           )
    )
    tb:buttons(bts)
    tl:add_tab(c).selected = true
    
    local appicon = capi.widget({type="imagebox"})
    
    tb.widgets = {                            --
        {                                     --
          appicon                              ,
          layout = layout.horizontal.leftright ,
        }                                      ,
        buttons.close.widget                   ,
        buttons.ontop.widget                   , 
        buttons.maximized.widget               ,
        buttons.sticky.widget                  ,
        buttons.floating.widget                ,
        layout = layout.horizontal.rightleft   ,
        tl                                     ,
    }
    
    --- Update a titlebar. This should be called in some hooks.
    -- @param c The client to update.
    -- @param prop The property name which has changed.
    function holder:update(c,event)
        if c.titlebar and data[c] then
            if event == 'focus' then
                tl:focus2()
            elseif event == 'unfocus' then
                tl:unfocus2()
            end
            
            local widgets = c.titlebar.widgets
            appicon.image = c.icon
            
            for k,v in pairs({close, ontop, floating, sticky, maximized}) do
                v:setImage()
            end
            
            c.titlebar.fg = (capi.client.focus == c) and data[c].fg_focus or data[c].fg
            c.titlebar.bg = (capi.client.focus == c) and data[c].bg_focus or data[c].bg
        end
    end
    c.titlebar = tb
    for k,v in pairs({"icon","name","sticky","floating","ontop","maximized_vertical","maximized_horizontal"}) do
        c:add_signal("property::"..v, function(c) holder:update(c) end)
    end
    holder:update(c)
    return {wibox = tb, tablist = tl}
end

--- Remove a titlebar from a client.
-- @param c The client.
function remove(c)
    if not c.titlebar then return end
    c.titlebar.visible = false
end

-- Register standards hooks
capi.client.add_signal("focus"   , function(c) if data[c] then data[c]:update(c,'focus'  ) end end)
capi.client.add_signal("unfocus" , function(c) if data[c] then data[c]:update(c,'unfocus') end end)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80