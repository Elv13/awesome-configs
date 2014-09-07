local setmetatable = setmetatable
local table,math   = table,math
local pairs,ipairs = pairs,ipairs
local print        = print
local tracker      = require( "tyrannical.extra.tracker" )
local menu4        = require( "radical.context"          )
local util         = require( "awful.util"               )
local beautiful    = require( "beautiful"                )
local wibox        = require( "wibox"                    )
local color        = require( "gears.color"              )
local surface      = require( "gears.surface"            )
local cairo        = require( "lgi"                      ).cairo
local listTags     = require( "radical.impl.common.tag"  ).listTags
local radical      = require( "radical"                  )
local appmenu      = require( "customMenu.appmenu"       )
local fd_async     = require( "utils.fd_async"           )
local capi = { screen = screen }

local module={}
local lauchBar = nil
local dir = util.getdir("config") .."/data/dock/"

local categories_pos,categories_name = {},{}

local function increment_cat(category)
    local index = categories_name[category]
    for i=index , #categories_pos do
        categories_pos[i] = categories_pos[i]+1
    end
end

local function add_category(menu,main_category)
    menu:add_widget(radical.widgets.separator())
    categories_pos[#categories_pos+1] = menu.rowcount
    categories_name[main_category] = #categories_pos
end

local function gen_menu(dock,name,command)
    if menu == nil then
        menu = menu4({parent_geo=geometry})
        menu:add_item({text="Screen 1",button1=function() print("exec "..menu.current_item) end})
        menu:add_item({text="Screen 9",icon=beautiful.path.."Icon/layouts/tileleft.png"})
        menu:add_item({text="Sub Menu",sub_menu = function() 
            local smenu = menu4({})
            smenu:add_item({text="item 1"})
            smenu:add_item({text="item 1"})
            smenu:add_item({text="item 1"})
            smenu:add_item({text="item 1"})
            return smenu
        end})
        menu:add_item({text="Open in new tag"})
        menu:add_item({text="Open in current tag"})
        menu:add_item({text="Open In tag", sub_menu = function() return listTags({button1= function(i,m)
            util.spawn(command,{tag=i._tag})
        end}) end})
        menu:add_item({text="Sub Menu",sub_menu = function()
            local smenu = menu4({})
            smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
            smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
            smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
            smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
            return smenu
        end})
        menu:add_item {text="Add application", sub_menu = function()
            if not menu._internal.appmenu then
                menu._internal.appmenu = appmenu({},{},{button1=function(item,menu)
                    fd_async.file.copy(item._internal.desktop.Path,dir..fd_async.file.name(item._internal.desktop.Path))
                end})
            end
            return menu._internal.appmenu
        end}
        local imb = wibox.widget.imagebox()
        menu:connect_signal("visible::changed",function(_,visible)
            if not menu.visible then
                dock.visible = false
            end
        end)
    end
    return menu
end

local function load_from_dir(menu)
    fd_async.ini.load_dir(dir,nil,util.getdir("config") .."/blind/arrow/Icon/"):connect_signal("file::content",function(path,content)
        local icon = content.Icon
        if icon and fd_async.file.exist(icon) then
            local main_category = content.Categories[1] or ""
            if not categories_name[main_category] then
                add_category(menu,main_category)
            end
            local item = menu:add_item{icon=content.Icon,tooltip=content.Name,button3= function(_m,_i,mods,geo)
                local m = gen_menu(menu,name,content.Exec)
                m.parent_geometry = geo
                m.visible = true
            end,
            button1 = function()
                util.spawn(content.Exec)
                menu.visible = false
            end}
            content.Class = content.Class or content.Name:lower()
            item._internal.ini = content

            -- Move the item to the right category
            menu:move(item,categories_pos[categories_name[main_category]])
            increment_cat(main_category)
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

local function draw_item(data,item,img,instances)
    local ini = item._internal.ini
    if not ini then return end
    local width = data.width-2--get_real_size(data)--img:get_width()
    local instances = instances or tracker:get_instances(ini.Class or "")
    cr = cairo.Context(img)
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
        cr:arc(0,width/2,3,0,2*math.pi)
        cr:fill()
    end
    
--     data.icon:set_image(img4)
end

local function create(screen, args)
    local args = args or {}
    dir = args.dir or dir
    local default_cats = args.default_cats or {}

    local dockW = radical.dock{position="left",screen=screen,
        icon_transformation = function(image,data,item)
    --     return themeutils.desaturate(surface(image),1,theme.default_height,theme.default_height)
            local img = color.apply_mask(image,color(beautiful.fg_dock or beautiful.fg_normal))
            draw_item(data,item,img)
            return img
        end
    }

    for k,v in ipairs(default_cats)do
        add_category(dockW,v)
    end

    --TODO use dock::request signal
--     local loaded = function()
        load_from_dir(dockW)
--         print("LOAD")
--         dockW:disconnect_signal("visible::changed",loaded)
--     end
--     dockW:connect_signal("visible::changed",loaded)

    return dockW
end

return setmetatable(module, { __call = function(_, ...) return create(...) end })
