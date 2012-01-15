local setmetatable = setmetatable
local widgets      = require( "widgets"    )
local awful        = require( "awful"      )
local beautiful    = require( 'beautiful'  )
local config       = require( "config"     )
local utils        = require( "utils"      )
local customMenu   = require( "customMenu" )

local capi = { image      = image      ,
               widget     = widget     ,
               mouse      = mouse      ,
               screen     = screen     ,
               keygrabber = keygrabber }

module("titlebar.default")

widgets.titlebar.add_signal("create",function(widgets,titlebar)
    local numberStyle    = "<span size='large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span>"--"</b></tt></span> "
    local menuTb         = capi.widget({type="textbox"})
    menuTb.text          = "<span color=\"".. beautiful.bg_normal .."\">[MENU]</span>"
    menuTb.bg            = beautiful.fg_normal
    widgets.icon.bg      = beautiful.fg_normal

    widgets.wibox.widgets = {                                      --
        {                                                          --
          widgets.icon                                              ,
          menuTb                                                    ,
          layout = awful.widget.layout.horizontal.leftright         ,
        }                                                           ,
        widgets.buttons.close.widget                                ,
        widgets.buttons.ontop.widget                                ,
        widgets.buttons.maximized.widget                            ,
        widgets.buttons.sticky.widget                               ,
        widgets.buttons.floating.widget                             ,
        layout = awful.widget.layout.horizontal.rightleft           ,
        widgets.tabbar.widgets_real                                 ,
    }
          
    local client = nil
    titlebar:add_signal('client_changed', function (c)
        client      = c
        menuTb.text = numberStyle.. (config.data().listPrefix[utils.clientSwitcher.getIndex(c)] or config.data().listPrefix[1] or 0) .. numberStyleEnd .."<span color=\"".. beautiful.bg_normal .."\">[MENU]</span>"
    end)
    
    local btn = awful.util.table.join(
    awful.button({ }, 1, function()
        if client ~= nil then
            customMenu.clientMenu.toggle(client)
        end
    end))
    
    menuTb:buttons( btn )
    widgets.icon:buttons( btn )
end)