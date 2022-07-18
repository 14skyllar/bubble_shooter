local Slider = class({
    name = "Slider"
})

function Slider:new(opts)
    self.knob_image = opts.knob_image
    self.bg_image = opts.bg_image

    self.sx = opts.sx or 1
    self.sy = opts.sy or 1
    self.ox = opts.ox or 0
    self.oy = opts.oy or 0

    self.current_value = opts.current_value
    self.max_value = opts.max_value
    self.x, self.y = opts.x, opts.y
    self.width, self.height = opts.width, opts.height
    self.knob_radius = self.knob_image:getHeight() * 0.5

    self.alpha = opts.alpha or 1
    self.max_alpha = opts.max_alpha or 1
    self.fade = 0
    self.fade_amount = opts.fade_amount or 1
    self.is_knob_hovered = false

    self.mouse = vec2()
    self.hold = false

    local value = self.current_value/self.max_value
    local bg_width = self.bg_image:getWidth()
    self.base_kx = self.x - self.ox * 0.25
    self.kw = bg_width * self.sx * 0.7
    local kx = self.base_kx + value * self.kw
    local ky = self.y
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
        local new_value = mx/(self.base_kx + self.kw)
        self.current_value = mathx.clamp(new_value, 0, self.max_value)

        if self.on_dragged then
            self:on_dragged(self.current_value)
        end
    end

    local value = self.current_value/self.max_value
    self.knob_pos.x = self.base_kx + value * self.kw
end

function Slider:draw()
    local value = self.current_value/self.max_value
    local w = value * self.kw

    love.graphics.setColor(72/255, 181/255, 175/255, self.alpha)
    love.graphics.rectangle(
        "fill",
        self.base_kx,
        self.y - self.height * 0.5,
        w,
        self.height,
        16
    )

    love.graphics.draw(self.bg_image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)

    local knob_scale = 1
    if self.is_knob_hovered then
        knob_scale = knob_scale + 0.1
    end

    love.graphics.setColor(1, 1, 1, self.alpha)
    local knob_width, knob_height = self.knob_image:getDimensions()
    love.graphics.draw(
        self.knob_image,
        self.knob_pos.x,
        self.knob_pos.y,
        0,
        knob_scale, knob_scale,
        knob_width * 0.5,
        knob_height * 0.5
    )
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
