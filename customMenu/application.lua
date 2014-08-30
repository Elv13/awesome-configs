local setmetatable = setmetatable
local pairs        = pairs
local ipairs       = ipairs
local button       = require( "awful.button"               )
local beautiful    = require( "beautiful"                  )
local util         = require( "awful.util"                 )
local menu         = require( "radical.context"            )
local tooltip2     = require( "radical.tooltip"           )
local fdutils      = require( "extern.freedesktop.utils"   )
local themeutils   = require( "blind.common.drawing"       )
local wibox        = require( "wibox"                      )
local cairo        = require( "lgi"                        ).cairo
local pango        = require( "lgi"                        ).Pango
local style        = require( "radical.style.classic"      )
local item_style   = require( "radical.item.style.classic" )
local color = require("gears.color")
local capi         = { screen  = screen }

fdutils.icon_theme = 'oxygen'

local show_generic_name = false

fdutils.add_base_path ( "/home/kde-devel/kde/share/icons/"         )
fdutils.add_theme_path( "/home/kde-devel/kde/share/icons/hicolor/" )

local categories = {
    AudioVideo ={icon="applications-multimedia.png" ,name="Multimedia"  }, Development={icon="applications-development.png",name="Development" },
    Education  ={icon="applications-science.png"    ,name="Education"   }, Game       ={icon="applications-games.png"      ,name="Games"       },
    Graphics   ={icon="applications-graphics.png"   ,name="Graphics"    }, Network    ={icon="applications-internet.png"   ,name="Internet"    },
    Office     ={icon="applications-office.png"     ,name="Office"      }, Settings   ={icon="preferences-desktop.png"     ,name="Settings"    },
    System     ={icon="applications-system.png"     ,name="System Tools"}, Utility    ={icon="applications-accessories.png",name="Accessories" },
    Other      ={icon="applications-other.png"      ,name="Other"       }, }

local parse_init,cats,programs = false,{},{}
local function parse_files()
    local dirs = { '/usr/share/applications/', '/usr/local/share/applications/',
    '~/.local/share/applications/', '/home/kde-devel/kde/share/applications/' }
    for i=1,#dirs do
        local entries = fdutils.parse_desktop_files({dir = dirs[i],size='22x22',category='apps'})
        for j=1, #entries do
            local program = entries[j]
            -- check whether to include in the menu
            if program.show and program.Name and program.cmdline then
                if show_generic_name and program.GenericName then
                    program.Name = program.Name .. ' (' .. program.GenericName .. ')'
                end
                local target_category = nil
                if program.categories then
                    for k=1, #program.categories do
                        local category = program.categories[k]
                        if categories[category] then
                            target_category = category
                            break
                        end
                    end
                end
                target_category = target_category or 'Other'
                program.Name = program.Name:gsub('&',"&amp;")
                local arr = cats[target_category]
                if not arr then
                    cats[target_category] = {}
                    arr = cats[target_category]
                end
                arr[#arr+1] = {text = program.Name, icon = program.icon_path,button1 = function() util.spawn(program.cmdline,true) end}
            end
        end
    end
    parse_init = true
end

local program2 = {}
local function gen_category_menu(cat)
    if program2[cat] then return program2[cat] end
    if not parse_init then parse_files() end
    local m = menu({has_decoration=false,style=style,item_style=item_style})
    for k,v in ipairs(cats[cat] or {}) do
        m:add_item(v)
    end
    program2[cat] = m
    return m
end

local function gen_menu(parent)
    local config = arg or {}

    local m = menu({filter = true, showfilter = true, y = capi.screen[1].geometry.height - 18, x = offset, 
    autodiscard = true,has_decoration=false,x=0,filtersubmenu=true,maxvisible=20,style=style,item_style=item_style,
    show_filter=true})
    for k,v in pairs(categories) do
        m:add_item({text=v.name,icon=fdutils.lookup_icon({icon=v.icon,icon_size='22x22'}),sub_menu=function() return gen_category_menu(k) end})
    end

    return m
end


local function get_menu()
    mymainmenu = mymainmenu or gen_menu(bgb)
    return mymainmenu
end

return setmetatable({get_menu=get_menu}, { __call = function(_, ...) return get_menu(...) end })