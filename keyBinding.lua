-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey, "Shift"   }, "p", function () 
					    if mouse.screen == 1 then
					      tag_to_screen(awful.tag.selected(mouse.screen), 2) 
					    else
					      tag_to_screen(awful.tag.selected(mouse.screen), 1) 
					    end
					  end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () main_menu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ "Control",        }, "Escape", function () awful.util.spawn("xkill") end),
    awful.key({ modkey,	    	  }, "x", function () mywibox4.visible = not mywibox4.visible end),
    awful.key({ modkey,           }, "z", function () awful.util.spawn("dolphin")  end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    --Switch screen
    awful.key({                   }, "#67", function () mouseManager.switchTo(1) end),
    awful.key({                   }, "#68", function () mouseManager.switchTo(2) end),
    awful.key({                   }, "#69", function () mouseManager.switchTo(3) end),
    awful.key({                   }, "#70", function () mouseManager.switchTo(4) end),
    awful.key({                   }, "#71", function () mouseManager.switchTo(5) end),

    --awful.keys.ignore_modifiers = { "Lock" }
    awful.key({                   }, "#86", function () awful.layout.inc(layouts,  1) end),
    awful.key({                   }, "#85", function () awful.layout.inc(layouts, -1) end),

    awful.key({                   }, "#90", awful.tag.viewprev ),
    awful.key({                   }, "#91", awful.tag.viewnext ),

    --awful.key({                   }, "#87", function () awful.screen.focus_relative( 1) end),
    --awful.key({                   }, "#88", function () awful.screen.focus_relative( -1) end),
    awful.key({                   }, "#87",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({                   }, "#88",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({                          }, "#89", function () awful.client.swap.byidx(  1) end),
    awful.key({                          }, "#84", function () awful.screen.focus_relative( 1) end),
    awful.key({                          }, "#83", awful.client.movetoscreen ),


    awful.key({                          }, "#177", function () awful.tag.viewonly(shifty.getpos(1)) end),
    awful.key({                          }, "#152", function () awful.tag.viewonly(shifty.getpos(2)) end),
    awful.key({                          }, "#190", function () awful.tag.viewonly(shifty.getpos(3)) end),
    awful.key({                          }, "#208", function () awful.tag.viewonly(shifty.getpos(4)) end),
    awful.key({                          }, "#129", function () awful.tag.viewonly(shifty.getpos(5)) end),
    awful.key({                          }, "#178", function () awful.tag.viewonly(shifty.getpos(6)) end),
    awful.key({                          }, "#81",  function () mypromptbox[mouse.screen]:run() end),
    -- Prompt
    awful.key({ modkey }, "F2",     function () mypromptbox[mouse.screen]:run() end)
    

--     awful.key({ modkey }, "F2",
--               function ()
--                   awful.prompt.run({ prompt = "Run: " },
--                   mypromptbox[mouse.screen],
--                   awful.util.spawn, awful.completion.shell,
--                   awful.util.getdir("cache") .. "/history")
--               end)
--     awful.key({ modkey }, "F4",
--               function ()
--                   awful.prompt.run({ prompt = "Run Lua code: " },
--                   mypromptbox[mouse.screen],
--                   awful.util.eval, nil,
--                   awful.util.getdir("cache") .. "/history_eval")
--               end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

shifty.config.clientkeys = clientkeys


-- Compute the maximum number of digit we need, limited to 9

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i=1, ( shifty.config.maxtags or 9 ) do
  
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey }, i,
  function ()
    local t = awful.tag.viewonly(shifty.getpos(i))
  end))
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control" }, i,
  function ()
    local t = shifty.getpos(i)
    t.selected = not t.selected
  end))
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control", "Shift" }, i,
  function ()
    if client.focus then
      awful.client.toggletag(shifty.getpos(i))
    end
  end))
  -- move clients to other tags
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Shift" }, i,
    function ()
      if client.focus then
        local t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
	if isPlayingMovie == true then
	  if musicBarVisibility == false then
	    volumepixmap.visible = true
	    volumewidget.visible = true
	    mywibox3.visible = false
	  end
	  enableAmarokCtrl(true)
	end
	isPlayingMovie = false
      end
    end))
end

-- clientbuttons = awful.util.table.join(
--     awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
--     awful.button({ modkey }, 1, awful.mouse.client.move),
--     awful.button({ modkey }, 2, clientMenu:toggle(awful.mouse.client) ),
--     awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
shifty.config.globalkeys = globalkeys
