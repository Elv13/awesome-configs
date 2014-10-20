--local socket  = require("socket")
local print = print
local table = table
local glib  = require("lgi").GLib

local capi = {
  mousegrabber = mousegrabber, timer = timer,
  keygrabber   = keygrabber  , root  = root ,
  mouse        = mouse       ,
}

local module = {}

local function get_time()
  local time2 = glib.TimeVal()
  glib.get_current_time(time2)
  return time2.tv_sec,time2.tv_usec
end

local function get_delta(sec1,usec1,sec2,usec2)
  return (sec2-sec1)*(1000000)+(usec2-usec1)
end

local function exec_key_ev(data)
  if data.event == "release" then
      capi.root.fake_input("key_release",data.key)
  else
      capi.root.fake_input("key_press",data.key)
  end
end

local buttons = {}

local function exec_mouse_buttons(ev)
  for i=1, #ev.buttons do
    if ev.buttons[i] == true and buttons[i] ~= true then
      capi.root.fake_input("button_press",i)
      buttons[i] = true
    elseif ev.buttons[i] == false and buttons[i] == true then
      capi.root.fake_input("button_release",i)
      buttons[i] = nil
    end
  end
end

local function exec_mouse_ev(ev,x,y)
  exec_mouse_buttons(ev)
  if x ~= ev.x or y ~= ev.y then
    capi.mouse.coords({x=ev.x,y = ev.y})
  end
end

local function release_all()
  for i=1,20 do
    if buttons[i] then
      capi.root.fake_input("button_release",i)
    end
  end
  buttons = {}
end

local function meta_macro_namespace()
  local start_sec,start_usec,last_sec,last_usec,x,y,m

  local mouse_fct = nil
  mouse_fct = function(mouse)
    print("Mouse",mouse.buttons[1],buttons[1])
    local new_sec,new_usec = get_time()
    local delta = get_delta(last_sec,last_usec,new_sec,new_usec)
    last_sec,last_usec = new_sec,new_usec
    table.insert(m,{type="m", data = mouse,delta=delta})

    -- Pause the grabbing to execute some buttons events --TODO buggy
--     capi.mousegrabber.stop()
--     exec_mouse_buttons(mouse)
--     capi.mousegrabber.run(mouse_fct,"fleur")
    return true
  end

  local key_fct = nil
  key_fct = function(mod, key, event)
    print("Key",key)
    if key == 'Escape' then
      print("STOP")
      capi.mousegrabber.stop()
      capi.keygrabber.stop()
      release_all()
      m.callback_fct(m)
      return false
    end
    local new_sec,new_usec = get_time()
    local delta = get_delta(last_sec,last_usec,new_sec,new_usec)
    last_sec,last_usec = new_sec,new_usec
    table.insert(m,{type="k", mod = mod, key = key, event= event, delta = delta})

    --Pause the grabber the time to execute the key
    capi.keygrabber.stop()
    exec_key_ev(m[#m])
    capi.keygrabber.run(key_fct)
    return true
  end

  function module.record(callback_fct)
    print("Start recording")
    x = capi.mouse.coords().x
    y = capi.mouse.coords().y
    m = {x=x,y=y,callback_fct=callback_fct}
    start_sec,start_usec = get_time()
    last_sec,last_usec = start_sec,start_usec

    -- Mouse
    capi.mousegrabber.run(mouse_fct,"fleur")

    -- Keyboard
    capi.keygrabber.run(key_fct)
    return m
  end
end
--Old JavaScript hack, this create a virtual object with local vars
meta_macro_namespace()

function  module.play(m)
    print("Playing macro")
    local timer = capi.timer({ timeout = m[1].delta/1000000 or 0.1 })
    local index = 1

    -- In case the first event is a key, reset the mouse
    local x = m.x
    local y = m.y
    capi.mouse.coords({x=x ,y=y})

    timer:connect_signal("timeout", function()
      if index <= #m then
        local data = m[index]
        if data.type == "m" then
          exec_mouse_ev(data.data,x,y)
        elseif data.type == "k" then
          exec_key_ev(data)
        end
        --print("Playing: "..data.type,data.event,'"'..(data.key or "N/A")..'"')
        index = index + 1
        -- Set the timer correctly
        data = m[index]
        if data then
          local delta = data.delta
          timer:stop()
          timer.timeout = delta/1000000
          timer:start()
        end
      else
        release_all()
        print("That's all folk")
        timer:stop()
        timer = nil
      end
    end)
    timer:start()
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
