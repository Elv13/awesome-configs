local setmetatable = setmetatable
local table        = table
local print        = print
local ipairs       = ipairs
local pairs        = pairs
local io           = io
local tooltip      = require( "widgets.tooltip" )
local button       = require( "awful.button"    )
local beautiful    = require( "beautiful"       )
local naughty      = require( "naughty"         )
local tag          = require( "awful.tag"       )
local menu         = require( "radical.context"            )
local util         = require( "awful.util"      )
local config       = require( "config"          )
local themeutils   = require( "utils.theme"     )
local wibox        = require( "wibox"           )
local style        = require( "radical.style.classic"      )
local item_style   = require( "radical.item_style.classic" )
local color = require("gears.color")
local cairo = require("lgi").cairo

local capi = { image  = image  ,
               widget = widget ,
               client = client ,
               mouse  = mouse  ,
               screen = screen }

module("customMenu.launcher")

local currentMenu = nil
local fkeymap = {}

local function save(command)
    local file = io.open(util.getdir("cache") .. "/history", "a")
    file:write("\n"..command)
    file:close()
end

function createMenu(offset)
    
    local numberStyle = "<span size='large' color='".. beautiful.bg_normal .."'><tt><b>"
    local numberStyleEnd = "</b></tt></span> "
    
     -- Read the history and sort them by use (most used first)
    local aFile = io.open(util.getdir("cache") .. "/history")
    local commandArray = {}
    if aFile then
        while true do
            local line = aFile:read("*line")
            if line == nil then break end
            if commandArray[line] == nil then
                commandArray[line] = 1
            else
                commandArray[line] = commandArray[line] + 1
            end
        end
        aFile:close()
    end
    
    local commandArray2 = {}
    
    for k,v in pairs(commandArray) do
        table.insert(commandArray2,{v,k})
    end
    
    function compare(a,b)
        return a[1] > b[1]
    end

    table.sort(commandArray2, compare)
  
    mainMenu = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, 
    autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,maxvisible=20,style=style,item_style=item_style,
    show_filter=true})
    
    mainMenu:add_key_hook({}, "Return", "press", function(menu)
        util.spawn(menu.filterString)
        save(menu.filterString)
        menu:toggle(false)
        return false
    end)
    
    for i=1,15 do
        mainMenu:add_key_hook({}, "F"..i, "press", function(menu)
            if fkeymap[i] ~= nil then
                util.spawn(fkeymap[i].text)
                save(fkeymap[i].text)
            end
            menu:toggle(false)
            return false
        end)
    end
    
   
    
    -- Fill the menu
    local counter = 1
    for k,v in pairs(commandArray2) do
        local function onclick()
            util.spawn(v[2])
            save(v[2])
        end
       local item = mainMenu:add_item({prefix = numberStyle.."[F".. counter .."]"..numberStyleEnd, prefixbg = beautiful.fg_normal,prefixwidth = 45, text =  v[2], onclick = onclick})
       item.fkey = "F"..counter
       fkeymap[counter] = item
       counter = counter + 1
    end
    
    mainMenu:connect_signal("visible::changed", function() currentMenu = nil end)
    
    mainMenu:connect_signal("menu::changed",  function(menu) 
        local counter = 1
        fkeymap = {}
        for k, v in pairs(menu.items) do
            if v.hidden ~= true then
                v.widgets.prefix.text = numberStyle.."[F".. counter .."]"..numberStyleEnd
                fkeymap[counter] = v
                counter = counter + 1
            end
        end
    end)
    
--     mainMenu.visible = true
--     mainMenu:set_coords(offset or 0,capi.screen[capi.mouse.screen].geometry.height-16)
    
    return mainMenu
end

function new(offset, args)
    local launcherText = wibox.widget.textbox()
--     launcherText:margin({ left = 30,right=17})
    launcherText:set_text("Launch")
    launcherText.bg_resize = true
    
    local head_img      = config.data().iconPath .. "gearA2.png"
--     local extents       = launcherText:extents()
--     extents.height      = 16
--     local normal_bg_img = themeutils.gen_button_bg(head_img,extents,false)
    local focus_bg_img  --= themeutils.gen_button_bg(head_img,extents,true )
    
    local bgb = wibox.widget.background()
    local l = wibox.layout.fixed.horizontal()
    local m = wibox.layout.margin(launcherText)
    m:set_left(30)
    m:set_right(10)
    l:add(m)
    l:fill_space(true)
    bgb:set_widget(l)
    local wdg_width = launcherText._layout:get_pixel_extents().width
    local img2 = cairo.ImageSurface.create(cairo.Format.ARGB32, wdg_width+42, beautiful.default_height)
    local arr = themeutils.get_end_arrow2({bg_color=beautiful.fg_normal})
    themeutils.apply_pattern(img2,beautiful.taglist_bg_image_used)
    img2 = themeutils.compose({img2,head_img,{layer = arr,y=0,x=wdg_width+33}})
    bgb:set_bgimage(img2)
    
    launcherText.bg_image = normal_bg_img
    local tt = tooltip("Execute a command",{down=true})
    
    bgb:connect_signal("mouse::enter", function()
        tt:showToolTip(true)
        if not focus_bg_img then
--             focus_bg_img  = themeutils.gen_button_bg(head_img,extents,true )
        end
        launcherText.bg_image = focus_bg_img
    end)
    bgb:connect_signal("mouse::leave", function()
        tt:showToolTip(false)
--         launcherText.bg_image = normal_bg_img
    end)
    
    bgb:buttons( util.table.join(
    button({ }, 1, function(geo)
        if not currentMenu then
            currentMenu = createMenu(offset)
        end
        currentMenu.parent_geometry = geo
        currentMenu.visible = not currentMenu.visible
    end)
    ))
    return bgb
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
