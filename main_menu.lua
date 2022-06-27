local Button = require("button")
local Slider = require("slider")
local UserData = require("user_data")
local Utils = require("utils")

local MainMenu = class({
    name = "MainMenu"
})

function MainMenu:new()
    local id = self:type()
    self.images = Utils.load_images(id)
    self.sources = Utils.load_sources(id)

    self.objects = {}
    self.objects_order = {
        "title", "play", "quit", "settings", "scoreboard",
        "settings_box", "txt_settings", "txt_volume",
        "txt_difficulty", "easy", "medium", "hard",
        "slider", "reset_levels", "back",
    }
end

function MainMenu:load()
    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local half_window_height = window_height * 0.5
    local button_fade_amount = 3

    local title_width, title_height = self.images.title:getDimensions()
    self.objects.title = Button({
        image = self.images.title,
        x = half_window_width, y = window_height * 0.25,
        sx = 0.5, sy = 0.5,
        ox = title_width * 0.5, oy = title_height * 0.5,
        is_hoverable = false,
        fade_amount = button_fade_amount
    })

    local button_scale = 0.6
    local play_width, play_height = self.images.button_play:getDimensions()
    self.objects.play = Button({
        image = self.images.button_play,
        x = half_window_width, y = half_window_height,
        sx = button_scale, sy = button_scale,
        ox = play_width * 0.5, oy = play_height * 0.5,
        fade_amount = button_fade_amount
    }
    )

    local quit_width, quit_height = self.images.button_quit:getDimensions()
    local quit_y = half_window_height + quit_height
    self.objects.quit = Button({
        image = self.images.button_quit,
        x = half_window_width, y = quit_y,
        sx = button_scale, sy = button_scale,
        ox = quit_width * 0.5, oy = quit_height * 0.5,
        fade_amount = button_fade_amount
    })

    local offset = 32
    local button2_scale = 0.5
    local settings_width, settings_height = self.images.button_settings:getDimensions()
    local bottom_y = window_height - offset

    self.objects.settings = Button({
        image = self.images.button_settings,
        x = offset, y = bottom_y,
        sx = button2_scale, sy = button2_scale,
        ox = settings_width * 0.5, oy = settings_height * 0.5
    })

    local scoreboard_width, scoreboard_height = self.images.button_scoreboard:getDimensions()
    self.objects.scoreboard = Button({
        image = self.images.button_scoreboard,
        x = window_width - offset, y = bottom_y,
        sx = button2_scale, sy = button2_scale,
        ox = scoreboard_width * 0.5, oy = scoreboard_height * 0.5,
        fade_amount = button_fade_amount
    })

    local settings_box_width, settings_box_height = self.images.settings_box:getDimensions()
    self.objects.settings_box = Button({
        image = self.images.settings_box,
        x = half_window_width, y = half_window_height,
        sx = 0.75, sy = 0.75,
        ox = settings_box_width * 0.5, oy = settings_box_height * 0.5,
        fade_amount = button_fade_amount * 1.5,
        is_hoverable = false, alpha = 0, max_alpha = 0.8
    })

    local back_width, back_height = self.images.button_back:getDimensions()
    self.objects.back = Button({
        image = self.images.button_back,
        x = half_window_width,
        y = self.objects.settings_box.y + self.objects.settings_box.oy * 0.5,
        sx = 0.5, sy = 0.5,
        ox = back_width * 0.5, oy = back_height * 0.5,
        fade_amount = button_fade_amount * 1.5, alpha = 0
    })

    local txt_settings_width, txt_settings_height = self.images.text_settings:getDimensions()
    self.objects.txt_settings = Button({
        image = self.images.text_settings,
        x = half_window_width,
        y = self.objects.settings_box.y - self.objects.settings_box.oy * 0.5,
        sx = 0.75, sy = 0.75,
        ox = txt_settings_width * 0.5, oy = txt_settings_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    local _, txt_volume_height = self.images.text_volume:getDimensions()
    self.objects.txt_volume = Button({
        image = self.images.text_volume,
        x = self.objects.settings_box.x - self.objects.settings_box.ox * self.objects.settings_box.sx + 32,
        y = self.objects.txt_settings.y + self.objects.txt_settings.oy * 3,
        sx = 0.5, sy = 0.5,
        ox = 0, oy = txt_volume_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    self.objects.slider = Slider({
        current_value = UserData.data.main_volume,
        max_value = 1,
        x = self.objects.txt_volume.x,
        y = self.objects.txt_volume.y + txt_settings_height * self.objects.txt_volume.sy,
        width = settings_box_width * self.objects.settings_box.sx - 72,
        height = 24, knob_radius = 16, alpha = 0,
        is_clickable = false,
        bg_color = {0, 0, 1},
        line_color = {43/255, 117/255, 222/255},
        knob_color = {1, 1, 1},
        fade_amount = button_fade_amount * 1.5
    })

    local reset_levels_width, reset_levels_height = self.images.button_reset_levels:getDimensions()
    self.objects.reset_levels = Button({
        image = self.images.button_reset_levels,
        x = half_window_width, y = half_window_height + 64,
        sx = 0.75, sy = 0.75,
        ox = reset_levels_width * 0.5, oy = reset_levels_height * 0.5,
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    local txt_difficulty_width, txt_difficulty_height = self.images.text_difficulty:getDimensions()
    self.objects.txt_difficulty = Button({
        image = self.images.text_difficulty,
        x = half_window_width,
        y = self.objects.settings_box.y - self.objects.settings_box.oy * 0.5 - 32,
        sx = 1.25, sy = 1.125,
        ox = txt_difficulty_width * 0.5, oy = txt_difficulty_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5,
    })

    local difficulty_scale = 0.5
    local easy_width, easy_height = self.images.button_easy:getDimensions()
    self.objects.easy = Button({
        image = self.images.button_easy,
        x = half_window_width,
        y = self.objects.txt_difficulty.y + self.objects.txt_difficulty.oy * 4,
        sx = difficulty_scale, sy = difficulty_scale,
        ox = easy_width * 0.5, oy = easy_height * 0.5,
        is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    local medium_width, medium_height = self.images.button_medium:getDimensions()
    self.objects.medium = Button({
        image = self.images.button_medium,
        x = half_window_width,
        y = self.objects.easy.y + self.objects.easy.oy * 1.25,
        sx = difficulty_scale, sy = difficulty_scale,
        ox = medium_width * 0.5, oy = medium_height * 0.5,
        is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    local hard_width, hard_height = self.images.button_hard:getDimensions()
    self.objects.hard = Button({
        image = self.images.button_hard,
        x = half_window_width,
        y = self.objects.medium.y + self.objects.medium.oy * 1.25,
        sx = difficulty_scale, sy = difficulty_scale,
        ox = hard_width * 0.5, oy = hard_height * 0.5,
        is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    local group_main = {
        self.objects.title,
        self.objects.play,
        self.objects.quit,
    }

    local group_settings = {
        self.objects.settings_box,
        self.objects.txt_settings,
        self.objects.txt_volume,
        self.objects.slider,
        self.objects.reset_levels,
        self.objects.back,
    }

    local group_difficulty = {
        self.objects.settings_box,
        self.objects.txt_difficulty,
        self.objects.easy,
        self.objects.medium,
        self.objects.hard,
        self.objects.back,
    }

    self.objects.play.on_clicked = function()
        for _, obj in ipairs(group_main) do obj.fade = -1 end
        self.objects.scoreboard.fade = -1
        for _, obj in ipairs(group_difficulty) do obj.fade = 1 end

        self.objects.play.is_clickable = false
        self.objects.quit.is_clickable = false
        self.objects.settings.is_clickable = false
        self.objects.scoreboard.is_clickable = false
        self.objects.back.is_clickable = true
        self.objects.easy.is_clickable = true
        self.objects.medium.is_clickable = true
        self.objects.hard.is_clickable = true
    end

    self.objects.easy.on_clicked = function() self:show_levels("easy") end
    self.objects.medium.on_clicked = function() self:show_levels("medium") end
    self.objects.hard.on_clicked = function() self:show_levels("hard") end

    self.objects.quit.on_clicked = function()
        love.event.quit()
    end

    self.objects.settings.on_clicked = function()
        for _, obj in ipairs(group_main) do obj.fade = -1 end
        for _, obj in ipairs(group_settings) do obj.fade = 1 end

        self.objects.play.is_clickable = false
        self.objects.quit.is_clickable = false
        self.objects.settings.is_clickable = false
        self.objects.back.is_clickable = true
        self.objects.reset_levels.is_clickable = true
        self.objects.slider.is_clickable = true
    end

    self.objects.scoreboard.on_clicked = function()
    end

    self.objects.back.on_clicked = function()
        for _, obj in ipairs(group_main) do obj.fade = 1 end
        self.objects.scoreboard.fade = 1
        for _, obj in ipairs(group_settings) do obj.fade = -1 end
        for _, obj in ipairs(group_difficulty) do obj.fade = -1 end

        self.objects.play.is_clickable = true
        self.objects.quit.is_clickable = true
        self.objects.settings.is_clickable = true
        self.objects.scoreboard.is_clickable = true
        self.objects.back.is_clickable = false
        self.objects.reset_levels.is_clickable = false
        self.objects.slider.is_clickable = false
        self.objects.easy.is_clickable = false
        self.objects.medium.is_clickable = false
        self.objects.hard.is_clickable = false
    end

    self.objects.slider.on_dragged = function(_, current_value)
        love.audio.setVolume(current_value)
        UserData.data.main_volume = current_value
    end

    self.objects.reset_levels.on_clicked = function()
        UserData:reset_levels()
        UserData:save()
    end
end

function MainMenu:show_levels(difficulty)
    local obj = self.objects[difficulty]
end

function MainMenu:update(dt)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        btn:update(dt)
    end
end

function MainMenu:draw()
    love.graphics.setColor(1, 1, 1, 1)

    local window_width, window_height = love.graphics.getDimensions()

    local bg_width, bg_height = self.images.background:getDimensions()
    local bg_scale_x = window_width/bg_width
    local bg_scale_y = window_height/bg_height
    love.graphics.draw(
        self.images.background,
        0, 0, 0,
        bg_scale_x, bg_scale_y
    )

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        btn:draw()
    end
end

function MainMenu:mousepressed(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        btn:mousepressed(mx, my, mb)
    end
end

function MainMenu:mousereleased(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        btn:mousereleased(mx, my, mb)
    end
end

return MainMenu
