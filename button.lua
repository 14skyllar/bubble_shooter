local Anim8 = require("libs.anim8.anim8")
local Dev = require("dev")

local Button = class({
    name = "Button"
})

function Button:new(opts)
    self.image = opts.image
    self.x, self.y = opts.x, opts.y
    self.r = opts.r or 0
    self.sx, self.sy = opts.sx or 1, opts.sy or 1
    self.ox, self.oy = opts.ox or 0, opts.oy or 0
    self.sx_dt = opts.sx_dt or 0.1
    self.sy_dt = opts.sy_dt or 0.1

    self.animated = opts.animated
    if self.animated then
        local g = Anim8.newGrid(self.animated.w, self.animated.h, self.image:getDimensions())
        self.anim8 = Anim8.newAnimation(
            g(self.animated.g, 1),
            self.animated.speed,
            self.animated.on_loop
        )

        if self.animated.start_frame then
            self.anim8:gotoFrame(self.animated.start_frame)
        end
    end

    local w, h = self.image:getDimensions()
    w, h = w * self.sx, h * self.sy
    self.size = vec2(w, h)
    self.half_size = vec2(w * 0.5, h * 0.5)

    local rx = self.x - self.ox * self.sx
    local ry = self.y - self.oy * self.sy
    self.pos = vec2(rx, ry)
    self.center_pos = vec2(rx + (w * 0.5), ry + (h * 0.5))

    self.mouse = vec2()
    self.is_overlap = false
    self.alpha = opts.alpha or 1
    self.max_alpha = opts.max_alpha or 1
    self.is_clickable = true
    self.is_hoverable = true
    self.on_click_sound = opts.on_click_sound

    if opts.is_clickable ~= nil then
        self.is_clickable = opts.is_clickable
    end
    if opts.is_hoverable ~= nil then
        self.is_hoverable = opts.is_hoverable
    end

    self.text_color = opts.text_color or {1, 1, 1}
    self.text_alpha = opts.text_alpha
    self.text = opts.text
    self.font = opts.font
    self.tx = opts.tx or self.x
    self.ty = opts.ty or self.y
    self.tox = opts.tox or 0
    self.toy = opts.toy or 0
    self.tsx = opts.tsx or 1
    self.tsy = opts.tsy or 1

    self.is_printf = opts.is_printf
    self.limit = opts.limit
    self.align = opts.align or "left"

    self.value = opts.value
end

function Button:update_y(y)
    self.y = y
    self.pos.y = y

    local h = self.image:getHeight() * self.sy
    local ry = self.y - self.oy * self.sy
    self.center_pos.y = ry + (h * 0.5)
end

function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.mouse.x, self.mouse.y = mx, my
    self.is_overlap = intersect.point_aabb_overlap(self.mouse, self.center_pos, self.half_size)

    if self.anim8 then
        self.anim8:update(dt)
    end
end

function Button:draw()
    local sx, sy = self.sx, self.sy
    if (self.is_hoverable and self.is_overlap) or self.is_hovered then
        sx = sx + self.sx_dt
        sy = sy + self.sy_dt
    end

    love.graphics.setColor(1, 1, 1, self.alpha)

    if self.anim8 then
        self.anim8:draw(self.image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
    else
        love.graphics.draw(self.image, self.x, self.y, self.r, sx, sy, self.ox, self.oy)
    end

    if self.text then
        local tmp_font
        if self.font then
            tmp_font = love.graphics.getFont()
            love.graphics.setFont(self.font)
        end

        local tsx, tsy = self.tsx, self.tsy
        if self.is_hoverable and self.is_overlap then
            tsx = tsx + self.sx_dt
            tsy = tsy + self.sy_dt
        end

        local tr, tg, tb = unpack(self.text_color)
        love.graphics.setColor(tr, tg, tb, self.text_alpha or self.alpha)

        if not self.is_printf then
            love.graphics.print(self.text, self.tx, self.ty, 0, tsx, tsy, self.tox, self.toy)
        else
            love.graphics.printf(self.text, self.tx, self.ty, self.limit, self.align,
             0, tsx, tsy, self.tox, self.toy)
        end

        if self.font then
            love.graphics.setFont(tmp_font)
        end
    end

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
        if self.on_click_sound then
            self.on_click_sound:play()
            self.on_click_sound:setLooping(false)
        end
        self:on_clicked()
        return true
    end
end

function Button:mousereleased(mx, my, mb)
end

return Button
