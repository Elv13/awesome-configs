local setmetatable = setmetatable
local ipairs       = ipairs
local pairs        = pairs
local print        = print
local table        = table
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local config       = require( "forgotten"       )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

local capi = { image  = image  ,
               widget = widget }

local module = {}

function  module.loadClassesRules(t)
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
    if config.persistent then
        for k,v in pairs(prop) do
            local realT = config.get_real(config.persistent.flags[v])
            print("Table "..v,realT)
            for k2,v2 in pairs(realT) do
                print("In table: "..v)
            end
            table.insert(t,{match=reatT,[v]=true})
        end
    end
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })