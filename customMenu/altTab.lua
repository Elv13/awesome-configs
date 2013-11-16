local setmetatable = setmetatable
local type         = type
local ipairs       = ipairs
local pairs        = pairs
local print        = print
local button       = require( "awful.button"     )
local beautiful    = require( "beautiful"        )
local tag          = require( "awful.tag"        )
local client2       = require( "awful.client"     )
local menu         = require( "radical.box"      )
local util         = require( "awful.util"       )
local config       = require( "forgotten"           )
local themeutils = require( "blind.common.drawing"    )
local wibox        = require( "wibox"            )
local color      = require( "gears.color"    )
local cairo      = require( "lgi"            ).cairo
local capi = { image      = image,
               widget     = widget,
               client     = client,
               mouse      = mouse,
               screen     = screen,
               keygrabber = keygrabber }

local module = {}

local function draw_underlay(text)
    return beautiful.draw_underlay and beautiful.draw_underlay(text) or nil
end

-- Keep its own history instead of using awful.client.focus.history
local focusIdx,focusTable = 1,setmetatable({}, { __mode = 'v' })
capi.client.connect_signal("focus", function(c)
    focusTable[c] = focusIdx
    focusIdx = focusIdx + 1
end)

local function compare(a,b)
  return a[1] > b[1]
end

local function get_history(screen)
   local result = {}
   for k,v in pairs(focusTable) do
       result[#result+1] = {v,k}
   end
   local orphanCount = -100
   for k,v in ipairs(capi.client.get(screen or 1)) do
      if not focusTable[v] then
         result[#result+1] = {orphanCount,v}
         orphanCount = orphanCount -1
      end
   end
   table.sort(result,compare)
   return result
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
        widget:set_image( config.themePath.. "Icon/titlebar/" .. field .."_"..curfocus .."_"..curactive..".png"  )
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

local function select_next(menu)
   local item = menu.next_item
   item.selected = true
   item.button1()
   return true
end

local function new2(screen, args)
    local args = args or {}
    local menuX = (capi.screen[(screen or capi.mouse.screen)].geometry.width)/4
    local menuY = (capi.screen[(screen or capi.mouse.screen)].geometry.height - (beautiful.menu_height*#capi.client.get(screen)))/2
    local currentMenu = menu({x= menuX, y= menuY, filter = true, show_filter=true, autodiscard = true,
        disable_markup=true,fkeys_prefix=true,width=(((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)})
    currentMenu.width = (((screen or capi.screen[capi.mouse.screen]).geometry.width)/2)

    currentMenu:add_key_hook({}, "Tab", "press", select_next)

    if args.auto_release then
        currentMenu:add_key_hook({}, "Alt_L", "release", function(menu)
            currentMenu.visible = false
            return false
        end)
    end

    for k,v2 in ipairs(get_history(screen)) do
        local l,v = wibox.layout.fixed.horizontal(),v2[2]
        l:add( button_group({client = v, width=5, field = "close",     focus = false, checked = false                            , onclick = function() v:kill() end                      })     )
        l:add( button_group({client = v, width=5, field = "ontop",     focus = false, checked = function() return v.ontop end    , onclick = function() v.ontop = not v.ontop end         })     )
        l:add( button_group({client = v, width=5, field = "maximized", focus = false, checked = function() return v.maximized end, onclick = function() v.maximized = not v.maximized end }) )
        l:add( button_group({client = v, width=5, field = "sticky",    focus = false, checked = function() return v.sticky end   , onclick = function() v.sticky = not v.sticky end       })    )
        l:add( button_group({client = v, width=5, field = "floating",  focus = false, checked = function() return v.floating end , onclick = function() v.floating = not v.floating end   })  )

        l.fit = function (s,w,h) return 5*h,h end
        currentMenu:add_item({
            text    = v.name,
            button1 = function()
                if v:tags()[1] and v:tags()[1].selected == false then
                    tag.viewonly(v:tags()[1])
                end
                capi.client.focus = v
            end,
            icon    = themeutils.apply_icon_transformations(v.icon or config.iconPath .. "tags/other.png",color(beautiful.fg_focus)),
            suffix_widget = l,
            selected = capi.client.focus == v,
            underlay = v:tags()[1] and draw_underlay(v:tags()[1].name)
        })
    end

    currentMenu.visible  = true
    if args.auto_release then
      select_next(currentMenu)
    end
    return currentMenu
end

return setmetatable({}, { __call = function(_, ...) return new2(...) end })
