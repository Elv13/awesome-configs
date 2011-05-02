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

module("widget.dock")

local lauchBar

local data = {}

function update()

end

local function run_or_raise(cmd, properties)
   local clients = client.get()
   for i, c in pairs(clients) do
      if match(properties, c) then
         local ctags = c:tags()
         if table.getn(ctags) == 0 then
            local curtag = tag.selected()
         else
            tag.viewonly(ctags[1])
         end
         return
      end
   end
   util.spawn(cmd)
end

local function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v then
         return false
      end
   end
   return true
end

local function executeApps(screen, tagName , cmd, class)
    --run_or_raise(cmd, { class = class })
    lauchBar.visible = false
    --if appInfo and appInfo[3] then
    --   naughty.destroy(appInfo[3])
    --end
end

local function executeAppsNew(screen, tagName , cmd)
    util.spawn(cmd) 
    lauchBar.visible = false
    --if appInfo and appInfo[3] then
    --   naughty.destroy(appInfo[3])
    --end
end

function new(screen, args)
  sensibleArea = wibox({ position = "free", screen = s, width = 1 })
  sensibleArea.ontop = true
  sensibleArea:geometry({ width = 1, height = capi.screen[1].geometry.height -100, x = 0, y = 50})
  
  lauchBar = wibox({ position = "free", screen = s, width = 49 })
  lauchBar:geometry({ width = 40, height = capi.screen[1].geometry.height -100, x = 0, y = 50})
  lauchBar.orientation = "north"
  lauchBar.ontop = true

  local appInfo = {}
  function appsInfo(name) 
    local f = io.popen('/home/lepagee/Scripts/appsInfo.sh ' .. name )
    local text2 = f:read("*all")
    f:close()
    appInfo = { month, year, 
                naughty.notify({
                    text = text2,
                    timeout = 5, hover_timeout = 0.5,
                    width = 210, screen = capi.mouse.screen
                })
              }
  end

  function displayInfo(anApps, name)
--     anApps:add_signal("mouse::enter", function ()
--         appsInfo(name)
--     end)
-- 
--     anApps:add_signal("mouse::leave", function ()
--       if appInfo and appInfo[3] then
--         naughty.destroy(appInfo[3])
--       end
--     end)
  end

  inkscape       = capi.widget({ type = "imagebox", align = "left" })
  inkscape.image = capi.image(util.getdir("config") .. "/Icon/inkscape.png")
  displayInfo(inkscape,"inkscape")
  inkscape:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Multimedia" , "inkscape", "Inkscape")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  konqueror       = capi.widget({ type = "imagebox", align = "left" })
  konqueror.image = capi.image(util.getdir("config") .. "/Icon/konquror.png")
  displayInfo(konqueror,"konqueror")
  konqueror:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "FileManager" , "konqueror", "Konqueror")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  blender       = capi.widget({ type = "imagebox", align = "left" })
  blender.image = capi.image(util.getdir("config") .. "/Icon/blender.png")
  displayInfo(blender,"blender")
  blender:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Multimedia" , "blender", "Blender")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  cinelerra       = capi.widget({ type = "imagebox", align = "left" })
  cinelerra.image = capi.image(util.getdir("config") .. "/Icon/cinelerra.png")
  displayInfo(cinelerra,"cinelerra")
  cinelerra:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Multimedia" , "cinelerra", "cinelerra")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  codeblocks       = capi.widget({ type = "imagebox", align = "left" })
  codeblocks.image = capi.image(util.getdir("config") .. "/Icon/code-blocks.png")
  displayInfo(codeblocks,"codeblocks")
  codeblocks:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Developpement" , "codeblocks", "Codeblocks")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  kdevelop       = capi.widget({ type = "imagebox", align = "left" })
  kdevelop.image = capi.image(util.getdir("config") .. "/Icon/kdevelop.png")
  displayInfo(kdevelop,"kdevelop")
  kdevelop:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Developpement" , "kdevelop", "Kdevelop")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  gimp       = capi.widget({ type = "imagebox", align = "left" })
  gimp.image = capi.image(util.getdir("config") .. "/Icon/gimp.png")
  displayInfo(gimp,"gimp")
  gimp:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Multimedia" , "gimp", "Gimp")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  oowrite       = capi.widget({ type = "imagebox", align = "left" })
  oowrite.image = capi.image(util.getdir("config") .. "/Icon/oowriter2.png")
  displayInfo(oowrite,"writer")
  oowrite:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Other1" , "oowriter", "OpenOffice Writer")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  oocalc       = capi.widget({ type = "imagebox", align = "left" })
  oocalc.image = capi.image(util.getdir("config") .. "/Icon/oocalc2.png")
  displayInfo(oocalc,"calc")
  oocalc:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Other1" , "oocalc", "OpenOffice Calc")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  ooimpress       = capi.widget({ type = "imagebox", align = "left" })
  ooimpress.image = capi.image(util.getdir("config") .. "/Icon/oopres2.png")
  displayInfo(ooimpress,"impress")
  ooimpress:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Other1" , "ooimpress", "OpenOffice Impress")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  oomath       = capi.widget({ type = "imagebox", align = "left" })
  oomath.image = capi.image(util.getdir("config") .. "/Icon/ooformula2.png")
  displayInfo(oomath,"math")
  oomath:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Other1" , "oomath", "OpenOffice Math")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  oobase       = capi.widget({ type = "imagebox", align = "left" })
  oobase.image = capi.image(util.getdir("config") .. "/Icon/oobase2.png")
  displayInfo(oobase,"base")
  oobase:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Other1" , "oobase", "OpenOffice Base")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  vlc       = capi.widget({ type = "imagebox", align = "left" })
  vlc.image = capi.image(util.getdir("config") .. "/Icon/vlc.png")
  displayInfo(vlc,"vlc")
  vlc:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Multimedia" , "vlc", "Vlc")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  vmware       = capi.widget({ type = "imagebox", align = "left" })
  vmware.image = capi.image(util.getdir("config") .. "/Icon/windows.png")
  vmware:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Internet" , "inkscape", "Inkscape") --Broken
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  amarok       = capi.widget({ type = "imagebox", align = "left" })
  amarok.image = capi.image(util.getdir("config") .. "/Icon/amarok.png")
  displayInfo(amarok,"amarok")
  amarok:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Multimedia" , "amarok", "Amarok")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  term       = capi.widget({ type = "imagebox", align = "left" })
  term.image = capi.image(util.getdir("config") .. "/Icon/term.png")
  term:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNewNew(1, "Term" , "urxvt -tint gray -fade 50 +bl +si -cr red -pr green -iconic -fn "xft:DejaVu Sans Mono:pixelsize=13" -pe tabbed")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  kolourpaint       = capi.widget({ type = "imagebox", align = "left" })
  kolourpaint.image = capi.image(util.getdir("config") .. "/Icon/kolourpaint.png")
  displayInfo(kolourpaint,"kolourpaint")
  kolourpaint:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Multimedia" , "kolourpaint", "Kolourpaint")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  thunar       = capi.widget({ type = "imagebox", align = "left" })
  thunar.image = capi.image(util.getdir("config") .. "/Icon/Thunar.png")
  displayInfo(thunar,"thunar")
  thunar:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "FileManager" , "thunar")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  digikam       = capi.widget({ type = "imagebox", align = "left" })
  digikam.image = capi.image(util.getdir("config") .. "/Icon/digikam.png")
  displayInfo(digikam,"digikam")
  digikam:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "Imaging" , "digikam")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  kcalc       = capi.widget({ type = "imagebox", align = "left" })
  kcalc.image = capi.image(util.getdir("config") .. "/Icon/calc.png")
  displayInfo(kcalc,"kcalc")
  kcalc:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "" , "kcalc")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  transmission       = capi.widget({ type = "imagebox", align = "left" })
  transmission.image = capi.image(util.getdir("config") .. "/Icon/transmission.png")
  displayInfo(transmission,"transmission")
  transmission:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "" , "transmission")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  kdenlive       = capi.widget({ type = "imagebox", align = "left" })
  kdenlive.image = capi.image(util.getdir("config") .. "/Icon/kdenlive.png")
  displayInfo(kdenlive,"kdenlive")
  kdenlive:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "" , "kdenlive")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  kino       = capi.widget({ type = "imagebox", align = "left" })
  kino.image = capi.image(util.getdir("config") .. "/Icon/kino.png")
  --displayInfo(kino,"kino")
  kino:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "" , "kino")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

  konversation       = capi.widget({ type = "imagebox", align = "left" })
  konversation.image = capi.image(util.getdir("config") .. "/Icon/konversation.png")
  displayInfo(konversation,"konversation")
  konversation:buttons(util.table.join(
    button({ }, 1, function()
        executeAppsNew(1, "" , "konversation")
    end),
    button({ }, 3, function()
        lauchBar.visible = false
    end)
  ))

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
                        layout = widget2.layout.horizontal.leftright
                        }
  lauchBar.visible = false


  local launcherPix = capi.widget({ type = "imagebox", align = "left" })
  launcherPix.image = capi.image(util.getdir("config") .. "/Icon/gearA2.png")
  
  --launcherPix:add_signal("mouse::enter", function() launcherPix.bg = beautiful.bg_highlight end)
  --launcherPix:add_signal("mouse::leave", function() launcherPix.bg = beautiful.bg_normal end)
  
  launcherPix:buttons( util.table.join(
  button({ }, 1, function()
      if lauchBar.visible ==  false then
	lauchBar.visible = true
      else
	lauchBar.visible = false
      end
  end)
  ))
  
  sensibleArea:add_signal("mouse::enter", function() lauchBar.visible = true end)
  lauchBar:add_signal("mouse::leave", function() lauchBar.visible = false end)
  
  return launcherPix
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
