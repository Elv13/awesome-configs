local setmetatable = setmetatable
local table        = table
local pairs        = pairs
local next         = next
local type         = type
local print        = print
local string       = string
local button       = require( "awful.button"     )
local beautiful    = require( "beautiful"        )
local widget2      = require( "awful.widget"     )
local config       = require( "config"           )
local util         = require( "awful.util"       )
local wibox        = require( "awful.wibox"      )
local checkbox     = require( "widgets.checkbox" )

local capi = { image      = image      ,
               widget     = widget     ,
               mouse      = mouse      ,
               screen     = screen     ,
               keygrabber = keygrabber }

module("widgets.menu")

-- Common function
local grabKeyboard = false
local currentMenu  = nil
local discardedItems = {}

local function getWibox()
    if #discardedItems > 0 then
        for k,v in pairs(discardedItems) do
            local wb = v
            discardedItems[k] = nil
            return wb
        end
    else
        return wibox({ position = "free", visible = false, ontop = true, border_width = 1, border_color = beautiful.border_normal })
    end
end

local function stopGrabber()
    currentMenu:toggle(false)
    capi.keygrabber.stop()
    grabKeyboard = false
    currentMenu  = nil return false
end

local function getFilterWidget(aMenu)
    local menu = aMenu or currentMenu or nil
    if menu.settings.showfilter == true then
        if menu.filterWidget == nil then
            local textbox       = capi.widget({type="textbox" })
            textbox.text        = menu.settings.filterprefix
            local filterWibox   = wibox({ position = "free", visible = false, ontop = true, border_width = 1, border_color = beautiful.border_normal })
            filterWibox.bg = beautiful.bg_highlight
            filterWibox.widgets = { textbox, layout = widget2.layout.horizontal.leftright }
            menu.filterWidget   = {textbox = textbox, widget = filterWibox, hidden = false, width = menu.settings.itemWidth, height = menu.settings.itemHeight}
            filterWibox:buttons( util.table.join(button({},3,function() menu:toggle(false) end)))
        end
        table.insert(menu.otherwdg,menu.filterWidget)
        return menu.filterWidget
    end
    return nil
end

local function getScrollWdg_common(aMenu,widget,step)
    local menu = aMenu or currentMenu or nil
    if menu.settings.maxvisible ~= nil and #menu.items > menu.settings.maxvisible then
        if not menu[widget] then
            local arrow = capi.widget({type="imagebox"})
            arrow.image = capi.image(beautiful.menu_submenu_icon)
            local wb = getWibox()
            wb.bg = beautiful.bg_highlight
            wb:buttons( util.table.join(
                        button({ }, 1 , function() menu:scroll(step) end),
                        button({ }, 4 , function() menu:scroll(1) end),
                        button({ }, 5 , function() menu:scroll(-1) end)
                    ))
            local test2 = capi.widget({type="textbox"})
            test2.text = " "
            wb.widgets = {test2,arrow,test2,layout = widget2.layout.horizontal.flex}
            menu[widget] = {widget = wb, hidden = false, width = menu.settings.itemWidth, height = menu.settings.itemHeight}
            table.insert(menu.otherwdg,menu[widget])
        end
        return menu[widget]
    end
    return nil
end

local function getScrollUpWdg(aMenu)
    return getScrollWdg_common(aMenu,"scrollUpWdg",1)
end

local function getScrollDownWdg(aMenu)
    return getScrollWdg_common(aMenu,"scrollDownWdg",-1)
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
                    local retval = v(currentMenu)
                    if retval == false then
                        grabKeyboard = false
                    end
                    return retval
                end
            end
            
            if (currentMenu.keyShortcut[{mod,key}] or key == 'Return') and currentMenu.items[currentMenu.currentIndex] and currentMenu.items[currentMenu.currentIndex].button1 then
                currentMenu.items[currentMenu.currentIndex].button1()
                currentMenu:toggle(false)
            elseif key == 'Escape' or (key == 'Tab' and currentMenu.filterString == "") then 
                stopGrabber()
            elseif (key == 'Up' and currentMenu.downOrUp == 1) or (key == 'Down' and currentMenu.downOrUp == -1) then 
                currentMenu:rotate_selected(-1)
            elseif (key == 'Down' and currentMenu.downOrUp == 1) or (key == 'Up' and currentMenu.downOrUp == -1) then 
                currentMenu:rotate_selected(1)
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
  local subArrow  = capi.widget({type="imagebox"             } )
  subArrow.image  = capi.image ( beautiful.menu_submenu_icon   )
  
  local function createMenu(args)
    args          = args or {}
    local menu    = { settings = { 
    -- Settings
    --PROPERTY          VALUE               BACKUP VLAUE         
    itemHeight    = args.itemHeight    or beautiful.menu_height ,
    visible       = false                                       ,
    itemWidth     = args.width         or beautiful.menu_width  ,
    bg_normal     = args.bg_normal     or beautiful.bg_normal   ,
    bg_focus      = args.bg_focus      or beautiful.bg_focus    ,
    nokeyboardnav = args.nokeyboardnav or false                 ,
    noautohide    = args.noautohide    or false                 ,
    filter        = args.filter        or false                 ,
    showfilter    = args.showfilter    or false                 ,
    maxvisible    = args.maxvisible    or nil                   ,
    filterprefix  = args.filterprefix  or "<b>Filter:</b>"      ,
    autodiscard   = args.autodiscard   or false                 ,
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
    scrollUpWdg   = nil                                         ,
    scrollDownWdg = nil                                         ,
    otherwdg      = {}                                          ,
    filterHooks   = {}                                          ,
    downOrUp      = 1                                           ,
    startat       = 1                                           ,
    -------------------------------------------------------------
    }

    function menu:toggle(value)
      if self.settings.visible == false and value == false then return end
      
      self.settings.visible = value or not self.settings.visible
      if self.settings.visible == false then
        self:toggle_sub_menu(nil,true,false)
      end
      
      if menu.settings.maxvisible ~= nil and #menu.items > menu.settings.maxvisible then
          menu:scroll(0,true)
      end
      
      for v, i in next, self.items do
        if type(i) ~= "function" and type(v) == "number" then
          i.widget.visible = self.settings.visible and not i.hidden and not i.off
        end
      end
      
      self:emit((self.settings.visible == true) and "menu::show" or "menu::hide")
      
      for v, i in next, self.otherwdg do
          i.widget.visible = value
      end
      
      activateKeyboard(self)
      self:set_coords()
      
      if self.settings.autodiscard == true and self.settings.visible == false then
          self:discard()
      end
    end
    
    function menu:discard()
      for v, i in next, self.items do
          i:discard()
      end
      for v, i in next, self.otherwdg do
          --table.insert(discardedItems,i.widget) --TODO LEAK
      end
    end
    
    function menu:scroll(step,notoggle)
        menu.startat = menu.startat + step
        if menu.startat < 1 then
            menu.startat = 1
        elseif menu.startat > #menu.items - menu.settings.maxvisible then
            menu.startat = #menu.items - menu.settings.maxvisible
        end
        local counter = 1
        for v, i in next, self.items do
            local tmp = i.off
            i.off = ((counter < menu.startat) or (counter - menu.startat > menu.settings.maxvisible))
            if not tmp == i.off then self.hasChanged = true end
            counter = counter +1
        end
        if not notoggle then menu:toggle(true) end
    end
    
    function menu:rotate_selected(leap)
        if self.currentIndex + leap > #self.items then
            self.currentIndex = 1
        elseif self.currentIndex + leap < 1 then
            self.currentIndex = #self.items
        else
            self.currentIndex = self.currentIndex + leap
        end
        if self.items[self.currentIndex].hidden == true or self.items[self.currentIndex].off == true then
            self:rotate_selected((leap > 0) and 1 or -1)
        end
        self:clear_highlight()
        self:highlight_item(self.currentIndex) 
        return self.items[self.currentIndex]
    end

    function menu:emit(signName)
        for k,v in pairs(self.signalList[signName] or {}) do
            v(self)
        end
    end
    
    function menu:highlight_item(index)
        if self.items[index] ~= nil then
            if self.items[index].widget ~= nil then
                self.items[index]:hightlight(true)
            end
        end
    end
    
    function menu:clear_highlight()
        if #(self.highlighted) > 0 then
            for k, v in pairs(self.highlighted) do
                v:hightlight(false)
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
                local hidden = toExec(v,text)
                self.hasChanged = self.hasChanged or (hidden ~= v.hidden)
                v.hidden = hidden
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
      
      if self.hasChanged == true then
          self:emit("menu::changed")
      end
      
      self.hasChanged = false
      
      local yPadding = 0
      if #self.items*self.settings.itemHeight + self.settings["yPos"] > capi.screen[capi.mouse.screen].geometry.height then
          self.downOrUp = -1
          yPadding = -self.settings.itemHeight
      end
            
      local set_geometry = function(wdg)
        if not wdg then return end
        if type(wdg) ~= "function" and wdg.hidden == false and wdg.off ~= true then
            local geo = wdg.widget:geometry()
            wdg.x = self.settings.xPos
            wdg.y = self.settings.yPos+yPadding
            if wdg.widget.x ~= wdg.x or wdg.widget.y ~= wdg.y or wdg.widget.width ~= wdg.width or wdg.widget.height ~= wdg.height then
                wdg.widget.x = wdg.x
                wdg.widget.y = wdg.y
                wdg.widget.height = wdg.height
                wdg.widget.width = wdg.width
            end
            yPadding = yPadding + (wdg.height or self.settings.itemHeight)*self.downOrUp
            if type(wdg.subMenu) ~= "function" and wdg.subMenu ~= nil and wdg.subMenu.settings ~= nil then
                wdg.subMenu.settings.x = wdg.x+wdg.width
                wdg.subMenu.settings.y = wdg.y
            end
        end
      end
      
      local function addWdg(tbl,order)
        for i=(order == -1) and #tbl or 1, (order == -1) and 1 or #tbl, order do
            set_geometry(tbl[i])
        end
      end
      
      local headerWdg = {getScrollUpWdg(self)}
      local footerWdg = {getScrollDownWdg(self),getFilterWidget()}
      
      addWdg((self.downOrUp == -1) and footerWdg or headerWdg,self.downOrUp)
      for v, i in next, self.items do
        set_geometry(i)
      end
      addWdg((self.downOrUp == 1) and footerWdg or headerWdg,self.downOrUp)
    end
    
    function menu:set_width(width)
        self.settings.itemWidth = width
    end
    
    
    ---Possible signals = "menu::hide", "menu::show", "menu::resize"
    function menu:add_signal(name,func)
        self.signalList[name] = self.signalList[name] or {}
        table.insert(self.signalList[name],func)
    end
    
    function menu:add_key_hook(mod, key, event, func)
        if key and event and func then
            --table.insert(filterHooks,{, func = func})
            self.filterHooks[{key = key, event = event, mod = mod}] = func
        end
    end
    
    function menu:toggle_sub_menu(aSubMenu,hideOld,forceValue) --TODO dead code?
      if (self.subMenu ~= nil) and (hideOld == true) then
        self.subMenu:toggle_sub_menu(nil,true,false)
        self.subMenu:toggle(false)
      end
      
      if aSubMenu ~= nil and aSubMenu.toggle ~= nil then
        aSubMenu:toggle(forceValue or true)
      end
      self.subMenu = aSubMenu
    end
    
    local hideEverything = function () 
        menu:toggle(false)
        local aMenu = menu.settings.parent
        while aMenu ~= nil do
          aMenu:toggle(value)
          aMenu = aMenu.settings.parent
        end
        if currentMenu == menu then
            stopGrabber()
        end
      end
      
      local clickCommon = function (data, index)
          if data["button"..index] ~= nil then
              data["button"..index](self,data)
          end
          if menu.settings.noautohide == false and index ~= 4 and index ~= 5 then
            hideEverything()
          elseif menu.settings.maxvisible and ( index == 4 or index == 5 ) and #menu.items > menu.settings.maxvisible then
              menu:scroll((index == 4) and 1 or -1)
          end
      end
      
      function registerButton(aWibox,data)
        aWibox:buttons( util.table.join(
            button({ }, 1 , function() clickCommon(data,1 ) end),
            button({ }, 2 , function() clickCommon(data,2 ) end),
            button({ }, 3 , function() clickCommon(data,3 ) end),
            button({ }, 4 , function() clickCommon(data,4 ) end),
            button({ }, 5 , function() clickCommon(data,5 ) end),
            button({ }, 6 , function() clickCommon(data,6 ) end),
            button({ }, 7 , function() clickCommon(data,7 ) end),
            button({ }, 8 , function() clickCommon(data,8 ) end),
            button({ }, 9 , function() clickCommon(data,9 ) end),
            button({ }, 10, function() clickCommon(data,10) end)
        ))
      end
    
    function menu:add_item(args)
      local aWibox = getWibox()
      local data = {
        --PROPERTY       VALUE                BACKUP VALUE          
        text        = args.text        or ""                       ,
        hidden      = args.hidden      or false                    ,
        off         = false            or nil                      ,
        prefix      = args.prefix      or nil                      ,
        suffix      = args.suffix      or nil                      ,
        align       = args.align       or "left"                   ,
        prefixwidth = args.prefixwidth or nil                      ,
        suffixwidth = args.suffixwidth or nil                      ,
        prefixbg    = args.prefixbg    or nil                      ,
        suffixbg    = args.suffixbg    or nil                      ,
        width       = args.width       or self.settings.itemWidth  ,
        height      = args.height      or self.settings.itemHeight ,
        widget      = aWibox           or nil                      ,
        icon        = args.icon        or nil                      ,
        checked     = args.checked     or nil                      ,
        button1     = args.onclick     or args.button1             ,
        onmouseover = args.onmouseover or nil                      ,
        onmouseout  = args.onmouseout  or nil                      ,
        subMenu     = args.subMenu     or nil                      ,
        nohighlight = args.nohighlight or false                    ,
        noautohide  = args.noautohide  or false                    ,
        addwidgets  = args.addwidgets  or nil                      ,
        nofilter    = args.nofilter    or false                    ,
        bg          = args.bg          or beautiful.bg_normal      ,
        fg          = args.fg          or beautiful.fg_normal      ,
        x           = 0                                            ,
        y           = 0                                            ,
        widgets     = {}                                           ,
        pMenu       = self                                         ,
        ------------------------------------------------------------
      }
      for i=2, 10 do
          data["button"..i] = args["button"..i]
      end
      data.pMenu.hasChanged = true
      
      table.insert(data.pMenu.items, data)
      local pos = #data.pMenu.items
      data.pMenu:set_coords() --TODO needed?
      
      --Member functions
      function data:check(value)
          self.checked = (value == nil) and self.checked or ((value == false) and false or value)
          if self.checked == nil then return end
          self.widgets.checkbox = self.widgets.checkbox or capi.widget({type="imagebox"})
          self.widgets.checkbox.image = (self.checked == true) and checkbox.checked() or checkbox.unchecked() or nil
          self.widgets.checkbox.bg = beautiful.bg_focus
      end
      
      function data:hightlight(value)
          if not self.widget or value == nil then return end

          self.widget.bg = ((value == true) and menu.settings.bg_focus or data.bg) or ""
          if value == true then
              table.insert(menu.highlighted,self)
          end
      end
      
      function data:discard()
          table.insert(discardedItems,aWibox)
      end
      
      if data.subMenu ~= nil then
         subArrow2 = subArrow
         if type(data.subMenu) ~= "function" and data.subMenu.settings then
           data.subMenu.settings.parent = data.pMenu
         end
      else
        subArrow2 = nil
      end
      
      local function toggleItem(value)
          if data.nohighlight ~= true then
              data:hightlight(value)
          end
          if value == true then
            currentMenu = data.pMenu
            data.pMenu.currentIndex = pos
            if type(data.subMenu) ~= "function" then
              data.pMenu:toggle_sub_menu(data.subMenu,value,value)
            elseif data.subMenu ~= nil then
              local aSubMenu = data.subMenu()
              if not aSubMenu then return end
              aSubMenu.settings.x = data.x + aSubMenu.settings.itemWidth
              aSubMenu.settings.y = data.y
              aSubMenu.settings.parent = data.pMenu
              data.pMenu:toggle_sub_menu(aSubMenu,value,value)
            end
          end
      end
      
      local optionalWdgFeild = {"width","bg"}
      local createWidget = function(field,type2)
        local newWdg = (data[field] ~= nil) and capi.widget({type=type2 }) or nil
        if newWdg ~= nil and type2 == "textbox" then
            newWdg.text  = data[field]
        elseif newWdg ~= nil and type2 == "imagebox" and type(data[field]) == "string" then
            newWdg.image = capi.image(data[field])
        elseif newWdg ~= nil and type2 == "imagebox" then
            newWdg.image = data[field]
        end
        
        for k,v in pairs(optionalWdgFeild) do
            if newWdg ~= nil and data[field..v] ~= nil then
                newWdg[v] = data[field..v]
            end
        end
        return newWdg
      end

      data:check()
      
      data.widgets.prefix = createWidget("prefix", "textbox"  )
      data.widgets.suffix = createWidget("suffix", "textbox"  )
      data.widgets.wdg    = createWidget("text"  , "textbox"  )
      data.widgets.icon   = createWidget("icon"  , "imagebox" )
      
      aWibox.bg = data.bg
      data.widgets.wdg.text = "<span color=\"".. data.fg .."\" >"..(data.widgets.wdg.text or "").."</span>"
      data.widgets.wdg.align = data.align
      --aWibox.widgets = {{data.widgets.prefix,data.widgets.icon, {subArrow2,data.widgets.checkbox,data.widgets.suffix, layout = widget2.layout.horizontal.rightleft},data.addwidgets, layout = widget2.layout.horizontal.leftright,{data.widgets.wdg, layout = widget2.layout.horizontal.flex}}, layout = widget2.layout.vertical.flex }
      aWibox.widgets = {{data.widgets.prefix,data.widgets.icon,data.widgets.wdg, {subArrow2,data.widgets.checkbox,data.widgets.suffix, layout = widget2.layout.horizontal.rightleft},data.addwidgets, layout = widget2.layout.horizontal.leftright}, layout = widget2.layout.vertical.flex }
      
      registerButton(aWibox, data)
      
      aWibox:add_signal("mouse::enter", function() toggleItem(true) end)
      aWibox:add_signal("mouse::leave", function() toggleItem(false) end)
      aWibox.visible = false
      return data
    end
    
    function menu:add_existing_item(item)
        if not item then return end
        item.pMenu = menu
        registerButton(item.widget,item)
        table.insert(self.items, item)
    end
    
    function menu:add_wibox(wibox,args)
        local data     = {
            widget     = wibox,
            hidden     = false,
            width      = args.width      or self.settings.itemWidth  , 
            height     = args.height     or self.settings.itemHeight , 
            button1    = args.onclick    or args.button1             ,
            noautohide = args.noautohide or false                    ,
        }
        for i=2, 10 do
            data["button"..i] = args["button"..i]
        end
        function data:hightlight(value)
            
        end
        registerButton(wibox,data)
        table.insert(self.items, data)
    end

    function menu:add_wibox(m,args)
       m.isMenu = true
    end  

    return menu
  end
  
  return createMenu(args)
end
setmetatable(_M, { __call = function(_, ...) return new(...) end })
