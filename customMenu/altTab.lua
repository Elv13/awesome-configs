local setmetatable = setmetatable
local type         = type
local ipairs       = ipairs
local pairs        = pairs
local print        = print
local button       = require( "awful.button"     )
local beautiful    = require( "beautiful"        )
local tag          = require( "awful.tag"        )
local menu         = require( "radical.box"      )
local util         = require( "awful.util"       )
local config       = require( "config"           )
local wibox        = require( "wibox"            )
local capi = { image      = image,
               widget     = widget,
               client     = client,
               mouse      = mouse,
               screen     = screen,
               keygrabber = keygrabber }

local module = {}

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
        widget:set_image( config.data().themePath.. "Icon/titlebar/" .. field .."_"..curfocus .."_"..curactive..".png"  )
    end

    local function createWidget()
        local wdg = wibox.widget.imagebox()
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
    local args = args or {}
    local menuX = ((screen or capi.screen[capi.mouse.screen]).geometry.width)/4
    local menuY = ((screen or capi.screen[capi.mouse.screen]).geometry.height - (beautiful.menu_height*#capi.client.get(screen)))/2
    local currentMenu = menu({x= menuX, y= menuY, filter = true, show_filter=true, autodiscard = true,noarrow=true,fkeys_prefix=true,width=(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)})
    currentMenu.width = (((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)

    currentMenu:add_key_hook({}, "Tab", "press", function(menu)
        local item = currentMenu.next_item
        item.selected = true
        item.button1()
        return true
    end)

    if args.auto_release then
        currentMenu:add_key_hook({}, "Alt_L", "release", function(menu)
            currentMenu.visible = false
            return false
        end)
    end

    for k,v in ipairs(capi.client.get(screen)) do
        local l = wibox.layout.fixed.horizontal()
        l:add( button_group({client = v, width=5, field = "close",     focus = false, checked = false                            , onclick = function() v:kill() end                      })     )
        l:add( button_group({client = v, width=5, field = "ontop",     focus = false, checked = function() return v.ontop end    , onclick = function() v.ontop = not v.ontop end         })     )
        l:add( button_group({client = v, width=5, field = "maximized", focus = false, checked = function() return v.maximized end, onclick = function() v.maximized = not v.maximized end }) )
        l:add( button_group({client = v, width=5, field = "sticky",    focus = false, checked = function() return v.sticky end   , onclick = function() v.sticky = not v.sticky end       })    )
        l:add( button_group({client = v, width=5, field = "floating",  focus = false, checked = function() return v.floating end , onclick = function() v.floating = not v.floating end   })  )

        l.fit = function () return 80,30 end
        currentMenu:add_item({
            text    = v.name,
            button1 = function()
                if v:tags()[1] and v:tags()[1].selected == false then
                    tag.viewonly(v:tags()[1])
                end
                capi.client.focus = v 
            end, 
            icon    = v.icon,
            suffix_widget = l,
            selected = capi.client.focus == v
        })
    end

    currentMenu.visible  = true
    return currentMenu
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
