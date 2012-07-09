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
local type         = type
local unpack       = unpack
local setmetatable = setmetatable
local print        = print
local table        = table
local beautiful    = require( "beautiful"                  )
local button       = require( "awful.button"               )
local util         = require( "awful.util"                 )
local layout       = require( "awful.widget.layout"        )
local wibox        = require( "awful.wibox"                )
local tabList      = require( "ultiLayout.widgets.tablist" )
local object_model = require( "ultiLayout.object_model"    )
local ultilayoutC  = require( "ultiLayout.common"          )

module("ultiLayout.widgets.titlebar")

local data     = setmetatable({}, { __mode = 'k' })
local hooks    = {}

local constructor_hook = object_model(titlebar,{},{},{},{})
function add_signal(name,func) constructor_hook:add_signal(name,func) end

function registerCustomClass(className, func)
    hooks[className] = func
end

local function create(cg, args)
    if not cg then return end
    local theme        = beautiful.get()
    local buttons      = {}
    local focus        = false
    args               = args or {}
    args.height        = args.height or capi.awesome.font_height * 1.5
    
    -- Store colors
    local titlebar     = {tabs={}}
    local tb = wibox(args)
    local tl = tabList.new(nil,nil,cg)
    titlebar.client    = cg
    titlebar.fg        = args.fg       or theme.titlebar_fg_normal or theme.fg_normal
    titlebar.bg        = args.bg       or theme.titlebar_bg_normal or theme.bg_normal
    titlebar.fg_focus  = args.fg_focus or theme.titlebar_fg_focus  or theme.fg_focus
    titlebar.bg_focus  = args.bg_focus or theme.titlebar_bg_focus  or theme.bg_focus
    titlebar.font      = args.font     or theme.titlebar_font      or theme.font
    titlebar.width     = args.width    --
    data[cg]           = titlebar
    
    local function set_focus(value)
        focus = value
        tl.focus = value
        tb.bg = (value == true) and titlebar.bg_focus or titlebar.bg
        tb.fg = (value == true) and titlebar.fg_focus or titlebar.fg
    end
    
    object_model(titlebar,{focus = function() return focus end,visible=function() print("dfgdfgdgf") end},{focus = set_focus,visible = function(val)print("ertert") end},{},{autogen_getmap = true,autogen_signals = true})
    
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
            local curfocus    = (focus == true) and "focus" or "normal"
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
            
            local buttons_t = {}
            for i=1,10 do
                table.insert(buttons_t,button({ }, i , data.mbuttons[i ]))
            end
            wdg:buttons( util.table.join(unpack(buttons_t)))
            
            wdg:add_signal("mouse::enter", function() self:setImage(true) end)
            wdg:add_signal("mouse::leave", function() self:setImage(false) end)
            return wdg
        end
        data.widget = wdg or data:createWidget()
        data:setImage()
        return data
    end
    
    buttons.close     = titlebar:button_group({width=5, field = "close"    , focus = false, checked = false                              , onclick = function() cg:kill()                       end })
    buttons.ontop     = titlebar:button_group({width=5, field = "ontop"    , focus = false, checked = function() return cg.ontop     end , onclick = function() cg.ontop     = not cg.ontop     end })
    buttons.floating  = titlebar:button_group({width=5, field = "floating" , focus = false, checked = function() return cg.floating  end , onclick = function() cg.floating  = not cg.floating  end })
    buttons.sticky    = titlebar:button_group({width=5, field = "sticky"   , focus = false, checked = function() return cg.sticky    end , onclick = function() cg.sticky    = not cg.sticky    end })
    buttons.maximized = titlebar:button_group({width=5, field = "maximized", focus = false, checked = function() return cg.maximized end , onclick = function() cg.maximized = not cg.maximized end })
    
    if not args.height then
      args.height = 16
    end
    
    tl:add_signal("button1::clicked",function(_tl,tab)
        cg.active = tab.clientgroup
        ultilayoutC.drag_cg(cg)
    end)
    tl:add_signal("button2::clicked",function(_tl,tab)
        local wb = tabList.create_dnd_widget(cg.title or  "N/A")
        ultilayoutC.drag_cg(tab.clientgroup,nil,{wibox = wb, button = 2})
    end)
    
    
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
    else --See if there is a custom default
        constructor_hook:emit_signal('create',{buttons=buttons,icon=appicon,tabbar=tl,wibox=tb},titlebar)
    end
    if not tb.widgets then
        tb.widgets =                               {
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
    
    function data:swap(_cg,old_cg,new_cg)
        --sdfdsfds()
        if _cg.parent ~= cg then
            --_cg:remove_signal("cg::swapped",swap) --TODO name changed
            titlebar.tabs[old_cg].clientgroup = new_cg
            --other_cg:add_signal("cg::swapped",swap)
            titlebar.tabs[new_cg] = titlebar.tabs[old_cg]
            titlebar.tabs[old_cg] = nil
        end
    end
        
    function titlebar:add_tab(child_cg)
        local tab = tl:add_tab()
        tab:add_autosignal_field("clientgroup")
        child_cg.decorations:remove_decoration("titlebar") --TODO check is multitab stack
        child_cg.decorations:remove_decoration("edge")
        tab.clientgroup = child_cg
        tab.title = child_cg.title
        cg.active = child_cg
        child_cg:add_signal("title::changed",function(_cg,title)
            tab.title = title
        end)
        child_cg:add_signal("focus:changed",function(_cg,value)
            tab.selected = value
        end)
        --child_cg:add_signal("cg::swapped",function(...) data:swap(...) end)
        titlebar.tabs[child_cg]=tab
        return tab
    end
    
    function titlebar:select_tab(child_cg)
        if child_cg == self.activeCg then
            return
        elseif child_cg and self.tabs[child_cg] then
            if self.activeCg then
                self.tabs[self.activeCg].selected = false
            end
            self.tabs[child_cg].selected      = true
        end
        self.activeCg = child_cg
        return self.tabs[child_cg]
    end
    
    function titlebar:update()
        appicon.image = cg.icon
        for k,v in pairs(buttons) do
            v:setImage()
        end
    end
    
    titlebar:emit_signal('client_changed',titlebar.client)
    
    for k,v in pairs({"icon","name","sticky","floating","ontop","maximized_vertical","maximized_horizontal"}) do
        cg:add_signal("property::"..v, function(cg) titlebar:update(cg) end)
    end
    titlebar:update()
    
    ultilayoutC.register_wibox(tb,cg,function(new_cg) cg:attach(new_cg) end)
    
    cg:add_signal("geometry::changed"   ,update                                        )
    cg:add_signal("focus::changed"      ,function(_cg,value) titlebar.focus = value end)
    cg:add_signal("child::replaced"     ,function(...) data:swap(...)               end)
    cg:add_signal("detached"            ,function(_cg,child)
        if not titlebar then return end
        if titlebar.tabs[child] then
            print("Removing ",titlebar.tabs[child])
            tl:remove_tab(titlebar.tabs[child])
            titlebar.tabs[child] = nil
            if #cg:childs() > 0 then
                _cg.active = cg:childs()[1]
            end
        else
            print("Error stack")
        end
    end)
    cg:add_signal("destroyed",function()
        tb.visible = false
        tb         = nil
        tl         = nil
        titlebar   = nil --If it ever crash here, find the cause, do not remove this line
    end)
    titlebar.wibox = tb
    titlebar.tablist = tl
    return titlebar --{wibox = tb, tablist = tl, titlebar = titlebar}
end
setmetatable(_M, { __call = function(_, ...) return create(...) end })