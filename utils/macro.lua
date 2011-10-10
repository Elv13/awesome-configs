--local socket  = require("socket")

local table = table

local capi = {
    mousegrabber = mousegrabber,
    keygrabber = keygrabber,
    timer = timer,
}

module("utils.macro")

function record()
   local timer_fade = capi.timer { timeout = 0.01 } --30fps
   timer_fade:add_signal("timeout", function () 
       
   end)
   local m = {}
   capi.mousegrabber.run(function(mouse)
      table.insert(m,{type="m", data = mouse, time = socket.gettime()*1000})
      return true
   end,"fleur")
   capi.keygrabber.run(function(mod, key, event)
            if key == 'Escape' or (key == 'Tab' and currentMenu.filterString == "") then
                capi.mousegrabber.stop()
                return false
            end
            table.insert(m,{type="k", mod = mod, key = key, event= event, time = socket.gettime()*1000})
            return true
        end)
   return m
end

function play(m)

end