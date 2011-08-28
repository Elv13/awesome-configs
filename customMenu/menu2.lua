local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local next         = next
local type         = type
local print        = print
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local widget2      = require( "awful.widget" )
local config       = require( "config"       )
local util         = require( "awful.util"   )
local wibox        = require( "awful.wibox"  )

local capi = { image  = image  ,
               widget = widget ,
               mouse  = mouse  ,
               screen = screen , }

module("customMenu.menu2")

function new(screen, args) 
  local subArrow = capi.widget({type="imagebox"})
  subArrow.image = capi.image(beautiful.menu_submenu_icon)
  
  local checkbox = capi.widget({type="imagebox"})
  checkbox.image = capi.image(config.data.iconPath .. "check.png")
  
  local function createMenu()
    local menu = {settings = {counter = 0, itemHeight = beautiful.menu_height, visible = false,
                              itemWidth = beautiful.menu_width, x = nil, y = nil,
                              highlighted = {} }, signalList = {}}
    
    function menu:toggle(value)
      if self["settings"].visible == false and value == false then
          return
      end
      
      self["settings"].visible = value or not self[1].widget.visible
      if self["settings"].visible == false then
        self:toggleSubMenu(nil,true,false)
      end
      
      for v, i in next, self do
        if type(i) ~= "function" and type(v) == "number" then
          i.widget.visible = self["settings"].visible
        end
      end
      
      if self["settings"].visible == false and self.signalList["menu::hide"] ~= nil then
          for k,v in pairs(self.signalList["menu::hide"]) do
              v(self)
          end
      elseif self["settings"].visible == true and self.signalList["menu::show"] ~= nil then
          for k,v in pairs(self.signalList["menu::show"]) do
              v(self)
          end
      end
      
      
      self:set_coords()
    end
    
    
    function hightlight(aWibox, value)
        if not aWibox or value == nil then
            return
        end
        aWibox.bg = ((value == true) and beautiful.bg_focus or beautiful.bg_normal) or ""
        if value == true then
            table.insert(menu["settings"].highlighted,aWibox)
        end
    end
    
    function menu:highlight_item(index)
        if self[index] ~= nil then
            if self[index].widget ~= nil then
                hightlight(self[index].widget,true)
            end
        end
    end
    
    function menu:clear_highlight()
        if #(self["settings"].highlighted) > 0 then
            for k, v in pairs(self["settings"].highlighted) do
                hightlight(v,false)
            end
            self["settings"].highlighted = {}
        end
    end
    
    function menu:set_coords(x,y)
      
      
      local prevX = self["settings"]["xPos"] or -1
      local prevY = self["settings"]["yPos"] or -1
      
      self["settings"]["xPos"] = x or self["settings"]["x"] or capi.mouse.coords().x
      self["settings"]["yPos"] = y or self["settings"]["y"] or capi.mouse.coords().y
      
      if prevX ~= self["settings"]["xPos"] or prevY ~= self["settings"]["yPos"] then
          self["settings"].hasChanged = true
      end
      
      if self["settings"].visible == false or self["settings"].hasChanged == false then
        return;
      end
      
      self["settings"].hasChanged = false
      
      self["settings"]["counter"] = 0
      
      local downOrUp = 1 --(down == false)
      local yPadding = 0
      if #self*self.settings.itemHeight + self["settings"]["yPos"] > capi.screen[capi.mouse.screen].geometry.height then
          downOrUp = -1
          yPadding = -self.settings.itemHeight
      end
      
      for v, i in next, self do
        if type(i) ~= "function" and type(v) == "number" then
          i.x = self.settings.xPos
          i.y = self.settings.yPos+(self.settings.itemHeight*self.settings.counter)*downOrUp+yPadding
          local geo = i.widget:geometry()
          if geo.x ~= i.x or geo.y ~= i.y or geo.width ~= i.width or geo.height ~= i.height then --moving is slow
            i.widget:geometry({ width = i.width, height = i.height, y=i.y, x=i.x})
          end
          self.settings.counter = self.settings.counter +1
          if type(i.subMenu) ~= "function" and i.subMenu ~= nil and i.subMenu.settings ~= nil then
            i.subMenu.settings.x = i.x+i.width
            i.subMenu.settings.y = i.y
          end
        end
      end
    end
    
    function menu:set_width(width)
        self["settings"]["itemWidth"] = width
    end
    
    
    ---Possible signals = "menu::hide", "menu::show", "menu::resize"
    function menu:add_signal(name,func)
        if self.signalList.name == nil then
            self.signalList.name = {}
        end
        table.insert(self.signalList.name,func)
    end
    
    
    function menu:toggleSubMenu(aSubMenu,hideOld,forceValue)
      if (self.subMenu ~= nil) and (hideOld == true) then
        self.subMenu:toggleSubMenu(nil,true,false)
        self.subMenu:toggle(false)
        --if self["settings"].parent ~= nil and self["settings"].parent["settings"].visible == true then
        --  self["settings"].parent:toggle(false)
        --end
      elseif aSubMenu ~= nil and aSubMenu.toggle ~= nil then
        aSubMenu:toggle(forceValue or true)  
      end
--       
      self.subMenu = aSubMenu
    end
    
    function menu:addItem(text, checked, aFunction, subMenu,args)
      local aWibox = wibox({ position = "free", visible = false, ontop = true, border_width = 1, border_color = beautiful.border_normal })
      local data = {width = self.settings.itemWidth, height = self.settings.itemHeight, widget = aWibox, aFunction = aFunction, subMenu = subMenu}
      self["settings"].hasChanged = true
      
      table.insert(self, data)
      self:set_coords()
      
      if subMenu ~= nil then
         subArrow2 = subArrow
         if type(subMenu) ~= "function" and subMenu.settings then
           subMenu["settings"].parent = self
         end
      else
        subArrow2 = nil
      end
      
      local function toggleItem(value)
         hightlight(aWibox,value)
          if value == true then
            if type(subMenu) ~= "function" then
              self:toggleSubMenu(subMenu,value,value)
            elseif self.subMenu == nil then --Prevent memory leak
              local aSubMenu = subMenu()
              aSubMenu["settings"].x = self["settings"]["xPos"] + aSubMenu["settings"].itemWidth
              aSubMenu["settings"].y = self["settings"]["yPos"]
              aSubMenu["settings"].parent = self
              self:toggleSubMenu(aSubMenu,value,value)
            end
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
      
      local hideEverything = function () 
        self:toggle(false)
        local aMenu = self["settings"].parent
        while aMenu ~= nil do
          aMenu:toggle(value)
          aMenu = aMenu["settings"].parent
        end
      end
      
      aWibox:buttons( util.table.join(
        button({ }, 1, function()
          if aFunction ~= nil then
            aFunction()
          end
          hideEverything()
        end),
        button({ }, 3, function()
          hideEverything()
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
