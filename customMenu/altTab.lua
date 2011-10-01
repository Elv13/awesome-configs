local setmetatable = setmetatable
local table        = table
local print        = print
local type         = type
local ipairs       = ipairs
local pairs        = pairs
local button       = require( "awful.button"     )
local beautiful    = require( "beautiful"        )
local naughty      = require( "naughty"          )
local tag          = require( "awful.tag"        )
local menu         = require( "widgets.menu"     )
local tooltip      = require( "awful.tooltip"    )
local util         = require( "awful.util"       )
local config       = require( "config"           )
local widget2      = require( "awful.widget"     )
local capi = { image      = image,
               widget     = widget,
               client     = client,
               mouse      = mouse,
               screen     = screen,
               keygrabber = keygrabber }

module("customMenu.altTab")

local currentMenu  = {}
local isVisible    = false
local currentMenu  = nil
local currentIndex = 1
local itemCount    = 1
local fkeyMapping  = {}

local function keyboardNavigation(leap)
    if currentMenu then
        if currentIndex + leap > itemCount then
            currentIndex = 1
        elseif currentIndex + leap < 1 then
            currentIndex = itemCount
        else
            currentIndex = currentIndex + leap
        end
        currentMenu:clear_highlight()
        currentMenu:highlight_item(currentIndex) 
    end
end

local function button_group(args)
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

function new(screen, args) 
    local numberStyle = "<span size='large' bgcolor='".. beautiful.fg_normal .."'color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span> "

    if isVisible == false then    

        local menuX = ((screen or capi.screen[capi.mouse.screen]).geometry.width)/4
        local menuY = ((screen or capi.screen[capi.mouse.screen]).geometry.height - (beautiful.menu_height*#capi.client.get(screen)))/2
        currentMenu = menu({x= menuX, y= menuY, filter = true, showfilter=true, autodiscard = true})
        currentMenu:set_width(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)
        
        currentMenu:add_key_hook({}, "Tab", "press", function(menu)
            currentMenu:rotate_selected(1)
            return true
        end)
        
        local testImg = capi.widget({type="imagebox"})
        testImg.image = capi.image(util.getdir("config") .. "/theme/darkBlue/Icon/titlebar/ontop_normal_inactive.png")
        
        itemCount = 1
        for k,v in ipairs(capi.client.get(screen)) do
            local close     = button_group({client = v, width=5, field = "close",     focus = false, checked = false                            , onclick = function() v:kill() end                      })
            local ontop     = button_group({client = v, width=5, field = "ontop",     focus = false, checked = function() return v.ontop end    , onclick = function() v.ontop = not v.ontop end         })
            local floating  = button_group({client = v, width=5, field = "floating",  focus = false, checked = function() return v.floating end , onclick = function() v.floating = not v.floating end   })
            local sticky    = button_group({client = v, width=5, field = "sticky",    focus = false, checked = function() return v.sticky end   , onclick = function() v.sticky = not v.sticky end       })
            local maximized = button_group({client = v, width=5, field = "maximized", focus = false, checked = function() return v.maximized end, onclick = function() v.maximized = not v.maximized end })
            fkeyMapping[itemCount] = currentMenu:add_item({
                prefix  = numberStyle.."[F".. itemCount .."]"..numberStyleEnd, 
                text    = v.name, 
                onclick = function() capi.client.focus = v end, 
                icon    = v.icon,
                addwidgets = {
                                close,
                                ontop, 
                                maximized,
                                sticky,
                                floating,
                                layout = widget2.layout.horizontal.rightleft
                             }
            })
            fkeyMapping[itemCount].c = v
            itemCount = itemCount + 1
        end
        
        currentMenu:toggle(true)
        currentMenu:set_coords(menuX,menuY)
        currentMenu:add_signal("menu::hide",function()
            currentMenu = nil
            isVisible   = false
            --capi.keygrabber.stop()
        end)
        
        
        currentMenu:clear_highlight()
        currentMenu:highlight_item(currentIndex)
        isVisible = true
    else
        keyboardNavigation(args.leap or 1)
    end
    
    return currentMenu
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
