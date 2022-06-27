local Slider = class({
    name = "Slider"
})

function Slider:new(opts)
    self.current_value = opts.current_value
    self.max_value = opts.max_value
    self.x, self.y = opts.x, opts.y
    self.width, self.height = opts.width, opts.height
    self.knob_radius = opts.knob_radius

    self.alpha = opts.alpha or 1
    self.max_alpha = opts.max_alpha or 1
    self.fade = 0
    self.fade_amount = opts.fade_amount or 1
    self.bg_color = opts.bg_color or {0, 0, 0}
    self.line_color = opts.line_color or {1, 1, 1}
    self.knob_color = opts.knob_color or {1, 1, 1}
    self.is_knob_hovered = false

    self.mouse = vec2()
    self.hold = false

    local value = self.current_value/self.max_value
    local kx = self.x + value * self.width
    local ky = self.y + self.height * 0.5
    self.knob_pos = vec2(kx, ky)
end

function Slider:update(dt)
    if self.fade ~= 0 then
        self.alpha = self.alpha + self.fade_amount * self.fade * dt

        if self.alpha <= 0 then
            self.fade = 0
        elseif self.alpha >= self.max_alpha then
            self.fade = 0
        end
    end

    local mx, my = love.mouse.getPosition()
    self.mouse.x, self.mouse.y = mx, my
    self.is_knob_hovered = intersect.point_circle_overlap(self.mouse, self.knob_pos, self.knob_radius)

    if self.hold then
        local new_value = mx/(self.x + self.width)
        self.current_value = mathx.clamp(new_value, 0, self.max_value)

        if self.on_dragged then
            self:on_dragged(self.current_value)
        end
    end

    local value = self.current_value/self.max_value
    local kx = self.x + value * self.width
    self.knob_pos.x = kx
end

function Slider:draw()
    local r, g, b = unpack(self.bg_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    local value = self.current_value/self.max_value
    local lr, lg, lb = unpack(self.line_color)
    love.graphics.setColor(lr, lg, lb, self.alpha)
    love.graphics.rectangle("fill", self.x, self.y, value * self.width, self.height)

    local kr, kg, kb = unpack(self.knob_color)

    love.graphics.setColor(kr, kg, kb, self.alpha)
    local rad = self.knob_radius
    if self.is_knob_hovered then
        rad = rad + 4
    end
    love.graphics.circle("fill", self.knob_pos.x, self.knob_pos.y, rad)
end

function Slider:mousepressed(mx, my, mb)
    if mb == 1 and self.is_knob_hovered then
        self.hold = true
    end
end

function Slider:mousereleased(mx, my, mb)
    if mb == 1 and self.hold then
        self.hold = false
    end
end

return Slider
