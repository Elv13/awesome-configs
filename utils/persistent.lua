local setmetatable = setmetatable
local ipairs       = ipairs
local pairs        = pairs
local print        = print
local table        = table
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local config       = require( "config"       )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

local capi = { image  = image  ,
               widget = widget }

module("utils.persistent")

function loadClassesRules(t)
--     startup
--     geometry
--     float
--     slave
--     border_width
--     nopopup
--     intrusive
--     fullscreen
--     honorsizehints
--     kill
--     ontop
--     above
--     below
--     buttons
--     nofocus
--     keys
--     hidden
--     minimized
--     dockable
--     urgent
--     opacity
--     titlebar
--     run
--     sticky
--     wfact
--     struts
--     skip_taskbar
--     props
    
    
    local prop = { "intrusive", "sticky" }--, geometry   , float          , slave    , border_width , nopopup   ,
--                   startup   , fullscreen , honorsizehints , kill     , ontop        , above     ,
--                   below     , buttons    , nofocus        , keys     , hidden       , minimized ,
--                   dockable  , urgent     , opacity        , titlebar , run          , sticky    ,
--                   wfact     , struts     , skip_taskbar   , props                               }

--     local prop = { startup       , geometry      , float           , slave    , border_width   , nopopup         ,
--                    intrusive     , fullscreen    , honorsizehints  , kill     , ontop          , above           ,
--                    below         , buttons       , nofocus         , keys     , hidden         , minimized       ,
--                    dockable      , urgent        , opacity         , titlebar , run            , sticky          ,
--                    wfact         , struts        , skip_taskbar    , props                                       }
    print("Loading persistent rules",#prop)
    for k,v in pairs(prop) do
        local realT = config.get_real(config.data().persistent.flags[v])
        print("Table "..v,realT)
        for k2,v2 in pairs(realT) do
            print("In table: "..v)
        end
        table.insert(t,{match=reatT,[v]=true})
    end
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })