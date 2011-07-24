-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Basic
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({ modkey,           }, "Left"  , function () awful.tag.viewprev()                 end ),
    awful.key({ modkey,           }, "Right" , function () awful.tag.viewnext()                 end ),
    awful.key({ modkey,           }, "Escape", function () awful.tag.history.restore()          end ),
    awful.key({ modkey, "Shift"   }, "p"     , function () utils.keyFunctions.moveTagToScreen() end ),
    awful.key({ modkey,           }, "Tab"   , function () utils.keyFunctions.altTab()          end ),
    awful.key({ modkey, "Shift"   }, "Tab"   , function () utils.keyFunctions.altTabBack()      end ),
    awful.key({ modkey,           }, "w"     , function () main_menu:show(true)                 end ),

    -- Layout manipulation
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({ modkey, "Shift"   }, "j"     , function () awful.client.swap.byidx(  1)         end ),
    awful.key({ modkey, "Shift"   }, "k"     , function () awful.client.swap.byidx( -1)         end ),
    awful.key({ modkey, "Control" }, "j"     , function () awful.screen.focus_relative( 1)      end ),
    awful.key({ modkey, "Control" }, "k"     , function () awful.screen.focus_relative(-1)      end ),
    awful.key({ modkey,           }, "u"     , awful.client.urgent.jumpto                           ),
    awful.key({ modkey,           }, "j"     , utils.keyFunctions.focusHistory                      ),

    -- Standard program
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal.cmd)       end ),
    awful.key({         "Control" }, "Escape", function () awful.util.spawn("xkill")            end ),
    awful.key({ modkey,           }, "x"     , function () utils.keyFunctions.toggleHWPan()     end ),
    awful.key({ modkey,           }, "z"     , function () awful.util.spawn("dolphin")          end ),
    awful.key({ modkey, "Control" }, "r"     , function () awesome.restart()                    end ),
    awful.key({ modkey, "Shift"   }, "q"     , function () awesome.quit()                       end ),
    awful.key({ modkey,           }, "l"     , function () awful.tag.incmwfact( 0.05)           end ),
    awful.key({ modkey,           }, "h"     , function () awful.tag.incmwfact(-0.05)           end ),
    awful.key({ modkey, "Shift"   }, "h"     , function () awful.tag.incnmaster( 1)             end ),
    awful.key({ modkey, "Shift"   }, "l"     , function () awful.tag.incnmaster(-1)             end ),
    awful.key({ modkey, "Control" }, "h"     , function () awful.tag.incncol( 1)                end ),
    awful.key({ modkey, "Control" }, "l"     , function () awful.tag.incncol(-1)                end ),
    awful.key({ modkey,           }, "space" , function () awful.layout.inc(layouts,  1)        end ),
    awful.key({ modkey, "Shift"   }, "space" , function () awful.layout.inc(layouts, -1)        end ),

    --Switch screen
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({                   }, "#177"  , function () utils.mouseManager.switchTo(1)       end ),
    awful.key({                   }, "#152"  , function () utils.mouseManager.switchTo(2)       end ),
    awful.key({                   }, "#190"  , function () utils.mouseManager.switchTo(3)       end ),
    awful.key({                   }, "#208"  , function () utils.mouseManager.switchTo(4)       end ),
    awful.key({                   }, "#129"  , function () utils.mouseManager.switchTo(5)       end ),    
    
    --Switch client
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({ "Control"         }, "#177"  , function () utils.clientSwitcher.switchTo(1)     end ),
    awful.key({ "Control"         }, "#152"  , function () utils.clientSwitcher.switchTo(2)     end ),
    awful.key({ "Control"         }, "#190"  , function () utils.clientSwitcher.switchTo(3)     end ),
    awful.key({ "Control"         }, "#208"  , function () utils.clientSwitcher.switchTo(4)     end ),
    awful.key({ "Control"         }, "#129"  , function () utils.clientSwitcher.switchTo(5)     end ),

    --awful.keys.ignore_modifiers = { "Lock" }
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({                   }, "#86"   , function () awful.layout.inc(layouts,  1)        end ),
    awful.key({                   }, "#85"   , function () awful.layout.inc(layouts, -1)        end ),
    awful.key({                   }, "#90"   , awful.tag.viewprev                                   ),
    awful.key({                   }, "#91"   , awful.tag.viewnext                                   ),
    awful.key({                   }, "#87"   , utils.keyFunctions.altTab                            ),
    awful.key({                   }, "#88"   , utils.keyFunctions.altTabBack                        ),
    awful.key({                   }, "#89"   , function () awful.client.swap.byidx(  1)         end ),
    awful.key({                   }, "#84"   , function () awful.screen.focus_relative( 1)      end ),
    awful.key({                   }, "#83"   , awful.client.movetoscreen                            ),
    
    -- Prompt
    --              MODIFIERS         KEY                        ACTION                               
    awful.key({                   }, "#81"   , function () promptbox[mouse.screen]:run()        end ),
    awful.key({ modkey            }, "F2"    , function () promptbox[mouse.screen]:run()        end ),
    awful.key({ modkey            }, "r"     , function () promptbox[mouse.screen]:run()        end ),
    awful.key({                   }, "#184"  , function () promptbox[mouse.screen]:run()        end )
)

-- Client shortcut
--                  MODIFIERS         KEY                        ACTION                               
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f"     , function (c) c.fullscreen = not c.fullscreen      end ),
    awful.key({                   }, "#93"   , function (c) c.fullscreen = not c.fullscreen      end ),
    awful.key({ modkey, "Shift"   }, "c"     , function (c) c:kill()                             end ),
    awful.key({                   }, "#247"  , function (c) c:kill()                             end ),
    awful.key({ modkey, "Control" }, "space" , awful.client.floating.toggle                          ),
    awful.key({                   }, "#178"  , function (c) c:swap(awful.client.getmaster())     end ),
    awful.key({ modkey,           }, "o"     , awful.client.movetoscreen                             ),
    awful.key({ modkey, "Shift"   }, "r"     , function (c) c:redraw()                           end ),
    awful.key({                   }, "#131"  , function (c) c.minimized = not c.minimized        end ),
    awful.key({ modkey,           }, "m"     , function (c) utils.keyFunctions.maxClient(c)      end )
)

shifty.config.clientkeys = clientkeys


-- Compute the maximum number of digit we need, limited to 9

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.

for i=1, ( 4 ) do
  globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "F"..i,
  function ()
    local t = awful.tag.viewonly(shifty.getpos(i))
  end))
end

for i=6, ( 8 ) do
  globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "F"..i,
  function ()
    print("get fav")
    utils.clientSwitcher.selectFavClient(i)
  end))
  globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey }, "F"..i,
  function ()
    print("setfav")
    utils.clientSwitcher.setFavClient(i, client.focus)
  end))
end

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
