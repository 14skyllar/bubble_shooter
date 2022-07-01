local Button = require("button")
local Resources = require("resources")
local Utils = require("utils")

local Game = class({
    name = "Game"
})

function Game:new(difficulty, level, hearts)
    local id = self:type()
    self.difficulty = difficulty
    self.level = level
    self.hearts = hearts or 3
    self.max_hearts = 3
    self.time = 0

    self.images_common = Utils.load_images(id)

    local diff = string.upper(difficulty:sub(1, 1)) .. difficulty:sub(2)
    self.images = Utils.load_images(diff)
    self.sources = Utils.load_sources(id)

    self.border = {}
    self.objects = {}
    self.objects_order = {
        "score_holder", "life_holder", "time_holder", "label",
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

    local bubble_width = self.images_common.bubble:getWidth()
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

    local label_width, label_height = self.images.label:getDimensions()
    local label_scale = 0.8
    self.objects.label = Button({
        image = self.images.label,
        x = gap, y = window_height - gap,
        sx = label_scale, sy = label_scale,
        ox = 0, oy = label_height,
        is_hoverable = false, is_clickable = false
    })
end

function Game:update(dt)
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

    for _, bubble in ipairs(self.border) do
        love.graphics.draw(bubble.image, bubble.x, bubble.y, 0, bubble.scale, bubble.scale)
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
