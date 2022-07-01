local Button = require("button")
local Resources = require("resources")
local Utils = require("utils")

local Game = class({
    name = "Game"
})

local rows = {
    easy = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13},
    medium = {4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17},
    hard = {4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
}

function Game:new(difficulty, level, hearts)
    local id = self:type()
    self.difficulty = difficulty
    self.level = level
    self.hearts = hearts or 3
    self.max_hearts = 3
    self.time = 0
    self.start = false
    self.rows = rows[difficulty][level]
    assert(self.rows ~= nil and self.rows > 0)

    local diff = string.upper(difficulty:sub(1, 1)) .. difficulty:sub(2)
    self.images_common = Utils.load_images(id)
    self.images = Utils.load_images(diff)
    self.sources = Utils.load_sources(id)

    self.border = {}
    self.objects = {}
    self.bubbles = {}
    self.objects_order = {
        "score_holder", "life_holder", "time_holder", "label", "settings",
        "shooter", "base", "shuffle",
        "txt_ready_go",
    }

    for i = 1, self.max_hearts do table.insert(self.objects_order, "heart_" .. i) end
end

function Game:load()
    print(self.difficulty, self.level)
    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local half_window_height = window_height * 0.5

    local score_holder_width, score_holder_height = self.images_common.score_holder:getDimensions()
    local gap = 8
    local ui_scale = 0.35
    self.objects.score_holder = Button({
        image = self.images_common.score_holder,
        x = gap, y = gap,
        sx = ui_scale, sy = ui_scale,
        ox = 0, oy = 0,
        is_hoverable = false, is_clickable = false,
        text = "Score: ", text_color = {1, 1, 1},
        font = Resources.game_font,
        tx = gap * 3,
        ty = gap + score_holder_height * 0.5 * ui_scale,
        toy = Resources.game_font:getHeight() * 0.5
    })

    local life_holder_width, life_holder_height = self.images_common.life_holder:getDimensions()
    self.objects.life_holder = Button({
        image = self.images_common.life_holder,
        x = self.objects.score_holder.x + score_holder_width * self.objects.score_holder.sx + gap,
        y = gap,
        sx = 0.5, sy = 0.5,
        ox = 0, oy = 0,
        is_hoverable = false, is_clickable = false,
    })

    local heart_width, heart_height = self.images.heart:getDimensions()
    local heart_scale = 0.35

    for i = 1, self.max_hearts do
        local image_heart
        if i <= self.hearts then
            image_heart = self.images.heart
        else
            image_heart = self.images_common.heart_empty
        end

        self.objects["heart_" .. i] = Button({
            image = image_heart,
            x = self.objects.life_holder.x + gap + (heart_width * heart_scale * (i - 1)),
            y = self.objects.life_holder.y + life_holder_height * 0.5 * self.objects.life_holder.sy,
            sx = heart_scale, sy = heart_scale,
            ox = 0, oy = heart_height * 0.5,
            is_hoverable = false, is_clickable = false,
        })
    end

    local time_holder_height = self.images_common.time_holder:getHeight()
    local thx = self.objects.life_holder.x + life_holder_width * self.objects.life_holder.sx + gap
    self.objects.time_holder = Button({
        image = self.images_common.time_holder,
        x = thx, y = gap,
        sx = ui_scale, sy = ui_scale,
        ox = 0, oy = 0,
        is_hoverable = false, is_clickable = false,
        text = string.format("Time: %.2f", self.time),
        text_color = {1, 1, 1},
        font = Resources.game_font,
        tx = thx + gap * 2,
        ty = gap + score_holder_height * 0.5 * ui_scale,
        toy = Resources.game_font:getHeight() * 0.5
    })

    local bubble_width, bubble_height = self.images_common.bubble:getDimensions()
    local bubble_scale = 0.4
    local bubble_count = math.floor(window_width/(bubble_width * bubble_scale)) + 1
    local bubble_y = (self.objects.time_holder.y + time_holder_height * ui_scale) + (gap * 3)
    for i = 1, bubble_count do
        self.border[i] = {
            image = self.images_common.bubble,
            x = (i - 1) * bubble_width * bubble_scale, y = bubble_y,
            scale = bubble_scale,
        }
    end

    local label_height = self.images.label:getHeight()
    local label_scale = 0.8
    self.objects.label = Button({
        image = self.images.label,
        x = gap, y = window_height - gap,
        sx = label_scale,
        sy = label_scale + 0.1,
        ox = 0, oy = label_height,
        is_hoverable = false, is_clickable = false
    })

    local settings_width, settings_height = self.images.settings:getDimensions()
    local settings_scale = 0.5
    self.objects.settings = Button({
        image = self.images.settings,
        x = window_width - gap, y = window_height - gap,
        sx = settings_scale, sy = settings_scale,
        ox = settings_width, oy = settings_height,
        is_hoverable = false, is_clickable = false,
    })

    local base_width, base_height = self.images_common.base:getDimensions()
    local base_scale = 0.25
    self.objects.base = Button({
        image = self.images_common.base,
        x = half_window_width,
        y = (window_height - gap) - (label_height * label_scale) - gap,
        sx = base_scale, sy = base_scale,
        ox = base_width * 0.5, oy = base_height,
        is_hoverable = false, is_clickable = false,
    })

    local shooter_width, shooter_height = self.images.shooter:getDimensions()
    local shooter_scale = 0.25
    self.objects.shooter = Button({
        image = self.images.shooter,
        x = half_window_width,
        y = self.objects.base.y - base_height * base_scale,
        sx = shooter_scale, sy = shooter_scale,
        ox = shooter_width * 0.5, oy = shooter_height * 0.75,
        is_hoverable = false, is_clickable = false,
    })

    local txt_ready_go_width, txt_ready_go_height = self.images_common.text_ready_go:getDimensions()
    local txt_ready_go_scale = (window_width - (gap * 2))/txt_ready_go_width

    self.objects.txt_ready_go = Button({
        image = self.images_common.text_ready_go,
        x = half_window_width,
        y = half_window_height,
        sx = txt_ready_go_scale, sy = txt_ready_go_scale,
        ox = txt_ready_go_width * 0.5, oy = txt_ready_go_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0
    })

    local shuffle_width, shuffle_height = self.images_common.shuffle:getDimensions()
    local shuffle_scale = 1.25
    self.objects.shuffle = Button({
        image = self.images_common.shuffle,
        x = gap * 6,
        y = self.objects.base.y - shuffle_height,
        sx = shuffle_scale, sy = shuffle_scale,
        ox = shuffle_width * 0.5, oy = shuffle_height * 0.5,
        is_clickable = false, is_hoverable = false
    })

    local fade_in_sec = 2
    local fade_out_sec = 1

    self.ready_timer = timer(fade_in_sec, function(progress)
        local txt_ready_go = self.objects.txt_ready_go
        txt_ready_go.alpha = progress
    end, function()
        self.ready_fade_timer = timer(fade_out_sec, function(progress)
            local txt_ready_go = self.objects.txt_ready_go
            txt_ready_go.alpha = 1 - progress
        end, function()
            self.start = true
            self.objects.shuffle.is_hoverable = true
            self.objects.shuffle.is_clickable = true
            self.objects.settings.is_clickable = true
            self.objects.settings.is_hoverable = true
        end)
    end)

    local rad = 16
    for i = 1, self.rows do
        self.bubbles[i] = {
            x = gap + rad * 2 * (i - 1),
            y = bubble_y + bubble_height * bubble_scale + rad,
            rad = rad,
        }
    end
end

function Game:update(dt)
    if not self.start then
        self.ready_timer:update(dt)
        if self.ready_fade_timer then
            self.ready_fade_timer:update(dt)
        end
    end

    if self.start then
        local shooter = self.objects.shooter
        local mx, my = love.mouse.getPosition()
        local dx = shooter.x - mx
        local dy = shooter.y - my
        local r = -math.atan2(dx, dy)
        r = mathx.clamp(r, -0.9, 0.9)
        self.objects.shooter.r = r
    end

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:update(dt)
        end
    end
end

function Game:draw()
    love.graphics.setColor(1, 1, 1, 1)

    local window_width, window_height = love.graphics.getDimensions()
    local bg_width, bg_height = self.images_common.background:getDimensions()
    local bg_scale_x = window_width/bg_width
    local bg_scale_y = window_height/bg_height
    love.graphics.draw(
        self.images_common.background,
        0, 0, 0,
        bg_scale_x, bg_scale_y
    )

    for _, border in ipairs(self.border) do
        love.graphics.draw(border.image, border.x, border.y, 0, border.scale, border.scale)
    end

    for _, bubble in ipairs(self.bubbles) do
        love.graphics.circle("line", bubble.x, bubble.y, bubble.rad)
    end

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:draw()
        end
    end
end

function Game:mousepressed(mx, my, mb)
end

function Game:mousereleased(mx, my, mb)
end

function Game:key(key)
end

return Game
