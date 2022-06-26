local Button = require("button")
local Utils = require("utils")

local MainMenu = class({
    name = "MainMenu"
})

function MainMenu:new()
    self.images = Utils.load_images(self:type())
    self.buttons = {}
end

function MainMenu:load()
    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local half_window_height = window_height * 0.5

    local button_scale = 0.6
    local play_width, play_height = self.images.button_play:getDimensions()
    self.buttons.play = Button(self.images.button_play,
        half_window_width, half_window_height, 0,
        button_scale, button_scale,
        play_width * 0.5, play_height * 0.5
    )

    local quit_width, quit_height = self.images.button_quit:getDimensions()
    local quit_y = half_window_height + quit_height
    self.buttons.quit = Button(self.images.button_quit,
        half_window_width, quit_y, 0,
        button_scale, button_scale,
        quit_width * 0.5, quit_height * 0.5
    )

    local offset = 16
    local button2_scale = 0.5
    local settings_width, settings_height = self.images.button_settings:getDimensions()
    local bottom_y = window_height - offset

    self.buttons.settings = Button(self.images.button_settings,
        offset, bottom_y, 0,
        button2_scale, button2_scale,
        0, settings_height
    )

    self.buttons.scoreboard = Button(self.images.button_scoreboard,
        window_width - offset, bottom_y, 0,
        button2_scale, button2_scale,
        settings_width, settings_height
    )
end

function MainMenu:update(dt)
    for _, btn in pairs(self.buttons) do
        btn:update(dt)
    end
end

function MainMenu:draw()
    love.graphics.setColor(1, 1, 1, 1)

    local window_width, window_height = love.graphics.getDimensions()

    local bg_width, bg_height = self.images.background:getDimensions()
    local bg_scale_x = window_width/bg_width
    local bg_scale_y = window_height/bg_height
    love.graphics.draw(self.images.background,
        0, 0, 0,
        bg_scale_x, bg_scale_y
    )

    local title_width, title_height = self.images.title:getDimensions()
    love.graphics.draw(self.images.title,
        window_width * 0.5, window_height * 0.25, 0,
        0.5, 0.5,
        title_width * 0.5, title_height * 0.5
    )

    for _, btn in pairs(self.buttons) do
        btn:draw()
    end
end

function MainMenu:mousepressed(mx, my, mb)
    for _, btn in pairs(self.buttons) do
        btn:mousepressed(mx, my, mb)
    end
end

return MainMenu
