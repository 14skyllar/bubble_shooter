local Button = require("button")
local Resources = require("resources")
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
        "title", "play", "quit", "settings", "scoreboard", "box",
        "txt_settings", "txt_volume",
        "txt_scoreboard", "box_easy", "box_medium", "box_hard", "close",
        "txt_easy_score", "txt_medium_score", "txt_hard_score",
        "txt_difficulty", "easy", "medium", "hard",
        "txt_easy", "txt_medium", "txt_hard",
        "left_arrow", "right_arrow",
        "slider", "reset_levels", "back",
    }

    for i = 1, UserData.data.progress.hard.total do
        table.insert(self.objects_order, "star_" .. i)
    end

    self.difficulty = nil
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

    local box_width, box_height = self.images.box:getDimensions()
    self.objects.box = Button({
        image = self.images.box,
        x = half_window_width, y = half_window_height,
        sx = 0.75, sy = 0.75,
        ox = box_width * 0.5, oy = box_height * 0.5,
        fade_amount = button_fade_amount * 1.5,
        is_hoverable = false, alpha = 0, max_alpha = 0.8
    })

    local close_width, close_height = self.images.close:getDimensions()
    self.objects.close = Button({
        image = self.images.close,
        x = self.objects.box.x + self.objects.box.ox * 0.65,
        y = self.objects.box.y - self.objects.box.oy * 0.65,
        sx = 0.25, sy = 0.25,
        ox = close_width * 0.5, oy = close_height * 0.5,
        fade_amount = button_fade_amount,
        alpha = 0,
        is_clickable = false,
    })

    local back_width, back_height = self.images.button_back:getDimensions()
    self.objects.back = Button({
        image = self.images.button_back,
        x = half_window_width,
        y = self.objects.box.y + self.objects.box.oy * 0.5,
        sx = 0.5, sy = 0.5,
        ox = back_width * 0.5, oy = back_height * 0.5,
        fade_amount = button_fade_amount * 1.5, alpha = 0
    })

    local txt_settings_width, txt_settings_height = self.images.text_settings:getDimensions()
    self.objects.txt_settings = Button({
        image = self.images.text_settings,
        x = half_window_width,
        y = self.objects.box.y - self.objects.box.oy * 0.5,
        sx = 0.75, sy = 0.75,
        ox = txt_settings_width * 0.5, oy = txt_settings_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    local txt_scoreboard_width, txt_scoreboard_height = self.images.text_scoreboard:getDimensions()
    self.objects.txt_scoreboard = Button({
        image = self.images.text_scoreboard,
        x = half_window_width,
        y = self.objects.box.y - self.objects.box.oy * 0.5,
        sx = 0.5, sy = 0.5,
        ox = txt_scoreboard_width * 0.5, oy = txt_scoreboard_height * 0.5,
        is_hoverable = false, is_clickable = false,
        alpha = 0, fade_amount = button_fade_amount * 1.5
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
            alpha = 0, fade_amount = button_fade_amount * 1.5
        })

        prev_box = self.objects[box_obj_id]
        box_oy_mult = 1.5

        local txt_image = self.images["text_" .. id .. "_score"]
        local _, txt_height = txt_image:getDimensions()

        local score_data = UserData.data.scores[id]
        local text = string.format("%d/%d", score_data.current, score_data.total)

        local pad = Resources.font:getWidth("   ")
        self.objects["txt_" .. id .. "_score"] = Button({
            image = txt_image,
            x = prev_box.x - prev_box.ox * 0.45,
            y = prev_box.y,
            sx = 0.3, sy = 0.3,
            ox = 0, oy = txt_height * 0.5,
            is_hoverable = false, is_clickable = false,
            alpha = 0, fade_amount = button_fade_amount * 1.5,
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
        alpha = 0, fade_amount = button_fade_amount * 1.5
    })

    self.objects.slider = Slider({
        current_value = UserData.data.main_volume,
        max_value = 1,
        x = self.objects.txt_volume.x,
        y = self.objects.txt_volume.y + txt_settings_height * self.objects.txt_volume.sy,
        width = box_width * self.objects.box.sx - 72,
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
        y = self.objects.box.y - self.objects.box.oy * 0.5 - 32,
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
        self.objects.reset_levels,
        self.objects.back,
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
        for _, obj in ipairs(self.group_main) do obj.fade = -1 end
        self.objects.scoreboard.fade = -1
        for _, obj in ipairs(self.group_difficulty) do obj.fade = 1 end

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
        for _, obj in ipairs(self.group_main) do obj.fade = -1 end
        for _, obj in ipairs(self.group_settings) do obj.fade = 1 end

        self.objects.play.is_clickable = false
        self.objects.quit.is_clickable = false
        self.objects.settings.is_clickable = false
        self.objects.back.is_clickable = true
        self.objects.reset_levels.is_clickable = true
        self.objects.slider.is_clickable = true
    end

    self.objects.scoreboard.on_clicked = function()
        self.objects.reset_levels.orig_y = self.objects.reset_levels.y
        self.objects.reset_levels:update_y(prev_box.y + prev_box.oy * 1.5)

        for _, obj in ipairs(self.group_main) do obj.fade = -1 end
        for _, obj in ipairs(self.group_scoreboard) do obj.fade = 1 end

        self.objects.play.is_clickable = false
        self.objects.quit.is_clickable = false
        self.objects.settings.is_clickable = false
        self.objects.scoreboard.is_clickable = false
        self.objects.back.is_clickable = false
        self.objects.reset_levels.is_clickable = true
        self.objects.close.is_clickable = true
    end

    self.objects.back.on_clicked = function()
        self.objects.reset_levels:update_y(self.objects.reset_levels.y)

        for _, obj in ipairs(self.group_main) do obj.fade = 1 end
        self.objects.scoreboard.fade = 1
        for _, obj in ipairs(self.group_settings) do obj.fade = -1 end
        for _, obj in ipairs(self.group_scoreboard) do obj.fade = -1 end
        for _, obj in ipairs(self.group_difficulty) do obj.fade = -1 end

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

        if self.group_stage then
            tablex.clear(self.group_stage)
        end
    end

    self.objects.close.on_clicked = function()
        for _, obj in ipairs(self.group_main) do obj.fade = 1 end
        self.objects.scoreboard.fade = 1
        for _, obj in ipairs(self.group_scoreboard) do obj.fade = -1 end

        self.objects.play.is_clickable = true
        self.objects.quit.is_clickable = true
        self.objects.settings.is_clickable = true
        self.objects.scoreboard.is_clickable = true
        self.objects.reset_levels.is_clickable = false
        self.objects.close.is_clickable = false
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
    if self.group_stage then
        tablex.clear(self.group_stage)
        local id = "txt_" .. self.difficulty
        self.objects[id] = nil
    end

    self.difficulty = difficulty

    local window_width = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5

    local txt_obj_id = "txt_" .. difficulty
    local image = self.images["text_" .. difficulty]
    local txt_diff_width, txt_diff_height = image:getDimensions()
    self.objects[txt_obj_id] = Button({
        image = image,
        x = half_window_width,
        y = self.objects.box.y - self.objects.box.oy * 0.5,
        sx = 0.75, sy = 0.75,
        ox = txt_diff_width * 0.5, oy = txt_diff_height * 0.5,
        is_clickable = false, is_hoverable = false,
        alpha = 0,
        fade_amount = 3,
    })

    local box = self.objects.box
    local bx = box.pos.x
    local bw, bh = box.size.x, box.size.y

    local left_arrow_width, left_arrow_height = self.images.button_arrow_left:getDimensions()
    self.objects.left_arrow = Button({
        image = self.images.button_arrow_left,
        x = bx + left_arrow_width * 0.5,
        y = box.pos.y + bh * 0.85,
        sx = 0.5, sy = 0.5,
        ox = left_arrow_width * 0.5,
        oy = left_arrow_height * 0.5,
        fade_amount = 3,
    })

    local right_arrow_width, right_arrow_height = self.images.button_arrow_right:getDimensions()
    self.objects.right_arrow = Button({
        image = self.images.button_arrow_right,
        x = bx + bw - right_arrow_width * 0.5,
        y = box.pos.y + bh * 0.85,
        sx = 0.5, sy = 0.5,
        ox = right_arrow_width * 0.5,
        oy = right_arrow_height * 0.5,
        fade_amount = 3,
    })

    self.objects.left_arrow.on_clicked = function()
        if self.difficulty == "easy" then
            self.objects.reset_levels:update_y(self.objects.reset_levels.y)

            for _, obj in ipairs(self.group_stage) do
                obj.fade = -1
                obj.is_clickable = false
                obj.is_hoverable = false
            end
            for _, obj in ipairs(self.group_difficulty) do obj.fade = 1 end
            self.objects.box.fade = -1

            self.objects.back.is_clickable = true
            self.objects.easy.is_clickable = true
            self.objects.medium.is_clickable = true
            self.objects.hard.is_clickable = true
            self.objects.left_arrow.is_clickable = false
            self.objects.right_arrow.is_clickable = false

            if self.group_stage then
                tablex.clear(self.group_stage)
            end
        elseif self.difficulty == "medium" then
            self:show_levels("easy")
        elseif self.difficulty == "hard" then
            self:show_levels("medium")
        end
    end

    self.objects.right_arrow.on_clicked = function()
        if self.difficulty == "easy" then
        elseif self.difficulty == "medium" then
            self:show_levels("hard")
        elseif self.difficulty == "hard" then
            self:show_levels("medium")
        end
    end

    local txt_obj = self.objects[txt_obj_id]
    local by = txt_obj.y
    local image_star = self.images["star_" .. difficulty]
    local image_locked_star = self.images["locked_star_" .. difficulty]
    local star_width, star_height = image_star:getDimensions()
    local ix, iy = 1, 1
    local progress = UserData.data.progress[difficulty]
    local limit = progress.total * 0.5
    local scale = 1.25
    local gap_x = (bx + bw)/star_width * limit
    local gap_y = (by + bh)/star_height * limit
    bx = bx + gap_x * 0.5
    by = by + gap_y * 0.5

    local text_colors = {
        easy = {88/255, 1, 0},
        medium = {1, 213/255, 0},
        hard = {1, 0, 3/255},
    }
    local text_color = text_colors[difficulty]

    self.group_stage = {
        self.objects.box,
        self.objects[txt_obj_id],
        self.objects.left_arrow,
        self.objects.right_arrow,
    }

    for i = 1, progress.total do
        local star_x = bx + star_width + gap_x * (ix - 1)
        local star_y = by + star_height + gap_y * (iy - 1)

        ix = ix + 1
        if (i % limit) == 0 then
            iy = iy + 1
            ix = 1
        end

        local is_unlocked = i <= progress.current
        local text = is_unlocked and tostring(i) or ""

        local star_obj_id = "star_" .. i
        self.objects[star_obj_id] = Button({
            image = is_unlocked and image_star or image_locked_star,
            x = star_x, y = star_y,
            sx = scale, sy = scale,
            ox = star_width * 0.5, oy = star_height * 0.5,
            sx_dt = 0.25, sy_dt = 0.25,
            alpha = 0,
            is_hoverable = is_unlocked, is_clickable = is_unlocked,
            font = Resources.font,
            text = text,
            text_color = text_color,
            tox = Resources.font:getWidth(text) * 0.5,
            toy = Resources.font:getHeight() * 0.5,
            fade_amount = 3,
        })

        table.insert(self.group_stage, self.objects[star_obj_id])
    end

    for _, obj in ipairs(self.group_difficulty) do
        obj.fade = -1
        obj.is_clickable = false
    end

    for _, obj in ipairs(self.group_stage) do
        obj.fade = 1
    end
end

function MainMenu:update(dt)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:update(dt)
        end
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
        if btn then
            btn:draw()
        end
    end
end

function MainMenu:mousepressed(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            local res = btn:mousepressed(mx, my, mb)
            if res then break end
        end
    end
end

function MainMenu:mousereleased(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:mousereleased(mx, my, mb)
        end
    end
end

return MainMenu
