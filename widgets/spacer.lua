local setmetatable = setmetatable
local wibox = require("wibox")
local capi = { widget = widget }

module("widgets.spacer")

local data = {}

function update()

end

function new(args)
  local spacer  = wibox.widget.textbox()
  spacer:set_text(args.text or "")
  spacer.width = args.width or 0
  return spacer
end


setmetatable(_M, { __call = function(_, ...) return new(...) end })
