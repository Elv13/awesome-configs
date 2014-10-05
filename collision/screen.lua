local capi = {screen=screen,client=client}
local wibox = require("wibox")
local awful = require("awful")
local cairo        = require( "lgi"          ).cairo
local color        = require( "gears.color"  )
local beautiful    = require( "beautiful"    )
local surface      = require( "gears.surface" )
local pango = require("lgi").Pango
local pangocairo = require("lgi").PangoCairo
local capi = {screen=screen,mouse=mouse}
local module = {}

local wiboxes ={}
local bgs = {}
local size = 60

local function init_wiboxes()
  for s=1, capi.screen.count() do
    print("Create",s)
    local wa = capi.screen[s].geometry
    local w = wibox{}-- x=wa.x+wa.width/2-size/2, y=wa.y+wa.height/2-size/2, width=size, height=size, ontop=true}
    w.width  = 50
    w.height = 50
    w.x=wa.x+wa.width/2-size/2
    w.y=wa.y+wa.height/2-size/2
    w.ontop = true
    wiboxes[s] = w
    
    local bg,tb = wibox.widget.background(),wibox.widget.textbox("1")
    tb:set_valign("center")
    tb:set_align("center")
    bg:set_widget(tb)
    bg:set_bg(beautiful.bg_alternate or beautiful.bg_normal)
    bgs[s] = bg
    
    w:set_widget(bg)
    w.visible = true
    
    tb:set_text("foo")
  end
end

local function next_screen(left)
  local current = capi.mouse.screen
  local next_scr = nil
  if left then
    next_scr = current== 1 and capi.screen.count() or current-1
  else
    next_scr = current==capi.screen.count() and 1 or current+1
  end
  bgs[current]:set_bg(beautiful.bg_alternate or beautiful.bg_normal)
  bgs[next_scr]:set_bg(beautiful.bg_urgent)
end

function module.display()
  if #wiboxes == 0 then
    init_wiboxes()
  end
  print("DISPLAT")
end

function module.hide()
  print("HIDE")
end

function module.reload()
  print("RELOAD")
end

return module
-- kate: space-indent on; indent-width 2; replace-tabs on;