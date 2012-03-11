---------------------------------------------------------------------------
-- @author Emmanuel Lepage Vallee &lt;elv1313@gmail.com&gt;                
-- @author Julien Danjou &lt;julien@danjou.info&gt;                        
-- @copyright 2008 Julien Danjou                                           
-- @copyright 2011-2012 Emmanuel Lepage Vallee                             
-- @release v4.0                                                           
---------------------------------------------------------------------------

local capi  = {
    awesome = awesome ,
    image   = image   ,
    widget  = widget  }

local pairs        = pairs
local print        = print
local type         = type
local setmetatable = setmetatable
local table        = table
local beautiful    = require( "beautiful"                  )
local button       = require( "awful.button"               )
local util         = require( "awful.util"                 )
local mouse        = require( "awful.mouse"                )
local client       = require( "awful.client"               )
local layout       = require( "awful.widget.layout"        )
local wibox        = require( "awful.wibox"                )
local tabList      = require( "ultiLayout.widgets.tablist" )
local config       = require( "config"                     )
local object_model = require( "ultiLayout.object_model"    )

module("ultiLayout.widgets.titlebar")

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

function create_from_cg(cg, args)
    --if not c or (c.type ~= "normal" and c.type ~= "dialog") then return end
    local theme        = beautiful.get()
    local buttons      = {}
    args               = args or {}
    args.height        = args.height or capi.awesome.font_height * 1.5
    
    -- Store colors
    local titlebar     = {}
    titlebar.client    = cg
    titlebar.fg        = args.fg       or theme.titlebar_fg_normal or theme.fg_normal
    titlebar.bg        = args.bg       or theme.titlebar_bg_normal or theme.bg_normal
    titlebar.fg_focus  = args.fg_focus or theme.titlebar_fg_focus  or theme.fg_focus
    titlebar.bg_focus  = args.bg_focus or theme.titlebar_bg_focus  or theme.bg_focus
    titlebar.font      = args.font     or theme.titlebar_font      or theme.font
    titlebar.width     = args.width    --
    data[cg]           = titlebar
    
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
    
    buttons.close     = titlebar:button_group({width=5, field = "close",     focus = false, checked = false                             , onclick = function() cg:kill()                      end })
    buttons.ontop     = titlebar:button_group({width=5, field = "ontop",     focus = false, checked = function() return cg.ontop     end , onclick = function() cg.ontop     = not cg.ontop     end })
    buttons.floating  = titlebar:button_group({width=5, field = "floating",  focus = false, checked = function() return cg.floating  end , onclick = function() cg.floating  = not cg.floating  end })
    buttons.sticky    = titlebar:button_group({width=5, field = "sticky",    focus = false, checked = function() return cg.sticky    end , onclick = function() cg.sticky    = not cg.sticky    end })
    buttons.maximized = titlebar:button_group({width=5, field = "maximized", focus = false, checked = function() return cg.maximized end , onclick = function() cg.maximized = not cg.maximized end })
    
    if not args.height then
      args.height = 16
    end
    
    local tb = wibox(args)
    local tl = tabList.new(nil,nil,cg)
    
    local bts = util.table.join(
        button({             }, 1, function() 
                                      cg:raise()
                                      --mouse.client.move(tb.client) 
                                   end ),
        button({ args.modkey }, 1, function() --[[return mouse.client.move(tb.client)]]      end ),
        button({ args.modkey }, 3, function() --[[return mouse.client.resize(tb.client)]]    end )
    )
    tb:buttons(bts)
    
    local appicon = capi.widget({type="imagebox"})
    
    local userWidgets
    if hooks[cg.class] ~= nil then
        userWidgets = hooks[cg.class]({buttons=buttons,icon=appicon,tabbar=tl,wibox=tb},titlebar,cg)
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
            tl.widgets_real                        ,
        }
    end
    
    function titlebar:update(cg,event)
        if cg.titlebar and titlebar then
            if event     == 'focus'   then
                tl:focus2()
            elseif event == 'unfocus' then
                tl:unfocus2()
            end
            
            local widgets = cg.titlebar.widgets
            appicon.image = cg.icon
            for k,v in pairs(buttons) do
                v:setImage()
            end
--             cg.titlebar.fg = (capi.client.focus == cg) and titlebar.fg_focus or titlebar.fg
--             cg.titlebar.bg = (capi.client.focus == cg) and titlebar.bg_focus or titlebar.bg
        end
    end
        
    for k,v in pairs(dataSignals['client_changed'] or {}) do
        v(titlebar.client)
    end
    
    cg.titlebar = tb
    for k,v in pairs({"icon","name","sticky","floating","ontop","maximized_vertical","maximized_horizontal"}) do
        cg:add_signal("property::"..v, function(cg) titlebar:update(cg) end)
    end
    titlebar:update(cg)
    config.data().titlebars[tb] = tl
    return {wibox = tb, tablist = tl}
end

-- Register standards hooks
-- capi.client.add_signal("focus"   , function(c) if data[c] then data[c]:update(c,'focus'  ) end end)
-- capi.client.add_signal("unfocus" , function(c) if data[c] then data[c]:update(c,'unfocus') end end)
