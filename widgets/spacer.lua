local setmetatable = setmetatable
local wibox = require("wibox")
local capi = { widget = widget }

local module={}

local data = {}

local function update()

end

local function fit(self, context, width, height)
    local w, h = wibox.widget.textbox.fit(self, context, width, height)
    return self._width or w, h
end

local function new(args)
  local spacer  = wibox.widget.textbox()
  spacer.fit = fit
  spacer:set_text(args.text or "")
  spacer._width = args.width or 0
  return spacer
end


return setmetatable(module, { __call = function(_, ...) return new(...) end })
