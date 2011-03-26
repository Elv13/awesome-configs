


    

function amixer_volume(format)
   local f = io.popen('amixer sget Master | tail -n1 |cut -f 6 -d " " | grep -o -e "[0-9]*"')
   local l = f:read()
   f:close()
   if l+0 == 0 then
    if volumepixmap == not nil then
      volumepixmap.image = image(awful.util.getdir("config") .. "/Icon/volm.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = image(awful.util.getdir("config") .. "/Icon/volm.png")
    end
   elseif l+0 < 15 then
   if volumepixmap == not nil then
      volumepixmap.image = image(awful.util.getdir("config") .. "/Icon/vol1.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = image(awful.util.getdir("config") .. "/Icon/vol1.png")
    end
   elseif l+0 < 35 then
   if volumepixmap == not nil then
      volumepixmap.image = image(awful.util.getdir("config") .. "/Icon/vol2.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = image(awful.util.getdir("config") .. "/Icon/vol2.png")
    end
   else
    if volumepixmap == not nil then
      volumepixmap.image = image(awful.util.getdir("config") .. "/Icon/vol3.png")
    end
    if volumepixmap2 == not nil then
      volumepixmap2.image = image(awful.util.getdir("config") .. "/Icon/vol3.png")
    end
   end
   return {l}
end

function run_or_raise(cmd, properties)
   local clients = client.get()
   for i, c in pairs(clients) do
      if match(properties, c) then
         local ctags = c:tags()
         if table.getn(ctags) == 0 then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            --awful.client.movetotag(curtag, c)
         else
            -- Otherwise, pop to first tag client is visible on
            awful.tag.viewonly(ctags[1])
         end
         -- And then focus the client
         --client.focus = c
         --c:raise()
         return
      end
   end
   awful.util.spawn(cmd)
end
--}}}
 
--{{{ functions / match
-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v then
         return false
      end
   end
   return true
end
--}}}

function explode(d,p)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return p end
    while true do
      l=string.find(p,d,ll+1,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end

--By bios007
-- {{{function tag_to_screen(t, scr)
function tag_to_screen(t, scr)
    local ts = t or awful.tag.selected()
    awful.tag.history.restore(ts.screen,1)
    shifty.set(ts, { screen = scr or
                    awful.util.cycle(screen.count(), ts.screen + 1)})
    awful.tag.viewonly(ts)
    mouse.screen = ts.screen

    if #ts:clients() > 0 then
        local c = ts:clients()[1]
        client.focus = c
        c:raise()
    end
end

function getFan1()
  local keyboardPipe = io.open('/sys/devices/platform/w83627ehf.656/fan1_input',"r")
  local text = keyboardPipe:read("*all")
  keyboardPipe:close()
  return { tonumber(text) }
end

function getTemp1()
  local keyboardPipe = io.open('/sys/devices/platform/w83627ehf.656/temp1_input',"r")
  local text = keyboardPipe:read("*all")
  keyboardPipe:close()
  return { tonumber(text)/1000 }
end

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function addTitleBar(screen)
  local add_title = false
  if awful.layout.get(screen) == awful.layout.suit.floating then
    add_title = true 
  end
  if awful.tag.selected() ~= nil then
    for i, client in ipairs(awful.tag.selected():clients()) do
      if client.class == "urxvt" or client.class == "URxvt" then
        tabbar.add(client)
      elseif add_title == true or awful.client.floating.get(client) == true or customMenu.layoutmenu.showTitle(awful.tag.selected()) == true then
	awful.titlebar.add(client, { modkey = modkey })
      else
	awful.titlebar.remove(client)
      end
    end
  end
end

function toggleSensorBar()
    if mywibox4.visible ==  false then
      mywibox4.visible = true
    else
      mywibox4.visible = false
    end
end

-- Focus a client by-position from left to right and top to bottom
-- function switchToClient(number)
--   awful.client.focus.byidx
-- end


-- }}}
