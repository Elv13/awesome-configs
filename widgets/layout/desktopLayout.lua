local setmetatable = setmetatable
local table        = table
local type         = type
local ipairs       = ipairs
local print        = print
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local config       = require( "forgotten"       )
local util         = require( "awful.util"   )
local wibox        = require( "awful.wibox"  )
local widget       = require( "awful.widget" )

local capi = { image  = image              ,
               widget = widget             ,
               mouse  = mouse              ,
               screen = screen             ,
               mousegrabber = mousegrabber }

local idCnt        = 0
local columns      = {}
local screens      = {}
local activeCol    = {}
local activeScreen = 1
local padding      = {}
local reservedItem = {}
local autoItems    = {}

local module = {}

local function usableSpace(s)
    local h = capi.screen[(#capi.screen >= s) and s or 1].geometry.height - (padding.top or 0)-(padding.bottom or 0)
    local w = capi.screen[(#capi.screen >= s) and s or 1].geometry.width  - (padding.left or 0)-(padding.left or 0)
    return {width = w, height = h}
end

local function new(args)
    padding.top    = args.padTop     or args.padDef or 0
    padding.bottom = args.padBottom  or args.padDef or 0
    padding.left   = args.padLeft    or args.padDef or 0
    padding.right  = args.padRight   or args.padDef or 0
    padding.item   = args.padItem    or 35
    for i=1, #(capi.screen)+1 do
        screens[i]          = {}
        screens[i].freeW    = usableSpace(i).width
        columns[i]          = {}
        columns[i][1]       = {}
        columns[i][1].freeH = usableSpace(i).height
        columns[i][1].width = 0
        activeCol[i]        = 1
    end
end

function registerSpace(args)
    table.insert(autoItems, args)
end

local function shiftyBy(s,x,y,width,height)
    local newX,newY = 0,0
    for k,v in ipairs(reservedItem) do
        if v.screen == s then
            if not (v.x+v.width < x  or x+width < v.x ) then
                newX = v.x+v.width
            end
            if not (v.y+v.height < y or y+height < v.y) then
                newY = v.y+v.height
            end
        end
    end
    return {x=newX, y=newY}
end

local function addCol(screen)
    activeCol[screen] = activeCol[screen] + 1
    columns[screen][activeCol[screen]]       = {}
    columns[screen][activeCol[screen]].width = 0
    columns[screen][activeCol[screen]].freeH = usableSpace(screen).height
end

local function getCurrentX(s)
    local xpos = 0
    for i=1, (activeCol[s] or 2)-1 do
        xpos = xpos + columns[s or 1][i].width
    end
    return xpos
end

local function registerSpace_real()
    for k,v in ipairs(autoItems) do
        
        local available = shiftyBy(v.screen,getCurrentX(v.screen),usableSpace(v.screen).height-columns[v.screen][activeCol[v.screen]].freeH,v.width,v.height)
        while available.x ~= 0 and available.y ~= 0 do
            columns[v.screen][activeCol[v.screen]].freeH = columns[v.screen][activeCol[v.screen]].freeH - available.x
            if columns[v.screen][activeCol[v.screen]].freeH - v.height - padding.item < 0 then
                addCol(v.screen)
            end
            available = shiftyBy(v.screen,getCurrentX(v.screen),usableSpace(v.screen).height-columns[v.screen][activeCol[v.screen]].freeH,v.width,v.height)
        end
        
        if columns[v.screen][activeCol[v.screen]].freeH - v.height - padding.item < 0 then
            addCol(v.screen)
        end
        
        if columns[v.screen][activeCol[v.screen]].width + padding.item < v.width then
            columns[v.screen][activeCol[v.screen]].width = v.width + padding.item
        end
        
        v.x = padding.left + getCurrentX(v.screen)
        v.y = padding.top + usableSpace(v.screen).height-columns[v.screen][activeCol[v.screen]].freeH
        columns[v.screen][activeCol[v.screen]].freeH = columns[v.screen][activeCol[v.screen]].freeH - v.height - padding.item
    end
end

function reserveSpace(args)
    table.insert(reservedItem,args)
end

local function genId()
    idCnt = idCnt + 1
    return "tmp_"..idCnt
end

function addCornerWidget(wdg,screen,corner,args)
    local wdgSet = addWidget(wdg,args,true)
    wdgSet.x     = capi.screen[(screen <= capi.screen.count()) and screen or 1].geometry.x+usableSpace(screen).width - wdgSet.width
    wdgSet.y     = 30--usableSpace(screen).height - wdgSet.height
end

function module.addWidget(wdg,args,reserved)
    local args = args or {}
    local wdgSet = {}
    local wb
    if     args.type == "wibox"  then
        wb = wdg
    elseif type(wdg) == "widget" then
        local aWb       = wibox({position="free"})
        wdgSet.height   = (wdg.height ~=0) and wdg.height or nil
        wdgSet.width    = (wdg.width  ~=0) and wdg.width  or nil
        aWb.widgets     = {wdg, layout = widget.horizontal.leftrightcached}
        wb = aWb
    end
    local saved = {}
    
    if args.id and config.desktop.position[args.id] then
        saved.height    = config.desktop.position[args.id].height or nil
        saved.width     = config.desktop.position[args.id].width  or nil
        saved.x         = config.desktop.position[args.id].x      or nil
        saved.y         = config.desktop.position[args.id].y      or nil
    end
    
    wdgSet.id           = args.id           or genId()
    wdgSet.height       = saved.height      or args.height           or wdgSet.height or wb:geometry().height
    wdgSet.width        = saved.width       or args.width            or wdgSet.width  or wb:geometry().width
    wdgSet.allowDrag    = args.allowDrag    or config.allowDrag or true
    wdgSet.opacity      = args.opacity      or wb.opacity
    wdgSet.transparency = args.transparency or wb.transparency
    wdgSet.bg           = args.bg           or wb.bg
    wdgSet.bg_image     = args.bg_image     or wb.bg_image
    wdgSet.bg_resize    = args.bg_resize    or wb.bg_resize
    wdgSet.screen       = args.screen       or 1
    wdgSet.button1      = args.button1      or args.onclick
    wdgSet.wibox        = wb
    
    for i=2,10 do
        wdgSet["button"..i] = args["button"..i]
    end
    
    wb:buttons(util.table.join(
        button({ }, 1 ,function (tab)
                            if wdgSet.allowDrag == true then
                                local curX = capi.mouse.coords().x
                                local curY = capi.mouse.coords().y
                                local moved = false
                                capi.mousegrabber.run(function(mouse)
                                    if mouse.buttons[1] == false then 
                                        if moved == false then
                                            wdgSet.button1()
                                        end
                                        capi.mousegrabber.stop()
                                        return false 
                                    end
                                    if mouse.x ~= curX and mouse.y ~= curY then
                                        local height = wb:geometry().height
                                        local width  = wb:geometry().width
                                        wb.x = mouse.x-(width/2)
                                        wb.y = mouse.y-(height/2)
                                        moved = true
                                    end
                                    return true
                                end,"fleur")
                            else
                                wdgSet.button1()
                            end
                        end),
        button({ }, 2 ,function (tab) if wdgSet.button2  then wdgSet.button2 () end end),
        button({ }, 3 ,function (tab) if wdgSet.button3  then wdgSet.button3 () end end),
        button({ }, 4 ,function (tab) if wdgSet.button4  then wdgSet.button4 () end end),
        button({ }, 5 ,function (tab) if wdgSet.button5  then wdgSet.button5 () end end),
        button({ }, 6 ,function (tab) if wdgSet.button6  then wdgSet.button6 () end end),
        button({ }, 7 ,function (tab) if wdgSet.button7  then wdgSet.button7 () end end),
        button({ }, 8 ,function (tab) if wdgSet.button8  then wdgSet.button8 () end end),
        button({ }, 9 ,function (tab) if wdgSet.button9  then wdgSet.button9 () end end),
        button({ }, 10,function (tab) if wdgSet.button10 then wdgSet.button10() end end)
    ))
    
    if saved.x or saved.y or reserved == true then
        wdgSet.x        = saved.x
        wdgSet.y        = saved.y
        reserveSpace (wdgSet)
    else
        registerSpace(wdgSet)
    end
    return wdgSet
end

function module.draw()
    registerSpace_real()
    for k,v in ipairs(reservedItem) do
        v.wibox.x = v.x
        v.wibox.y = v.y
        v.wibox.width = v.width
        v.wibox.height=v.height
    end
    for k,v in ipairs(autoItems) do
        v.wibox.x = v.x
        v.wibox.y = v.y
        v.wibox.width = v.width
        v.wibox.height=v.height
    end
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
