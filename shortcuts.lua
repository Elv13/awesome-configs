local awful        = require( "awful"       )
local shorter      = require( "shorter" )
local widgets      = require( "widgets"                    )
local alttab       = require( "radical.impl.alttab"        )
local alttag       = require( "radical.impl.alttag"        )
local customButton = require( "customButton"               )
local customMenu   = require( "customMenu"                 )
local menubar      = require( "menubar"                    )
local collision    = require( "collision"                  )

shorter.Navigation = {
    desc = "Navigate between clients",

    {desc = "Move to the previous focussed client",
        key = {{ modkey, }, "j"},
        fct = function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end
    },

    {desc = "Move to the next focussed client",
        key  = {{ modkey,           }, "k"},
        fct  = function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end
    },

--     {desc = "",
--     key={{ modkey, "Shift"   }, "j"     }, fct = function () awful.client.swap.byidx(  1)                      end},
-- 
--     {desc = "",
--     key={{ modkey, "Shift"   }, "k"     }, fct = function () awful.client.swap.byidx( -1)                      end},

    {desc = "Jump to urgent clients",
    key={{  modkey,           }, "u"    }, fct = awful.client.urgent.jumpto                                       },

    {desc = "Display the mission center",
    key={{  modkey,           }, "Tab"  }, fct = function () alttab.altTab()                                   end},

    {desc = "Display the mission center",
    key={{  modkey, "Shift"   }, "Tab"  }, fct = function () alttab.altTabBack()                               end},

    {desc = "Select previous client",
    key={{  "Mod1",           }, "Tab"  }, fct = function () alttab.altTab({auto_release=true})                end},

    {desc = "Select the next client",
    key={{  "Mod1", "Shift"   }, "Tab"  }, fct = function () alttab.altTabBack({auto_release=true})            end},

    {desc = "Display the tag search box",
    key={{  modkey,           }, "#49"  }, fct = function () alttag()                                   end},

    {desc = "Display the tag switcher",
    key={{  "Mod1",           }, "#49"  }, fct = function () alttag()                                   end},
}

shorter.Client = {
   {desc = "Launch xkill",
   key={{          "Control" }, "Escape"}, fct = function () awful.util.spawn("xkill")                         end},
}

shorter.Screen = {
    {desc = "Select screen 2",
    key={ {                   }, "#179" }, fct = function () collision.select_screen(2)       end },

    {desc = "Select screen 3",
    key={ {                   }, "#175" }, fct = function () collision.select_screen(3)       end },

    {desc = "Select screen 4",
    key={ {                   }, "#176" }, fct = function () collision.select_screen(4)       end },

    {desc = "Select screen 1",
    key={ {                   }, "#178" }, fct = function () collision.select_screen(1)       end },

    {desc = "Select screen 5",
    key={ {                   }, "#177" }, fct = function () collision.select_screen(5)       end },
      
      
    {desc = "Select screen 5",
    key={ {                   }, "#180" }, fct = function () collision.swap_screens(5)       end },
}

local hooks = {
    {{         },"Return",function(command)
        local result = awful.util.spawn(command)
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end},
    {{"Mod1"   },"Return",function(command)
        local result = awful.util.spawn(command,{intrusive=true})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end},
    {{"Shift"  },"Return",function(command)
        local result = awful.util.spawn(command,{intrusive=true,ontop=true,floating=true})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end}
}

--Open clients in screen "s"
for s = 1, screen.count() do
    table.insert(hooks, {{"Mod4"  },tostring(s),function(command)
        local result = awful.util.spawn(command,{screen=s})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end})
    table.insert(hooks, {{  },"F"..s,function(command)
        local result = awful.util.spawn(command,{screen=s,intrusive=true,ontop=true,floating=true})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end})
end

shorter.Launch = {
    {desc = "Launch a terminal",
    key={{  modkey,           }, "Return" }, fct = function () awful.util.spawn(terminal)                        end},

    {desc = "Show the application menu",
    key={{  modkey }, "p"}, fct = function() print("meh");menubar.show()                                                     end},

    {desc = "Run a command",
    key={{  modkey },            "r"},
        fct = function ()
            awful.prompt.run({ prompt = "Run: ", hooks = hooks},
            mypromptbox[mouse.screen].widget,
            function (com)
                    local result = awful.util.spawn(com)
                    if type(result) == "string" then
                        mypromptbox[mouse.screen].widget:set_text(result)
                    end
                    return true
            end, awful.completion.shell,
            awful.util.getdir("cache") .. "/history")
        end
    },

    {desc = "",
    key={{  modkey }, "x"}, fct = function ()
        awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end}
}

shorter.Session = {
    {desc = "Restart Awesome",
    key={{ modkey, "Control" }, "r"     }, fct = awesome.restart},

    {desc = "Quit Awesome",
    key={{ modkey, "Shift"   }, "q"     }, fct = awesome.quit},
}

shorter.Tag = {
    {desc = "Set the tag state",
    key={{  modkey, "Control" }, "Tab"   }, fct = function () customButton.lockTag.show_menu()                  end},

    {desc = "Switch to the next layout",
    key={{  modkey,           }, "space" }, fct = function () customMenu.layoutmenu.centered_menu(layouts)      end},

    {desc = "Switch to the previous layout",
    key={{  modkey, "Shift"   }, "space" }, fct = function () customMenu.layoutmenu.centered_menu(layouts,true) end},

    {desc = "Increate the master width",
    key={{  modkey,           }, "l"     }, fct = function () awful.tag.incmwfact( 0.05)                        end},

    {desc = "Reduce the master width",
    key={{  modkey,           }, "h"     }, fct = function () awful.tag.incmwfact(-0.05)                        end},

    {desc = "Add a new master",
    key={{  modkey, "Shift"   }, "h"     }, fct = function () awful.tag.incnmaster( 1)                          end},

    {desc = "Remove a master",
    key={{  modkey, "Shift"   }, "l"     }, fct = function () awful.tag.incnmaster(-1)                          end},

    {desc = "Add a column",
    key={{  modkey, "Control" }, "h"     }, fct = function () awful.tag.incncol( 1)                             end},

    {desc = "Remove a column",
    key={{  modkey, "Control" }, "l"     }, fct = function () awful.tag.incncol(-1)                             end},
}

shorter.Hardware = {
    {desc = "Change keyboard layout",
    key={{ "Mod1"            }, "space" }, fct = widgets.keyboard.quickswitchmenu                                 },

    {desc = "Select wacom area",
    key={{ modkey,           }, "w"     }, fct = function() wacky.select_rect(10)                              end},

    {desc = "Set wacom area around focussed",
    key={{ modkey, "Shift"   }, "w"     }, fct = function() wacky.focussed_client(10)                          end},

--     awful.key({ modkey,"Control" }, "p", function()
--         utils.profile.start()
--         debug.sethook(utils.profile.trace, "crl", 1)
--     end),
--     awful.key({ modkey,"Control","Shift" }, "p", function()
--         debug.sethook()
--         utils.profile.stop(_G)
--     end),
}

shorter.Selection = {
  {desc = "Change keyboard layout",
    key={{ modkey            }, "v" }, fct = function()
    print(selection())
  end},
}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}





clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f"     , function (c) c.fullscreen = not c.fullscreen     end),
    awful.key({ modkey, "Shift"   }, "c"     , function (c) c:kill()                            end),
    awful.key({ modkey, "Control" }, "space" , awful.client.floating.toggle                        ),
    awful.key({ modkey,           }, "o"     , awful.client.movetoscreen                           ),
    awful.key({ modkey,           }, "t"     , function (c) c.ontop = not c.ontop               end),
    awful.key({ modkey,           }, "y"     , function (c) collision.resize.display(c,true)    end),
    awful.key({ modkey,           }, "m"     , function (c) c.minimized = true                  end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local tagSelect = {}
for i = 1, 10 do
    tagSelect[#tagSelect+1] = {key={{ modkey }, "#" .. i + 9},
        desc= "Switch to tag "..i,
        fct = function ()
            local screen = mouse.screen
            local tag = awful.tag.gettags(screen)[i]
            if tag then
                awful.tag.viewonly(tag)
            end
        end
    }
    tagSelect[#tagSelect+1] = {key={{ modkey, "Control" }, "#" .. i + 9},
        desc= "Toggle tag "..i,
        fct = function ()
            local screen = mouse.screen
            local tag = awful.tag.gettags(screen)[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end
    }
    tagSelect[#tagSelect+1] = {key={{ modkey, "Shift" }, "#" .. i + 9},
        desc= "Move cofussed to tag "..i,
        fct = function ()
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if client.focus and tag then
                awful.client.movetotag(tag)
            end
        end
    }
    tagSelect[#tagSelect+1] = {key={{ modkey, "Control", "Shift" }, "#" .. i + 9},
        desc= "Toggle tag "..i,
        fct = function ()
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if client.focus and tag then
                awful.client.toggletag(tag)
            end
        end
    }
end
shorter.Navigation = tagSelect

local copts_sec,copts_usec = 0,0

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    awful.button({  }, 6, collision.util.double_click(function() customMenu.client_opts() end))
)
