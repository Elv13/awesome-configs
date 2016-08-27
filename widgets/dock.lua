local setmetatable = setmetatable
local table,math   = table,math
local pairs,ipairs = pairs,ipairs
local print        = print
local tracker      = require( "tyrannical.extra.tracker"   )
local menu4        = require( "radical.context"            )
local util         = require( "awful.util"                 )
local beautiful    = require( "beautiful"                  )
local wibox        = require( "wibox"                      )
local color        = require( "gears.color"                )
local surface      = require( "gears.surface"              )
local cairo        = require( "lgi"                        ).cairo
local listTags     = require( "radical.impl.common.tag"    ).listTags
local radical      = require( "radical"                    )
local appmenu      = require( "customMenu.appmenu"         )
local fd_async     = require( "utils.fd_async"             )
local rad_client   = require( "radical.impl.common.client" )
local capi = { screen = screen }

local module={}
local menu,current_item = nil,nil
local dir = util.getdir("config") .."/data/dock/"

local categories_pos,categories_name = {},{}

local function increment_cat(category)
    local index = categories_name[category]
    for i=index , #categories_pos do
        categories_pos[i] = categories_pos[i]+1
    end
end

-- Remove the file argument from the exec line
local function exec(ini,args)
    local previous,ret = "",""
    for arg in string.gmatch(ini.Exec,"%S+") do
        if arg ~= "%c" then
            ret = ret.." "..previous
            previous = arg
        else
            previous = ""
        end
    end
    if previous ~= "%U" and ret ~= "%u" then
        ret = ret.." "..previous
    end

    util.spawn(ret,args)
end

local function add_category(menu,main_category)
    local offset = 1

--     if #categories_pos > 0 then
        menu:add_widget(radical.widgets.separator(menu,
            (menu.position == "left" or menu.position=="right") and radical.widgets.separator.HORIZONTAL or radical.widgets.separator.VERTICAL))
--     else
--         offset = 0
--     end
    categories_pos[#categories_pos+offset] = menu.rowcount
    categories_name[main_category] = #categories_pos
end

local function set_category(cat_item,dock)
    local item = dock._current_item
    local category,ini,path = cat_item.text,item._internal.ini,item._internal.path
    ini.Categories = {category}
    fd_async.ini.write(ini,path)
end

local function gen_menu(dock,name,ini,item)
    if menu then return menu end

    menu = menu4({parent_geo=geometry})
    menu:add_item({text="Launch",button1=function() print("exec "..menu.current_item) end})
--     menu:add_item({text="Screen 9",icon=beautiful.path.."Icon/layouts/tileleft.png"})
    if capi.screen.count() > 1 then
        menu:add_item({text="Launch on screen",sub_menu = function()
            local smenu = menu4({})
            smenu:add_item({text="item 1"})
            smenu:add_item({text="item 1"})
            smenu:add_item({text="item 1"})
            smenu:add_item({text="item 1"})
            return smenu
        end})
    end
    menu:add_item({text="Launch in new tag",button1=function()
        local item = dock._current_item
        if not item then return end
        local exec = item._internal.ini
        if not exec then return end
        exec(exec,{new_tag=true,volatile=true})
        menu.visible = false
    end})
    menu:add_item({text="Launch in current tag",button1=function()
        local item = dock._current_item
        if not item then return end
        local exec = item._internal.ini
        if not exec then return end
        exec(exec,{intrusive=true})
        menu.visible = false
    end})
    menu:add_item({text="Launch In tag", sub_menu = function() return listTags({button1= function(i,m)
        exec(ini,{tag=i._tag})
    end}) end})
    menu:add_widget(radical.widgets.separator())
    menu:add_item({text="Dock position",sub_menu = function()
        local smenu = menu4({})
        smenu:add_item({text="Left"   ,icon=beautiful.path.."Icon/layouts/tileleft.png"})
        smenu:add_item({text="Right"  ,icon=beautiful.path.."Icon/layouts/tile.png"})
        smenu:add_item({text="Top"    ,icon=beautiful.path.."Icon/layouts/tiletop.png"})
        smenu:add_item({text="Bottom" ,icon=beautiful.path.."Icon/layouts/tilebottom.png"})
        return smenu
    end})
    menu:add_item({text="Set category",sub_menu = function()
        local smenu = menu4({})
        for cat in pairs(categories_name) do
            smenu:add_item({text=cat,button1=function(i) set_category(i,dock) end})
        end
        return smenu
    end})
    menu:add_item {text="Add application", sub_menu = function()
        if not menu._internal.appmenu then
            menu._internal.appmenu = appmenu({},{},{button1=function(item,menu)
                fd_async.file.copy(item._internal.desktop.Path,dir..fd_async.file.name(item._internal.desktop.Path))
                menu.visible = false
            end})
        end
        return menu._internal.appmenu
    end}
    local ib = wibox.widget.imagebox()
    ib:set_image(beautiful.titlebar_close_button_normal)
    menu:add_item({text="Remove from dock",suffix_widget = ib})
    local imb = wibox.widget.imagebox()
    menu:connect_signal("visible::changed",function(_,visible)
        if not menu.visible and not beautiful.dock_always_show then
            dock.visible = false
        end
    end)

    return menu
end

local function load_item(menu,content,path)
    local main_category = content.Categories[1] or ""
    if not categories_name[main_category] then
        add_category(menu,main_category)
    end
    local item = menu:add_item{icon=content.Icon,tooltip=content.Name,button2 = function(_i,_m,mods,geo)
        local instances = instances or tracker:get_instances(_i._internal.ini.Class or "")
        if instances and #instances > 0 then
            local m = rad_client.screenshot(instances,geo)
            menu._tmp_menu = m
            _i._tmp_menu   = m
        end
    end,
    button3= function(_i,_m,mods,geo)
        local m = gen_menu(menu,name,content,_i)
        menu._tmp_menu = m
        _i._tmp_menu = m
        m.parent_geometry = geo
        m.visible = true
    end,
    button1 = function(i)
        exec(content,{callback = function(c)
            local real_class,known_class = c.class:lower(),(i._internal.ini.Class or ""):lower()
            --Some .desktop don't have proper 'Class'. Set it
            if real_class ~= known_class then
                i._internal.ini.Class = real_class
                fd_async.ini.write(i._internal.ini,i._internal.path)
            end
        end})
        if not beautiful.dock_always_show then
            menu.visible = false
        end
    end}
    item.margins.left  = 1
    item.margins.right = 1
    content.Class = content.Class or content.Name:lower()
    item._internal.ini = content
    item._internal.path = path

    -- Move the item to the right category
    menu:move(item,categories_pos[categories_name[main_category]])
    increment_cat(main_category)
end

local function load_from_dir(menu)
    fd_async.ini.load_dir(dir,nil,util.getdir("config") .."/blind/arrow/Icon/"):connect_signal("file::content",function(path,content)
        local icon = content.Icon
        local icon_exist = fd_async.file.exist(icon)
        if icon and icon_exist then
            load_item(menu,content,path)
        elseif icon then
            -- The icon is not a path, get the real one
            fd_async.icon.load(icon,48):connect_signal("request::completed",function(icn)
                content.Icon_orig = content.Icon
                content.Icon = icn
                load_item(menu,content,path)
            end)
        end
    end)
end

local function get_real_size(data)
    local ret = data.width
    if data.height < ret then
        ret = data.height
    end
    return ret
end

local function draw_item(data,item,cr,width,height)
    local ini = item._internal.ini
    if not ini then return end
--     local width = data.width-2--get_real_size(data)--img:get_width()
    local instances = instances or tracker:get_instances(ini.Class or "")
    cr:move_to(3,3)
    if #instances > 1 then
        cr:set_source(color("#9A1C00"))
        cr:arc(width-5-2,5,5,0,2*math.pi)
        cr:fill()
        cr:set_source(color("#BDC4BE"))
        cr:move_to(width-5-6,8)
        cr:select_font_face("Verdana", cairo.FontSlant.NORMAL, cairo.FontWeight.BOLD)
        cr:set_font_size(10)
        cr:show_text(#instances)
    end
    if #instances > 0 then
        cr:set_source(color("#8A0B00"))
        cr:arc(0,height/2,3,0,2*math.pi)
        cr:fill()
    end

--     data.icon:set_image(img4)
end

local function default_icon_transformation(image,data,item)
    local s = surface(image)
    local w,h = surface.get_size(s)
    local fg_col = beautiful.fg_dock
    if (not fg_col) and beautiful.fg_dock_1 and beautiful.fg_dock_2 then
        fg_col = { type = "linear", from = { 0, 0 }, to = { 0, s:get_height() }, stops = { { 0, beautiful.fg_dock_1 }, { 1, beautiful.fg_dock_2 }}}
    end
    return color.apply_mask(s,color(fg_col or beautiful.fg_normal))
end

local function create(screen, args)
    local args = args or {}
    dir = args.dir or dir
    local default_cats = args.default_cats or {}

    local dockW = nil
    dockW = radical.dock{position=args.position or "left",screen=screen,
        spacing = beautiful.dock_spacing,
        icon_transformation = function(image,data,item)
            local f = beautiful.dock_icon_transformation or default_icon_transformation
            return f(image,data,item)
        end,
        overlay_draw = function(context,item,cr,width,height)
            draw_item(dockW,item,cr,width,height)
        end
    }

    dockW.margins.top  = 4
    dockW.margins.left = 2
    dockW.margins.right= 3 --border + 2

    local init = false

    dockW:connect_signal("visible::changed", function()
        if not init then
            for k,v in ipairs(default_cats)do
                add_category(dockW,v)
            end
            load_from_dir(dockW)
            init = true
        end
    end)

    return dockW
end

return setmetatable(module, { __call = function(_, ...) return create(...) end })
