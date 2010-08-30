local setmetatable = setmetatable
local table = table
local button = require("awful.button")
local beautiful = require("beautiful")
local widget2 = require("awful.widget")
local next = next
local type = type
local util = require("awful.util")
local wibox = require("awful.wibox")
local capi = { image = image,
               widget = widget,
               mouse = mouse}

module("customMenu.menu2")

local function hightlight(aWibox, value)
  aWibox.bg = (value == true) and beautiful.bg_focus or beautiful.bg_normal
end

function new(screen, args) 
  local subArrow = capi.widget({type="imagebox"})
  subArrow.image = capi.image(beautiful.menu_submenu_icon)
  
  local checkbox = capi.widget({type="imagebox"})
  checkbox.image = capi.image(util.getdir("config") .. "/Icon/check.png")
  
  local function createMenu()
    local menu = {settings = {counter = 0, itemHeight = beautiful.menu_height, itemWidth = beautiful.menu_width, x = nil, y = nil, } }
    
    function menu:toggle(value)
      self["settings"].visible = value or not self[1].widget.visible
      if self["settings"].visible == false then
        self:toggleSubMenu(nil,true,false)
      end
      for v, i in next, self do
        if type(i) ~= "function" and type(v) == "number" then
          i.widget.visible = self["settings"].visible
        end
      end
      self:set_coords()
    end
    
    function menu:set_coords(x,y)
      self["settings"]["xPos"] = x or self["settings"]["x"] or capi.mouse.coords().x
      self["settings"]["yPos"] = y or self["settings"]["y"] or capi.mouse.coords().y
      self["settings"]["counter"] = 0
      for v, i in next, self do
        if type(i) ~= "function" and type(v) == "number" then
          i.x = self.settings.xPos
          i.y = self.settings.yPos+(self.settings.itemHeight*self.settings.counter)
          i.widget:geometry({ width = i.width, height = i.height, y=i.y, x=i.x})
          self.settings.counter = self.settings.counter +1
          if i.subMenu ~= nil then
            i.subMenu.settings.x = i.x+i.width
            i.subMenu.settings.y = i.y
          end
        end
      end
    end
    
    function menu:toggleSubMenu(aSubMenu,hideOld,forceValue)
      if (self.subMenu ~= nil) and (hideOld == true) then
	self.subMenu:toggleSubMenu(nil,true,false)
	self.subMenu:toggle(false)
	if self["settings"].parent ~= nil and self["settings"].parent["settings"].visible == true then
          self["settings"].parent:toggle(false)
	end
      elseif aSubMenu ~= nil then
	aSubMenu:toggle(forceValue or true)  
      end
--       
      self.subMenu = aSubMenu
    end
    
    function menu:addItem(text, checked, aFunction, subMenu,args)
      local aWibox = wibox({ position = "free", visible = false, ontop = true, border_width = 1, border_color = beautiful.border_normal })
      local data = {width = self.settings.itemWidth, height = self.settings.itemHeight, widget = aWibox, aFunction = aFunction, subMenu = subMenu}
      table.insert(self, data)
      self:set_coords()
      
      if subMenu ~= nil then
         subArrow2 = subArrow
         subMenu["settings"].parent = self
      else
	subArrow2 = nil
      end
      
      local function toggleItem(value)
         hightlight(aWibox,value)
          if value == true then
            self:toggleSubMenu(subMenu,value,value)
          end
      end
      
      local wdg = capi.widget({type="textbox"})
      wdg.text = text
      
      if checked ~= nil then
	checkbox2 = checkbox
      else
	checkbox2 = nil
      end
      
      icon = capi.widget({type="imagebox"})
      if args ~= nil and args.icon ~= nil then
	icon.image = capi.image(args.icon)
      else
	icon.image = capi.image()
      end
      
      aWibox.widgets = { {icon,wdg, {subArrow2,checkbox2, layout = widget2.layout.horizontal.rightleft}, layout = widget2.layout.horizontal.leftright}, layout = widget2.layout.vertical.flex }
      
      aWibox:buttons( util.table.join(
	button({ }, 1, function()
	  if aFunction ~= nil then
	    aFunction()
	  end
	  self:toggle(false)
	end),
	button({ }, 3, function()
	  self:toggle(false)
	end)
      ))
      
      aWibox:add_signal("mouse::enter", function() toggleItem(true) end)
      aWibox:add_signal("mouse::leave", function() toggleItem(false) end)
      aWibox.visible = false
      return aWibox
    end
    return menu
  end
  
  return createMenu()
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })
