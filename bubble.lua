local Dev = require("dev")

local Bubble = class({
    name = "Bubble"
})

function Bubble:new(opts)
    self.image = opts.image
    self.x, self.y = opts.x, opts.y
    self.r = opts.r or 0
    self.sx = opts.sx or 1
    self.sy = opts.sy or 1
    self.ox = opts.ox or 0
    self.oy = opts.oy or 0
    self.main_oy = opts.main_oy or self.oy
    self.rad = self.image:getWidth() * self.sx * 0.25
    self.alpha = opts.alpha or 1
    self.vx, self.vy = 0, 0
    self.is_hit = false
end

function Bubble:check_collision(other, is_border)
    local a = vec2(self.x, self.y)
    local b = vec2(other.x, other.y)
    local rad_a = self.rad * self.sx
    local rad_b = other.rad * other.sx
    if is_border then
        rad_b = other.rad
    end
    self.is_hit = intersect.circle_circle_overlap(a, rad_a, b, rad_b)

    if self.is_hit then
        local excess = intersect.circle_circle_collide(a, rad_a, b, rad_b)
        self.x = self.x + excess.x
        self.y = self.y + excess.y
    end

    return self.is_hit
end

function Bubble:update(dt)
    if self.is_dead then return end
    if self.is_hit then return end
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    local window_width, window_height = love.graphics.getDimensions()
    local threshold = self.rad * 2
    self.is_dead = (self.x < -threshold) or (self.x > window_width + threshold) or
        (self.y < -threshold) or (self.y > window_height + threshold)
end

function Bubble:draw()
    love.graphics.setColor(1, 1, 1, self.alpha)

    love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)

    if Dev.is_enabled then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.circle("line", self.x, self.y, self.rad * self.sx)
        love.graphics.circle("fill", self.x, self.y, 2)
    end
end

return Bubble
