local setmetatable = setmetatable
local menu2        = require("radical.context")
local beautiful    = require( "beautiful"                    )
local awful = require("awful")
-- local shifty    = require( "shifty"       )
local util    = require( "awful.util"                    )
local type = type
local config = require("forgotten")
local print = print
local ipairs = ipairs
local pairs = pairs
local capi = {
               mouse = mouse,
               screen = screen,
               tag = tag,
             }

local module = {}

-- local function hightlight(aWibox, value)
--   aWibox.bg = (value == true) and beautiful.bg_focus or beautiful.bg_normal
-- end

module.client = nil
local mainMenu

local function listTags()
    function createTagList(aScreen)
        local tagList = menu2({autodiscard = true})
        local count = 0
        for _, v in ipairs(awful.tag.gettags(aScreen)) do
            tagList:add_item({text = v.name})
            count = count + 1
        end
        return tagList
    end
    if capi.screen.count() == 1 then
        return createTagList(1)
    else
        local screenSelect = menu2(({autodiscard = true}))
        for i=1, capi.screen.count() do
            screenSelect:add_item({text="Screen "..i , sub_menu = createTagList(i)})
        end
--         screenSelect.width = 300
        return screenSelect
    end
end

local function createNewTag_click(c1,c2,c3,screen)
    local t
    if not screen and capi.screen.count() > 1 then
        return nil
    elseif screen then
        t = shifty.add({name = module.client.name, screen = screen})
    else
        t = shifty.add({name = module.client.name, screen = 1})
    end
    if t and module.client then
        module.client:tags({t})
    end
end

local function createNewTag()
    return awful.tag.add(module.client.class)
end

local function initConf()
    if not config.persistent then config.persistent = {} end
    if not config.persistent.flags then config.persistent.flags = {} end
    
    if not config.persistent.flags.startup         then config.persistent.flags.startup        = {} end
    if not config.persistent.flags.geometry        then config.persistent.flags.geometry       = {} end
    if not config.persistent.flags.float           then config.persistent.flags.float          = {} end
    if not config.persistent.flags.slave           then config.persistent.flags.slave          = {} end
    if not config.persistent.flags.border_width    then config.persistent.flags.border_width   = {} end
    if not config.persistent.flags.nopopup         then config.persistent.flags.nopopup        = {} end
    if not config.persistent.flags.intrusive       then config.persistent.flags.intrusive      = {} end
    if not config.persistent.flags.fullscreen      then config.persistent.flags.fullscreen     = {} end
    if not config.persistent.flags.honorsizehints  then config.persistent.flags.honorsizehints = {} end
    if not config.persistent.flags.kill            then config.persistent.flags.kill           = {} end
    if not config.persistent.flags.ontop           then config.persistent.flags.ontop          = {} end
    if not config.persistent.flags.above           then config.persistent.flags.above          = {} end
    if not config.persistent.flags.below           then config.persistent.flags.below          = {} end
    if not config.persistent.flags.buttons         then config.persistent.flags.buttons        = {} end
    if not config.persistent.flags.nofocus         then config.persistent.flags.nofocus        = {} end
    if not config.persistent.flags.keys            then config.persistent.flags.keys           = {} end
    if not config.persistent.flags.hidden          then config.persistent.flags.hidden         = {} end
    if not config.persistent.flags.minimized       then config.persistent.flags.minimized      = {} end
    if not config.persistent.flags.dockable        then config.persistent.flags.dockable       = {} end
    if not config.persistent.flags.urgent          then config.persistent.flags.urgent         = {} end
    if not config.persistent.flags.opacity         then config.persistent.flags.opacity        = {} end
    if not config.persistent.flags.titlebar        then config.persistent.flags.titlebar       = {} end
    if not config.persistent.flags.run             then config.persistent.flags.run            = {} end
    if not config.persistent.flags.sticky          then config.persistent.flags.sticky         = {} end
    if not config.persistent.flags.wfact           then config.persistent.flags.wfact          = {} end
    if not config.persistent.flags.struts          then config.persistent.flags.struts         = {} end
    if not config.persistent.flags.skip_taskbar    then config.persistent.flags.skip_taskbar   = {} end
    if not config.persistent.flags.props           then config.persistent.flags.props          = {} end
    if not config.persistent.flags.maximized       then config.persistent.flags.maximized      = {} end
end


local sigMenu = nil
local function singalMenu()
    if sigMenu then
        return sigMenu
    end
    sigMenu = menu2()
    sig0          = sigMenu:add_item({text="SIG0"             , button1 = function() util.spawn("kill -s 0       "..module.client.pid) end})
    sigalrm       = sigMenu:add_item({text="SIGALRM"          , button1 = function() util.spawn("kill -s ALRM    "..module.client.pid) end})
    sighup        = sigMenu:add_item({text="SIGHUP"           , button1 = function() util.spawn("kill -s HUP     "..module.client.pid) end})
    sigint        = sigMenu:add_item({text="SIGINT"           , button1 = function() util.spawn("kill -s INT     "..module.client.pid) end})
    sigkill       = sigMenu:add_item({text="SIGKILL"          , button1 = function() util.spawn("kill -s KILL    "..module.client.pid) end})
    sigpipe       = sigMenu:add_item({text="SIGPIPE"          , button1 = function() util.spawn("kill -s PIPE    "..module.client.pid) end})
    sigpoll       = sigMenu:add_item({text="SIGPOLL"          , button1 = function() util.spawn("kill -s POLL    "..module.client.pid) end})
    sigprof       = sigMenu:add_item({text="SIGPROF"          , button1 = function() util.spawn("kill -s PROF    "..module.client.pid) end})
    sigterm       = sigMenu:add_item({text="SIGTERM"          , button1 = function() util.spawn("kill -s TERM    "..module.client.pid) end})
    sigusr1       = sigMenu:add_item({text="SIGUSR1"          , button1 = function() util.spawn("kill -s USR1    "..module.client.pid) end})
    sigusr2       = sigMenu:add_item({text="SIGUSR2"          , button1 = function() util.spawn("kill -s USR2    "..module.client.pid) end})
    sigsigvtalrm  = sigMenu:add_item({text="SIGVTALRM"        , button1 = function() util.spawn("kill -s VTALRM  "..module.client.pid) end})
    sigstkflt     = sigMenu:add_item({text="SIGSTKFLT"        , button1 = function() util.spawn("kill -s STKFLT  "..module.client.pid) end})
    sigpwr        = sigMenu:add_item({text="SIGPWR"           , button1 = function() util.spawn("kill -s PWR     "..module.client.pid) end})
    sigwinch      = sigMenu:add_item({text="SIGWINCH"         , button1 = function() util.spawn("kill -s WINCH   "..module.client.pid) end})
    sigchld       = sigMenu:add_item({text="SIGCHLD"          , button1 = function() util.spawn("kill -s CHLD    "..module.client.pid) end})
    sigurg        = sigMenu:add_item({text="SIGURG"           , button1 = function() util.spawn("kill -s URG     "..module.client.pid) end})
    sigtstp       = sigMenu:add_item({text="SIGTSTP"          , button1 = function() util.spawn("kill -s TSTP    "..module.client.pid) end})
    sigttin       = sigMenu:add_item({text="SIGTTIN"          , button1 = function() util.spawn("kill -s TTIN    "..module.client.pid) end})
    sigttou       = sigMenu:add_item({text="SIGTTOU"          , button1 = function() util.spawn("kill -s TTOU    "..module.client.pid) end})
    sigstop       = sigMenu:add_item({text="SIGSTOP"          , button1 = function() util.spawn("kill -s STOP    "..module.client.pid) end})
    sigcont       = sigMenu:add_item({text="SIGCONT"          , button1 = function() util.spawn("kill -s CONT    "..module.client.pid) end})
    sigabrt       = sigMenu:add_item({text="SIGABRT"          , button1 = function() util.spawn("kill -s ABRT    "..module.client.pid) end})
    sigfpe        = sigMenu:add_item({text="SIGFPE"           , button1 = function() util.spawn("kill -s FPE     "..module.client.pid) end})
    sigill        = sigMenu:add_item({text="SIGILL"           , button1 = function() util.spawn("kill -s ILL     "..module.client.pid) end})
    sigquit       = sigMenu:add_item({text="SIGQUIT"          , button1 = function() util.spawn("kill -s QUIT    "..module.client.pid) end})
    sigsegv       = sigMenu:add_item({text="SIGSEGV"          , button1 = function() util.spawn("kill -s SEGV    "..module.client.pid) end})
    sigtrap       = sigMenu:add_item({text="SIGTRAP"          , button1 = function() util.spawn("kill -s TRAP    "..module.client.pid) end})
    sigsys        = sigMenu:add_item({text="SIGSYS"           , button1 = function() util.spawn("kill -s SYS     "..module.client.pid) end})
    sigemt        = sigMenu:add_item({text="SIGEMT"           , button1 = function() util.spawn("kill -s EMT     "..module.client.pid) end})
    sigbus        = sigMenu:add_item({text="SIGBUS"           , button1 = function() util.spawn("kill -s BUS     "..module.client.pid) end})
    sigxcpu       = sigMenu:add_item({text="SIGXCPU"          , button1 = function() util.spawn("kill -s XCPU    "..module.client.pid) end})
    sigxfsz       = sigMenu:add_item({text="SIGXFSZ"          , button1 = function() util.spawn("kill -s XFSZ    "..module.client.pid) end})
    return sigMenu
end

local layer_m = nil
function layerMenu()
    if layer_m then
        return layer_m
    end
    layer_m = menu2()
    
--     local norm = layer_m:add_item({text="Normal"      , checked=true , button1 = function() module.client. = not module.client.;norm.checked =  end})
    above = layer_m:add_item({text="Above"       , checked=true , button1 = function()
      module.client.above = not module.client.above
      above.checked = module.client.above
      ontop.checked = module.client.ontop
      below.checked = module.client.below
    end})
    below = layer_m:add_item({text="Below"       , checked=true , button1 = function()
      module.client.below = not module.client.below
      below.checked = module.client.below
      above.checked = module.client.above
      ontop.checked = module.client.ontop
    end})
    ontop = layer_m:add_item({text="On Top"      , checked=true , button1 = function()
      module.client.ontop = not module.client.ontop
      ontop.checked = module.client.ontop
      below.checked = module.client.below
      above.checked = module.client.above
    end})
    
    return layer_m
end

local function new(screen, args)
  initConf()
  mainMenu = menu2()
  itemVisible    = mainMenu:add_item({text="Visible"     , checked= function() if module.client ~= nil then return not module.client.hidden else return false end end
    , button1 = function()
        module.client.minimized =  not module.client.minimized
        itemVisible.checked = not module.client.minimized
  end})
  itemVSticky    = mainMenu:add_item({text="Sticky"      , checked= function() if module.client ~= nil then return module.client.sticky else return false end end
    , button1 = function() 
        module.client.sticky = not module.client.sticky
        itemVSticky.checked = module.client.sticky
  end})
  itemVFloating  = mainMenu:add_item({text="Floating"    , checked=true , button1 = function() 
    awful.client.floating.set(module.client,not awful.client.floating.get(module.client))
    itemVFloating.checked = awful.client.floating.get(module.client)
  end})
  itemMaximized  = mainMenu:add_item({text="Fullscreen"   , checked=true , button1 = function() 
    module.client.fullscreen = not module.client.fullscreen
    itemMaximized.checked = module.client.fullscreen 
  end})
  itemMoveToTag  = mainMenu:add_item({text="Move to tag" , sub_menu=listTags,})
  itemSendSignal = mainMenu:add_item({text="Send Signal" , sub_menu = singalMenu()})
  itemRenice     = mainMenu:add_item({text="Renice"      , checked=true , button1 = function()  end})
  itemNewTag     = mainMenu:add_item({text="Move to a new Tag"      , button1 = function() 
    local t = createNewTag()
    module.client:tags({t})
    awful.tag.viewonly(t)
    mainMenu.visible = false
  end})
  
  itemLayer     = mainMenu:add_item({text="Layer"       , sub_menu=layerMenu(), button1 = function()  end})
  itemClose      = mainMenu:add_item({text="Close"       , button1 = function() if module.client ~= nil then  module.client:kill();mainMenu.visible=false end end})
  
  mainMenu_per = menu2()
  itemMaximized_per       = mainMenu_per:add_item({text="Maximized"      , checked= true , button1 = function() config.persistent.flags.maximized[module.client.class]      = not (config.persistent.flags.maximized[module.client.class] or false) end})
  itemStartup_per         = mainMenu_per:add_item({text="Startup"        , checked= true , button1 = function() config.persistent.flags.startup[module.client.class]        = not (config.persistent.flags.startup[module.client.class]        or false) end})
  itemGeometry_per        = mainMenu_per:add_item({text="Geometry"       , checked= true , button1 = function() config.persistent.flags.geometry[module.client.class]       = not (config.persistent.flags.geometry[module.client.class]       or false) end})
  itemFloat_per           = mainMenu_per:add_item({text="Float"          , checked= true , button1 = function() config.persistent.flags.float[module.client.class]          = not (config.persistent.flags.float[module.client.class]          or false) end})
  itemSlave_per           = mainMenu_per:add_item({text="Slave"          , checked= true , button1 = function() config.persistent.flags.slave[module.client.class]          = not (config.persistent.flags.slave[module.client.class]          or false) end})
  itemBorder_width_per    = mainMenu_per:add_item({text="Border_width"   , checked= true , button1 = function() config.persistent.flags.border_width[module.client.class]   = not (config.persistent.flags.border_width[module.client.class]   or false) end})
  itemNopopup_per         = mainMenu_per:add_item({text="Nopopup"        , checked= true , button1 = function() config.persistent.flags.nopopup[module.client.class]        = not (config.persistent.flags.nopopup[module.client.class]        or false) end})
  itemIntrusive_per       = mainMenu_per:add_item({text="Intrusive"      , checked= true , button1 = function() config.persistent.flags.intrusive[module.client.class]      = not (config.persistent.flags.intrusive[module.client.class]      or false) end})
  itemFullscreen_per      = mainMenu_per:add_item({text="Fullscreen"     , checked= true , button1 = function() config.persistent.flags.fullscreen[module.client.class]     = not (config.persistent.flags.fullscreen[module.client.class]     or false) end})
  itemHonorsizehints_per  = mainMenu_per:add_item({text="Honorsizehints" , checked= true , button1 = function() config.persistent.flags.honorsizehints[module.client.class] = not (config.persistent.flags.honorsizehints[module.client.class] or false) end})
  itemKill_per            = mainMenu_per:add_item({text="Kill"           , checked= true , button1 = function() config.persistent.flags.kill[module.client.class]           = not (config.persistent.flags.kill[module.client.class]           or false) end})
  itemOntop_per           = mainMenu_per:add_item({text="Ontop"          , checked= true , button1 = function() config.persistent.flags.ontop[module.client.class]          = not (config.persistent.flags.ontop[module.client.class]          or false) end})
  itemAbove_per           = mainMenu_per:add_item({text="Above"          , checked= true , button1 = function() config.persistent.flags.above[module.client.class]          = not (config.persistent.flags.above[module.client.class]          or false) end})
  itemBelow_per           = mainMenu_per:add_item({text="Below"          , checked= true , button1 = function() config.persistent.flags.below[module.client.class]          = not (config.persistent.flags.below[module.client.class]          or false) end})
  itemButtons_per         = mainMenu_per:add_item({text="Buttons"        , checked= true , button1 = function() config.persistent.flags.buttons[module.client.class]        = not (config.persistent.flags.buttons[module.client.class]        or false) end})
  itemNofocus_per         = mainMenu_per:add_item({text="Nofocus"        , checked= true , button1 = function() config.persistent.flags.nofocus[module.client.class]        = not (config.persistent.flags.nofocus[module.client.class]        or false) end})
  itemKeys_per            = mainMenu_per:add_item({text="Keys"           , checked= true , button1 = function() config.persistent.flags.keys[module.client.class]           = not (config.persistent.flags.keys[module.client.class]           or false) end})
  itemHidden_per          = mainMenu_per:add_item({text="Hidden"         , checked= true , button1 = function() config.persistent.flags.hidden[module.client.class]         = not (config.persistent.flags.hidden[module.client.class]         or false) end})
  itemMinimized_per       = mainMenu_per:add_item({text="Minimized"      , checked= true , button1 = function() config.persistent.flags.minimized[module.client.class]      = not (config.persistent.flags.minimized[module.client.class]      or false) end})
  itemDockable_per        = mainMenu_per:add_item({text="Dockable"       , checked= true , button1 = function() config.persistent.flags.dockable[module.client.class]       = not (config.persistent.flags.dockable[module.client.class]       or false) end})
  itemUrgent_per          = mainMenu_per:add_item({text="Urgent"         , checked= true , button1 = function() config.persistent.flags.urgent[module.client.class]         = not (config.persistent.flags.urgent[module.client.class]         or false) end})
  itemOpacity_per         = mainMenu_per:add_item({text="Opacity"        , checked= true , button1 = function() config.persistent.flags.opacity[module.client.class]        = not (config.persistent.flags.opacity[module.client.class]        or false) end})
  itemTitlebar_per        = mainMenu_per:add_item({text="Titlebar"       , checked= true , button1 = function() config.persistent.flags.titlebar[module.client.class]       = not (config.persistent.flags.titlebar[module.client.class]       or false) end})
  itemRun_per             = mainMenu_per:add_item({text="Run"            , checked= true , button1 = function() config.persistent.flags.run[module.client.class]            = not (config.persistent.flags.run[module.client.class]            or false) end})
  itemSticky_per          = mainMenu_per:add_item({text="Sticky"         , checked= true , button1 = function() config.persistent.flags.sticky[module.client.class]         = not (config.persistent.flags.sticky[module.client.class]         or false) end})
  itemWfact_per           = mainMenu_per:add_item({text="Wfact"          , checked= true , button1 = function() config.persistent.flags.wfact[module.client.class]          = not (config.persistent.flags.wfact[module.client.class]          or false) end})
  itemStruts_per          = mainMenu_per:add_item({text="Struts"         , checked= true , button1 = function() config.persistent.flags.struts[module.client.class]         = not (config.persistent.flags.struts[module.client.class]         or false) end})
  itemSkip_taskbar_per    = mainMenu_per:add_item({text="Skip_taskbar"   , checked= true , button1 = function() config.persistent.flags.skip_taskbar[module.client.class]   = not (config.persistent.flags.skip_taskbar[module.client.class]   or false) end})
  itemProps_per           = mainMenu_per:add_item({text="Props"          , checked= true , button1 = function() config.persistent.flags.props[module.client.class]          = not (config.persistent.flags.props[module.client.class]          or false) end})

  return mainMenu
end

module.menu = function()
    return mainMenu or new()
end

function module.toggle(c)
    module.client = c
    if not itemVisible then
        new()
    end
    local mainMenu2 = menu2()
    mainMenu2:add_existing_item( itemVisible    )
    mainMenu2:add_existing_item( itemSticky     )
    mainMenu2:add_existing_item( itemFloating   )
    mainMenu2:add_existing_item( itemMaximized  )
    mainMenu2:add_existing_item( itemMaster     )
    mainMenu2:add_existing_item( itemLayer      )
    mainMenu2:add_existing_item( itemMoveToTag  )
    mainMenu2:add_existing_item( itemClose      )
    mainMenu2:add_existing_item( itemSendSignal )
    mainMenu2:add_existing_item( itemRenice     )
    mainMenu2:add_existing_item( itemNewTag     )
    if mainMenu then
        function classMenu(c)
            local classM = menu2()
            classM:add_item({text = "<b><tt>PERSISTENT</tt></b>",bg= beautiful.fg_normal,fg=beautiful.bg_normal,align="center"})
            classM:add_item({text = c.name})
            classM:add_item({text = "Intrusive"     })
            classM:add_item({text = "Match to Tags" })
            classM:add_item({text = "Flags", sub_menu = function()
--                 local flagMenu = menu2()
--                 itemMaximized_per     :check( config.persistent.flags.maximized[module.client.class]      or false)
--                 itemStartup_per       :check( config.persistent.flags.startup[module.client.class]        or false)
--                 itemGeometry_per      :check( config.persistent.flags.geometry[module.client.class]       or false)
--                 itemFloat_per         :check( config.persistent.flags.float[module.client.class]          or false)
--                 itemSlave_per         :check( config.persistent.flags.slave[module.client.class]          or false)
--                 itemBorder_width_per  :check( config.persistent.flags.border_width[module.client.class]   or false)
--                 itemNopopup_per       :check( config.persistent.flags.nopopup[module.client.class]        or false)
--                 itemIntrusive_per     :check( config.persistent.flags.intrusive[module.client.class]      or false)
--                 itemFullscreen_per    :check( config.persistent.flags.fullscreen[module.client.class]     or false)
--                 itemHonorsizehints_per:check( config.persistent.flags.honorsizehints[module.client.class] or false)
--                 itemKill_per          :check( config.persistent.flags.kill[module.client.class]           or false)
--                 itemOntop_per         :check( config.persistent.flags.ontop[module.client.class]          or false)
--                 itemAbove_per         :check( config.persistent.flags.above[module.client.class]          or false)
--                 itemBelow_per         :check( config.persistent.flags.below[module.client.class]          or false)
--                 itemButtons_per       :check( config.persistent.flags.buttons[module.client.class]        or false)
--                 itemNofocus_per       :check( config.persistent.flags.nofocus[module.client.class]        or false)
--                 itemKeys_per          :check( config.persistent.flags.keys[module.client.class]           or false)
--                 itemHidden_per        :check( config.persistent.flags.hidden[module.client.class]         or false)
--                 itemMinimized_per     :check( config.persistent.flags.minimized[module.client.class]      or false)
--                 itemDockable_per      :check( config.persistent.flags.dockable[module.client.class]       or false)
--                 itemUrgent_per        :check( config.persistent.flags.urgent[module.client.class]         or false)
--                 itemOpacity_per       :check( config.persistent.flags.opacity[module.client.class]        or false)
--                 itemTitlebar_per      :check( config.persistent.flags.titlebar[module.client.class]       or false)
--                 itemRun_per           :check( config.persistent.flags.run[module.client.class]            or false)
--                 itemSticky_per        :check( config.persistent.flags.sticky[module.client.class]         or false)
--                 itemWfact_per         :check( config.persistent.flags.wfact[module.client.class]          or false)
--                 itemStruts_per        :check( config.persistent.flags.struts[module.client.class]         or false)
--                 itemSkip_taskbar_per  :check( config.persistent.flags.skip_taskbar[module.client.class]   or false)
--                 itemProps_per         :check( config.persistent.flags.props[module.client.class]          or false)
--                 flagMenu:add_existing_item( itemMaximized_per      )
--                 flagMenu:add_existing_item( itemStartup_per        )
--                 flagMenu:add_existing_item( itemGeometry_per       )
--                 flagMenu:add_existing_item( itemFloat_per          )
--                 flagMenu:add_existing_item( itemSlave_per          )
--                 flagMenu:add_existing_item( itemBorder_width_per   )
--                 flagMenu:add_existing_item( itemNopopup_per        )
--                 flagMenu:add_existing_item( itemIntrusive_per      )
--                 flagMenu:add_existing_item( itemFullscreen_per     )
--                 flagMenu:add_existing_item( itemHonorsizehints_per )
--                 flagMenu:add_existing_item( itemKill_per           )
--                 flagMenu:add_existing_item( itemOntop_per          )
--                 flagMenu:add_existing_item( itemAbove_per          )
--                 flagMenu:add_existing_item( itemBelow_per          )
--                 flagMenu:add_existing_item( itemButtons_per        )
--                 flagMenu:add_existing_item( itemNofocus_per        )
--                 flagMenu:add_existing_item( itemKeys_per           )
--                 flagMenu:add_existing_item( itemHidden_per         )
--                 flagMenu:add_existing_item( itemMinimized_per      )
--                 flagMenu:add_existing_item( itemDockable_per       )
--                 flagMenu:add_existing_item( itemUrgent_per         )
--                 flagMenu:add_existing_item( itemOpacity_per        )
--                 flagMenu:add_existing_item( itemTitlebar_per       )
--                 flagMenu:add_existing_item( itemRun_per            )
--                 flagMenu:add_existing_item( itemSticky_per         )
--                 flagMenu:add_existing_item( itemWfact_per          )
--                 flagMenu:add_existing_item( itemStruts_per         )
--                 flagMenu:add_existing_item( itemSkip_taskbar_per   )
--                 flagMenu:add_existing_item( itemProps_per          )
                return flagMenu
            end})
            classM:add_item({text = "Tags", sub_menu = function() 
                local tagMenu = menu2()
                for k,v in pairs(shifty.config.tags) do
                    if type(k) == "string" then
                        local check = false
                        if config.persistent.tag and config.persistent.tag[k] and config.persistent.tag[k].class and config.persistent.tag[k].class[module.client.class] == true then
                            check = true
                        end
                        tagMenu:add_item({text=k      , checked=check , button1 = function() 
                            if not config.persistent.tag then config.persistent.tag = {} end
                            if not config.persistent.tag[k] then config.persistent.tag[k] = {} end
                            if not config.persistent.tag[k].class then config.persistent.tag[k].class = {} end
                            config.persistent.tag[k].class[module.client.class] = not config.persistent.tag[k].class[module.client.class] or false
                        end})
                    end
                end
                return tagMenu
            end})
            return classM
        end

        mainMenu2.x = c:geometry().x
        mainMenu2.y = c:geometry().y+16
        mainMenu2:add_item({text = "<b><u>"..c.class.."</u></b>", sub_menu = function() return classMenu(c) end, fg="#880000"})
        mainMenu2.visible = true
    end
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
