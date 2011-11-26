--This module handle client groups with a titlebar
local setmetatable = setmetatable
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local util         = require( "awful.util"   )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.subTopLevel")

function new(screen, args) 
   local data = {}
   data.titlebar = nil
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })