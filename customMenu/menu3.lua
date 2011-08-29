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

module("customMenu.menu3")

function new(args) 
  local subArrow = capi.widget({type="imagebox", image = capi.image( beautiful.menu_submenu_icon         ) })
  local checkbox = capi.widget({type="imagebox", image = capi.image( config.data.iconPath .. "check.png" ) })
  
  local function createMenu(args)
    args = args or {}
    local menu = { settings = { 
    -- Settings
    --PROPERTY          VALUE               BACKUP VLAUE       
    itemHeight  = args.itemHeight    or beautiful.menu_height , 
    visible     = false                                       ,
    itemWidth   = args.width         or beautiful.menu_width  , 
    bg_normal   = args.bg_normal     or beautiful.bg_normal   ,
    bg_focus    = args.bg_focus      or beautiful.bg_focus    ,
    x           = args.x             or nil                   ,
    y           = args.y             or nil                   ,
    },---------------------------------------------------------

    -- Data
    --  TYPE      INIT                                         
    signalList  = {}                                          ,
    items       = {}                                          ,
    hasChanged  = nil                                         ,
    highlighted = {}                                          ,
    -----------------------------------------------------------
    }
    
    function menu:toggle(value)
      if self.settings.visible == false and value == false then return end
      
      self.settings.visible = value or not self.items[1].widget.visible
      if self.settings.visible == false then
        self:toggleSubMenu(nil,true,false)
      end
      
      for v, i in next, self.items do
        if type(i) ~= "function" and type(v) == "number" then
          i.widget.visible = self.settings.visible
        end
      end
      
      if self.settings.visible == false and self.signalList["menu::hide"] ~= nil then
          for k,v in pairs(self.signalList["menu::hide"]) do
              v(self)
          end
      elseif self.settings.visible == true and self.signalList["menu::show"] ~= nil then
          for k,v in pairs(self.signalList["menu::show"]) do
              v(self)
          end
      end
      
      self:set_coords()
    end
    
    
    function hightlight(aWibox, value)
        if not aWibox or value == nil then return end
        
        aWibox.bg = ((value == true) and menu.settings.bg_focus or menu.settings.bg_normal) or ""
        if value == true then
            table.insert(menu.highlighted,aWibox)
        end
    end
    
    function menu:highlight_item(index)
        if self.items[index] ~= nil then
            if self.items[index].widget ~= nil then
                hightlight(self.items[index].widget,true)
            end
        end
    end
    
    function menu:clear_highlight()
        if #(self.highlighted) > 0 then
            for k, v in pairs(self.highlighted) do
                hightlight(v,false)
            end
            self.highlighted = {}
        end
    end
    
    function menu:set_coords(x,y)
      local prevX = self.settings["xPos"] or -1
      local prevY = self.settings["yPos"] or -1
      
      self.settings["xPos"] = x or self.settings["x"] or capi.mouse.coords().x
      self.settings["yPos"] = y or self.settings["y"] or capi.mouse.coords().y
      
      if prevX ~= self.settings["xPos"] or prevY ~= self.settings["yPos"] then
          self.hasChanged = true
      end
      
      if self.settings.visible == false or self.hasChanged == false then
        return;
      end
      
      self.hasChanged = false
      local counter = 0
      
      local downOrUp = 1 --(down == false)
      local yPadding = 0
      if #self*self.settings.itemHeight + self.settings["yPos"] > capi.screen[capi.mouse.screen].geometry.height then
          downOrUp = -1
          yPadding = -self.settings.itemHeight
      end
      
      for v, i in next, self.items do
        if type(i) ~= "function" and type(v) == "number" then
          i.x = self.settings.xPos
          i.y = self.settings.yPos+(self.settings.itemHeight*counter)*downOrUp+yPadding
          local geo = i.widget:geometry()
          if geo.x ~= i.x or geo.y ~= i.y or geo.width ~= i.width or geo.height ~= i.height then --moving is slow
            i.widget:geometry({ width = i.width, height = i.height, y=i.y, x=i.x})
          end
          counter = counter +1
          if type(i.subMenu) ~= "function" and i.subMenu ~= nil and i.subMenu.settings ~= nil then
            i.subMenu.settings.x = i.x+i.width
            i.subMenu.settings.y = i.y
          end
        end
      end
    end
    
    function menu:set_width(width)
        self.settings["itemWidth"] = width
    end
    
    
    ---Possible signals = "menu::hide", "menu::show", "menu::resize"
    function menu:add_signal(name,func)
        if self.signalList.name == nil then
            self.signalList.name = {}
        end
        table.insert(self.signalList.name,func)
    end
    
    
    function menu:toggleSubMenu(aSubMenu,hideOld,forceValue) --TODO dead code?
      if (self.subMenu ~= nil) and (hideOld == true) then
        self.subMenu:toggleSubMenu(nil,true,false)
        self.subMenu:toggle(false)
      elseif aSubMenu ~= nil and aSubMenu.toggle ~= nil then
        aSubMenu:toggle(forceValue or true)  
      end
      self.subMenu = aSubMenu
    end
    
    function menu:addItem(args)
      local aWibox = wibox({ position = "free", visible = false, ontop = true, border_width = 1, border_color = beautiful.border_normal })
      local data = {
        --PROPERTY       VALUE                BACKUP VALUE          
        text        = args.text        or ""                       ,
        prefix      = args.prefix      or nil                      ,
        suffix      = args.suffix      or nil                      ,
        width       = capi.width       or self.settings.itemWidth  , 
        height      = capi.height      or self.settings.itemHeight , 
        widget      = aWibox           or nil                      , 
        icon        = args.icon        or nil                      ,
        checked     = args.checked     or nil                      ,
        button1     = args.onclick     or args.button1             ,
        onmouseover = args.onmouseover or nil                      ,
        onmouseout  = args.onmouseout  or nil                      ,
        subMenu     = args.subMenu     or nil                      ,
        nohighlight = args.nohighlight or false                    ,
        noautohide  = args.noautohide  or false                    ,
        ------------------------------------------------------------
      }
      for i=2, 10 do
          data["button"..i] = args["button"..i]
      end
      self.hasChanged = true
      
      table.insert(self.items, data)
      self:set_coords()
      
      if subMenu ~= nil then
         subArrow2 = subArrow
         if type(subMenu) ~= "function" and subMenu.settings then
           subMenu.settings.parent = self
         end
      else
        subArrow2 = nil
      end
      
      local function toggleItem(value)
          if data.nohighlight ~= true then
              hightlight(aWibox,value)
          end
          if value == true then
            if type(subMenu) ~= "function" then
              self:toggleSubMenu(subMenu,value,value)
            elseif self.subMenu == nil then --Prevent memory leak
              local aSubMenu = subMenu()
              aSubMenu.settings.x = self.settings["xPos"] + aSubMenu.settings.itemWidth
              aSubMenu.settings.y = self.settings["yPos"]
              aSubMenu.settings.parent = self
              self:toggleSubMenu(aSubMenu,value,value)
            end
          end
      end
      
      local createWidget = function(field,type)
        local newWdg = (field ~= nil) and capi.widget({type=type }) or nil
        if newWdg ~= nil and type == "textbox" then
            newWdg.text  = field
        elseif newWdg ~= nil and type == "imagebox" then
            newWdg.image = capi.image(field)
        end
        return newWdg
      end
      
      local checkbox2 = (checked ~= nil) and checkbox or nil
      
      local prefix = createWidget(data.prefix,"textbox")
      local suffix = createWidget(data.suffix,"textbox")
      local wdg    = createWidget(data.text,"textbox")
      
      aWibox.widgets = {prefix,data.icon,wdg, {subArrow2,checkbox2,suffix, layout = widget2.layout.horizontal.rightleft}, layout = widget2.layout.horizontal.leftright}
      
      local hideEverything = function () 
        self:toggle(false)
        local aMenu = self.settings.parent
        while aMenu ~= nil do
          aMenu:toggle(value)
          aMenu = aMenu.settings.parent
        end
      end
      
      local clickCommon = function (index)
          if data.noautohide ~= true then
            if data["button"..index] ~= nil then
              data["button"..index]()
            end
            hideEverything()
          end
      end
      
      aWibox:buttons( util.table.join(
        button({ }, 1, function() clickCommon(1 ) end),
        button({ }, 1, function() clickCommon(2 ) end),
        button({ }, 3, function() clickCommon(3 ) end),
        button({ }, 3, function() clickCommon(4 ) end),
        button({ }, 3, function() clickCommon(5 ) end),
        button({ }, 3, function() clickCommon(6 ) end),
        button({ }, 3, function() clickCommon(7 ) end),
        button({ }, 3, function() clickCommon(8 ) end),
        button({ }, 3, function() clickCommon(9 ) end),
        button({ }, 3, function() clickCommon(10) end)
      ))
      
      aWibox:add_signal("mouse::enter", function() toggleItem(true) end)
      aWibox:add_signal("mouse::leave", function() toggleItem(false) end)
      aWibox.visible = false
      return aWibox
    end
    return menu
  end
  
  return createMenu(args)
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })
