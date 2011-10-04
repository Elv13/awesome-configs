local setmetatable = setmetatable
local widgets      = require( "widgets"             )
local awful        = require( "awful"               )
local beautiful    = require( 'beautiful'           )
local config       = require( "config"              )
local utils        = require( "utils"               )
local customMenu   = require( "customMenu"          )
local tablist_old  = require( "widgets.tablist_old" )

local capi = { image      = image      ,
               widget     = widget     ,
               mouse      = mouse      ,
               screen     = screen     ,
               keygrabber = keygrabber }

module("titlebar.urxvt")

widgets.titlebar.registerCustomClass("URxvt",function(widgets,titlebar,c)
    local numberStyle    = "<span size='large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span>"--"</b></tt></span> "
    local menuTb         = capi.widget({type="textbox"})
    menuTb.text          = "<span color=\"".. beautiful.bg_normal .."\">[MENU]</span>"
    menuTb.bg            = beautiful.fg_normal
    widgets.icon.bg      = beautiful.fg_normal
    local addTab         = capi.widget({ type = "imagebox"})
    addTab.image         = capi.image(config.data.iconPath .. "addTabs.png")
    
    local bell0          = capi.widget({ type = "imagebox"})
    bell0.image          = capi.image(config.data.iconPath .. "bell2.png")
    
    local aTabList = tablist_old.new(nil,nil)
    aTabList:add_tab(c.window).selected = true
    
    addTab:buttons( awful.util.table.join(
      awful.button({ }, 1, function()
        local pid = c.window
        awful.util.spawn('dbus-send --type=method_call --dest=org.schmorp.urxvt /term/'..c.window..'/control org.schmorp.urxvt.addTab', false)
        aTabList:add_tab(pid)
      end)
    ))
    
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
        bell0                                                       ,
        addTab                                                      ,
        layout = awful.widget.layout.horizontal.rightleft           ,
        aTabList                                                    ,
    }
end)