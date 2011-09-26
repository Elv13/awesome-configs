local setmetatable = setmetatable
local menu2        = require("widgets.menu")
local beautiful    = require( "beautiful"                    )
local shifty    = require( "shifty"       )
local print = print
local ipairs = ipairs

local capi = {
               mouse = mouse,
               screen = screen,
               tag = tag,
             }

module("customMenu.clientMenu")

-- local function hightlight(aWibox, value)
--   aWibox.bg = (value == true) and beautiful.bg_focus or beautiful.bg_normal
-- end

local aClient
local mainMenu

local function listTags()
    function createTagList(aScreen)
        local tagList = menu2()
        local count = 0
        for _, v in ipairs(capi.screen[aScreen]:tags()) do
            tagList:add_item({text = v.name})
            count = count + 1
        end
        return tagList
    end
    if capi.screen.count() == 1 then
        return createTagList(1)
    else
        local screenSelect = menu2()
        for i=1, capi.screen.count() do
            screenSelect:add_item({text="Screen "..i , subMenu = createTagList(i)})
        end
        return screenSelect
    end
end

local function createNewTag_click(c1,c2,c3,screen)
    local t
    if not screen and capi.screen.count() > 1 then
        return nil
    elseif screen then
        t = shifty.add({name = aClient.name, screen = screen})
    else
        t = shifty.add({name = aClient.name, screen = 1})
    end
    if t and aClient then
        aClient:tags({t})
    end
end

local function createNewTag()
    if capi.screen.count() == 1 then
        return nil
    else
        return function()
            local screenSelect = menu2()
            for i=1, capi.screen.count() do
                screenSelect:add_item({text="Screen "..i , onclick = function() createNewTag_click(nil,nil,nil,i) end})
            end
            return screenSelect
        end
    end
end

local function signalMenu()
    
end

local function singalMenu()
    local sigMenu = menu2()
    sig0          = sigMenu:add_item({text="SIG0"             , onclick = function() util.spawn("kill -s 0       "..aClient.pid) end})
    sigalrm       = sigMenu:add_item({text="SIGALRM"          , onclick = function() util.spawn("kill -s ALRM    "..aClient.pid) end})
    sighup        = sigMenu:add_item({text="SIGHUP"           , onclick = function() util.spawn("kill -s HUP     "..aClient.pid) end})
    sigint        = sigMenu:add_item({text="SIGINT"           , onclick = function() util.spawn("kill -s INT     "..aClient.pid) end})
    sigkill       = sigMenu:add_item({text="SIGKILL"          , onclick = function() util.spawn("kill -s KILL    "..aClient.pid) end})
    sigpipe       = sigMenu:add_item({text="SIGPIPE"          , onclick = function() util.spawn("kill -s PIPE    "..aClient.pid) end})
    sigpoll       = sigMenu:add_item({text="SIGPOLL"          , onclick = function() util.spawn("kill -s POLL    "..aClient.pid) end})
    sigprof       = sigMenu:add_item({text="SIGPROF"          , onclick = function() util.spawn("kill -s PROF    "..aClient.pid) end})
    sigterm       = sigMenu:add_item({text="SIGTERM"          , onclick = function() util.spawn("kill -s TERM    "..aClient.pid) end})
    sigusr1       = sigMenu:add_item({text="SIGUSR1"          , onclick = function() util.spawn("kill -s USR1    "..aClient.pid) end})
    sigusr2       = sigMenu:add_item({text="SIGUSR2"          , onclick = function() util.spawn("kill -s USR2    "..aClient.pid) end})
    sigsigvtalrm  = sigMenu:add_item({text="SIGVTALRM"        , onclick = function() util.spawn("kill -s VTALRM  "..aClient.pid) end})
    sigstkflt     = sigMenu:add_item({text="SIGSTKFLT"        , onclick = function() util.spawn("kill -s STKFLT  "..aClient.pid) end})
    sigpwr        = sigMenu:add_item({text="SIGPWR"           , onclick = function() util.spawn("kill -s PWR     "..aClient.pid) end})
    sigwinch      = sigMenu:add_item({text="SIGWINCH"         , onclick = function() util.spawn("kill -s WINCH   "..aClient.pid) end})
    sigchld       = sigMenu:add_item({text="SIGCHLD"          , onclick = function() util.spawn("kill -s CHLD    "..aClient.pid) end})
    sigurg        = sigMenu:add_item({text="SIGURG"           , onclick = function() util.spawn("kill -s URG     "..aClient.pid) end})
    sigtstp       = sigMenu:add_item({text="SIGTSTP"          , onclick = function() util.spawn("kill -s TSTP    "..aClient.pid) end})
    sigttin       = sigMenu:add_item({text="SIGTTIN"          , onclick = function() util.spawn("kill -s TTIN    "..aClient.pid) end})
    sigttou       = sigMenu:add_item({text="SIGTTOU"          , onclick = function() util.spawn("kill -s TTOU    "..aClient.pid) end})
    sigstop       = sigMenu:add_item({text="SIGSTOP"          , onclick = function() util.spawn("kill -s STOP    "..aClient.pid) end})
    sigcont       = sigMenu:add_item({text="SIGCONT"          , onclick = function() util.spawn("kill -s CONT    "..aClient.pid) end})
    sigabrt       = sigMenu:add_item({text="SIGABRT"          , onclick = function() util.spawn("kill -s ABRT    "..aClient.pid) end})
    sigfpe        = sigMenu:add_item({text="SIGFPE"           , onclick = function() util.spawn("kill -s FPE     "..aClient.pid) end})
    sigill        = sigMenu:add_item({text="SIGILL"           , onclick = function() util.spawn("kill -s ILL     "..aClient.pid) end})
    sigquit       = sigMenu:add_item({text="SIGQUIT"          , onclick = function() util.spawn("kill -s QUIT    "..aClient.pid) end})
    sigsegv       = sigMenu:add_item({text="SIGSEGV"          , onclick = function() util.spawn("kill -s SEGV    "..aClient.pid) end})
    sigtrap       = sigMenu:add_item({text="SIGTRAP"          , onclick = function() util.spawn("kill -s TRAP    "..aClient.pid) end})
    sigsys        = sigMenu:add_item({text="SIGSYS"           , onclick = function() util.spawn("kill -s SYS     "..aClient.pid) end})
    sigemt        = sigMenu:add_item({text="SIGEMT"           , onclick = function() util.spawn("kill -s EMT     "..aClient.pid) end})
    sigbus        = sigMenu:add_item({text="SIGBUS"           , onclick = function() util.spawn("kill -s BUS     "..aClient.pid) end})
    sigxcpu       = sigMenu:add_item({text="SIGXCPU"          , onclick = function() util.spawn("kill -s XCPU    "..aClient.pid) end})
    sigxfsz       = sigMenu:add_item({text="SIGXFSZ"          , onclick = function() util.spawn("kill -s XFSZ    "..aClient.pid) end})
    
end

function new(screen, args)
  
  mainMenu = menu2()
  itemVisible    = mainMenu:add_item({text="Visible"     , checked= function() if aClient ~= nil then return not aClient.hidden else return false end end, onclick = function()  end})
  itemVSticky    = mainMenu:add_item({text="Sticky"      , checked= function() if aClient ~= nil then return aClient.sticky else return false end end , onclick = function()  end})
  itemVFloating  = mainMenu:add_item({text="Floating"    , checked=true , onclick = function()  end})
  itemMaximized  = mainMenu:add_item({text="Maximized"   , checked=true , onclick = function()  end})
  --itemMaster     = mainMenu:add_item({text="Master"      , checked=true , onclick = function()  end})
  itemMoveToTag  = mainMenu:add_item({text="Move to tag" , subMenu=listTags,})
  itemClose      = mainMenu:add_item({text="Close"       , onclick = function() if aClient ~= nil then  aClient:kill() end end})
  itemSendSignal = mainMenu:add_item({text="Send Signal" , subMenu = function() if not sig0 then signalMenu() end
        local sigMenu = menu2()
        sigMenu:add_existing_item(sig0    )
        sigMenu:add_existing_item(sigalrm )
        sigMenu:add_existing_item(sighup  )
        sigMenu:add_existing_item(sigint  )
        sigMenu:add_existing_item(sigkill )
        sigMenu:add_existing_item(sigpipe )
        sigMenu:add_existing_item(sigpoll )
        sigMenu:add_existing_item(sigprof )
        sigMenu:add_existing_item(sigterm )
        sigMenu:add_existing_item(sigusr1 )
        sigMenu:add_existing_item(sigusr2 )
        sigMenu:add_existing_item(sigsigvtalrm)
        sigMenu:add_existing_item(sigstkflt)
        sigMenu:add_existing_item(sigpwr  )
        sigMenu:add_existing_item(sigwinch)
        sigMenu:add_existing_item(sigchld )
        sigMenu:add_existing_item(sigurg  )
        sigMenu:add_existing_item(sigtstp )
        sigMenu:add_existing_item(sigttin )
        sigMenu:add_existing_item(sigttou )
        sigMenu:add_existing_item(sigstop )
        sigMenu:add_existing_item(sigcont )
        sigMenu:add_existing_item(sigabrt )
        sigMenu:add_existing_item(sigfpe  )
        sigMenu:add_existing_item(sigill  )
        sigMenu:add_existing_item(sigquit )
        sigMenu:add_existing_item(sigsegv )
        sigMenu:add_existing_item(sigtrap )
        sigMenu:add_existing_item(sigsys  )
        sigMenu:add_existing_item(sigemt  )
        sigMenu:add_existing_item(sigbus  )
        sigMenu:add_existing_item(sigxcpu )
        sigMenu:add_existing_item(sigxfsz )
        return sigMenu
      
  end, onclick = function()  end})
  itemRenice     = mainMenu:add_item({text="Renice"      , checked=true , onclick = function()  end})
  itemNewTag     = mainMenu:add_item({text="Open in a new Tag"      , subMenu=createNewTag() , onclick = createNewTag_click})
  
  mainMenu_per = menu2()
  itemVSticky_per    = mainMenu_per:add_item({text="Sticky"      , checked=true , onclick = function()  end})
  itemVFloating_per  = mainMenu_per:add_item({text="Floating"    , checked=true , onclick = function()  end})
  itemMaximized_per  = mainMenu_per:add_item({text="Maximized"   , checked=true , onclick = function()  end})
  itemSendSignal_per = mainMenu_per:add_item({text="Send Signal" , checked=true , onclick = function()  end})
  itemRenice_per     = mainMenu_per:add_item({text="Renice"      , checked=true , onclick = function()  end})

  return mainMenu
end

function menu()
    return mainMenu or new()
end

function toggle(c)
    aClient = c
    local mainMenu2 = menu2()
    mainMenu2:add_existing_item( itemVisible    )
    mainMenu2:add_existing_item( itemSticky     )
    mainMenu2:add_existing_item( itemFloating   )
    mainMenu2:add_existing_item( itemMaximized  )
    mainMenu2:add_existing_item( itemMaster     )
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
            classM:add_item({text = "Flags", subMenu = function()
                local flagMenu = menu2()
                flagMenu:add_existing_item( itemVSticky_per    )
                flagMenu:add_existing_item( itemVFloating_per  )
                flagMenu:add_existing_item( itemMaximized_per  )
                flagMenu:add_existing_item( itemSendSignal_per )
                flagMenu:add_existing_item( itemRenice_per     )
                return flagMenu
            end})
            return classM
        end
        
        mainMenu2.settings.x = c:geometry().x
        mainMenu2.settings.y = c:geometry().y+16
        mainMenu2:add_item({text = "<b><u>"..c.class.."</u></b>", subMenu = function() return classMenu(c) end, fg="#880000"})
        mainMenu2:toggle(true)
    end
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
