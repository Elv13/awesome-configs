local setmetatable = setmetatable
local table        = table
local io           = io
local button       = require( "awful.button"     )
local beautiful    = require( "beautiful"        )
local naughty      = require( "naughty"          )
local client       = require( "awful.client"     )
local tag          = require( "awful.tag"        )
local util         = require( "awful.util"       )
local tools        = require( "utils.tools"      )
local customMenu   = require( "customMenu.altTab")

local capi = { image  = image,
               widget = widget,
               client = client,
               mouse  = mouse,
               root   = root}

module("utils.keyFunctions")

function moveTagToScreen() 
    if capi.mouse.screen == 1 then
        tools.tag_to_screen(tag.selected(capi.mouse.screen), 2) 
    else
        tools.tag_to_screen(tag.selected(capi.mouse.screen), 1) 
    end
end

function altTab()
    customMenu()
    
    if not capi.client.focus then
       return 
    end
    
    client.focus.byidx( 1)
    --if capi.client.focus then capi.client.focus:raise() end --TODO
end

function altTabBack()
    if not capi.client.focus then
       return 
    end
    
    client.focus.byidx(-1)
    
    if capi.client.focus then 
        capi.client.focus:raise() 
    end
end

function focusHistory()
    client.focus.history.previous()
    
    if capi.client.focus then
        capi.client.focus:raise()
    end
end

function maxClient(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
end

function toggleHWPan() 
    hardwarePanel.visible  = not hardwarePanel.visible 
end

function printTextBuffer() 
    local f = io.popen('xsel')
    local text = f:read("*all")
    f:close()
    naughty.notify({text = '<u><b>Buffer content:</b></u>\n'..text})
    --capi.root.fake_input('key_press',38)
    --capi.root.fake_input('key_release',38)
end

function printClipboard() 
    local f = io.popen('xsel -b')
    local text = f:read("*all")
    f:close()
    naughty.notify({text = '<u><b>Clipboard content:</b></u>\n'..text})
end