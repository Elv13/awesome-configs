local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local next         = next
local type         = type
local print        = print
local string       = string
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local widget2      = require( "awful.widget" )
local config       = require( "config"       )
local util         = require( "awful.util"   )
local wibox        = require( "awful.wibox"  )

local capi = { image      = image      ,
               widget     = widget     ,
               mouse      = mouse      ,
               screen     = screen     , 
               keygrabber = keygrabber }

module("widgets.menu")

-- Common function
local grabKeyboard = false
local currentMenu  = nil

local function stopGrabber()
    currentMenu:toggle(false)
    capi.keygrabber.stop()
    grabKeyboard = false
    currentMenu  = nil
    return false
end

local function keyboardNavigation(leap)
    if currentMenu.currentIndex + leap > #currentMenu.items then
        currentMenu.currentIndex = 1
    elseif currentMenu.currentIndex + leap < 1 then
        currentMenu.currentIndex = #currentMenu.items
    else
        currentMenu.currentIndex = currentMenu.currentIndex + leap
    end
    currentMenu:clear_highlight()
    currentMenu:highlight_item(currentMenu.currentIndex) 
end

local function getFilterWidget(aMenu)
    local menu = aMenu or currentMenu or nil
    if menu.settings.showfilter == true then
        if menu.filterWidget == nil then
            local textbox = capi.widget({type="textbox" })
            textbox.text = menu.settings.filterprefix
            local filterWibox = wibox({ position = "free", visible = false, ontop = true, border_width = 1, border_color = beautiful.border_normal })
            filterWibox:buttons( util.table.join(button({},3,function() menu:toggle(false) end)))
            filterWibox.widgets = { textbox, layout = widget2.layout.horizontal.leftright }
            menu.filterWidget = {textbox = textbox, widget = filterWibox, hidden = false, width = menu.settings.itemWidth, height = menu.settings.itemHeight}
        end
        return menu.filterWidget
    end
    return nil
end

local function activateKeyboard(curMenu)
    currentMenu = curMenu or currentMenu or nil
    if not currentMenu or grabKeyboard == true then return end
    
    if (not currentMenu.settings.nokeyboardnav) and currentMenu.settings.visible == true then
        grabKeyboard = true
        capi.keygrabber.run(function(mod, key, event)
            if event == "release" then 
                return true 
            end 
            
            for k,v in pairs(currentMenu.filterHooks) do --TODO modkeys
                if k.key == key and k.event == event then
                    return v(currentMenu)
                end
            end
            
            if (currentMenu.keyShortcut[{mod,key}] or key == 'Enter') and currentMenu.keyShortcut[{mod,key}].button1 then --TODO use a different function
                currentMenu.keyShortcut[{mod,key}].button1()
            elseif key == 'Escape' or (key == 'Tab' and currentMenu.filterString == "") then 
                stopGrabber()
            elseif key == 'Up' then 
                keyboardNavigation(-1)
            elseif key == 'Down' then 
                keyboardNavigation(1)
            elseif (key == 'BackSpace') and currentMenu.filterString ~= "" and currentMenu.settings.filter == true then
                currentMenu.filterString = currentMenu.filterString:sub(1,-2)
                currentMenu:filter(currentMenu.filterString:lower())
                if getFilterWidget() ~= nil then
                    getFilterWidget().textbox.text = getFilterWidget().textbox.text:sub(1,-2)
                end
            elseif currentMenu.settings.filter == true and key:len() == 1 then 
                currentMenu.filterString = currentMenu.filterString .. key
                if getFilterWidget() ~= nil then
                    getFilterWidget().textbox.text = getFilterWidget().textbox.text .. key
                end
                currentMenu:filter(currentMenu.filterString:lower())
            else
                stopGrabber()
            end
            return true
        end)
    end
end

-- Individual menu function
function new(args) 
  local subArrow = capi.widget({type="imagebox", image = capi.image( beautiful.menu_submenu_icon         ) })
  local checkbox = capi.widget({type="imagebox", image = capi.image( config.data.iconPath .. "check.png" ) })
  
  local function createMenu(args)
    args = args or {}
    local menu = { settings = { 
    -- Settings
    --PROPERTY          VALUE               BACKUP VLAUE         
    itemHeight    = args.itemHeight    or beautiful.menu_height , 
    visible       = false                                       ,
    itemWidth     = args.width         or beautiful.menu_width  , 
    bg_normal     = args.bg_normal     or beautiful.bg_normal   ,
    bg_focus      = args.bg_focus      or beautiful.bg_focus    ,
    nokeyboardnav = args.nokeyboardnav or false                 ,
    filter        = args.filter        or false                 ,
    showfilter    = args.showfilter    or false                 ,
    filterprefix  = args.filterprefix  or "<b>Filter:</b>"      ,
    x             = args.x             or nil                   ,
    y             = args.y             or nil                   ,
    },-----------------------------------------------------------

    -- Data
    --  TYPE      INITIAL VALUE                                  
    signalList    = {}                                          ,
    items         = {}                                          ,
    hasChanged    = nil                                         ,
    highlighted   = {}                                          ,
    currentIndex  = 1                                           ,
    keyShortcut   = {}                                          ,
    filterString  = ""                                          ,
    filterWidget  = nil                                         ,
    filterHooks   = {}                                          ,
    -------------------------------------------------------------
    }
    
    menu.signalList["menu::hide"] = {}
    menu.signalList["menu::show"] = {}

    function menu:toggle(value)
      if self.settings.visible == false and value == false then return end
      
      self.settings.visible = value or not self.items[1].widget.visible
      if self.settings.visible == false then
        self:toggleSubMenu(nil,true,false)
      end
      
      for v, i in next, self.items do
        if type(i) ~= "function" and type(v) == "number" then
          i.widget.visible = self.settings.visible and not i.hidden
        end
      end
      
      if self.settings.visible == false and #self.signalList["menu::hide"] ~= 0 then
          for k,v in pairs(self.signalList["menu::hide"]) do
              v(self)
          end
      elseif self.settings.visible == true and #self.signalList["menu::show"] ~= 0 then
          for k,v in pairs(self.signalList["menu::show"]) do
              v(self)
          end
      end
      
      if getFilterWidget(self) then
          menu.filterWidget.widget.visible = value
      end
      
      activateKeyboard(self)
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
    
    local filterDefault = function(item,text)
        if item.text:find(text) ~= nil then
            return false
        end
        return true
    end
    
    function menu:filter(text,func)
        local toExec = func or filterDefault
        for k, v in next, self.items do
            if v.nofilter == false then
                v.hidden = toExec(v,text)
            end
        end
        self:toggle(self.settings.visible)
    end
    
    function menu:set_coords(x,y)
      local prevX = self.settings["xPos"] or -1
      local prevY = self.settings["yPos"] or -1
      
      self.settings.xPos = x or self.settings.x or capi.mouse.coords().x
      self.settings.yPos = y or self.settings.y or capi.mouse.coords().y
      
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
      if #self.items*self.settings.itemHeight + self.settings["yPos"] > capi.screen[capi.mouse.screen].geometry.height then
          downOrUp = -1
          yPadding = -self.settings.itemHeight
      end
            
      local set_geometry = function(wdg)
        if type(wdg) ~= "function" and wdg.hidden == false then
            local geo = wdg.widget:geometry()
            wdg.x = self.settings.xPos
            wdg.y = self.settings.yPos+(self.settings.itemHeight*counter)*downOrUp+yPadding
            if geo.x ~= wdg.x or geo.y ~= wdg.y or geo.width ~= wdg.width or geo.height ~= wdg.height then --moving is slow
                wdg.widget:geometry({ width = wdg.width, height = wdg.height, y=wdg.y, x=wdg.x})
            end
            counter = counter +1
            if type(wdg.subMenu) ~= "function" and wdg.subMenu ~= nil and wdg.subMenu.settings ~= nil then
                wdg.subMenu.settings.x = wdg.x+wdg.width
                wdg.subMenu.settings.y = wdg.y
            end
        end
      end
      
      for v, i in next, self.items do
        set_geometry(i)
      end
      
      if getFilterWidget() ~= nil then
          set_geometry(getFilterWidget())
      end
    end
    
    function menu:set_width(width)
        self.settings.itemWidth = width
    end
    
    
    ---Possible signals = "menu::hide", "menu::show", "menu::resize"
    function menu:add_signal(name,func)
        if self.signalList[name] == nil then
            self.signalList[name] = {}
        end
        table.insert(self.signalList[name],func)
    end
    
    function menu:add_filter_hook(mod, key, event, func)
        if key and event and func then
            --table.insert(filterHooks,{, func = func})
            self.filterHooks[{key = key, event = event, mod = mod}] = func
        end
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
        hidden      = args.hidden      or false                    ,
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
        nofilter    = args.nofilter    or false                    ,
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
            currentMenu = self
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
        button({ }, 1 , function() clickCommon(1 ) end),
        button({ }, 2 , function() clickCommon(2 ) end),
        button({ }, 3 , function() clickCommon(3 ) end),
        button({ }, 4 , function() clickCommon(4 ) end),
        button({ }, 5 , function() clickCommon(5 ) end),
        button({ }, 6 , function() clickCommon(6 ) end),
        button({ }, 7 , function() clickCommon(7 ) end),
        button({ }, 8 , function() clickCommon(8 ) end),
        button({ }, 9 , function() clickCommon(9 ) end),
        button({ }, 10, function() clickCommon(10) end)
      ))
      
      aWibox:add_signal("mouse::enter", function() toggleItem(true) end)
      aWibox:add_signal("mouse::leave", function() toggleItem(false) end)
      aWibox.visible = false
      return data
    end
    return menu
  end
  
  return createMenu(args)
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })
