lauchBar = awful.wibox({ position = "top", screen = s, height = 49 })

tagList = {}
tagList["Term"] = 1
tagList["Internet"] = 2
tagList["FileManager"] = 3
-- tagList["Developpement"] = 4
tagList["Editor"] = 5
tagList["Multimedia"] = 6
tagList["Doc"] = 7
tagList["Other1"] = 8
tagList["Other2"] = 9

--awful.tag.viewonly(tags[1][3]) end)

function executeApps(screen, tagName , cmd, class)
    --awful.tag.viewonly(shifty.getpos(tagList[tagName]))
    run_or_raise(cmd, { class = class })
    lauchBar.visible = false
    naughty.destroy(appInfo[3])
end

function executeAppsNew(screen, tagName , cmd)
    --awful.tag.viewonly(tags[screen][tagList[tagName]])
    awful.util.spawn(cmd) 
    lauchBar.visible = false
    naughty.destroy(appInfo[3])
end

local appInfo = {}
function appsInfo(name) 
local f = io.popen('/home/lepagee/Scripts/appsInfo.sh ' .. name )
  local text2 = f:read("*all")
  f:close()
  appInfo = { month, year, 
	      naughty.notify({
		  text = text2,
		  timeout = 5, hover_timeout = 0.5,
		  width = 210, screen = mouse.screen
	      })
	    }
end

function displayInfo(anApps, name)
  anApps:add_signal("mouse::enter", function ()
      appsInfo(name)
  end)

  anApps:add_signal("mouse::leave", function ()
    naughty.destroy(appInfo[3])
  end)
end

inkscape       = widget({ type = "imagebox", align = "left" })
inkscape.image = image(awful.util.getdir("config") .. "/Icon/inkscape.png")
displayInfo(inkscape,"inkscape")
inkscape:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Multimedia" , "inkscape", "Inkscape")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

konqueror       = widget({ type = "imagebox", align = "left" })
konqueror.image = image(awful.util.getdir("config") .. "/Icon/konquror.png")
displayInfo(konqueror,"konqueror")
konqueror:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "FileManager" , "konqueror", "Konqueror")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

blender       = widget({ type = "imagebox", align = "left" })
blender.image = image(awful.util.getdir("config") .. "/Icon/blender.png")
displayInfo(blender,"blender")
blender:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Multimedia" , "blender", "Blender")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

cinelerra       = widget({ type = "imagebox", align = "left" })
cinelerra.image = image(awful.util.getdir("config") .. "/Icon/cinelerra.png")
displayInfo(cinelerra,"cinelerra")
cinelerra:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Multimedia" , "cinelerra", "cinelerra")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

codeblocks       = widget({ type = "imagebox", align = "left" })
codeblocks.image = image(awful.util.getdir("config") .. "/Icon/code-blocks.png")
displayInfo(codeblocks,"codeblocks")
codeblocks:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Developpement" , "codeblocks", "Codeblocks")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

kdevelop       = widget({ type = "imagebox", align = "left" })
kdevelop.image = image(awful.util.getdir("config") .. "/Icon/kdevelop.png")
displayInfo(kdevelop,"kdevelop")
kdevelop:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Developpement" , "kdevelop", "Kdevelop")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

gimp       = widget({ type = "imagebox", align = "left" })
gimp.image = image(awful.util.getdir("config") .. "/Icon/gimp.png")
displayInfo(gimp,"gimp")
gimp:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Multimedia" , "gimp", "Gimp")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

oowrite       = widget({ type = "imagebox", align = "left" })
oowrite.image = image(awful.util.getdir("config") .. "/Icon/oowriter2.png")
displayInfo(oowrite,"writer")
oowrite:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Other1" , "oowriter", "OpenOffice Writer")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

oocalc       = widget({ type = "imagebox", align = "left" })
oocalc.image = image(awful.util.getdir("config") .. "/Icon/oocalc2.png")
displayInfo(oocalc,"calc")
oocalc:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Other1" , "oocalc", "OpenOffice Calc")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

ooimpress       = widget({ type = "imagebox", align = "left" })
ooimpress.image = image(awful.util.getdir("config") .. "/Icon/oopres2.png")
displayInfo(ooimpress,"impress")
ooimpress:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Other1" , "ooimpress", "OpenOffice Impress")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

oomath       = widget({ type = "imagebox", align = "left" })
oomath.image = image(awful.util.getdir("config") .. "/Icon/ooformula2.png")
displayInfo(oomath,"math")
oomath:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Other1" , "oomath", "OpenOffice Math")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

oobase       = widget({ type = "imagebox", align = "left" })
oobase.image = image(awful.util.getdir("config") .. "/Icon/oobase2.png")
displayInfo(oobase,"base")
oobase:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Other1" , "oobase", "OpenOffice Base")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

vlc       = widget({ type = "imagebox", align = "left" })
vlc.image = image(awful.util.getdir("config") .. "/Icon/vlc.png")
displayInfo(vlc,"vlc")
vlc:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Multimedia" , "vlc", "Vlc")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

vmware       = widget({ type = "imagebox", align = "left" })
vmware.image = image(awful.util.getdir("config") .. "/Icon/windows.png")
vmware:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Internet" , "inkscape", "Inkscape") --Broken
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

amarok       = widget({ type = "imagebox", align = "left" })
amarok.image = image(awful.util.getdir("config") .. "/Icon/amarok.png")
displayInfo(amarok,"amarok")
amarok:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Multimedia" , "amarok", "Amarok")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

term       = widget({ type = "imagebox", align = "left" })
term.image = image(awful.util.getdir("config") .. "/Icon/term.png")
term:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeAppsNew(1, "Term" , terminal)
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

kolourpaint       = widget({ type = "imagebox", align = "left" })
kolourpaint.image = image(awful.util.getdir("config") .. "/Icon/kolourpaint.png")
displayInfo(kolourpaint,"kolourpaint")
kolourpaint:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Multimedia" , "kolourpaint", "Kolourpaint")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

thunar       = widget({ type = "imagebox", align = "left" })
thunar.image = image(awful.util.getdir("config") .. "/Icon/Thunar.png")
displayInfo(thunar,"thunar")
thunar:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeAppsNew(1, "FileManager" , "thunar")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

digikam       = widget({ type = "imagebox", align = "left" })
digikam.image = image(awful.util.getdir("config") .. "/Icon/digikam.png")
displayInfo(digikam,"digikam")
digikam:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "Imaging" , "digikam")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

kcalc       = widget({ type = "imagebox", align = "left" })
kcalc.image = image(awful.util.getdir("config") .. "/Icon/calc.png")
displayInfo(kcalc,"kcalc")
kcalc:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeAppsNew(1, "" , "kcalc")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

transmission       = widget({ type = "imagebox", align = "left" })
transmission.image = image(awful.util.getdir("config") .. "/Icon/transmission.png")
displayInfo(transmission,"transmission")
transmission:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "" , "transmission")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

kdenlive       = widget({ type = "imagebox", align = "left" })
kdenlive.image = image(awful.util.getdir("config") .. "/Icon/kdenlive.png")
displayInfo(kdenlive,"kdenlive")
kdenlive:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "" , "kdenlive")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

kino       = widget({ type = "imagebox", align = "left" })
kino.image = image(awful.util.getdir("config") .. "/Icon/kino.png")
--displayInfo(kino,"kino")
kino:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "" , "kino")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

konversation       = widget({ type = "imagebox", align = "left" })
konversation.image = image(awful.util.getdir("config") .. "/Icon/konversation.png")
displayInfo(konversation,"konversation")
konversation:buttons(awful.util.table.join(
   awful.button({ }, 1, function()
      executeApps(1, "" , "konversation")
   end),
   awful.button({ }, 3, function()
      lauchBar.visible = false
   end)
))

-- konversation2       = widget({ type = "imagebox", align = "left" })
-- konversation2.image = image(awful.util.getdir("config") .. "/Icon/konversation.png")
-- konversation2.mouse_enter = function () appsInfo("konversation") end
-- konversation2.mouse_leave = function () naughty.destroy(appInfo[3]) end
-- konversation2:buttons({
--    button({ }, 1, function()
--       executeApps(1, "" , "konversation")
--    end)
-- })

-- firefox       = widget({ type = "imagebox", align = "left" })
-- firefox.image = image(awful.util.getdir("config") .. "/Icon/firefox.png")
-- firefox.mouse_enter = function () appsInfo("mozilla-firefox-3.5") end
-- firefox.mouse_leave = function () naughty.destroy(appInfo[3]) end
-- firefox:buttons({
--    button({ }, 1, function()
--       executeApps(1, "" , "firefox")
--    end)
-- })

-- thunderbird       = widget({ type = "imagebox", align = "left" })
-- thunderbird.image = image(awful.util.getdir("config") .. "/Icon/thunderbird.png")
-- thunderbird.mouse_enter = function () appsInfo("mozilla-thunderbird") end
-- thunderbird.mouse_leave = function () naughty.destroy(appInfo[3]) end
-- thunderbird:buttons({
--    button({ }, 1, function()
--       executeApps(1, "" , "thunderbird")
--    end)
-- -- })

lauchBar.widgets = {  --firefox,
		      --thunderbird,
		      inkscape,
		      konqueror,
		      blender,
		      cinelerra,
		      codeblocks,
		      kdevelop,
		      gimp,
		      oowrite,
		      oocalc,
		      ooimpress,
		      oomath,
		      oobase,
		      vlc,
		      vmware,
		      amarok,
		      term,
		      kolourpaint,
		      thunar,
		      digikam,
		      kcalc,
		      transmission,
		      kdenlive,
		      kino,
 		      konversation,
		      layout = awful.widget.layout.horizontal.leftright
		      }
lauchBar.visible = false
