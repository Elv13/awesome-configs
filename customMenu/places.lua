local setmetatable = setmetatable
local button = require("awful.button")
local beautiful = require("beautiful")
local util = require("awful.util")
local menu = require("awful.menu")
local capi = { image = image,
               screen = screen,
               widget = widget,
               mouse = mouse}

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

  local mylauncher2text = capi.widget({ type = "textbox" })
  mylauncher2text.text = "      Places  "
  mylauncher2text.bg_image = capi.image(util.getdir("config") .. "/Icon/tags/home2.png")
  mylauncher2text.bg_align = "left"
  mylauncher2text.bg_resize = true
  
  mylauncher2text:add_signal("mouse::enter", function() mylauncher2text.bg = beautiful.bg_highlight end)
  mylauncher2text:add_signal("mouse::leave", function() mylauncher2text.bg = beautiful.bg_normal end)
  
  mylauncher2text:buttons( util.table.join(
    button({ }, 1, function()
      data:toggle()
  end)
  ))
  
  return mylauncher2text
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
