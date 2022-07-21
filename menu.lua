local Button = require("button")
local Resources = require("resources")
local Slider = require("slider")
local StateManager = require("state_manager")
local UserData = require("user_data")
local Utils = require("utils")

local Menu = class({
    name = "Menu"
})

function Menu:new(start_screen)
    local id = self:type()
    self.images = Utils.load_images(id)
    self.sources = Utils.load_sources(id)

    self.objects = {}
    self.objects_order = {
        "title", "play", "quit", "settings", "gear", "btn_info", "scoreboard",
        "sparkle1", "sparkle2", "box", "txt_settings", "txt_volume",
        "txt_scoreboard", "box_info", "credits", "box_easy", "box_medium",
        "box_hard", "close", "txt_easy_score", "txt_medium_score",
        "txt_hard_score", "txt_difficulty", "easy", "medium", "hard",
        "txt_easy", "txt_medium", "txt_hard", "slider", "reset_levels", "back",
        "btn_credits",
    }

    for i = 1, UserData.data.progress.hard.total do
        table.insert(self.objects_order, "star_" .. i)
    end

    self.difficulty = nil
    self.start_screen = start_screen
end

function Menu:load()
    self.sources.bgm_gameplay:play()
    self.sources.bgm_gameplay:setLooping(true)

    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local half_window_height = window_height * 0.5

    local title_width, title_height = self.images.title:getDimensions()
    self.objects.title = Button({
        image = self.images.title,
        x = half_window_width, y = window_height * 0.25,
        sx = 0.5, sy = 0.5,
        ox = title_width * 0.5, oy = title_height * 0.5,
        is_hoverable = false,
        on_click_sound = self.sources.snd_buttons,
    })

    local button_scale = 0.6
    local play_width, play_height = self.images.button_play:getDimensions()
    self.objects.play = Button({
        image = self.images.button_play,
        x = half_window_width, y = half_window_height,
        sx = button_scale, sy = button_scale,
        ox = play_width * 0.5, oy = play_height * 0.5,
        on_click_sound = self.sources.snd_buttons,
    })

    local quit_width, quit_height = self.images.button_quit:getDimensions()
    local quit_y = half_window_height + quit_height
    self.objects.quit = Button({
        image = self.images.button_quit,
        x = half_window_width, y = quit_y,
        sx = button_scale, sy = button_scale,
        ox = quit_width * 0.5, oy = quit_height * 0.5,
        on_click_sound = self.sources.snd_buttons,
    })

    local offset = 32
    local button2_scale = 0.5
    local settings_width, settings_height = self.images.button_settings:getDimensions()
    local bottom_y = window_height - offset

    self.objects.settings = Button({
        image = self.images.button_settings,
        x = offset, y = bottom_y,
        sx = button2_scale, sy = button2_scale,
        ox = settings_width * 0.5, oy = settings_height * 0.5,
        on_click_sound = self.sources.snd_buttons,
    })

    local gear_width, gear_height = self.images.gear:getDimensions()
    self.objects.gear = Button({
        image = self.images.gear,
        x = self.objects.settings.x, y = self.objects.settings.y,
        sx = button2_scale, sy = button2_scale,
        ox = gear_width * 0.5, oy = gear_height * 0.5,
    })

    local info_width, info_height = self.images.btn_info:getDimensions()
    self.objects.btn_info = Button({
        image = self.images.btn_info,
        x = self.objects.settings.x + settings_width * button2_scale * 0.5 + info_width * 0.75 * button2_scale,
        y = self.objects.settings.y,
        sx = button2_scale, sy = button2_scale,
        ox = info_width * 0.5, oy = info_height * 0.5,
        on_click_sound = self.sources.snd_buttons,
    })

    local box_info_width, box_info_height = self.images.box_info:getDimensions()
    local box_info_sx = (window_width - 48)/box_info_width
    local box_info_sy = (window_height * 0.6)/box_info_height
    self.objects.box_info = Button({
        image = self.images.box_info,
        x = half_window_width, y = half_window_height,
        sx = box_info_sx, sy = box_info_sy,
        ox = box_info_width * 0.5, oy = box_info_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0,
    })

    local credits_width, credits_height = self.images.credits:getDimensions()
    local credits_sx = (window_width - 48)/credits_width
    local credits_sy = (window_height * 0.6)/credits_height
    self.objects.credits = Button({
        image = self.images.credits,
        x = half_window_width, y = half_window_height,
        sx = credits_sx, sy = credits_sy,
        ox = credits_width * 0.5, oy = credits_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0,
    })

    local scoreboard_width, scoreboard_height = self.images.button_scoreboard:getDimensions()
    self.objects.scoreboard = Button({
        image = self.images.button_scoreboard,
        x = window_width - offset, y = bottom_y,
        sx = button2_scale, sy = button2_scale,
        ox = scoreboard_width * 0.5, oy = scoreboard_height * 0.5,
        on_click_sound = self.sources.snd_buttons,
    })

    self.objects.sparkle1 = Button({
        image = self.images.sparkle,
        animated = {
            g = "1-12", w = 105, h = 94,
            speed = 0.05,
            n_frames = 12,
            start_frame = love.math.random(1, 12),
            on_loop = function(anim8)
                anim8:pauseAtEnd()
                self.timer_sparkle1 = timer(love.math.random(0.3, 1.5), nil, function()
                    anim8:gotoFrame(1)
                    anim8:resume()
                    self.timer_sparkle1 = nil
                end)
            end
        },
        x = self.objects.scoreboard.x - scoreboard_width * button2_scale * 0.4,
        y = self.objects.scoreboard.y - scoreboard_height * button2_scale * 0.4,
        sx = button2_scale, sy = button2_scale,
        ox = 105/2, oy = 94/2,
        is_hoverable = false, is_clickable = false,
    })

    self.objects.sparkle2 = Button({
        image = self.images.sparkle,
        animated = {
            g = "1-12", w = 105, h = 94,
            speed = 0.05,
            n_frames = 12,
            start_frame = love.math.random(1, 12),
            on_loop = function(anim8)
                anim8:pauseAtEnd()
                self.timer_sparkle2 = timer(love.math.random(0.3, 1.5), nil, function()
                    anim8:gotoFrame(1)
                    anim8:resume()
                    self.timer_sparkle2 = nil
                end)
            end
        },
        x = self.objects.scoreboard.x + scoreboard_width * button2_scale * 0.4,
        y = self.objects.scoreboard.y + scoreboard_height * button2_scale * 0.4,
        sx = button2_scale, sy = button2_scale,
        ox = 105/2, oy = 94/2,
        is_hoverable = false, is_clickable = false,
    })

    local box_width, box_height = self.images.box:getDimensions()
    self.objects.box = Button({
        image = self.images.box,
        x = half_window_width, y = half_window_height,
        sx = 0.75, sy = 0.75,
        ox = box_width * 0.5, oy = box_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0, max_alpha = 0.8
    })

    local close_width, close_height = self.images.close:getDimensions()
    self.objects.close = Button({
        image = self.images.close,
        x = self.objects.box.x + self.objects.box.ox * 0.65,
        y = self.objects.box.y - self.objects.box.oy * 0.65,
        sx = 0.25, sy = 0.25,
        ox = close_width * 0.5, oy = close_height * 0.5,
        alpha = 0,
        is_clickable = false,
        on_click_sound = self.sources.snd_buttons,
    })

    local back_width, back_height = self.images.button_back:getDimensions()
    self.objects.back = Button({
        image = self.images.button_back,
        x = half_window_width,
        y = self.objects.box.y + self.objects.box.oy * 0.5 + 24,
        sx = 0.5, sy = 0.5,
        ox = back_width * 0.5, oy = back_height * 0.5,
        alpha = 0,
        on_click_sound = self.sources.snd_buttons,
    })

    local btn_credits_width, btn_credits_height = self.images.button_credits:getDimensions()
    self.objects.btn_credits = Button({
        image = self.images.button_credits,
        x = half_window_width,
        y = self.objects.back.y - back_height * 0.5 - 12,
        sx = 0.5, sy = 0.5,
        ox = btn_credits_width * 0.5, oy = btn_credits_height * 0.5,
        alpha = 0,
        on_click_sound = self.sources.snd_buttons,
    })

    local txt_settings_width, txt_settings_height = self.images.text_settings:getDimensions()
    self.objects.txt_settings = Button({
        image = self.images.text_settings,
        x = half_window_width,
        y = self.objects.box.y - self.objects.box.oy * 0.5,
        sx = 0.75, sy = 0.75,
        ox = txt_settings_width * 0.5, oy = txt_settings_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0,
    })

    local txt_scoreboard_width, txt_scoreboard_height = self.images.text_scoreboard:getDimensions()
    self.objects.txt_scoreboard = Button({
        image = self.images.text_scoreboard,
        x = half_window_width,
        y = self.objects.box.y - self.objects.box.oy * 0.5,
        ox = txt_scoreboard_width * 0.5, oy = txt_scoreboard_height * 0.75,
        is_hoverable = false, is_clickable = false,
        alpha = 0,
    })

    local boxes = {"easy", "medium", "hard"}
    local prev_box, box_oy_mult = self.objects.txt_scoreboard, 2.5
    local text_color = {
        easy = {79/255, 212/255, 74/255},
        medium = {1, 254/255, 64/255},
        hard = {213/255, 48/244, 41/255},
    }

    for _, id in ipairs(boxes) do
        local box_obj_id = "box_" .. id
        local box_image = self.images[box_obj_id]
        local box_d_width, box_d_height = box_image:getDimensions()
        self.objects[box_obj_id] = Button({
            image = box_image,
            x = half_window_width,
            y = prev_box.y + prev_box.oy * box_oy_mult,
            sx = 0.5, sy = 0.5,
            ox = box_d_width * 0.5, oy = box_d_height * 0.5,
            is_hoverable = false, is_clickable = false,
            alpha = 0,
        })

        prev_box = self.objects[box_obj_id]
        box_oy_mult = 1.5

        local txt_image = self.images["text_" .. id .. "_score"]
        local _, txt_height = txt_image:getDimensions()

        local score_data = UserData.data.scores[id]
        local text = tostring(score_data.current)

        local pad = Resources.font:getWidth("   ")
        self.objects["txt_" .. id .. "_score"] = Button({
            image = txt_image,
            x = prev_box.x - prev_box.ox * 0.45,
            y = prev_box.y,
            sx = 0.3, sy = 0.3,
            ox = 0, oy = txt_height * 0.5,
            is_hoverable = false, is_clickable = false,
            alpha = 0,
            text = text, text_color = text_color[id],
            font = Resources.font,
            tx = prev_box.x + prev_box.ox * 0.5 - pad,
            ty = prev_box.y,
            tox = Resources.font:getWidth(text),
            toy = Resources.font:getHeight() * 0.5,
        })
    end

    local _, txt_volume_height = self.images.text_volume:getDimensions()
    self.objects.txt_volume = Button({
        image = self.images.text_volume,
        x = self.objects.box.x - self.objects.box.ox * self.objects.box.sx + 32,
        y = self.objects.txt_settings.y + self.objects.txt_settings.oy * 3,
        sx = 0.5, sy = 0.5,
        ox = 0, oy = txt_volume_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0,
    })

    local sbg_width, sbg_height = self.images.slider_bg:getDimensions()

    self.objects.slider = Slider({
        knob_image = self.images.knob,

        bg_image = self.images.slider_bg,
        x = self.objects.box.x,
        y = self.objects.box.y + txt_settings_height * 0.5,
        sx = 0.5, sy = 0.5,
        ox = sbg_width * 0.5, oy = sbg_height * 0.5,

        current_value = UserData.data.main_volume,
        max_value = 1,
        width = box_width * self.objects.box.sx - 72,
        height = 24,
        alpha = 0,
        is_clickable = false,
    })

    local reset_levels_width, reset_levels_height = self.images.button_reset_levels:getDimensions()
    self.objects.reset_levels = Button({
        image = self.images.button_reset_levels,
        x = half_window_width, y = half_window_height + 64,
        sx = 0.75, sy = 0.75,
        ox = reset_levels_width * 0.5, oy = reset_levels_height * 0.5,
        alpha = 0,
        is_clickable = false, is_hoverable = false,
        on_click_sound = self.sources.snd_buttons,
    })

    local txt_difficulty_width, txt_difficulty_height = self.images.text_difficulty:getDimensions()
    self.objects.txt_difficulty = Button({
        image = self.images.text_difficulty,
        x = half_window_width,
        y = self.objects.box.y - self.objects.box.oy * 0.5 - 32,
        sx = 1.25, sy = 1.125,
        ox = txt_difficulty_width * 0.5, oy = txt_difficulty_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0,
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
        alpha = 0,
        on_click_sound = self.sources.snd_buttons,
    })

    local medium_width, medium_height = self.images.button_medium:getDimensions()
    self.objects.medium = Button({
        image = self.images.button_medium,
        x = half_window_width,
        y = self.objects.easy.y + self.objects.easy.oy * 1.25,
        sx = difficulty_scale, sy = difficulty_scale,
        ox = medium_width * 0.5, oy = medium_height * 0.5,
        is_clickable = false,
        alpha = 0,
        on_click_sound = self.sources.snd_buttons,
    })

    local hard_width, hard_height = self.images.button_hard:getDimensions()
    self.objects.hard = Button({
        image = self.images.button_hard,
        x = half_window_width,
        y = self.objects.medium.y + self.objects.medium.oy * 1.25,
        sx = difficulty_scale, sy = difficulty_scale,
        ox = hard_width * 0.5, oy = hard_height * 0.5,
        is_clickable = false,
        alpha = 0,
        on_click_sound = self.sources.snd_buttons,
    })

    self.group_main = {
        self.objects.title,
        self.objects.play,
        self.objects.quit,
    }

    self.group_settings = {
        self.objects.box,
        self.objects.txt_settings,
        self.objects.txt_volume,
        self.objects.slider,
        self.objects.back,
        self.objects.btn_credits,
    }

    self.group_scoreboard = {
        self.objects.box,
        self.objects.txt_scoreboard,
        self.objects.box_easy,
        self.objects.txt_easy_score,
        self.objects.box_medium,
        self.objects.txt_medium_score,
        self.objects.box_hard,
        self.objects.txt_hard_score,
        self.objects.reset_levels,
        self.objects.close,
    }

    self.group_difficulty = {
        self.objects.box,
        self.objects.txt_difficulty,
        self.objects.easy,
        self.objects.medium,
        self.objects.hard,
        self.objects.back,
    }

    self.objects.play.on_clicked = function()
        for _, obj in ipairs(self.group_main) do obj.alpha = 0 end
        self.objects.settings.alpha = 0
        self.objects.gear.alpha = 0
        self.objects.btn_info.alpha = 0
        self.objects.scoreboard.alpha = 0
        self.objects.sparkle1.alpha = 0
        self.objects.sparkle2.alpha = 0
        for _, obj in ipairs(self.group_difficulty) do obj.alpha = 1 end

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
        for _, obj in ipairs(self.group_main) do obj.alpha = 0 end
        for _, obj in ipairs(self.group_settings) do obj.alpha = 1 end

        self.objects.play.is_clickable = false
        self.objects.play.is_hoverable = false
        self.objects.quit.is_clickable = false
        self.objects.quit.is_hoverable = false
        self.objects.settings.is_clickable = false
        self.objects.settings.is_hoverable = false
        self.objects.btn_info.is_hoverable = false
        self.objects.btn_info.is_clickable = false
        self.objects.scoreboard.is_clickable = false
        self.objects.scoreboard.is_hoverable = false
        self.objects.back.is_clickable = true
        self.objects.slider.is_clickable = true
    end

    self.objects.btn_info.on_clicked = function()
        for _, obj in ipairs(self.group_main) do obj.alpha = 0 end
        self.objects.box_info.alpha = 1
        self.objects.close.alpha = 1
        self.objects.close.is_clickable = 1
        self.objects.close.is_hoverable = 1

        self.objects.play.is_clickable = false
        self.objects.play.is_hoverable = false
        self.objects.quit.is_clickable = false
        self.objects.quit.is_hoverable = false
        self.objects.settings.is_clickable = false
        self.objects.settings.is_hoverable = false
        self.objects.btn_info.is_hoverable = false
        self.objects.btn_info.is_clickable = false
        self.objects.scoreboard.is_clickable = false
        self.objects.scoreboard.is_hoverable = false
        self.objects.back.is_clickable = true
        self.objects.reset_levels.is_clickable = true
        self.objects.slider.is_clickable = true
    end

    self.objects.scoreboard.on_clicked = function()
        self.objects.reset_levels:update_y(prev_box.y + prev_box.oy * 1.5)

        for _, obj in ipairs(self.group_main) do obj.alpha = 0 end
        for _, obj in ipairs(self.group_scoreboard) do obj.alpha = 1 end

        self.objects.play.is_clickable = false
        self.objects.play.is_hoverable = false
        self.objects.quit.is_clickable = false
        self.objects.quit.is_hoverable = false
        self.objects.settings.is_clickable = false
        self.objects.settings.is_hoverable = false
        self.objects.btn_info.is_clickable = false
        self.objects.btn_info.is_hoverable = false
        self.objects.scoreboard.is_clickable = false
        self.objects.scoreboard.is_hoverable = false
        self.objects.back.is_clickable = false
        self.objects.reset_levels.is_clickable = true
        self.objects.close.is_clickable = true
    end

    self.objects.btn_credits.on_clicked = function()
        for _, obj in ipairs(self.group_settings) do
            obj.alpha = 0
            obj.is_hoverable = false
            obj.is_clickable = false
        end
        self.objects.credits.alpha = 1
        self.objects.close.alpha = 1
        self.objects.close.is_clickable = 1
        self.objects.close.is_hoverable = 1
    end

    self.objects.back.on_clicked = function()
        local diff_back = self.objects.txt_difficulty.alpha == 0 and self.objects.slider.alpha == 0

        for _, obj in ipairs(self.group_main) do obj.alpha = 1 end
        self.objects.settings.alpha = 1
        self.objects.gear.alpha = 1
        self.objects.btn_info.alpha = 1
        self.objects.scoreboard.alpha = 1
        self.objects.sparkle1.alpha = 1
        self.objects.sparkle2.alpha = 1
        for _, obj in ipairs(self.group_settings) do obj.alpha = 0 end
        for _, obj in ipairs(self.group_scoreboard) do obj.alpha = 0 end

        if self.group_stage then
            for _, obj in ipairs(self.group_stage) do obj.alpha = 0 end
        end

        self.objects.play.is_clickable = true
        self.objects.play.is_hoverable = true
        self.objects.quit.is_clickable = true
        self.objects.quit.is_hoverable = true
        self.objects.settings.is_clickable = true
        self.objects.settings.is_hoverable = true
        self.objects.btn_info.is_clickable = true
        self.objects.btn_info.is_hoverable = true
        self.objects.scoreboard.is_clickable = true
        self.objects.scoreboard.is_hoverable = true
        self.objects.back.is_clickable = false
        self.objects.reset_levels.is_clickable = false
        self.objects.slider.is_clickable = false
        self.objects.easy.is_clickable = false
        self.objects.medium.is_clickable = false
        self.objects.hard.is_clickable = false

        if self.group_stage then
            tablex.clear(self.group_stage)
        end

        if diff_back then
            self.objects.play.on_clicked()
        else
            for _, obj in ipairs(self.group_difficulty) do obj.alpha = 0 end
        end
    end

    self.objects.close.on_clicked = function()
        for _, obj in ipairs(self.group_main) do obj.alpha = 1 end
        self.objects.scoreboard.alpha = 1
        for _, obj in ipairs(self.group_scoreboard) do obj.alpha = 0 end

        if self.objects.credits.alpha == 1 then
            self.objects.credits.alpha = 0
            for _, obj in ipairs(self.group_settings) do
                obj.alpha = 1
                if obj ~= self.objects.box then
                    obj.is_hoverable = true
                    obj.is_clickable = true
                end
            end
        else
            self.objects.box_info.alpha = 0
            self.objects.play.is_clickable = true
            self.objects.play.is_hoverable = true
            self.objects.quit.is_clickable = true
            self.objects.quit.is_hoverable = true
            self.objects.settings.is_clickable = true
            self.objects.settings.is_hoverable = true
            self.objects.btn_info.is_clickable = true
            self.objects.btn_info.is_hoverable = true
            self.objects.scoreboard.is_clickable = true
            self.objects.scoreboard.is_hoverable = true
            self.objects.reset_levels.is_clickable = false
            self.objects.close.is_clickable = false
        end
    end

    self.objects.slider.on_dragged = function(_, current_value)
        love.audio.setVolume(current_value)
        UserData.data.main_volume = current_value
    end

    self.objects.reset_levels.on_clicked = function()
        UserData:reset_levels()
        UserData:save()
    end

    if self.start_screen then
        self:show_levels(self.start_screen)
    end
end

function Menu:show_levels(difficulty)
    if self.group_stage then
        tablex.clear(self.group_stage)
        local id = "txt_" .. self.difficulty
        self.objects[id] = nil

        local progress = UserData.data.progress[self.difficulty]
        for i = 1, progress.total do
            local star_obj_id = "star_" .. i
            local obj = self.objects[star_obj_id]
            if obj then
                self.objects[star_obj_id] = nil
            end
        end
    end

    self.difficulty = difficulty

    local half_window_width = love.graphics.getWidth() * 0.5
    local txt_obj_id = "txt_" .. difficulty
    local image = self.images["text_" .. difficulty]
    local txt_diff_width, txt_diff_height = image:getDimensions()
    self.objects[txt_obj_id] = Button({
        image = image,
        x = half_window_width,
        y = self.objects.box.y - self.objects.box.oy * 0.5 - 32,
        sx = 0.75, sy = 0.75,
        ox = txt_diff_width * 0.5, oy = txt_diff_height * 0.5,
        is_clickable = false, is_hoverable = false,
        alpha = 0,
    })

    local box = self.objects.box
    local txt_obj = self.objects[txt_obj_id]
    local image_star = self.images["star_" .. difficulty]
    local image_locked_star = self.images["locked_star_" .. difficulty]
    local star_width, star_height = image_star:getDimensions()
    local progress = UserData.data.progress[difficulty]

    local text_colors = {
        easy = {88/255, 1, 0},
        medium = {1, 213/255, 0},
        hard = {1, 0, 3/255},
    }
    local text_color = text_colors[difficulty]

    self.group_stage = {
        self.objects.box,
        self.objects[txt_obj_id],
    }

    local scale = 1.25
    local limit = 5
    local gap_x = star_width * scale * 0.25
    local gap_y = star_height * scale * 0.25
    local half_cols = math.floor(limit * 0.5)

    local spacings = {
        easy = 1.5,
        medium = 1.5,
        hard = 1,
    }

    local bx = box.pos.x + box.half_size.x
    bx = bx - ((half_cols * star_width * scale) + (gap_x * half_cols))

    local by = txt_obj.y
    by = by + star_height * scale * spacings[self.difficulty]

    local ix, iy = 0, 0
    for i = 1, progress.total do
        local star_x = bx + star_width * scale * ix + gap_x * ix
        local star_y = by + star_height * scale * iy + gap_y * iy

        ix = ix + 1
        if (i % limit) == 0 then
            iy = iy + 1
            ix = 0
        end

        local is_unlocked = i <= progress.current
        local text = is_unlocked and tostring(i) or ""

        local star_obj_id = "star_" .. i
        local star_obj = Button({
            image = is_unlocked and image_star or image_locked_star,
            x = star_x, y = star_y,
            sx = scale, sy = scale,
            ox = star_width * 0.5,
            oy = star_height * 0.5,
            sx_dt = 0.25, sy_dt = 0.25,
            alpha = 0,
            is_hoverable = is_unlocked, is_clickable = is_unlocked,
            font = Resources.font,
            text = text,
            text_color = text_color,
            tox = Resources.font:getWidth(text) * 0.5,
            toy = Resources.font:getHeight() * 0.5,
            on_click_sound = self.sources.snd_buttons,
        })
        self.objects[star_obj_id] = star_obj

        star_obj.on_clicked = function()
            local next_state = require("game")
            StateManager:switch(next_state, difficulty, i)
        end

        table.insert(self.group_stage, star_obj)
    end

    for _, obj in ipairs(self.group_difficulty) do
        obj.alpha = 0
        obj.is_clickable = false
    end

    for _, obj in ipairs(self.group_stage) do
        obj.alpha = 1
    end

    self.objects.back.alpha = 1
    self.objects.back.is_hoverable = true
    self.objects.back.is_clickable = true
end

function Menu:update(dt)
    local obj_gear = self.objects.gear
    obj_gear.r = obj_gear.r + dt

    if self.timer_sparkle1 then self.timer_sparkle1:update(dt) end
    if self.timer_sparkle2 then self.timer_sparkle2:update(dt) end

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:update(dt)
        end
    end
end

function Menu:draw()
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
        if btn then
            btn:draw()
        end
    end
end

function Menu:mousepressed(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            local res = btn:mousepressed(mx, my, mb)
            if res then break end
        end
    end
end

function Menu:mousereleased(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:mousereleased(mx, my, mb)
        end
    end
end

function Menu:exit()
    for _, source in pairs(self.sources) do
        source:stop()
    end
end

return Menu
