local setmetatable = setmetatable
local table = table
local print = print
local string = string
local ipairs = ipairs
local button = require("awful.button")
local beautiful = require("beautiful")
local tag = require("awful.tag")
local layout = require("awful.layout")
local client = require("awful.client")
-- local titlebar = require("widgets.titlebar")
-- local tabbar = require("widgets.tabbar")
local config = require("forgotten")
local layoutmenu = require("customMenu.layoutmenu")
local util = require("awful.util")
-- local shifty = require("shifty")

local capi = { image = image,
               mouse = mouse,
               client = client,
               widget = widget}

local module = {}

local data = {}

function  module.run_or_raise(cmd, properties)
    if not capi.client.get then
        return
    end
   local clients = capi.client.get()
   for i, c in pairs(clients) do
      if match(properties, c) then
         local ctags = c:tags()
         if table.getn(ctags) == 0 then
            -- ctags is empty, show client on current tag
            local curtag = tag.selected()
            --awful.client.movetotag(curtag, c)
         else
            -- Otherwise, pop to first tag client is visible on
            tag.viewonly(ctags[1])
         end
         -- And then focus the client
         --client.focus = c
         --c:raise()
         return
      end
   end
   util.spawn(cmd)
end

function tag_to_screen(t, scr)
    local ts = t or tag.selected()
    if not ts then
        return
    end
    tag.setscreen(t,src)
    tag.history.restore(ts.screen,1)
--     shifty.set(ts, { screen = scr or util.cycle(screen.count(), ts.screen + 1)})
    tag.viewonly(ts)
    --capi.mouse.screen = ts.screen

    if #ts:clients() > 0 then
        local c = ts:clients()[1]
        if c.filter ~= nil then
            client.focus = c
            c:raise()
        end
    end
end

function  module.match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v then
         return false
      end
   end
   return true
end

function  module.explode(d,p)
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

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end


function  module.invertedIconPath(tagName)
    return config.iconPath .. (config.useListPrefix == true and "tags_invert/" or "tags/") .. tagName
end

function stripHtml(str)
    local safeStr = ""
    local isInTag = false
    local skip = false
    for i=1, str:len() do
        if str:sub(i,i) == "<" then
            isInTag = true
        elseif str:sub(i,i) == ">" then
            isInTag = false
            skip = true
        else
            skip = false
        end
        if not isInTag and not skip then
            safeStr = safeStr .. str:sub(i,i)
        end
    end
    return safeStr
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
