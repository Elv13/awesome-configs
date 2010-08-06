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
local shifty = require("shifty")
local menu = require("awful.menu")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse,
               tag = tag}

module("customMenu.places")

local data 

function update()

end

function new(screen, args) 
 data = menu.new({ items = {{ "Home", "dolphin $HOME",capi.image(util.getdir("config") .. "/Icon/tags/home.png") },
					{ "KDE-devel", "dolphin /home/kde-devel",capi.image(util.getdir("config") .. "/Icon/tags/kde.png") },
					{ "Image", "dolphin /mnt/smbsda1/My\ Pictures/",capi.image(util.getdir("config") .. "/Icon/tags/image.png") },
					{ "Video", "dolphin /mnt/smbsdb3/movie/to_burn/",capi.image(util.getdir("config") .. "/Icon/tags/video.png") },
					{ "Music", "dolphin /mnt/smbsda1/music/",capi.image(util.getdir("config") .. "/Icon/tags/media.png") },
					{ "Backup", "dolphin /mnt/smbsda1/backup/",capi.image(util.getdir("config") .. "/Icon/tags/backup.png") },
					{ "Notes", "dolphin /home/lepagee/Notes/",capi.image(util.getdir("config") .. "/Icon/tags/editor.png") },
                                     },
                           })


  local mylauncher2 = widget2.launcher({ image = capi.image(util.getdir("config") .. "/Icon/tags/home2.png"), menu = data })
  local mylauncher2text = capi.widget({ type = "textbox" })
  mylauncher2text.text = " Places  "
  
  return {menu = mylauncher2, text = mylauncher2text}
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
