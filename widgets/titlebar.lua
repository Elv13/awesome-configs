---------------------------------------------------------------------------
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @copyright 2011 Emmanuel Lepage Vallee
-- @release v4.0
---------------------------------------------------------------------------
local pairs        = pairs
local print        = print
local type         = type
local setmetatable = setmetatable
local table        = table
local capi  = {
    awesome = awesome ,
    wibox   = wibox   ,
    image   = image   ,
    widget  = widget  ,
    client  = client  }
local beautiful      = require( "beautiful"            )
local button         = require( "awful.button"         )
local util           = require( "awful.util"           )
local mouse          = require( "awful.mouse"          )
local client         = require( "awful.client"         )
local layout         = require( "awful.widget.layout"  )
local wibox          = require( "awful.wibox"          )
local tabList        = require( "widgets.tablist"      )
local config         = require( "config"               )

module("widgets.titlebar")

local data     = setmetatable({}, { __mode = 'k' })
local leftW    = nil
local rightW   = nil
local buttonsA = nil
local hooks    = {}
local signals  = {}

function add_signal(name,func)
    if not signals[name] then
        signals[name] = {}
    end
    table.insert(signals[name],func)
end

function registerCustomClass(className, func)
    hooks[className] = func
end

function buttons(args)
    buttonsA = args
end

local function create(c, args)
    if not c or (c.type ~= "normal" and c.type ~= "dialog") then return end
    local theme        = beautiful.get()
    local buttons      = {}
    args               = args or {}
    args.height        = args.height or beautiful.titlebar_height or capi.awesome.font_height * 1.5
    
    -- Store colors
    local titlebar     = {}
    titlebar.client    = c
    titlebar.fg        = args.fg       or theme.titlebar_fg_normal or theme.titlebar_fg_normal or theme.fg_normal
    titlebar.bg        = args.bg       or theme.titlebar_bg_normal or theme.bg_normal
    titlebar.fg_focus  = args.fg_focus or theme.titlebar_fg_focus  or theme.titlebar_fg_focus  or theme.fg_focus
    titlebar.bg_focus  = args.bg_focus or theme.titlebar_bg_focus  or theme.bg_focus
    titlebar.font      = args.font     or theme.titlebar_font      or theme.font
    titlebar.width     = args.width    --
    data[c]            = titlebar
    
    local dataSignals = {}
    function titlebar:add_signal(name,func)
        if not dataSignals[name] then
            dataSignals[name] = {}
        end
        table.insert(dataSignals[name],func)
    end
    
    --Buttons creation
    function titlebar:button_group(args)
        local data = {
            field      = args.field   or ""                   , --will explode
            focus      = args.focus   or false                ,
            checked    = args.checked or false                ,
            onclick    = args.onclick or args.button1 or nil  ,
            widget     = nil                                  ,
            mbuttons   = {                                   --
                args.button1          or args.onclick or nil },
            wdgprop    = {                                   --
                width    = args.width or 0                    ,
                bg       = args.bg    or nil                  }
        }
        
        for i=2, 10 do
            data.mbuttons[i]   = args["button"..i]
        end
        
        function data:setImage(hover)
            local curfocus    = (((type(data.focus) == "function") and data.focus() or data.focus) == true) and "focus" or "normal"
            local curactive   = ((((type(data.checked) == "function") and data.checked() or data.checked) == true) and "active" or "inactive")
            data.widget.image = capi.image((beautiful["titlebar_"..data.field .."_button_"..curfocus .."_"..curactive.. ((hover == true) and "_hover" or "")]) 
                or  (beautiful["titlebar_"..data.field .."_button_"..curfocus .. ((hover == true) and "_hover" or "")])
                or  (beautiful["titlebar_"..data.field .."_button_"..curfocus.."_"..curactive])
                or  (beautiful["titlebar_"..data.field .."_button_"..curfocus]))
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
            
            wdg:add_signal("mouse::enter", function() self:setImage(true) end)
            wdg:add_signal("mouse::leave", function() self:setImage(false) end)
      
            return wdg
        end
        data.widget = wdg or data:createWidget()
        data:setImage()
        return data
    end
    
    buttons.close     = titlebar:button_group({width=5, field = "close",     focus = false, checked = false                             , onclick = function() c:kill()                      end })
    buttons.ontop     = titlebar:button_group({width=5, field = "ontop",     focus = false, checked = function() return c.ontop     end , onclick = function() c.ontop     = not c.ontop     end })
    buttons.floating  = titlebar:button_group({width=5, field = "floating",  focus = false, checked = function() return c.floating  end , onclick = function() c.floating  = not c.floating  end })
    buttons.sticky    = titlebar:button_group({width=5, field = "sticky",    focus = false, checked = function() return c.sticky    end , onclick = function() c.sticky    = not c.sticky    end })
    buttons.maximized = titlebar:button_group({width=5, field = "maximized", focus = false, checked = function() return c.maximized end , onclick = function() c.maximized = not c.maximized end })
    
    if not args.height then
      args.height = 16
    end
    
    local tb = capi.wibox(args)
    local tl = tabList.new(nil,nil)
    
    local bts = util.table.join(
        button({             }, 1, function() 
                                      capi.client.focus = tb.client
                                      tb.client:raise()
                                      mouse.client.move(tb.client) 
                                   end ),
        button({ args.modkey }, 1, function() return mouse.client.move(tb.client)      end ),
        button({ args.modkey }, 3, function() return mouse.client.resize(tb.client)    end )
    )
    tb:buttons(bts)
    tl:add_tab(c).selected = true
    
--     if beautiful.titlebar_mask then
--         tb:add_signal("property::width",function()
--             local mask = beautiful.titlebar_mask(tb.width,tb.height)
--             tb.shape_clip      = mask
--             tb.shape_bounding  = mask
--             tb.bg_image = mask
--         end)
--     end
    
    local appicon = capi.widget({type="imagebox"})
    
    local userWidgets
    if hooks[c.class] ~= nil then
        userWidgets = hooks[c.class]({buttons=buttons,icon=appicon,tabbar=tl,wibox=tb},titlebar,c)
    elseif #(signals['create'] or {}) > 0 then
        userWidgets = signals['create'][1]({buttons=buttons,icon=appicon,tabbar=tl,wibox=tb},titlebar)
    end
    if not tb.widgets then
        tb.widgets =                {             --
            {                                     --
            appicon                                ,
            layout = layout.horizontal.leftright   ,
            }                                      ,
            buttons.close.widget                   ,
            buttons.ontop.widget                   , 
            buttons.maximized.widget               ,
            buttons.sticky.widget                  ,
            buttons.floating.widget                ,
            layout = layout.horizontal.rightleft   ,
            tl                                     ,
        }
    end
    
    function titlebar:update(c,event)
        if c.titlebar and titlebar then
            if event     == 'focus'   then
                tl:focus2()
            elseif event == 'unfocus' then
                tl:unfocus2()
            end
            
            local widgets = c.titlebar.widgets
            appicon.image = c.icon
            for k,v in pairs(buttons) do
                v:setImage()
            end
            c.titlebar.fg = (capi.client.focus == c) and titlebar.fg_focus or titlebar.fg
            if beautiful.titlebar_bg_normal_grad and beautiful.titlebar_bg_focus_grad then
                c.titlebar.bg = "#00000000"
                local img = capi.image.argb32(c.titlebar.width,c.titlebar.height,nil)
                img:draw_rectangle_gradient(0,0,c.titlebar.width,c.titlebar.height,(capi.client.focus == c) and beautiful.titlebar_bg_focus_grad or beautiful.titlebar_bg_normal_grad,0)
                c.titlebar.bg_image = img
            else
                c.titlebar.bg = (capi.client.focus == c) and titlebar.bg_focus or titlebar.bg
            end
        end
    end
        
    for k,v in pairs(dataSignals['client_changed'] or {}) do
        v(titlebar.client)
    end
    
    c.titlebar = tb
    for k,v in pairs({"icon","name","sticky","floating","ontop","maximized_vertical","maximized_horizontal"}) do
        c:add_signal("property::"..v, function(c) titlebar:update(c) end)
    end
    titlebar:update(c)
    return {wibox = tb, tablist = tl}
end

function add(c, args)
  if config.data().titlebars == nil then
      config.data().titlebars = {}
  end
  if c.titlebar == nil then
    local retval = create(c,args)
    config.data().titlebars[retval.wibox] = retval.tablist
  else
    c.titlebar.visible = true
  end
end

--TODO redo
function remove(c)
    if not c.titlebar then return end
    c.titlebar.visible = false
end

-- Register standards hooks
capi.client.add_signal("focus"   , function(c) if data[c] then data[c]:update(c,'focus'  ) end end)
capi.client.add_signal("unfocus" , function(c) if data[c] then data[c]:update(c,'unfocus') end end)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
