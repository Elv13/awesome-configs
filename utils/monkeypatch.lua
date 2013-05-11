--Function to set textbox width and height
wibox.widget.textbox.set_fixed_width = function(tb,width)
    tb.fit = function(box,w,h)
        local w,h = wibox.widget.textbox.fit(box,w,h) return math.max(pctwidth,w),h
    end
end