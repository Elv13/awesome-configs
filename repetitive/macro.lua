--local socket  = require("socket")
local print = print
local table = table

local capi = {
    mousegrabber = mousegrabber,
    keygrabber = keygrabber,
    timer = timer,
    root = root,
    mouse = mouse,
}

local module = {}

local buttons = {}
local x = capi.mouse.coords().x
local y = capi.mouse.coords().y
local function execMouseEv(ev)
    for i=1, #ev.buttons do
        if not ev.buttons[i] ~= buttons[i] then
            if ev.buttons[i] == true and buttons[i] ~= true then
                capi.root.fake_input("button_press",i)
            elseif ev.buttons[i] == false and buttons[i] == true then
                capi.root.fake_input("button_release",i)
            end
        end
    end
    if x ~= ev.x or y ~= ev.y then
        capi.mouse.coords({x=ev.x,y = ev.y})
    end
end

function  module.record(callBackFunc)
    print("Start recording")
   local timer_fade = capi.timer { timeout = 0.01 } --30fps
   timer_fade:connect_signal("timeout", function () 
       
   end)
   local m = {}
   capi.mousegrabber.run(function(mouse)
      print("Mouse")
      table.insert(m,{type="m", data = mouse})
      execMouseEv(mouse)
      return true
   end,"fleur")
   capi.keygrabber.run(function(mod, key, event)
            print("Key",key)
            if key == 'Escape' then
                print("STOP")
                capi.mousegrabber.stop()
                capi.keygrabber.stop()
                callBackFunc(m)
                return false
            end
            table.insert(m,{type="k", mod = mod, key = key, event= event})
            return true
        end)
   return m
end

function  module.play(m)
    print("Playing macro")
    local timer = capi.timer({ timeout = 0.1 })
    local index = 1
    local buttons = {}
    local x = capi.mouse.coords().x
    local y = capi.mouse.coords().y
    timer:connect_signal("timeout", function()
        if index <= #m then
            if     m[index].type == "m" then
                execMouseEv(m[index].data)
            elseif m[index].type == "k" then
                if m[index].event == "release" then
                    capi.root.fake_input("key_release",m[index].key)
                else
                    capi.root.fake_input("key_press",m[index].key)
                end
            end
            print("Playing:"..m[index].type,m[index].event,'"'..m[index].key..'"')
            index = index + 1
        else
            print("That's all folk")
            timer:stop()
            timer = nil
        end
    end)
    timer:start()
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
