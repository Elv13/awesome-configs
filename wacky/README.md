Wacky: Wacom tablet support for AwesomeWM
=====

This module add 2 functions to Awesome to set the Wacom rectangle.


### wacky.focussed_client
Set the rect around the focussed client geometry

### wacky.select_rect
Draw a red rectangle on the screen

In both case, it take an array of device id (use xsetwacom --list to get them)

Add this to rc.lua:

````

    awful.key({ modkey,           }, "w", function() wacky.select_rect(10) end),
    awful.key({ modkey, "Shift"   }, "w", function() wacky.focussed_client(10) end),

````