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
    self.pos = vec2(x - ox * sx, y - oy * sy)
    self.size = vec2(w, h)
    self.half_size = vec2(w * 0.5, h * 0.5)
    self.mouse = vec2()

    self.is_overlap = false
end

function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.mouse.x, self.mouse.y = mx, my
    self.is_overlap = intersect.aabb_point_overlap(self.pos, self.half_size, self.mouse)
end

function Button:draw()
    if self.is_overlap then
        love.graphics.setColor(1, 0, 0, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.draw(self.image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)

    if IS_DEV then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("line", self.pos.x, self.pos.y, self.size.x, self.size.y)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Button:mousepressed(mx, my, mb)
end

return Button
