local Dev = require("dev")

local window_width, window_height = love.graphics.getDimensions()
local l_start = vec2(0, 0)
local l_end = vec2(0, window_height)
local r_start = vec2(window_width, 0)
local r_end = vec2(window_width, window_height)

local Bubble = class({
    name = "Bubble"
})

function Bubble:new(opts)
    local width = opts.image:getWidth()
    self.image = opts.image
    self.x, self.y = opts.x, opts.y
    self.r = opts.r or 0
    self.sx = opts.sx or 1
    self.sy = opts.sy or 1
    self.ox = opts.ox or 0
    self.oy = opts.oy or 0
    self.main_oy = opts.main_oy or self.oy
    self.rad = width * self.sx * 0.5
    self.alpha = opts.alpha or 1
    self.vx, self.vy = 0, 0
    self.is_hit = false
    self.within_rad = self.rad * 2.5
    self.color_name = opts.color_name
end

function Bubble:check_collision(other, is_border)
    local a = vec2(self.x, self.y)
    local b = vec2(other.x, other.y)
    local rad_a = self.rad
    local rad_b = other.rad
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

function Bubble:check_match(other)
    if other == self then return false end
    return self.color_name == other.color_name, other.color_name == "powerup"
end

function Bubble:get_within_radius(bubbles)
    local within = {}
    for _, other in ipairs(bubbles) do
        if self ~= other then
            local is_same, is_powerup = self:check_match(other)
            if is_powerup then
                return true
            elseif is_same then
                local this_pos = vec2(self.x, self.y)
                local other_pos = vec2(other.x, other.y)
                local distance = this_pos:distance(other_pos)
                if distance <= self.within_rad then
                    table.insert(within, other)
                end
            end
        end
    end
    return within
end

function Bubble:update(dt)
    if self.is_dead then return end
    if self.is_hit then return end

    local a = vec2(self.x, self.y)
    local rad = self.rad * self.sx

    local left = intersect.circle_line_collide(a, rad, l_start, l_end, 1)
    local right = intersect.circle_line_collide(a, rad, r_start, r_end, 1)

    if left or right then
        self.vx = -self.vx
    end

    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    local threshold = self.rad * 2
    self.is_dead = (self.x < -threshold) or (self.x > window_width + threshold) or
        (self.y < -threshold) or (self.y > window_height + threshold)

    if self.y >= love.graphics.getHeight() * 1.25 then
        self.is_dead = true
    end
end

function Bubble:draw()
    love.graphics.setColor(1, 1, 1, self.alpha)

    love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)

    if Dev.is_enabled then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.circle("line", self.x, self.y, self.rad)
        love.graphics.circle("fill", self.x, self.y, 2)
        love.graphics.circle("line", self.x, self.y, self.within_rad)
    end
end

return Bubble
