local wibox     = require( "wibox"                   )
local awful     = require( "awful"                   )
local rad_tag   = require( "radical.impl.common.tag" )
local beautiful = require( "beautiful"               )
local radical   = require( "radical"                 )
local rad_task  = require( "radical.impl.tasklist"   )
local chopped   = require( "chopped"                 )
local collision = require( "collision"               )
local color     = require( "gears.color"             )
local infobg    = require( "radical.widgets.infoshapes" )
local shape     = require( "gears.shape")

local capi = {client = client}

local endArrowR2,endArrow_alt

local function draw_3_dots(self, context, cr, width, height)
    cr:set_source(color(beautiful.bg_resize_handler or "#00000000"))
    cr:arc(3+width/2,3,2,0,2*math.pi)
    cr:fill()
    cr:arc(3+width/2+7,3,2,0,2*math.pi)
    cr:fill()
    cr:arc(3+width/2-7,3,2,0,2*math.pi)
    cr:fill()
end

local function draw_bottom_left(self, context, cr, width, height)
    if beautiful.titlebar_side_bottom_left then
        cr:set_source_surface(beautiful.titlebar_side_bottom_left)
    else
        cr:set_source(color(beautiful.bg_resize_handler or "#00000000"))
    end
    cr:paint()
end

local function draw_bottom_right(self, context, cr, width, height)
    if beautiful.titlebar_side_bottom_right then
        cr:set_source_surface(beautiful.titlebar_side_bottom_right)
    else
        cr:set_source(color(beautiful.bg_resize_handler or "#00000000"))
    end
    cr:paint()
end

local function bottom_corner_fit(self, context, w,h)
    return 20,h
end

local function set_underlay(c,infoshapes,underlays)
    if not infoshapes or beautiful.titlebar_show_underlay == false then
        return
    end

    local underlays = underlays or {}
    if #underlays == 0 then
        for k,v in ipairs(c:tags()) do
            underlays[#underlays+1] = {
                text  = v.name,
                bg    = beautiful.titlebar_underlay_bg or beautiful.underlay_bg or "#0C2853"
            }
        end
    end
    infoshapes:set_infoshapes(underlays)
end

local function new(c)
    local alt_color = beautiful.titlebar_bg_alternate or beautiful.bar_bg_alternate or beautiful.bg_alternate
    local alt_image = beautiful.titlebar_bgimage_alternate or beautiful.bar_bgimage_alternate or beautiful.bgimafe_alternate
    if (not endArrowR2) and beautiful.titlebar_show_separator ~= false then
        endArrowR2      = chopped.get_separator {
            weight      = chopped.weight.FULL                       ,
            direction   = chopped.direction.LEFT                    ,
            sep_color   = nil                                       ,
            left_color  = nil                                       ,
            right_color = alt_color                                 ,
        }

        endArrow_alt    = chopped.get_separator {
            weight      = chopped.weight.FULL                       ,
            direction   = chopped.direction.RIGHT                   ,
            sep_color   = nil                                       ,
            left_color  = alt_color                                 ,
            right_color = nil                                       ,
        }
    end

    -- Use underlays instead of tooltips
    local infoshapes = nil
    local title = awful.titlebar.widget.titlewidget(c)

    if beautiful.titlebar_to_upper then
        title._private.layout.text = title._private.layout.text:upper()
    end

    -- Create a resize handle
    local resize_handle = wibox.widget.imagebox()
    resize_handle:set_image(beautiful.titlebar_resize)
    resize_handle:buttons( awful.util.table.join(
        awful.button({ }, 1, function(geometry)
            awful.mouse.client.resize(c)
        end))
    )

    local tag_selector = wibox.widget.imagebox()
    tag_selector:set_image(beautiful.titlebar_tag)
    tag_selector:buttons( awful.util.table.join(

        awful.button({ }, 1, function(geometry)

            local m,tag_item = rad_tag({checkable=true,
            button1 = function(i,m)
                awful.client.toggletag(i._tag,c)
                i.checked = not i.checked
            end})
            for k,t in ipairs(c:tags()) do
                if tag_item[t] then
                    tag_item[t].checked = true
                end
            end
            m.parent_geometry = geometry
            m.visible = true
        end))
    )

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    local labels = {"Floating","Maximize","Sticky","On Top","Close"}
    for k,v in ipairs({awful.titlebar.widget.floatingbutton(c) , awful.titlebar.widget.maximizedbutton(c), awful.titlebar.widget.stickybutton(c),
        awful.titlebar.widget.ontopbutton(c), awful.titlebar.widget.closebutton(c)}) do
        right_layout:add(v)
        v:connect_signal("mouse::enter",function()
            if not c.valid then return end
            set_underlay(c,infoshapes,{{
                text = labels[k],
                bg    = beautiful.titlebar_underlay_bg or beautiful.underlay_bg or "#0C2853"
            }})
        end)
        v:connect_signal("mouse::leave",function()
            if not c.valid then return end
            set_underlay(c,infoshapes)
        end)
    end

    -- The title goes in the middle
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    local align = beautiful.titlebar_title_align

    local tb = awful.titlebar(c,{size=beautiful.titlebar_height or 16, bg = beautiful.titlebar_bg_normal})

    --------------------------------------------------
    --                 Top titlebar                 --
    --------------------------------------------------

    local title_layout = {
       {
         {
               {
                  beautiful.titlebar_show_icon and wibox.widget.imagebox(c.icon) or nil,
                  title,
                  spacing = 4,
                  layout = wibox.layout.fixed.horizontal,
               },
               left   = 13                 ,
               right  = 13                 ,
               layout = wibox.container.margin,
         },
         id                 = "title_bg"                                  ,
         shape              = beautiful.titlebar_title_shape              ,
         shape_border_width = beautiful.titlebar_title_border_width       ,
         shape_border_color = beautiful.titlebar_title_border_color_active,
         bg                 = beautiful.titlebar_title_bg                 ,
         bgimage            = beautiful.titlebar_title_bgimage            ,
         buttons            = (align ~= "center") and buttons             ,
         layout             = wibox.container.background                  ,
      },
      align              = align,
      expand             = (align == "center") and "fill" or nil,
      spacing            = 10,
      id                 = "infoshapes",
      shape              = shape.hexagon,
      shape_bg           = beautiful.titlebar_underlay_bg or beautiful.underlay_bg or "#0C2853",
      shape_border_color = beautiful.titlebar_underlay_border_color,
      shape_border_width = beautiful.titlebar_underlay_border_width,
      fg                 = beautiful.titlebar_underlay_fg,
      widget             = infobg,
    }

    tb:setup {
        { -- Left
            beautiful.titlebar_side_top_left and wibox.widget.imagebox(beautiful.titlebar_side_top_left),
            {
                {
                    {
                        resize_handle,
                        tag_selector ,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    left   = 2                  ,
                    right  = 10                 ,
                    layout = wibox.container.margin,
                },
                id      = "left_button_bg"       ,
                bg      = beautiful.titlebar_top_left_bg or alt_color              ,
                bgimage = alt_image              ,
                shape   = beautiful.titlebar_top_left_shape,
                shape_args = beautiful.titlebar_top_left_shape_args,
                shape_border_color   = beautiful.titlebar_top_left_shape_border_color,
                shape_border_width   = beautiful.titlebar_top_left_shape_border_width,
                layout  = wibox.container.background,
            },
            endArrow_alt,
            (not align or align == "left") and title_layout or nil,
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Middle
            nil,
            (align  == "center") and title_layout or nil,
            id      = "middle_section"               ,
            expand  = align == "center" and "outside",
            buttons = buttons                        ,
            layout  = wibox.layout.align.horizontal  ,
        },
        { -- Right
            endArrowR2,
            {
                {
                    right_layout                ,
                    left   = 10                 ,
                    right  = 2                  ,
                    layout = wibox.container.margin,
                },
                id      = "title_bg"             ,
                bg      = beautiful.titlebar_top_right_bg or alt_color              ,
                bgimage = alt_image              ,
                shape   = beautiful.titlebar_top_right_shape,
                shape_border_color   = beautiful.titlebar_top_right_shape_border_color,
                shape_border_width   = beautiful.titlebar_top_right_shape_border_width,
                shape_args           = beautiful.titlebar_right_left_shape_args,
                layout  = wibox.container.background,
            },
            beautiful.titlebar_side_top_right and wibox.widget.imagebox(beautiful.titlebar_side_top_right),
            layout = wibox.layout.fixed.horizontal,
        },
        expand = "inside"                     ,
        id     = "main_layout"                ,
        layout = wibox.layout.align.horizontal,
    }

    infoshapes = tb:get_children_by_id("infoshapes")[1]

    title:connect_signal("widget::redraw_needed", function()
        infoshapes:emit_signal("widget::layout_changed") --HACK
    end)

    resize_handle:connect_signal("mouse::enter",function()
        set_underlay(c,infoshapes,{{
            text = "Resize",
            bg    = beautiful.titlebar_underlay_bg or beautiful.underlay_bg or "#0C2853"
        }})
    end)
    resize_handle:connect_signal("mouse::leave",function()
        set_underlay(c,infoshapes)
    end)

    tag_selector:connect_signal("mouse::enter",function()
        set_underlay(c,infoshapes,{{
            text = "Tag",
            bg    = beautiful.titlebar_underlay_bg or beautiful.underlay_bg or "#0C2853"
        }})
    end)
    tag_selector:connect_signal("mouse::leave",function()
        set_underlay(c,infoshapes)
    end)
    set_underlay(c,infoshapes)

    --------------------------------------------------
    --               Bottom titlebar                --
    --------------------------------------------------

    if c.floating or beautiful.titlebar_bottom then

        local tb2 = awful.titlebar(c,{size= beautiful.titlebar_bottom_height or 5,position="bottom"})

        tb2:setup {
            {
                draw    = draw_bottom_left             ,
                fit     = bottom_corner_fit            ,
                widget  = wibox.widget.base.make_widget,
                buttons = awful.util.table.join(
                    awful.button({ }, 1, function(geometry)
                        awful.mouse.client.resize(c)
                end))
            },
            {
                draw    = beautiful.titlebar_bottom_draw or draw_3_dots,
                fit     = function(self,w,h)
                    return w,h
                end                                    ,
                widget  = wibox.widget.base.make_widget,
                buttons = awful.util.table.join(
                    awful.button({ }, 1, function(geometry)
                        c:raise()
                        awful.mouse.client.resize(c)
                end))
            },
            {
                draw    = draw_bottom_right            ,
                fit     = bottom_corner_fit            ,
                widget  = wibox.widget.base.make_widget,
                buttons = awful.util.table.join(
                    awful.button({ }, 1, function(geometry)
                        awful.mouse.client.resize(c)
                end))
            },
            id     = "main_layout",
            layout = wibox.layout.align.horizontal,
        }

    end

    --------------------------------------------------
    --               Sides titlebars                --
    --------------------------------------------------

    -- The left border
    if beautiful.titlebar_left then
        local tb2 = awful.titlebar(c,{size= beautiful.titlebar_left_width or 5,position="left"})
        tb2:setup {
            wibox.widget.textbox(" "),
            bg        = beautiful.titlebar_bg_left or beautiful.titlebar_bg_sides or beautiful.fg_normal,
            bgimage   = beautiful.titlebar_bgimage_left,
            widget    = wibox.container.background
        }
    end

    -- The right border
    if beautiful.titlebar_right then
        local tb2 = awful.titlebar(c,{size= beautiful.titlebar_right_width or 5,position="right"})
        tb2:setup {
            wibox.widget.textbox(" "),
            bg        = beautiful.titlebar_bg_left or beautiful.titlebar_bg_sides or beautiful.fg_normal,
            bgimage   = beautiful.titlebar_bgimage_right,
            widget    = wibox.container.background
        }
    end



    -- Update the bar when focus change
--     c:connect_signal("focus", function(c)
--         title:emit_signal("widget::redraw_needed")
--         print("HERE", beautiful.titlebar_fg_focus)
--         tb:set_fg("#ff00ff")
--     end)
-- 
--     c:connect_signal("unfocus", function(c)
-- --         tb:set_fg("#ff0000")
--     end)
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 4; replace-tabs on;
