
local vicious      = require("extern.vicious")
local radialprog   = require("wibox.container.radialprogressbar")
local allinone     = require( "widgets.allinone"         )
local textbox      = require( "wibox.widget.textbox"     )
local f = unpack or table.unpack -- Lua 5.1 compat

for k,v in ipairs {
        radialprog, allinone, textbox
    } do
    function v:vicious(args)
        vicious.register(self, f(args))
    end
end

return  {
    soundInfo = require("drawer.soundInfo"),
    dateInfo  = require("drawer.dateInfo"),
    memInfo   = require("drawer.memInfo"),
    cpuInfo   = require("drawer.cpuInfo"),
    netInfo   = require("drawer.netInfo"),
}
