

module("macro")

function record()
   local m = {}
   capi.mousegrabber.run(function(mouse)
      table.insert(m,{type="m", data = mouse})
      return true
   end,"fleur")
   capi.keygrabber.run(function(mod, key, event)
            if key == 'Escape' or (key == 'Tab' and currentMenu.filterString == "") then
                stopGrabber()
                return false
            end
            table.insert(m,{type="k", mod = mod, key = key, event= event})
            return true
        end)
   return m
end

function play(m)

end