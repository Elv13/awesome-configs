local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local ipairs       = ipairs
local print        = print
local button       = require( "awful.button"    )
local beautiful    = require( "beautiful"       )
local widget2      = require( "awful.widget"    )
local config       = require( "config"          )
local util         = require( "awful.util"      )
local tools        = require( "utils.tools"     )
local wibox        = require( "awful.wibox"     )
local tooltip      = require( "widgets.tooltip" )
local fdutils      = require( "extern.freedesktop.utils"   )
local capi = { image  = image  ,
               screen = screen ,
               widget = widget }

module("widgets.dock")
local lauchBar,visible_tt = nil,nil

local function hide_tooltip(tt)
    if visible_tt then
        visible_tt:showToolTip(false)
    end
    if tt then
        tt:showToolTip(false)
    end
    visible_tt = nil
end

local function load_from_dir()
    local dir = util.getdir("config") .."/data/dock"
    local entries = fdutils.parse_desktop_files({dir = dir,size='48x48',category='apps'})
    local toReturn = {}
    for j=1, #entries do
        local program = entries[j]
        -- check whether to include in the menu
        if program.show and program.Name and program.cmdline then
            toReturn[#toReturn+1] = program
        end
    end
    return toReturn
end

local function create(screen, args)
    local width = 40
    local entries = load_from_dir()
    local height,separator = capi.screen[1].geometry.height -100,capi.widget({type="imagebox"})
    local vertical_extents,widgets,img = 0,{},capi.image.argb32(width, 7, nil)
    lauchBar = wibox({ position = "free", screen = s, width = width+9 })
    lauchBar:geometry({ width = width, height = height, x = 0, y = 50})
    lauchBar.ontop = true
    lauchBar.border_color = beautiful.fg_normal

    function displayInfo(anApps, name,tooltip1)
        anApps:add_signal("mouse::enter", function ()
            if not lauchBar.visible then return end
            hide_tooltip()
            local tt,ext = tooltip1()
            visible_tt = tt
            tt:showToolTip(true,{x=width,y=lauchBar.y + ext-30})
        end)

        anApps:add_signal("mouse::leave", function ()
            local tt,ext = tooltip1()
            hide_tooltip(visible_tt)
            hide_tooltip(tt)
        end)
    end

    img:draw_rectangle(0 ,0, width, 11 , true, beautiful.bg_normal)
    img:draw_rectangle(3 ,4, width-7, 1  , true, beautiful.fg_normal)
    separator.image = img

    local function add_item(name,command,icon_path,category,description)
        local icon = capi.widget({ type = "imagebox", align = "left" })
        icon.image = tools.scale_image(icon_path,width,width,5)
        vertical_extents = vertical_extents + icon:extents().height
        local self_extents,tt = vertical_extents,nil
        local function getTooltip()
            if not tt then
                tt = tooltip(name,{left=true})
            end
            return tt,self_extents
        end
        displayInfo(icon,name,getTooltip)
        icon:buttons(util.table.join(
            button({ }, 1, function()
                util.spawn(command)
                hide_tooltip()
                lauchBar.visible = false
            end),
            button({ }, 3, function()
                hide_tooltip()
                lauchBar.visible = false
            end)
        ))
        table.insert(widgets,icon)
    end

    local function add_separator()
        vertical_extents = vertical_extents + 7
        table.insert(widgets,separator)
    end

    local function add_items(items)
        for i=1,#items do
            local item = items[i]
            add_item(item.Name,item.cmdline,item.icon_path,"Tools",nil)
        end
    end

    local categories = {Tools={},Development={},Network={},Player={}}
    local categories_other = {}
    local total_item = 0
    for k=1,#entries do
        local entry = entries[k]
        if entry.icon_path then --No icon = impossible
            if categories[entry.categories[1]] then
                local cat = categories[entry.categories[1]]
                cat[#cat+1] = entry
            else
                if not categories_other[entry.categories[1]] then
                    categories_other[entry.categories[1]] = {}
                end
                local cat = categories_other[entry.categories[1]]
                cat[#cat+1] = entry
            end
            total_item = total_item + 1
        end
    end
    local ratio = height/(total_item*width + #categories_other*11 + 44)
    if ratio < 1 then
        width = width*ratio
    end

    for k,v in ipairs({"Tools","Development","Network","Player"}) do
        add_items(categories[v])
        add_separator()
    end

    for k,v in pairs(categories_other) do
        add_items(v)
        add_separator()
    end

    --Resize the dock if necessary
    if vertical_extents < lauchBar.height then
        height = vertical_extents
        lauchBar.height = height
        lauchBar.y = (capi.screen[1].geometry.height - vertical_extents) / 2
    end


    local img,img2 = capi.image.argb32(width, height, nil),capi.image.argb32(width, height, nil)
    --Top corner (outer)
    img:draw_rectangle(width-15 ,0, 15, 15   , true, "#ffffff")
    img:draw_circle    (width-15, 15, 15, 15, true, "#000000")

    --Bottom corner (outer)
    img:draw_rectangle(width-15 ,height-15, 15, 15   , true, "#ffffff")
    img:draw_circle    (width-15, height-15, 15, 15, true, "#000000")

    --Top corner (border)
    img2:draw_rectangle(width-16 ,0, 16, 16   , true, "#ffffff")
    img2:draw_circle    (width-16, 16, 15, 15, true, "#000000")
    img2:draw_rectangle(0 ,0, width, 1   , true, "#ffffff")

    --Bottom corner (border)
    img2:draw_rectangle (width-16 ,height-16, 16, 16   , true, "#ffffff")
    img2:draw_circle    (width-16, height-16, 15, 15, true, "#000000")
    img2:draw_rectangle (0 ,height-1, width, 1   , true, "#ffffff")
    img2:draw_rectangle (width-1 ,5, 1, height   , true, "#ffffff")
    lauchBar.width           = width
    lauchBar.shape_clip      = img2
    lauchBar.shape_bounding  = img
    lauchBar.widgets         = widgets
    lauchBar.widgets.layout  = widget2.layout.vertical.topbottom

    lauchBar:add_signal("mouse::leave", function()lauchBar.visible = false; hide_tooltip() end)
    return lauchBar
end

function new()
  sensibleArea = wibox({ position = "free", screen = s, width = 1 })
  sensibleArea.ontop = true
  sensibleArea:geometry({ width = 1, height = capi.screen[1].geometry.height -100, x = 0, y = 50})
  sensibleArea:add_signal("mouse::enter", function() local l = lauchBar or create();l.visible = true end)
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
