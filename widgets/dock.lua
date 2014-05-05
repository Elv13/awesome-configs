local setmetatable = setmetatable
local table,math   = table,math
local pairs,ipairs = pairs,ipairs
local print        = print
local awful        = require( "awful" )
local tracker      = require( "tyrannical.extra.tracker" )
local menu4        = require( "radical.context"          )
local button       = require( "awful.button"             )
local util         = require( "awful.util"               )
local widget2      = require( "awful.widget"             )
local beautiful    = require( "beautiful"                )
local config       = require( "forgotten"                   )
local tools        = require( "utils.tools"              )
local wibox        = require( "wibox"                    )
local tooltip2     = require( "radical.tooltip"         )
local fdutils      = require( "extern.freedesktop.utils" )
local color        = require( "gears.color"              )
local cairo        = require( "lgi"                      ).cairo
local themeutils   = require( "blind.common.drawing"    )
local listTags     = require( "radical.impl.common.tag" ).listTags
local capi = { screen = screen }

local module={}
local lauchBar,visible_tt,sensibleArea = nil,nil,nil

local function draw_item(data,instances,width)
    local instances = instances or tracker:get_instances(data.class or "")
    if not data.icon_surface then
        data.icon_surface = cairo.ImageSurface.create_from_png(data.icon_path)
    end
    if data.damage_w ~= width then
        local sw,sh = data.icon_surface:get_width(),data.icon_surface:get_height()
        local ratio = ((sw > sh) and sw or sh) / (width-6)
        local grad  = { type = "linear", from = { 0, 0 }, to = { 0, sh }, stops = { { 0, "#1889F2" }, { 1, "#0A3E6E" }}}
        data.icon_surface_pattern = cairo.Pattern.create_for_surface(color.apply_mask(data.icon_surface,grad))
        local matrix = cairo.Matrix()
        cairo.Matrix.init_scale(matrix,ratio,ratio)
        matrix:translate(-3,-3)
        data.icon_surface_pattern:set_matrix(matrix)
        data.damage_w = width
    end
    local img4 = cairo.ImageSurface.create(cairo.Format.ARGB32, width, width)
    cr = cairo.Context(img4)
    cr:move_to(3,3)
    cr:set_source(data.icon_surface_pattern)
    cr:paint()
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
    data.icon:set_image(img4)
end

local function hide_tooltip(tt)
    if visible_tt then
        visible_tt:hide()
    end
    if tt then
        tt:hide()
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

local function mask(width,height,radius,offset,anti,bg,fg)
    local img = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
    local cr = cairo.Context(img)
    cr:set_operator(cairo.Operator.SOURCE)
    cr:set_antialias(anti)
    cr:rectangle(0, 0, width, height)
    cr:set_source(bg)
    cr:fill()
    cr:set_source(fg)
    cr:arc(width-radius-1-offset,radius+offset*2,radius,0,2*math.pi)
    cr:arc(width-radius-1-offset,height-radius-2*offset,radius,0,2*math.pi)
    cr:rectangle(0, offset, width-radius-1, height-2*offset)
    cr:rectangle(width-radius-1-offset, radius+2*offset, radius, height-2*radius-2*offset)
    cr:fill()
    return img
end

local function create(screen, args)
    local width = 40
    local menu = nil
    local entries = load_from_dir()
    local height,separator = capi.screen[screen or 1].geometry.height -100,wibox.widget.imagebox()
    local vertical_extents,widgetsL,img = 0, wibox.layout.fixed.vertical()
    local img = cairo.ImageSurface(cairo.Format.ARGB32, width, 7)
    local cr = cairo.Context(img)
    lauchBar = wibox({width = width+9})
    lauchBar:geometry({ width = width, height = height, x = 0, y = 50})
    lauchBar.ontop = true
    lauchBar.border_color = beautiful.fg_normal

    function displayInfo(anApps, name,tooltip1)
        anApps:connect_signal("mouse::enter", function ()
            if not lauchBar.visible then return end
            local tt,ext = tooltip1()
            visible_tt = tt
        end)

        anApps:connect_signal("mouse::leave", function ()
            local tt,ext = tooltip1()
        end)
    end

    cr:set_line_width(1)
    cr:rectangle(3, 2, width -6, 1)
    cr:set_source(color(beautiful.fg_normal))
    cr:stroke()
    separator:set_image(img)

    local function add_item(name,command,icon_path,category,description)
        local icon = wibox.widget.imagebox()
--         icon:set_image(icon_path)
        vertical_extents = vertical_extents + 40--icon:extents().height
        local self_extents,tt = vertical_extents,nil
        local function getTooltip()
            if not tt then
                tt = tooltip2(icon,name,{left=true})
            end
            return tt,self_extents
        end
        icon:buttons(util.table.join(
            button({ }, 1, function()
                awful.util.spawn(command)
                hide_tooltip()
                lauchBar.visible = false
                sensibleArea.visible = true
            end),
            button({ }, 3, function(geometry)
                hide_tooltip()
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
                        print("launching in",i._tag,i._tag.name)
                        awful.util.spawn(command,{tag=i._tag})
                    end}) end})
                    menu:add_item({text="Sub Menu",sub_menu = function()
                        local smenu = menu4({})
                        smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
                        smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
                        smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
                        smenu:add_item({text="item 1",icon=beautiful.path.."Icon/layouts/tileleft.png"})
                        return smenu
                    end})
                    local imb = wibox.widget.imagebox()
                    menu:connect_signal("visible::changed",function(_,visible)
                        if not menu.visible then
                            lauchBar.visible = false
                            sensibleArea.visible = true
                        end
                    end)
                end
                menu.current_item = command
                menu.parent_geometry = geometry
                menu.visible = true
            end)
        ))
        local data = {icon_surface=nil,icon_surface_pattern,damage_w=nil,class=name:lower(),icon=icon,icon_path=icon_path}
        tracker:connect_signal(name:lower().."::instances",function(instances)
            draw_item(data,instances,width)
        end)
        draw_item(data,nil,width)
        local m = wibox.layout.margin()
        m:set_top(2)
        m:set_bottom(2)
        m:set_right(4)
        m:set_widget(icon)
        widgetsL:add(m)
        displayInfo(icon,name,getTooltip)
    end

    local function add_separator()
        vertical_extents = vertical_extents + 7
        widgetsL:add(separator)
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

    local need_sep = false --Prevent the last item to be a separator
    for k,v in pairs(categories_other) do
        if need_sep then
            add_separator()
        end
        add_items(v)
        need_sep = true
    end

    --Resize the dock if necessary
    if vertical_extents < lauchBar.height then
        height = vertical_extents
        lauchBar.height = height
        sensibleArea.height = height
        lauchBar.y = (capi.screen[screen or 1].geometry.height - vertical_extents) / 2
        sensibleArea.y = (capi.screen[screen or 1].geometry.height - vertical_extents) / 2
    end

    lauchBar:set_bg(cairo.Pattern.create_for_surface(mask(width,height,8,1,0,color(beautiful.fg_normal),color(beautiful.bg_dock or beautiful.bg_normal))))
    lauchBar.shape_bounding  = mask(width,height,10,0,1,color("#00000000"),color("#FFFFFFFF"))._native
    lauchBar.width           = width
    lauchBar:set_widget(widgetsL)

    lauchBar:connect_signal("mouse::leave", function()
        hide_tooltip()
        if (menu and menu.visible ~= true) or not menu then
            lauchBar.visible = false
            sensibleArea.visible = true
        end
    end)
    return lauchBar
end

--No, screen 1 is not always at x=0
local function get_first_screen()
    for i=1,capi.screen.count() do
        if capi.screen[i].geometry.x == 0 then
            return i
        end
    end
end

local function new()
  local screen = get_first_screen() or 1
  sensibleArea = wibox({ position = "free", screen = screen, width = 1 })
  sensibleArea.ontop = true
  sensibleArea:geometry({ width = 1, height = capi.screen[screen].geometry.height -100, x = 0, y = 50})
  sensibleArea:connect_signal("mouse::enter", function() local l = lauchBar or create(screen);sensibleArea.visible = false;l.visible = true end)
  sensibleArea.visible = true
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
