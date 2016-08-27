
--TODO [DONE] talk about hte meaning of direction (up, down) vs. position (top, bottom)
--TODO [DONE] commit message: Mutualize code from awful.wibox, awful.tooltip, awful.menu, Collision and Radical-menu
--TODO [DOME] pull-request message: Explain all the alias functions are for easier key-bindings and code example/image and code coverage
--TODO merge hot_corner
--TODO [DONE] add some tests / screenshot
--TODO [DONE] make awful.wibox use this
--TODO make awful.menu use this
--TODO [DONE] make awful.rules/awful.client use this using the new property syntax
--TODO [DONE] use metatable magic to placement.top_left -> align("top_left") + doc
--TODO [WIP] change how honor_size_hints and maximize* work, use request::, handle here instead of the C code, maybe fully move lua side
--TODO the mode for (mouse vs. widget) for position + offset
--TODO merge smart_wibox into awful.wibox
--TODO add tooltip modes
--TODO [DONE] add a "aero-snap" mode to awful.mouse.move, turn on per-client, support struts docking
--TODO [DONE] merge the dynamic layout resize code into this, like closest corner, support out of rect, remove awful.mouse algos
--TODO [DONE] add doc header about how to use for clients/wiboxes/cr/mouse, talk about cairo surface/rectangle math APIs
--TODO [DONE] add enter/move/leave callbacks to the mouse "move" operation (like resize)
--TODO [DONE] add placement to awful.rules
--TODO [DONE] propose a push-pop geometry for clients in awful.tag instead of maximize/floating/...
--TODO Add :geometry() to the capi.mouse object to it works with the placement functions or 
--     add an apply_geometry method, for client, use request::geometry
--TODO for the aero stuff, mix with get_closest_corner, add modes for 3 point or 7 points?
--TODO [DONE] for awful.rules, have placement, then stretch, then maximize, check is the client (or layout) is floating
--TODO [DONE] stretch/shrink to mouse
--TODO crop to screen
--TODO [DONE] a daisy chain syntax for placement methods by adding standard return value
--TODO [DONE] resize to & resize_percent
--TODO be able to use dynamic layouts on random parents (not only tag+screen)

--[[
 * This work consolidate/rewrite geometry, placement and resizing code under one
   roof
 * This turn the awful.placement methods into a standardized API so the methods
   can be used as properties (like in `awful.rules`)
 * Allow existing features for an object type (wibox, client, mouse) to be
    re-used by other drawable types.
 * Re-use existing code in other placement methods, creating a rich and flexible
   API in the process.
 * Have an unified test templates designed to test placement methods.
 * Reduce code duplication (like between awful.mouse and layout.dynamic)
 * Fix unhandled corner cases in a single places rather than once for tooltip,
    menu and client.
]]

