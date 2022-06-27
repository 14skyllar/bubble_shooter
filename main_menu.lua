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
        "settings_box", "txt_settings", "txt_volume", "slider", "reset_levels", "back",
    }
end

function MainMenu:load()
    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local half_window_height = window_height * 0.5
    local button_fade_amount = 3

    local title_width, title_height = self.images.title:getDimensions()
    self.objects.title = Button(
        self.images.title,
        half_window_width, window_height * 0.25, 0,
        0.5, 0.5,
        title_width * 0.5, title_height * 0.5
    )
    self.objects.title.is_hoverable = false
    self.objects.title.fade_amount = button_fade_amount

    local button_scale = 0.6
    local play_width, play_height = self.images.button_play:getDimensions()
    self.objects.play = Button(
        self.images.button_play,
        half_window_width, half_window_height, 0,
        button_scale, button_scale,
        play_width * 0.5, play_height * 0.5
    )
    self.objects.play.fade_amount = button_fade_amount

    local quit_width, quit_height = self.images.button_quit:getDimensions()
    local quit_y = half_window_height + quit_height
    self.objects.quit = Button(
        self.images.button_quit,
        half_window_width, quit_y, 0,
        button_scale, button_scale,
        quit_width * 0.5, quit_height * 0.5
    )
    self.objects.quit.fade_amount = button_fade_amount

    local offset = 32
    local button2_scale = 0.5
    local settings_width, settings_height = self.images.button_settings:getDimensions()
    local bottom_y = window_height - offset

    self.objects.settings = Button(
        self.images.button_settings,
        offset, bottom_y, 0,
        button2_scale, button2_scale,
        settings_width * 0.5, settings_height * 0.5
    )

    local scoreboard_width, scoreboard_height = self.images.button_scoreboard:getDimensions()
    self.objects.scoreboard = Button(
        self.images.button_scoreboard,
        window_width - offset, bottom_y, 0,
        button2_scale, button2_scale,
        scoreboard_width * 0.5, scoreboard_height * 0.5
    )

    local settings_box_width, settings_box_height = self.images.settings_box:getDimensions()
    self.objects.settings_box = Button(
        self.images.settings_box,
        half_window_width, half_window_height, 0,
        0.75, 0.75,
        settings_box_width * 0.5, settings_box_height * 0.5
    )
    self.objects.settings_box.fade_amount = button_fade_amount * 1.5
    self.objects.settings_box.is_hoverable = false
    self.objects.settings_box.alpha = 0
    self.objects.settings_box.max_alpha = 0.8

    local back_width, back_height = self.images.button_back:getDimensions()
    self.objects.back = Button(
        self.images.button_back,
        half_window_width, self.objects.settings_box.y + self.objects.settings_box.oy * 0.5, 0,
        0.5, 0.5,
        back_width * 0.5, back_height * 0.5
    )
    self.objects.back.alpha = 0
    self.objects.back.fade_amount = button_fade_amount * 1.5

    local txt_settings_width, txt_settings_height = self.images.text_settings:getDimensions()
    self.objects.txt_settings = Button(
        self.images.text_settings,
        half_window_width,
        self.objects.settings_box.y - self.objects.settings_box.oy * 0.5,
        0,
        0.75, 0.75,
        txt_settings_width * 0.5, txt_settings_height * 0.5
    )
    self.objects.txt_settings.is_hoverable = false
    self.objects.txt_settings.is_clickable = false
    self.objects.txt_settings.alpha = 0
    self.objects.txt_settings.fade_amount = button_fade_amount * 1.5

    local _, txt_volume_height = self.images.text_volume:getDimensions()
    self.objects.txt_volume = Button(
        self.images.text_volume,
        self.objects.settings_box.x - self.objects.settings_box.ox * self.objects.settings_box.sx + 32,
        self.objects.txt_settings.y + self.objects.txt_settings.oy * 3,
        0,
        0.5, 0.5,
        0, txt_volume_height * 0.5
    )
    self.objects.txt_volume.is_hoverable = false
    self.objects.txt_volume.is_clickable = false
    self.objects.txt_volume.alpha = 0
    self.objects.txt_volume.fade_amount = button_fade_amount * 1.5

    self.objects.slider = Slider(
        UserData.data.main_volume, 1,
        self.objects.txt_volume.x,
        self.objects.txt_volume.y + txt_settings_height * self.objects.txt_volume.sy,
        settings_box_width * self.objects.settings_box.sx - 72,
        24,
        16
    )
    self.objects.slider.alpha = 0
    self.objects.slider.is_clickable = false
    self.objects.slider.bg_color = {0, 0, 1}
    self.objects.slider.line_color = {43/255, 117/255, 222/255}
    self.objects.slider.knob_color = {1, 1, 1}
    self.objects.slider.fade_amount = button_fade_amount * 1.5

    local reset_levels_width, reset_levels_height = self.images.button_reset_levels:getDimensions()
    self.objects.reset_levels = Button(
        self.images.button_reset_levels,
        half_window_width, half_window_height + 64,
        0, 0.75, 0.75,
        reset_levels_width * 0.5, reset_levels_height * 0.5
    )
    self.objects.reset_levels.alpha = 0
    self.objects.reset_levels.fade_amount = button_fade_amount * 1.5

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

    self.objects.settings.on_clicked = function()
        for _, obj in ipairs(group_main) do
            obj.fade = -1
        end
        for _, obj in ipairs(group_settings) do
            obj.fade = 1
        end

        self.objects.play.is_clickable = false
        self.objects.quit.is_clickable = false
        self.objects.settings.is_clickable = false
        self.objects.back.is_clickable = true
        self.objects.reset_levels.is_clickable = true
        self.objects.slider.is_clickable = true
    end

    self.objects.back.on_clicked = function()
        for _, obj in ipairs(group_main) do
            obj.fade = 1
        end
        for _, obj in ipairs(group_settings) do
            obj.fade = -1
        end

        self.objects.play.is_clickable = true
        self.objects.quit.is_clickable = true
        self.objects.settings.is_clickable = true
        self.objects.back.is_clickable = false
        self.objects.reset_levels.is_clickable = false
        self.objects.slider.is_clickable = false
    end

    self.objects.slider.on_dragged = function(_, current_value)
        love.audio.setVolume(current_value)
        UserData.data.main_volume = current_value
    end
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
