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
    self.rad = self.image:getWidth() * 0.5
    self.alpha = opts.alpha or 1
end

function Bubble:update(dt)
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
