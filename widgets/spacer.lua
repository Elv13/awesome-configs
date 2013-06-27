local setmetatable = setmetatable
local wibox = require("wibox")
local capi = { widget = widget }

local module={}

local data = {}

local function update()

end

local function new(args)
  local spacer  = wibox.widget.textbox()
  spacer:set_text(args.text or "")
  spacer.width = args.width or 0
  return spacer
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
