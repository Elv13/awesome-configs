local setmetatable = setmetatable
local table        = table
local io           = io
local string       = string
local button       = require( "awful.button"     )
local beautiful    = require( "beautiful"        )
local naughty      = require( "naughty"          )
local client       = require( "awful.client"     )
local tag          = require( "awful.tag"        )
local util         = require( "awful.util"       )
local tools        = require( "utils.tools"      )
-- local customMenu   = require( "customMenu.altTab")

local capi = { image  = image,
               widget = widget,
               client = client,
               mouse  = mouse,
               root   = root}

local module = {}

function  module.moveTagToScreen()
    if capi.mouse.screen == 1 then
        tools.tag_to_screen(tag.selected(capi.mouse.screen), 2) 
    else
        tools.tag_to_screen(tag.selected(capi.mouse.screen), 1) 
    end
end

function  module.focusHistory()
    client.focus.history.previous()
    
    if capi.client.focus then
        capi.client.focus:raise()
    end
end

function  module.maxClient(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
end

function  module.toggleHWPan() 
    hardwarePanel.visible  = not hardwarePanel.visible 
end

function  module.printTextBuffer() 
    local f = io.popen('xsel')
    local text = f:read("*all")
    f:close()
    naughty.notify({text = '<u><b>Buffer content:</b></u>\n'..text})
    --capi.root.fake_input('key_press',38)
    --capi.root.fake_input('key_release',38)
end

function  module.printClipboard() 
    local f = io.popen('xsel -b')
    local text = f:read("*all")
    f:close()
    naughty.notify({text = '<u><b>Clipboard content:</b></u>\n'..text})
end

function  module.pasteTextBuffer() 
    local f = io.popen('xsel')
    local text = f:read("*all")
    f:close()
    util.spawn("xvkbd -text '".. text:gsub("'", "\\'" ) .."'")
end

function  module.pasteClipboard() 
    local f = io.popen('xsel -b')
    local text = f:read("*all")
    f:close()
    util.spawn("xvkbd -text '".. text:gsub("'", "\\'" ) .."'")
end

function  module.printHexTextBuffer() 
    local header = "<tt><span color='".. beautiful.bg_normal .."' bgcolor='".. beautiful.fg_normal .."'>  LINE  |                        CONTENT                          |     ASCII      |</span>\n"
    local f = io.popen('xsel | /usr/bin/hexdump -f '..util.getdir("config")..'/Scripts/hexDumpSyntax')
    local text = ""
    
    local line1 = f:read("*line")
    local line2 = f:read("*line")
    local alternate = false
    while line1 ~= nil and line2 ~= nil do
        local block = line1..'\n'..line2..'\n'
        block = block:gsub('toReplace1', alternate and "#DDDDDD" or "#DDDDDD")
        block = block:gsub('toReplace2',beautiful.fg_normal)
        block = block:gsub('toReplace3',"#FFBBBB")
        block = block:gsub('toReplace4', alternate and beautiful.bg_normal or beautiful.bg_highlight)
        block = block:gsub('toReplace5', alternate and beautiful.bg_normal or beautiful.bg_highlight)
        block = block:gsub('toReplace6', alternate and beautiful.bg_normal or beautiful.bg_highlight)
        text =  text .. block
        line1 = f:read("*line")
        line2 = f:read("*line")
        alternate = not alternate
    end
    
    
    f:close()
    naughty.notify({text = '<u><b>Hexdecimal content:</b></u>\n\n'..header..text..'</tt>', timeout = 999, noslider = true})
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
