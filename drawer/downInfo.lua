local setmetatable = setmetatable
local io           = io
local ipairs       = ipairs
local table        = table
local button    = require( "awful.button"   )
local beautiful = require( "beautiful"      )
local widget2   = require( "awful.widget"   )
local naughty   = require( "naughty"        )
local config    = require( "forgotten"         )
local vicious   = require( "extern.vicious" )
local tag       = require( "awful.tag"      )
local util      = require( "awful.util"     )
local shifty    = require( "shifty"         )
local themeutils = require( "blind.common.drawing"    )
local capi = { image  = image ,
               screen = screen,
               widget = widget,
               mouse  = mouse ,
               tag    = tag   }

local module = {}

local function update()

end

local function new(screen, args)
  kgetpixmap       = widget({ type = "imagebox", align = "right" })
  kgetpixmap.image = image(config.iconPath .. "tags/download.png")

  kgetwidget = widget({
      type = 'textbox',
      name = 'volumewidget'
  })

  kgetwidget.text = "KGet: 1 |"

  local kgetInfo
  function downloadInfo() 
    local percent = ""
    local source = ""
    local destination = ""
    local size = ""
    local downloaded = ""
    local downloadTable = {}
    local count = 0
    
    local f = io.popen('/home/lepagee/Scripts/kgetInfo.sh')
    if (f:read("*line") == "ready") then
      while true do
	percent = f:read("*line")
	
	if percent == "END" or nil then
	  break
	end
	
	source = f:read("*line")
	destination = f:read("*line")
	size = f:read("*line")
	downloaded = f:read("*line")
	local aLine = f:read("*line")
	
	local kgetdown1 = widget({
	  type = 'textbox',
	  name = 'volumewidget'
	})
	
	local kgetdownpercent = widget({
	  type = 'textbox',
	  name = 'volumewidget'
	})
	
	local kgetdowndescription = widget({
	  type = 'textbox',
	  name = 'volumewidget'
	})
	
	local kgetdownprogress = widget({
	  type = 'textbox',
	  name = 'volumewidget'
	})
	
	kgetdownpercent.text = " ("..percent.."%)"
	kgetdownpercent.width = 40
	
	size = string.format("%.2f", tonumber(size) / 1024 /1024)
	downloaded = string.format("%.2f", tonumber(downloaded) / 1024 /1024)
	
	local path = utils.tools.explode("/",source)
	local fileName = path[# path]:gsub("\"","")
	
	local dpath = utils.tools.explode("/",destination:gsub("\"",""))
	destination = ""
	for i = 1, (# dpath) -1 do
	  destination = destination .. dpath[i] .. "/"
	end

	kgetdown1.text = " <b>File: </b>".. fileName
	
	kgetdowndescription.text = " <b>Destination: </b>"  .. destination
	
	kgetdownprogress.text = " <b>Progress: </b>" .. downloaded .. "mb / " .. size .. "mb (" .. percent .. "%)"
	
	local downbar = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
	downbar:set_width(320)
	downbar:set_height(18)
	downbar:set_vertical(false)
	downbar:set_background_color(beautiful.bg_normal)
	downbar:set_border_color(beautiful.fg_normal)
	downbar:set_color(beautiful.fg_normal)
	downbar:set_value(tonumber(percent)/100)
	
	table.insert(downloadTable, kgetdown1)
	table.insert(downloadTable, kgetdowndescription)
	table.insert(downloadTable, kgetdownprogress)
  --       table.insert(downloadTable, downbar)
  --       table.insert(downloadTable, kgetdownpercent)
  --       table.insert(downloadTable, { downbar,
  -- 				    kgetdownpercent,
  -- 				    layout = awful.widget.layout.horizontal.leftright
  --       })
	
	count = count + 1
	
	if count > 0 then
	  local kgetdowntmp = widget({
	    type = 'textbox',
	    name = 'volumewidget'
	  })
	  kgetdowntmp.text = " "
	  table.insert(downloadTable, kgetdowntmp)
	end
	
      end
    end 
    f:close()
    
    local toRemove = 0
    
    if count > 0 then
      table.remove(downloadTable, # downloadTable)
    end
    
    if count == 1 then
      toRemove = 1
    end

    local text2 = ""
    
    for i =0, (count * 4) -1 - toRemove do
      text2 = text2 .. "\n"
    end
    
    kgetInfo = naughty.notify({
		    text = text2,
		    timeout = 0, hover_timeout = 0.5,
		    width = 360, screen = mouse.screen
		})
		
    downloadTable['layout'] = awful.widget.layout.vertical.flex
    kgetInfo.box.widgets = downloadTable
  end

  function currentDownload() 
    local f = io.open('/tmp/kgetDwn.txt','r')
    local text2 = f:read("*all")
    f:close()
    local count = tonumber(text2) or 0
    if count > 0 then
      kgetwidget.visible = true
      kgetpixmap.visible = true
    else
      kgetwidget.visible = false
      kgetpixmap.visible = false
    end
    return {count}
  end

  vicious.register(kgetwidget, currentDownload, 'KGet: $1 | ',5)


  kgetwidget:add_signal("mouse::enter", function ()
      --downloadInfo()  --Disabled while porting to a module
  end)

  kgetwidget:add_signal("mouse::leave", function ()
    naughty.destroy(kgetInfo)
  end)

  kgetpixmap:add_signal("mouse::enter", function ()
      --downloadInfo()  --Disabled while porting to a module
  end)

  kgetpixmap:add_signal("mouse::leave", function ()
    naughty.destroy(kgetInfo)
  end)
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
