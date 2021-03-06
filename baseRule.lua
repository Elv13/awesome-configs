local awful = require("awful")
local utils = require("utils")
local tyrannical = require("tyrannical")
local config = require("forgotten")

local tile   = require('dynamite.layout.ratio')
local cond   = require('dynamite.layout.conditional')
local corner = require('dynamite.suit.corner')
local fair   = require('dynamite.suit.fair')
local margin = require('wibox.container.margin')
local dynamite = require("dynamite")
local mycustomtilelayout = dynamite {
    {
        {
            command = "urxvtc",
            widget = dynamite.widget.spawn,
        },
        {
            command = "urxvtc",
            widget = dynamite.widget.spawn,
        },
        {
            command = "urxvtc",
            widget = dynamite.widget.spawn,
        },
        {
            command = "urxvtc",
            widget = dynamite.widget.spawn,
        },
        {
            command = "urxvtc",
            widget = dynamite.widget.spawn,
        },
        layout = corner
    },
    reflow = true,
    layout = cond
}

local function fair_split_or_tile(c,tag)
    if count == 2 then
        awful.layout.set(awful.layout.suit.tile,tag)
        tag.master_count = 1
        tag.master_width_factor = 0.5
    else
        awful.layout.set(awful.layout.suit.tile,tag)
        tag.master_count = 1
        tag.master_width_factor = 0.6
    end
    return 6
end

-- }}}

tags = {} --TODO remove


tyrannical.settings.block_children_focus_stealing = true
tyrannical.settings.group_children = true
tyrannical.settings.force_odd_as_intrusive = true

tyrannical.settings.tag.layout = awful.layout.suit.tile
tyrannical.settings.tag.master_width_factor = 0.66


tyrannical.tags = {
    {
        name = "Term",
        init        = true                                           ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("term.png")       ,
        screen      = {config.scr.pri, config.scr.sec} ,
        layout      = mycustomtilelayout,
        focus_new   = true                                           ,
        selected    = true,
--         nmaster     = 2,
--         mwfact      = 0.6,
        index       = 1,
        class       = {
            "xterm" , "urxvt" , "aterm","URxvt","XTerm"
        },
    } ,
    {
        name = "Internet",
        init        = true                                           ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("net.png")        ,
        screen      = config.scr.pri                          ,
        layout      = awful.layout.suit.max                          ,
--         clone_on    = 2,
        class = {
            "Opera"         , "Firefox"        , "Rekonq"    , "Dillo"        , "Arora",
            "Chromium"      , "nightly"        , "Nightly"   , "minefield"    , "Minefield",
            "luakit"
        }
    } ,
    {
        name = "Files",
        init        = true                                           ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("folder.png")     ,
        screen      = config.scr.pri                          ,
        layout      = awful.layout.suit.tile                         ,
        exec_once   = {"dolphin"},
        no_focus_stealing_in = true,
        max_clients = fair_split_or_tile,
        rotate_shortcut = true,
        shortcut    = { {modkey} , "e" },
        class  = { 
            "Thunar"        , "Konqueror"      , "Dolphin"   , "ark"          , "Nautilus",
            "filelight"
        }
    } ,
    {
        name = "Develop",
     init        = true                                              ,
        exclusive   = true                                           ,
--                     screen      = {config.scr.pri, config.scr.sec}     ,
        icon        = utils.tools.invertedIconPath("bug.png")        ,
        layout      = awful.layout.suit.max                          ,
        class ={ 
            "Kate"          , "KDevelop"       , "Codeblocks", "Code::Blocks" , "DDD", "kate4"             }
    } ,
    {
        name = "Edit",
        init        = false                                          ,
        exclusive   = false                                           ,
--                     screen      = {config.scr.pri, config.scr.sec}     ,
        icon        = utils.tools.invertedIconPath("editor.png")     ,
        layout      = awful.layout.suit.tile.bottom                  ,
        class = { 
            "KWrite"        , "GVim"           , "Emacs"     , "Code::Blocks" , "DDD"               }
    } ,
    {
        name = "Media",
        init        = false                                          ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("media.png")      ,
        layout      = awful.layout.suit.max                          ,
        class = { 
            "Xine"          , "xine Panel"     , "xine*"     , "MPlayer"      , "GMPlayer",
            "XMMS" }
    } ,
    {
        name = "Doc",
        init        = false                                          ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("info.png")       ,
--                     screen      = config.scr.music                          ,
        layout      = awful.layout.suit.max                          ,
        force_screen= true                                           ,
        class       = {
            "Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "xpdf",
            "Xpdf"          ,                                        }
    } ,


    -----------------VOLATILE TAGS-----------------------
    {
        name        = "Imaging",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Inkscape"      , "KolourPaint"    , "Krita"     , "Karbon"       , "Karbon14"}
    } ,
    {
        name        = "Picture",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Digikam"       , "F-Spot"         , "GPicView"  , "ShowPhoto"    , "KPhotoAlbum"}
    } ,
    {
        name        = "Video",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("video.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"KDenLive"      , "Cinelerra"      , "AVIDeMux"  , "Kino"}
    } ,
    {
        name        = "Movie",
        init        = false                                          ,
        position    = 12                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("video.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"VLC"}
    } ,
    {
        name        = "3D",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("3d.png")         ,
        layout      = awful.layout.suit.max.fullscreen               ,
        class       = {"Blender"       , "Maya"           , "K-3D"      , "KPovModeler"  , }
    } ,
    {
        name        = "Music",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = config.scr.music or config.scr.pri             ,
        force_screen= true                                           ,
        icon        = utils.tools.invertedIconPath("media.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Amarok"        , "SongBird"       , "last.fm"   ,}
    } ,
    {
        name        = "Down",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("download.png")   ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Transmission-qt"  , "KGet"}
    } ,
    {
        name        = "Office",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("office.png")     ,
        layout      = awful.layout.suit.max                          ,
        class       = {
            "OOWriter"      , "OOCalc"         , "OOMath"    , "OOImpress"    , "OOBase"       ,
            "SQLitebrowser" , "Silverun"       , "Workbench" , "KWord"        , "KSpread"      ,
            "KPres","Basket", "openoffice.org" , "OpenOffice.*"               ,                }
    } ,
    {
        name        = "RSS",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("rss.png")        ,
        layout      = awful.layout.suit.max                          ,
        class       = {}
    } ,
    {
        name        = "Chat",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = config.scr.sec or config.scr.sec ,
        icon        = utils.tools.invertedIconPath("chat.png")       ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"Pidgin"        , "Kopete"         ,}
    } ,
    {
        name        = "Burning",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        icon        = utils.tools.invertedIconPath("burn.png")       ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"k3b"}
    } ,
    {
        name        = "Mail",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
--         screen      = config.scr.sec or config.scr.pri     ,
        icon        = utils.tools.invertedIconPath("mail2.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {"Thunderbird"   , "kmail"          , "evolution" ,}
    } ,
    {
        name        = "IRC",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        screen      = config.scr.irc or config.scr.pri ,
        init        = true                                           ,
        spawn       = "konversation"                                 ,
        icon        = utils.tools.invertedIconPath("irc.png")        ,
        force_screen= true                                           ,
        layout      = awful.layout.suit.fair                         ,
        exec_once   = {"konversation"},
        class       = {"Konversation"  , "Botch"          , "WeeChat"   , "weechat"      , "irssi"}
    } ,
    {
        name        = "Test",
        init        = false                                          ,
        position    = 99                                             ,
        exclusive   = false                                          ,
        screen      = config.scr.sec or config.scr.pri     ,
        leave_kills = true                                           ,
        persist     = true                                           ,
        icon        = utils.tools.invertedIconPath("tools.png")      ,
        layout      = awful.layout.suit.max                          ,
        class       = {}
    } ,
    {
        name        = "Config",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
        icon        = utils.tools.invertedIconPath("tools.png")      ,
        layout      = awful.layout.suit.max                        ,
        class       = {"Systemsettings", "Kcontrol"       , "gconf-editor"}
    } ,
    {
        name        = "Game",
        init        = false                                          ,
        screen      = config.scr.pri                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
        icon        = utils.tools.invertedIconPath("game.png")       ,
        force_screen= true                                           ,
        layout      = awful.layout.suit.max                        ,
        class       = {"sauer_client"  , "Cube 2$"        , "Cube 2: Sauerbraten"        ,}
    } ,
    {
        name        = "Gimp",
        init        = false                                          ,
        position    = 10                                             ,
        exclusive   = false                                          ,
        icon        = utils.tools.invertedIconPath("image.png")      ,
        layout      = awful.layout.tile                              ,
        nmaster     = 1                                              ,
        incncol     = 10                                             ,
        ncol        = 2                                              ,
        mwfact      = 0.00                                           ,
        class       = {}
    } ,
    {
        name        = "Other",
        init        = true                                           ,
        position    = 15                                             ,
        exclusive   = false                                          ,
        selected    = true                                           ,
        icon        = utils.tools.invertedIconPath("term.png")       ,
        max_clients = 5                                              ,
        screen      = {3, 4, 5}                                      ,
        layout      = awful.layout.suit.tile                         ,
        class       = {}
    },
    {
        name        = "MediaCenter",
        init        = true                                           ,
        position    = 15                                             ,
        exclusive   = false                                          ,
        icon        = utils.tools.invertedIconPath("video.png")      ,
        max_clients = 5                                              ,
        screen      = config.scr.media or config.scr.pri   ,
        init        = "mythfrontend"                                 ,
        layout      = awful.layout.suit.tile                         ,
        class       = {"mythfrontend"  , "xbmc" , "xbmc.bin"        ,}
    },
    {
        name        = "Awesome",
        init        = true                                           ,
        position    = 10                                             ,
        exclusive   = true                                           ,
        master_width_factor = 0.66,
        mwfact = 0.66,
        layout      = dynamite {
            {
                {
                    command = "kate -s 'Awesome'",
                    widget = dynamite.widget.spawn,
                },
                max_elements = 1,
                priority     = 3,
                ratio        = 0.66,
                layout       = dynamite.layout.ratio.vertical
            },
            {
                {
                    command = "urxvtc -cd /home/lepagee/dev/awesome/build",
                    widget = dynamite.widget.spawn,
                },
                {
                    command = "urxvtc -cd /home/elv13",
                    widget = dynamite.widget.spawn,
                },
                reflow       = true,
                priority     = 1,
                ratio        = 0.33,
                layout       = dynamite.layout.ratio.vertical
            },
            layout = dynamite.layout.ratio.horizontal
        }
    },
    {
        name        = "Ring-KDE",
        init        = true      ,
        position    = 10        ,
        exclusive   = true      ,
        locked      = true,
        master_width_factor = 0.66,
        mwfact = 0.66,
        layout      = dynamite {
            {
                {
                    command = "kate -s 'libringclient'",
                    widget = dynamite.widget.spawn,
                },
                max_elements = 1,
                ratio        = 0.66,
                priority     = 3,
                layout       = dynamite.layout.ratio.vertical
            },
            {
                {
                    command = "urxvtc -cd /home/lepagee/dev/sflphone_review",
                    widget = dynamite.widget.spawn,
                },
                {
                    command = "urxvtc -cd /home/lepagee/dev/libringqt/build",
                    widget = dynamite.widget.spawn,
                },
                {
                    command = "urxvtc -cd /home/lepagee/dev/ring-kde/build",
                    widget = dynamite.widget.spawn,
                },
                reflow       = true,
                priority     = 1,
                ratio        = 0.33,
                layout       = dynamite.layout.ratio.vertical
            },
            layout = dynamite.layout.ratio.horizontal
        }
    },
}

tyrannical.properties.intrusive = {
    "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"           ,
    "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color",
    "kcolorchooser" , "plasmoidviewer" , "plasmaengineexplorer" , "Xephyr" , "kruler"     ,
    "yakuake"       , "wxmaxima",
    "sflphone-client-kde", "sflphone-client-gnome", "xev",
}
tyrannical.properties.floating = {
    "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
    "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
    "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
    "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer" ,
    "sflphone-client-kde", "sflphone-client-gnome", "xev", "wxmaxima",
    amarok = false , "yakuake", "Conky"
}

tyrannical.properties.ontop = {
    "Xephyr"       , "ksnapshot"       , "kruler"
}

tyrannical.properties.focusable = {
    conky=false
}


tyrannical.properties.no_autofocus = {
    "Conky"
}

tyrannical.properties.below = {
    "Conky"
}

tyrannical.properties.maximize = {
    amarok = false, kodi=false,
}

tyrannical.properties.fullscreen = {
    kodi = false,
}

-- tyrannical.properties.border_width = {
--     URxvt = 0
-- }

tyrannical.properties.border_color = {
    URxvt = "#0A1535"
}

tyrannical.properties.intrusive_popup = {
    "transmission-qt"
}

tyrannical.properties.placement = { kcalc=awful.placement.centered }

tyrannical.properties.skip_taskbar = {"yakuake"}
tyrannical.properties.hidden = {"yakuake"}

-- tyrannical.properties.no_autofocus = {"umbrello"}

tyrannical.properties.size_hints_honor = { URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false, kodi = false}
