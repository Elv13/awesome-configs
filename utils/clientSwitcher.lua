--Switch client with the keybpard by assigning a number to every client in a tag
--Requier fork of tasklist.lua to work (this is the backend)
--Author: Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local io     = io
local ipairs = ipairs
local table  = table
local math   = math
local print  = print
local util   = require( "awful.util"   )
local button = require( "awful.button" )
local tag    = require("awful.tag")
local wibox  = require("wibox")
local macro  = require("utils.macro")
local capi   = { screen = screen,
                mouse  = mouse,
                widget = widget,
               mousegrabber = mousegrabber,
                client = client}

local module = {}

local data = {client = {}, index = {}, wibox = {}, fav = {}, layout = {}}

local function new(screen, args) 
  return --Nothing to do
end

function  module.assign(client, index)
  if client:tags()[1] == capi.screen[capi.mouse.screen]:tags()[1] then
    data.client[index] = client
    data.index[client.pid] = index
  end
end

function  module.switchTo(i)
  if data.client[i] ~= nil then
    capi.client.focus = data.client[i]
  else
    print("client not set")
  end
end

function  module.getIndex(c)
  if data.index[c.pid] ~= nil then
    return data.index[c.pid]
  else
    print("client not set")
    return nil
  end
end

function  module.setFavClient(idx,c)
  data.fav[idx] = function()
    if c:tags()[1] ~= tag.selected(c.screen) then
      tag.viewonly(c:tags()[1])
    end
    capi.client.focus = c
  end
end

function  module.setFavTag(idx,t)
  data.fav[idx] = function()
   tag.viewonly(t)
  end
end

function  module.selectFavClient(idx)
  if data.fav[idx] ~= nil then
      data.fav[idx]()
  end
end

function  module.setFavMacro(idx)
    print("Set Macro")
    local m = nil
    macro.record(function(aMacro) m = aMacro; print("setting macro") end)
    data.fav[idx] = function()
        if m then
            macro.play(m)
        else
            print("Nothing to playback")
        end
    end
end

function  module.selectFavMacro(idx)
  if data.fav[idx] ~= nil then
      data.fav[idx]()
  end
end

function  module.addCornerWibox(c,i)
  data.wibox[i] = wibox({})
  data.wibox.ontop = true
  data.wibox.visible = false
  createDrawer() 
  data.wibox:geometry({ width = 147, height = 994, x = capi.screen[capi.mouse.screen].geometry.width*2 -  147, y = 20})
end

function  module.reset()
  --data.client = {} --TODO restore this
end

local res = 20

function  module.approxPos(t)
    data.layout[t.screen] = data.layout[t.screen] or {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
    local xPad = 0
    local yPad = 0
    local screenWSection = capi.screen[t.screen].geometry.width  /res
    local screenHSection = capi.screen[t.screen].geometry.height /res
    for k,v in ipairs(t:clients()) do
        local geo = v:geometry()
        for i=1,res do --x
            for j=1,res do --y
            --if j == res then print(geo.y + geo.height,(j-1)*screenHSection+1) end
                if (i-1)*screenWSection+1 <= geo.x + geo.width and (j-1)*screenHSection+1 <= geo.y + geo.height then
                    data.layout[t.screen][i][j] = v
                    --if j == res then print(data.layout[t.screen][i][j]) end
                end
            end
        end
    end
end
-- tag.attached_add_signal(1, "property::selected", approxPos)
-- tag.attached_add_signal(1, "property::layout"  , approxPos)
--TODO a client was added/deleted

local function  moveFocus()
    return {
        xr = math.floor(((capi.client.focus:geometry().x + capi.client.focus:geometry().width)  / (capi.screen[capi.client.focus.screen].geometry.width /res))+1),
        xl = math.floor(((capi.client.focus:geometry().x) / (capi.screen[capi.client.focus.screen].geometry.width /res))+1),
        yt = math.floor(((capi.client.focus:geometry().y) / (capi.screen[capi.client.focus.screen].geometry.height/res))+1),
        yb = math.floor(((capi.client.focus:geometry().y + capi.client.focus:geometry().height) / (capi.screen[capi.client.focus.screen].geometry.height/res))+1),
    }
end

function  module.mergeHandle(t)
    for k,v in ipairs(t:clients()) do
        local w = wibox({position="free"})
        w.ontop = true
        w.width  = 60
        w.height = 60
        w.bg = "#00ff00"
        local geo = v:geometry()
        w.x = geo.x + geo.width  -60
        w.y = geo.y + geo.height/2
    end
    
end

--It do work, but have too many problems, patches welcome
function  module.addResizeHandle(t)
    for k,v in ipairs(t:clients()) do
        local w = wibox({position="free"})
        w.ontop = true
        w.width  = 10
        w.height = 10
        w.bg = "#ff0000"
        local geo = v:geometry()
        w.x = geo.x + geo.width  -10
        w.y = geo.y + geo.height -10
        
        w:buttons(util.table.join(
        button({ }, 1 ,function (tab)
                                local curX = capi.mouse.coords().x
                                local curY = capi.mouse.coords().y
                                local moved = false
                                capi.mousegrabber.run(function(mouse)
                                    if mouse.buttons[1] == false then 
                                        if moved == false then
                                            wdgSet.button1()
                                        end
                                        capi.mousegrabber.stop()
                                        return false 
                                    end
                                    if mouse.x ~= curX and mouse.y ~= curY then
                                        local height = w:geometry().height
                                        local width  = w:geometry().width
                                        w.x = mouse.x-(5)
                                        w.y = mouse.y-(5)
                                        v:geometry({width=mouse.x-geo.x,height=mouse.y-geo.y})
                                        moved = true
                                    end
                                    return true
                                end,"fleur")
                        end)))
    end
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
