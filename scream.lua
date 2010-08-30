local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local loadstring = loadstring
local button = require("awful.button")
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local naughty = require("naughty")
local vicious = require("vicious")
local tag = require("awful.tag")
local print = print
local util = require("awful.util")
local wibox = require("awful.wibox")
local shifty = require("shifty")
local menu = require("awful.menu")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
	       tag = tag}

module("customButton.showDesktop")

local data = {}

function update()

end

--scream.init = {
--   main = 1,  
--   alt = 2,
--   tv = 3,
--   notification = 4
--}

--minWidth
--maxWidth
--maxHeight
--minHeight
--screen = nil = all, array of string/number or number/string
--position left right flex right.left left.right top bottom top.bottom bottom.top

--scream.rule
function rule(widget, wibox, args)


end

-- =2 : last or >5 : 2 or =1 : first
-- all
-- {1,3,4}

--if all
--else
--  split (or)
--  for each
--    split(:)
--    trim()
--    if([1] == "=")
--    elseif...
--  end
--end

--position:
-- left : rigth
-- flex : 
-- allow array as parameter


function new(screen, args) 
  local desktopPix       = capi.widget({ type = "imagebox", align = "left" })
  desktopPix.image = capi.image(util.getdir("config") .. "/Icon/tags/desk2.png")
  
  desktopPix:buttons( util.table.join(
    button({ }, 1, function()
      tag.viewnone()
    end)
  ))
  
  return desktopPix
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
