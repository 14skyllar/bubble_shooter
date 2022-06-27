local Dev = require("dev")

local Button = class({
    name = "Button"
})

function Button:new(image, x, y, r, sx, sy, ox, oy)
    self.image = image
    self.x, self.y = x, y
    self.r = r
    self.sx, self.sy = sx, sy
    self.ox, self.oy = ox, oy

    local w, h = image:getDimensions()
    w, h = w * sx, h * sy
    self.size = vec2(w, h)
    self.half_size = vec2(w * 0.5, h * 0.5)

    local rx = x - ox * sx
    local ry = y - oy * sy
    self.pos = vec2(rx, ry)
    self.center_pos = vec2(rx + (w * 0.5), ry + (h * 0.5))

    self.mouse = vec2()
    self.is_overlap = false
    self.fade = 0
    self.alpha = 1
    self.max_alpha = 1
    self.fade_amount = 1
    self.is_clickable = true
    self.is_hoverable = true
end

function Button:update(dt)
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
    self.is_overlap = intersect.point_aabb_overlap(self.mouse, self.center_pos, self.half_size)
end

function Button:draw()
    local sx, sy = self.sx, self.sy
    if self.is_hoverable and self.is_overlap then
        sx = sx + 0.1
        sy = sy + 0.1
    end

    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(self.image, self.x, self.y, self.r, sx, sy, self.ox, self.oy)

    if Dev.is_enabled then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("line", self.pos.x, self.pos.y, self.size.x, self.size.y)
        love.graphics.circle("fill", self.center_pos.x, self.center_pos.y, 2)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Button:mousepressed(mx, my, mb)
    if not self.is_clickable then return end
    if mb == 1 and self.is_overlap and self.on_clicked then
        self:on_clicked()
    end
end

function Button:mousereleased(mx, my, mb)
end

return Button
