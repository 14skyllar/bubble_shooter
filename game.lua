local utf8 = require("utf8")

local Bubble = require("bubble")
local Button = require("button")
local Colors = require("colors")
local Resources = require("resources")
local StateManager = require("state_manager")
local UserData = require("user_data")
local Utils = require("utils")

local Game = class({
    name = "Game"
})

local rows = {
    easy = {2, 2, 3, 4, 5, 6, 7, 8, 9, 9},
    medium = {3, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9},
    hard = {4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9},
}

local game_timers = {
    easy = 5 * 60 + 1,
    medium = 4 * 60 + 1,
    hard = 3 * 60 + 1,
}

local push_back = {
    easy = 5,
    medium = 4,
    hard = 3,
}

local shuffle_limits = {
    easy = 5,
    medium = 3,
    hard = 2,
}

local MIN_ANGLE, MAX_ANGLE = -0.9, 0.9

local fade_in_sec = 2
local fade_out_sec = 1
local info_show_dur = 1.5
local info_dur = 5
local wrong_dur = 1.5
local pop_dur = 1
local bgm_delay = 2

--TODO remove these
-- fade_in_sec = 0.1
-- fade_out_sec = 0.1
-- info_show_dur = 0.1
-- info_dur = 0.1
-- wrong_dur = 0.1
-- pop_dur = 0.25
-- bgm_delay = 0.5

local score_color = {
    dark_blue = 1,
    yellow = 1,
    orange = 1,
    yellow_green = 2,
    light_blue = 2,
    pink = 2,
    violet = 3,
    yellow_gold = 3,
    red = 3,
    green = 5
}
local border_scale = 0.4

function Game:new(difficulty, level, hearts)
    local id = self:type()
    self.bubble_scale = 0.2
    self.bubble_size = 240

    self.difficulty = difficulty
    self.level = level
    self.hearts = hearts or 3
    self.max_hearts = 3
    self.is_game_over = false
    self.start = false
    self.is_question = false
    self.is_targeting = false
    self.can_shoot = false
    self.target_path = {}
    self.rows = rows[difficulty][level]
    self.rotation = 0
    self.game_timer = game_timers[difficulty]
    self.score = 0
    self.last_score_threshold = 0
    self.last_score_threshold_p = 0
    self.powerups = false
    self.powerups_timer = 0
    self.shuffle_count = shuffle_limits[self.difficulty]
    self.shuffle_mode = 1
    assert(self.rows ~= nil and self.rows > 0)

    local diff = string.upper(difficulty:sub(1, 1)) .. difficulty:sub(2)
    self.images_bubbles = Utils.load_images("Bubbles" .. diff)
    self.images_common = Utils.load_images(id)
    self.images = Utils.load_images(diff)
    self.sources = Utils.load_sources(id)
    self.bubbles_key = tablex.keys(self.images_bubbles)

    self.border = {}
    self.objects = {}
    self.bubbles = {}
    self.objects_order = {
        "score_holder", "life_holder", "time_holder", "label", "settings",
        "base", "shooter", "ammo", "shuffle", "btn_shuffle", "line_indicator",
        "txt_ready_go",
        "bg_question", "bg_box", "bg_win_lose", "text_lose", "text_win",
        "text_level_cleared", "btn_sound", "btn_bgm",
        "btn_resume", "btn_restart", "btn_main_menu", "powerup",
        "btn_next", "btn_retry", "btn_stages",
    }

    for i = 1, self.max_hearts do table.insert(self.objects_order, "heart_" .. i) end

    self.current_question = nil
    self.questions = tablex.copy(require("questions." .. difficulty))
    self.n_choices = 4
    for i = 1, self.n_choices do table.insert(self.objects_order, "choice_" .. i) end
    for i = 1, 3 do table.insert(self.objects_order, "star_" .. i) end

    self.remaining_shots = 0
    self.increase = 32
    self.pop_timers = {}
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
        text = "Score: 0", text_color = {1, 1, 1},
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
        text = string.format("Time: %.2f", self.game_timer),
        text_color = {1, 1, 1},
        font = Resources.game_font,
        tx = thx + gap * 2,
        ty = gap + score_holder_height * 0.5 * ui_scale,
        toy = Resources.game_font:getHeight() * 0.5
    })

    local border_width, border_height = self.images_common.bubble:getDimensions()
    local border_count = math.floor(window_width/(border_width * border_scale)) + 1
    local border_y = (self.objects.time_holder.y + time_holder_height * ui_scale) + (gap * 3)
    self.border_y = border_y + border_height * border_scale

    for i = 1, border_count do
        self.border[i] = {
            image = self.images_common.bubble,
            x = (i - 1) * border_width * border_scale,
            y = self.border_y,
            scale = border_scale,
            sx = border_scale, sy = border_scale,
            ox = border_width * 0.5,
            oy = border_height * 0.5,
            rad = border_width * border_scale * 0.5,
        }
    end

    local label_height = self.images.label:getHeight()
    local label_scale = 0.4
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
    self.objects.settings.on_clicked = function() self:open_settings() end

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
    local shooter = self.objects.shooter

    local liw, lih = self.images_common.line_indicator:getDimensions()
    self.objects.line_indicator = Button({
        image = self.images_common.line_indicator,
        x = half_window_width,
        y = shooter.y - shooter.oy * shooter.sy,
        ox = liw * 0.5,
        oy = lih * 0.5,
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
        x = gap * 5,
        y = self.objects.base.y - shuffle_height,
        sx = shuffle_scale, sy = shuffle_scale,
        ox = shuffle_width * 0.5, oy = shuffle_height * 0.5,
        is_clickable = false, is_hoverable = false,
        on_click_sound = self.sources.snd_bubble_swap,

        text = self.shuffle_count,
        text_color = {1, 1, 1, 1},
        tox = shuffle_width * shuffle_scale * 0.5,
        toy = shuffle_height * shuffle_scale * 0.5,
    })
    self.objects.shuffle.on_clicked = function() self:shuffle() end

    local shuffle_ud_width, shuffle_ud_height = self.images_common.btn_shuffle_up:getDimensions()
    self.objects.btn_shuffle = Button({
        image = self.images_common.btn_shuffle_up,
        x = gap * 5,
        y = self.objects.shuffle.y - shuffle_height * shuffle_scale - 8,
        sx = shuffle_scale, sy = shuffle_scale,
        ox = shuffle_ud_width * 0.5, oy = shuffle_ud_height * 0.5,
        is_clickable = false, is_hoverable = false,
        on_click_sound = self.sources.snd_bubble_swap,
    })
    self.objects.btn_shuffle.on_clicked = function() self:change_shuffle() end

    self.ready_timer = timer(fade_in_sec, function(progress)
        local txt_ready_go = self.objects.txt_ready_go
        if txt_ready_go then
            txt_ready_go.alpha = progress
        end
    end, function()
        self.objects.txt_ready_go.alpha = 1
        self.ready_fade_timer = timer(fade_out_sec, function(progress)
            local txt_ready_go = self.objects.txt_ready_go
            txt_ready_go.alpha = 1 - progress
        end, function()
            self.objects.txt_ready_go.alpha = 0
            self:show_question()
        end)
    end)

    self:create_bubbles(border_height)

    if #self.bubbles > 0 then
        self.sources.snd_ready_go:play()
        self.sources.snd_ready_go:setLooping(false)

        self.bgm_timer = timer(bgm_delay, nil, function()
            self.sources.bgm_gameplay:play()
            self.sources.bgm_gameplay:setLooping(true)
            self.bgm_timer = nil
        end)
    end
end

function Game:show_question()
    if self.powerups then return end
    local padding = 64
    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local bg_question_width, bg_question_height = self.images.bg_question:getDimensions()
    local sx = (window_width - padding)/bg_question_width
    local sy = (window_height * 0.75 - padding)/bg_question_height
    local font = Resources.font
    local margin = 16
    local wy = window_height * 0.6
    local ty = wy - bg_question_height * sy * 0.5 + margin
    local limit = bg_question_width * sx - margin * 2

    local most = 0
    for _, q in ipairs(self.questions) do
        if q.identification then
            most = math.max(most, #q.answer)
        end
    end
    self.max_answer_length = most

    self.current_question = tablex.take_random(self.questions)
    print("Remaining questions:", #self.questions)

    self.objects.bg_question = Button({
        image = self.images.bg_question,
        x = half_window_width,
        y = wy,
        sx = sx, sy = sy,
        ox = bg_question_width * 0.5,
        oy = bg_question_height * 0.5,
        is_hoverable = false, is_clickable = false,
        is_printf = true,
        font = font,
        text = self.current_question.question,
        text_color = {0, 0, 0}, text_alpha = 1,
        tx = half_window_width - bg_question_width * sx * 0.5 + margin,
        ty = ty,
        limit = limit,
    })

    local choice_width, choice_height = self.images_common.box_choice:getDimensions()
    local ascii = 97

    local n_choices = 4
    if self.current_question.true_or_false then
        n_choices = 2
    elseif self.current_question.identification then
        n_choices = 1
    end

    local _, wrap = font:getWrap(self.current_question.question, limit)
    ty = ty + font:getHeight() * (#wrap + 2)

    local choice_sx = (window_width - padding * 2)/choice_width
    local choice_sy = ((self.objects.bg_question.half_size.y - (padding * 0.5))/choice_height)/self.n_choices

    if self.current_question.identification then
        choice_sy = ((self.objects.bg_question.half_size.y - (padding * 0.5))/(choice_height * 2))
    end

    for i = 1, self.n_choices do
        local key = "choice_" .. i
        local str_question, letter

        if self.current_question.true_or_false then
            letter = tostring(i == 1)
            str_question = tostring(letter)
        elseif self.current_question.identification then
            letter = ""
            str_question = "(tap here to type)"
        elseif type(self.current_question.answer) == "table" then
            letter = self.current_question.answer
            local widest = ""
            for _, str in ipairs(self.current_question.answer) do
                if #str > #widest then
                    widest = str
                end
            end
            str_question = widest
        else
            letter = string.char(ascii)
            str_question = self.current_question[letter]
        end

        local txt_width = font:getWidth(str_question)
        local txt_height = font:getHeight()
        local y

        if self.current_question.identification then
            y = ty + (choice_height + margin)
        else
            y = ty + (choice_height + margin * 1.5) * choice_sy * (i - 1)
        end

        local _, wrap_choice = font:getWrap(str_question, (choice_width * choice_sx))
        local text_x, text_y, tsx, tsy
        if #wrap_choice > 1 then
            txt_width = 0
            for _, txt in ipairs(wrap_choice) do
                local w = font:getWidth(txt)
                txt_width = math.max(txt_width, w)
            end

            text_x = half_window_width - choice_width * choice_sx * 0.5 + txt_width * 0.5
            text_y = y - choice_height * choice_sy * 0.5 + txt_height * 0.5
            tsx = (choice_width * choice_sx)/(txt_width + padding)
            tsy = (choice_height * choice_sy)/(font:getHeight() * (#wrap_choice + 1))
        else
            text_x = half_window_width
            text_y = y
        end

        self.objects[key] = Button({
            image = self.images_common.box_choice,
            x = half_window_width,
            y = y,
            sx = choice_sx,
            sy = choice_sy,
            ox = choice_width * 0.5,
            oy = choice_height * 0.5,
            font = font,
            text = str_question,
            tx = text_x, ty = text_y,
            tox = txt_width * 0.5,
            toy = txt_height * 0.5,
            is_printf = #wrap_choice > 1,
            limit = choice_width * choice_sx,
            align = "center",
            tsx = tsx,
            tsy = tsy,
            value = letter,
            on_click_sound = self.sources.snd_buttons,
        })
        local obj = self.objects[key]

        obj.on_clicked = function()
            if self.current_question.identification then
                love.keyboard.setKeyRepeat(true)
                love.keyboard.setTextInput(true)
                self.waiting_for_input = obj
                obj.text = ""
                obj.is_hoverable = false
            else
                self:check_answer(self.objects[key])
            end
        end

        if not self.current_question.true_or_false then
            ascii = ascii + 1
            if ascii > 100 then
                ascii = 97
            end
        end

        if i > n_choices then
            obj.alpha = 0
            obj.is_clickable = false
            obj.is_hoverable = false
        end
    end

    self.objects.shuffle.is_hoverable = false
    self.objects.shuffle.is_clickable = false
    self.objects.btn_shuffle.is_hoverable = false
    self.objects.btn_shuffle.is_clickable = false
    self.objects.settings.is_clickable = false
    self.objects.settings.is_hoverable = false

    self.is_question = true
    self.can_shoot = true
end

function Game:check_answer(choice_obj)
    for i = 1, self.n_choices do
        local obj = self.objects["choice_" .. i]
        obj.is_hoverable = false
        obj.is_clickable = false
    end

    local answer = self.current_question.answer
    if type(answer) == "boolean" then
        answer = tostring(answer)
    end
    local user_answer = string.lower(choice_obj.value)
    local is_correct = false

    if type(answer) == "string" then
        is_correct = user_answer == string.lower(answer)
    elseif type(answer) == "table" then
        for _, str in ipairs(answer) do
            str = string.lower(str)
            if user_answer == str then
                is_correct = true
                break
            end
        end
    end

    if is_correct then
        print("correct")
        self:correct_answer()
        choice_obj.text_color = {0, 1, 0}
    else
        print("wrong")
        self:wrong_answer()
        choice_obj.text_color = {1, 0, 0}
    end
end

function Game:correct_answer()
    local obj_question = self.objects.bg_question
    if not obj_question then return end

    self.wait_timer = timer(info_show_dur,
        function(progress)
            obj_question.text_alpha = 1 - progress
            for i = 1, self.n_choices do
                self.objects["choice_" .. i].alpha = 1 - progress
            end
        end,
        function()
            self.showing_info = true
            obj_question.text = self.current_question.info
            obj_question.text_alpha = 1
            for i = 1, self.n_choices do self.objects["choice_" .. i] = nil end

            self.wait_timer = timer(info_dur, nil, function()
                self.objects.shuffle.is_hoverable = true
                self.objects.shuffle.is_clickable = true
                self.objects.btn_shuffle.is_hoverable = true
                self.objects.btn_shuffle.is_clickable = true
                self.objects.settings.is_clickable = true
                self.objects.settings.is_hoverable = true
                self.objects.bg_question = nil
                self.remaining_shots = 3
                self.start = true
                self.is_question = false
                self.showing_info = false
                self:reload()
            end)
        end)
end

function Game:wrong_answer(value, push_only)
    value = value or self.increase
    if #self.questions == 0 then
        self.questions = tablex.copy(require("questions." .. self.difficulty))
    end

    if self.objects.bg_question then
        self.objects.bg_question.alpha = 0.5
    end
    for i = 1, self.n_choices do
        local obj = self.objects["choice_" .. i]
        if obj then
            obj.alpha = 0.5
        end
    end

    for _, border in ipairs(self.border) do border.target_y = border.y + value end
    for _, bubble in ipairs(self.bubbles) do bubble.target_y = bubble.y + value end
    self.border_y = self.border_y + value

    if push_only then
        for _, border in ipairs(self.border) do border.y = border.target_y end
        for _, bubble in ipairs(self.bubbles) do bubble.y = bubble.target_y end
    else
        self.border_move_timer = timer(wrong_dur,
            function(progress)
                for _, border in ipairs(self.border) do border.y = mathx.lerp(border.y, border.target_y, progress) end
                for _, bubble in ipairs(self.bubbles) do bubble.y = mathx.lerp(bubble.y, bubble.target_y, progress) end
            end,
            function()
                self:show_question()
            end)
    end
end

function Game:create_bubbles(border_height)
    local window_width = love.graphics.getWidth()
    local half_window_width = window_width * 0.5

    --check if bubbles will go past windows edges
    local temp_key = tablex.pick_random(self.bubbles_key)
    local bubble_image = self.images_bubbles[temp_key]
    local bw = bubble_image:getWidth()

    local n_rows = self.rows
    print("rows =", n_rows)
    if self.difficulty == "hard" then
        n_rows = math.floor(self.rows * 1.5)
    end
    local total_width = n_rows * bw * self.bubble_scale

    while total_width > window_width * 0.95 do
        self.bubble_scale = self.bubble_scale - 0.01
        total_width = n_rows * bw * self.bubble_scale
        print("bubble_scale = ", self.bubble_scale)
    end

    if self.difficulty == "easy" then
        for i = 0, self.rows - 1 do
            local cols = self.rows - i
            for j = 0, cols - 1 do
                local key = tablex.pick_random(self.bubbles_key)
                local color_name = Colors.get_color(key)
                local image = self.images_bubbles[key]
                local width, height = image:getDimensions()
                local x = half_window_width - ((cols - 1) * 0.5) * (width * self.bubble_scale)
                local y = self.border_y + (border_height * border_scale * 0.5) + height * self.bubble_scale * 0.5
                x = x + (width * self.bubble_scale * j)
                y = y + (height * self.bubble_scale * i)

                local bubble = Bubble({
                    image = image,
                    x = x, y = y,
                    sx = self.bubble_scale, sy = self.bubble_scale,
                    ox = width * 0.5, oy = height * 0.5,
                    color_name = color_name,
                })
                bubble._height = height

                table.insert(self.bubbles, bubble)
            end
        end

    elseif self.difficulty == "medium" then
        local cols = math.floor(window_width/(self.bubble_size * self.bubble_scale))
        for i = 0, self.rows - 1 do
            for j = 0, cols - 1 do
                local key = tablex.pick_random(self.bubbles_key)
                local color_name = Colors.get_color(key)
                local image = self.images_bubbles[key]
                local width, height = image:getDimensions()
                local x = half_window_width - ((cols - 1) * 0.5) * (width * self.bubble_scale)
                local y = self.border_y + (border_height * border_scale * 0.5) + height * self.bubble_scale * 0.5
                x = x + (width * self.bubble_scale * j)
                y = y + (height * self.bubble_scale * i)

                local bubble = Bubble({
                    image = image,
                    x = x, y = y,
                    sx = self.bubble_scale, sy = self.bubble_scale,
                    ox = width * 0.5, oy = height * 0.5,
                    color_name = color_name,
                })
                bubble._height = height

                table.insert(self.bubbles, bubble)
            end
            cols = cols - 1
        end

    elseif self.difficulty == "hard" then
        local cols = self.rows
        for i = 0, self.rows - 1 do
            for j = 0, cols - 1 do
                local key = tablex.pick_random(self.bubbles_key)
                local color_name = Colors.get_color(key)
                local image = self.images_bubbles[key]
                local width, height = image:getDimensions()
                local x = half_window_width - ((cols - 1) * 0.5) * (width * self.bubble_scale)
                local y = self.border_y + (border_height * border_scale * 0.5) + height * self.bubble_scale * 0.5
                x = x + (width * self.bubble_scale * j)
                y = y + (height * self.bubble_scale * i)

                local bubble = Bubble({
                    image = image,
                    x = x, y = y,
                    sx = self.bubble_scale, sy = self.bubble_scale,
                    ox = width * 0.5, oy = height * 0.5,
                    color_name = color_name,
                })
                bubble._height = height

                table.insert(self.bubbles, bubble)
            end

            local dir = i < math.floor(self.rows * 0.5) and 1 or -1
            cols = cols + dir
        end

    end

    self._top = self.border_y + (border_height * border_scale * 0.5)
    -- compress initial bubbles
    -- for _, bubble in ipairs(self.bubbles) do
    --     bubble.vy = -bubble.within_rad
    --     bubble.y = bubble.y + bubble.vy * love.timer.getDelta()
    --     for _, border in ipairs(self.border) do
    --         bubble:check_collision(border, true)
    --     end
    --     bubble.vy = 0
    -- end

    --check for total y the bubbles will reach after compressing
    local lowest_y, lowest_bubble = 0, nil
    for _, bubble in ipairs(self.bubbles) do
        local y = bubble.y + bubble.rad * bubble.sy
        if y > lowest_y then
            lowest_y = y
            lowest_bubble = bubble
        end
    end

    local window_height = love.graphics.getHeight()
    local threshold = window_height * 0.55

    while lowest_y > threshold do
        self:wrong_answer(-self.increase * push_back[self.difficulty], true)
        lowest_y = lowest_bubble.y + lowest_bubble.rad * lowest_bubble.sy
    end
end

function Game:shuffle()
    if self.shuffle_count <= 0 then return end

    if self.shuffle_mode == 1 then
        local temp_images = {}
        for _, bubble in ipairs(self.bubbles) do
            local data = {
                image = bubble.image,
                color_name = bubble.color_name,
            }
            table.insert(temp_images, data)
        end
        for _, bubble in ipairs(self.bubbles) do
            local data = tablex.take_random(temp_images)
            bubble.image = data.image
            bubble.color_name = data.color_name
        end
    elseif self.shuffle_mode == 2 then
        self:reload()
    end

    self.shuffle_count = self.shuffle_count - 1
    self.objects.shuffle.text = self.shuffle_count
end

function Game:change_shuffle()
    local obj = self.objects.btn_shuffle
    if self.shuffle_mode == 1 then
        obj.image = self.images_common.btn_shuffle_down
        self.shuffle_mode = 2
    elseif self.shuffle_mode == 2 then
        obj.image = self.images_common.btn_shuffle_up
        self.shuffle_mode = 1
    end
end

function Game:after_shoot()
    local ammo = self.objects.ammo
    if not ammo then return end

    local stack = {ammo}
    local found = {}
    found[ammo] = ammo

    while #stack > 0 do
        local current = table.remove(stack, 1)
        local within_radius = current:get_within_radius(self.bubbles)
        if type(within_radius) == "boolean" then
            self.sources.snd_bubble_pop:play()
            self.sources.snd_bubble_pop:setLooping(false)
            self.powerups = true

            local t = timer(pop_dur,
                function(progress)
                    self.objects.powerup.alpha = 1 - progress
                    ammo.alpha = 1 - progress
                end,
                function()
                    self.objects.powerup.is_dead = true
                    ammo.is_dead = true
                end
            )
            table.insert(self.pop_timers, t)
            break
        end

        for _, bubble in ipairs(within_radius) do
            if not found[bubble] then
                found[bubble] = bubble
                table.insert(stack, bubble)
            end
        end
    end

    local matches = #tablex.keys(found)
    if matches >= 3 then
        self.sources.snd_bubble_pop:play()
        self.sources.snd_bubble_pop:setLooping(false)
        self.has_match = true

        local color_name

        for k in pairs(found) do
            for i = #self.bubbles, 1, -1 do
                local bubble = self.bubbles[i]
                if bubble == k then
                    color_name = bubble.color_name
                    local t = timer(pop_dur,
                        function(progress)
                            bubble.alpha = 1 - progress
                            ammo.alpha = 1 - progress

                            if self.pending_score then
                                self.pending_score.alpha = 1 - progress
                                self.pending_score.y = self.pending_score.y - progress
                            end
                        end,
                        function()
                            bubble.is_dead = true
                            ammo.is_dead = true
                            self.pending_score = nil
                        end)

                    table.insert(self.pop_timers, t)
                end
            end
        end

        -- local score = matches == 3 and "1" or "2"
        local score = score_color[color_name]
        self.score = self.score + score
        self.pending_score = {
            text = score,
            x = ammo.x, y = ammo.y,
            alpha = 1,
        }

        if (self.score - self.last_score_threshold) >= 10 then
            self.last_score_threshold = self.last_score_threshold + 10
            self.game_timer = self.game_timer + 60
        end

        if (self.score - self.last_score_threshold_p) >= 15 then
            self.last_score_threshold_p = self.last_score_threshold_p + 15
            self:show_powerup()
        end
    end

    if ammo then
        table.insert(self.bubbles, ammo)
    end

    self.objects.ammo = nil
    self:check_hanging()

    if matches >= 3 then
        return
    end

    self:resolve_post_shoot()
end

function Game:check_hanging()
    local at_top = {}
    local found = {}

    for _, bubble in ipairs(self.bubbles) do
        bubble.is_connected = false
        local res = (bubble.y - bubble.within_rad) <= self._top
        if res then
            bubble.is_connected = res
            table.insert(at_top, bubble)
        end
    end

    while #at_top > 0 do
        local current = table.remove(at_top, 1)
        local ns = current:get_within_others(self.bubbles)
        for _, other in ipairs(ns) do
            if not found[other] then
                other.is_connected = true
                found[other] = other
                table.insert(at_top, other)
            end
        end
    end

    for _, bubble in ipairs(self.bubbles) do
        if not bubble.is_connected then
            local ty = love.graphics.getHeight()
            bubble.should_fall = true
            local t = timer(pop_dur,
                function(progress)
                    bubble.y = mathx.lerp(bubble.y, ty, progress * 0.25)
                    bubble.alpha = 1 - progress
                end,
                function()
                    bubble.is_dead = true
                end)
            table.insert(self.pop_timers, t)
        end
    end
end

function Game:check_hanging2()
    for _, bubble in ipairs(self.bubbles) do
        bubble._top = self._top
    end

    local found = {}
    local stack = {}
    for _, bubble in ipairs(self.bubbles) do
        local res = (bubble.y - bubble.within_rad) <= bubble._top
        bubble.is_connected = res
        table.insert(stack, bubble)
    end

    while #stack > 0 do
        local current = table.remove(stack, 1)
        local within_radius = current:get_within_others(self.bubbles)
        for _, bubble in ipairs(within_radius) do
            if not found[bubble] then
                bubble.is_connected = current.is_connected
                found[bubble] = bubble
                table.insert(stack, bubble)

                if not bubble.is_connected then
                    local ty = love.graphics.getHeight()
                    bubble.should_fall = true
                    local t = timer(pop_dur,
                        function(progress)
                            bubble.y = mathx.lerp(bubble.y, ty, progress * 0.25)
                            bubble.alpha = 1 - progress
                        end,
                        function()
                            bubble.is_dead = true
                        end)

                    table.insert(self.pop_timers, t)
                end
            end
        end
    end
end

function Game:resolve_post_shoot()
    if self.remaining_shots == 0 and not self.is_question then
        self.can_shoot = false
        self.wait_timer = timer(0.5, nil, function() self:show_question() end)
    else
        self:reload()
        self.can_shoot = true
    end
    self.sources.snd_drop_bubbles:play()
    self.sources.snd_drop_bubbles:setLooping(false)
end

function Game:reload()
    local present_bubbles = {}
    for _, bubble in ipairs(self.bubbles) do
        local data = {
            image = bubble.image,
            color_name = bubble.color_name,
        }
        table.insert(present_bubbles, data)
    end
    if #present_bubbles == 0 then return end
    local new_data = tablex.pick_random(present_bubbles)
    local image = new_data.image
    local width, height = image:getDimensions()
    local shooter = self.objects.shooter

    self.objects.ammo = Bubble({
        image = image,
        x = shooter.x, y = shooter.y,
        sx = self.bubble_scale, sy = self.bubble_scale,
        ox = width * 0.5, oy = height * 0.75,
        main_oy = height * 0.5,
        color_name = new_data.color_name,
    })
end

function Game:update_target_path(mx, my)
    if self.is_game_over then return end
    local within_range = self.rotation >= MIN_ANGLE and self.rotation <= MAX_ANGLE
    if not within_range then return end
    tablex.clear(self.target_path)
    local shooter = self.objects.shooter
    local x, y = shooter.x, shooter.y
    local a = vec2(x, y)
    local b = vec2(mx, my)
    local c = b:vsub(a):smul(100)
    local d, len = c:normalise_both()
    local spacing = 16

    local window_width, window_height = love.graphics.getDimensions()
    for _ = 0, len, spacing * 2 do
        local v1 = a:fma(d, spacing)
        local v2 = a:fma(d, spacing * 2)

        local past_window_edges = (v1.x < 0 or v1.x > window_width) or
            (v1.y < 0 or v1.y > window_height)
        local past_border = (v2.y < self.border_y)

        local past_bubble
        for _, bubble in ipairs(self.bubbles) do
            local bpos = vec2(bubble.x, bubble.y)
            local rad = bubble.rad * bubble.sx
            if intersect.point_circle_overlap(v2, bpos, rad) then
                past_bubble = true
                break
            end
        end

        if past_window_edges or past_border or past_bubble then
            break
        end

        local dash = {v1, v2}
        a = v2
        table.insert(self.target_path, dash)
    end
end

function Game:shoot(mx, my)
    local ammo = self.objects.ammo
    if not ammo then return end

    local mpos = vec2(mx, my)
    local ppos = vec2(ammo.x, ammo.y)
    local diff = mpos:vsub(ppos)

    ammo.vx = diff.x
    ammo.vy = diff.y
    ammo.oy = ammo.main_oy

    self.sources.snd_drop_bubbles:play()
    self.sources.snd_drop_bubbles:setLooping(false)
end

function Game:game_over(has_won)
    if not has_won then
        self.sources.bgm_lose:play()
        self.sources.bgm_lose:setLooping(false)
    end
    self.is_game_over = true
    for i = #self.border, 1, -1 do
        table.remove(self.border, i)
    end
    for i = #self.bubbles, 1, -1 do
        table.remove(self.bubbles, i)
    end
    for k in pairs(self.objects) do
        if not (k == "label" or k == "settings") then
            self.objects[k] = nil
        end
    end

    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local half_window_height = window_height * 0.5

    local bg_width, bg_height = self.images_common.bg_box:getDimensions()
    local bg_sx = (window_width - 64)/bg_width
    local bg_sy = (window_height * 0.6)/bg_height

    self.objects.bg_box = Button({
        image = self.images_common.bg_box,
        x = half_window_width, y = half_window_height,
        sx = bg_sx, sy = bg_sy,
        ox = bg_width * 0.5, oy = bg_height * 0.5,
        is_hoverable = false, is_clickable = false
    })
    local bg_box = self.objects.bg_box

    local box_width, box_height = self.images.bg_win_lose:getDimensions()
    self.objects.bg_win_lose = Button({
        image = self.images.bg_win_lose,
        x = half_window_width, y = half_window_height,
        sx = 1, sy = 1,
        ox = box_width * 0.5, oy = box_height * 0.5,
        is_hoverable = false, is_clickable = false,
    })
    local bg_win_lose = self.objects.bg_win_lose
    local font = Resources.wl_score_font
    local text_key, star_image, text_image
    local score = self.score or 0

    if has_won then
        text_key = "text_win"
        star_image = self.images_common.whole_star
        text_image = self.images.text_win

        self.sources.bgm_level_cleared:play()
        self.sources.bgm_level_cleared:setLooping(false)
    else
        text_key = "text_lose"
        star_image = self.images_common.empty_star
        text_image = self.images_common.text_lose
    end

    local text_width, text_height = text_image:getDimensions()
    local text_sx = (box_width - 32)/text_width
    local text_sy = (box_height * 0.35)/text_height
    local text = "SCORE: " .. score
    local y = bg_win_lose.y - bg_win_lose.half_size.y + text_height * text_sy

    self.objects[text_key] = Button({
        image = text_image,
        x = bg_win_lose.x,
        y = y,
        sx = text_sx, sy = text_sy,
        ox = text_width * 0.5,
        oy = text_height * 0.5,
        is_clickable = false, is_hoverable = false,
        text_color = {1, 1, 1},
        text = text,
        font = font,
        tx = bg_win_lose.x,
        ty = y + font:getHeight(),
        tox = font:getWidth(text) * 0.5,
        toy = font:getHeight() * 0.25,
    })

    local btn_scale = 0.25
    local btn_retry_width, btn_retry_height = self.images_common.btn_retry:getDimensions()
    local btn_y = bg_win_lose.y + box_height * 0.75
    self.objects.btn_retry = Button({
        image = self.images_common.btn_retry,
        x = bg_win_lose.x,
        y = btn_y,
        sx = btn_scale, sy = btn_scale,
        ox = btn_retry_width * 0.5, oy = btn_retry_height * 0.5,
        is_hoverable = true, is_clickable = true,
    })
    self.objects.btn_retry.on_clicked = function()
        local next_state = require("game")
        StateManager:switch(next_state, self.difficulty, self.level)
    end

    local btn_stages_width, btn_stages_height = self.images_common.btn_stages:getDimensions()
    self.objects.btn_stages = Button({
        image = self.images_common.btn_stages,
        x = self.objects.btn_retry.x - btn_retry_width * btn_scale * 1.25,
        y = btn_y,
        sx = btn_scale, sy = btn_scale,
        ox = btn_stages_width * 0.5, oy = btn_stages_height * 0.5,
        is_hoverable = true, is_clickable = true,
    })
    self.objects.btn_stages.on_clicked = function()
        local next_state = require("menu")
        StateManager:switch(next_state, self.difficulty)
    end

    if has_won then
        local btn_next_width, btn_next_height = self.images_common.btn_next:getDimensions()
        self.objects.btn_next = Button({
            image = self.images_common.btn_next,
            x = self.objects.btn_retry.x + btn_retry_width * btn_scale * 1.25,
            y = btn_y,
            sx = btn_scale, sy = btn_scale,
            ox = btn_next_width * 0.5, oy = btn_next_height * 0.5,
            is_hoverable = true, is_clickable = true,
        })
        self.objects.btn_next.on_clicked = function()
            local next_state = require("game")
            self.level = self.level + 1
            if self.level > UserData.data.progress[self.difficulty].total then
                if self.difficulty == "easy" then
                    self.difficulty = "medium"
                elseif self.difficulty == "medium" then
                    self.difficulty = "hard"
                end
                self.level = UserData.data.progress[self.difficulty].current
            end
            StateManager:switch(next_state, self.difficulty, self.level)
        end
    end

    self.win_lose_buttons = {
        self.objects.btn_next,
        self.objects.btn_retry,
        self.objects.btn_stages,
    }

    local star_width, star_height = star_image:getDimensions()
    local star_sx = has_won and 0.5 or 0.6
    local star_sy = has_won and 0.5 or 0.6
    local gap = 8
    local bx = half_window_width - ((star_width * star_sx * 0.5) * 1.5) - (gap * 1.5)
    local by = bg_box.y - bg_height * bg_sy * 0.5 + star_height * star_sy - gap

    for i = 1, 3 do
        local key = "star_" .. i
        self.objects[key] = Button({
            image = star_image,
            x = bx + (star_width * star_sx * (i - 1)) + gap * (i - 1),
            y = by,
            sx = star_sx, sy = star_sy,
            ox = star_width * 0.5, oy = star_height * 0.5,
            is_hoverable = false, is_clickable = false,
        })
    end

    if has_won then
        local txt_width, txt_height = self.images_common.text_level_cleared:getDimensions()
        self.objects.text_level_cleared = Button({
            image = self.images_common.text_level_cleared,
            x = half_window_width,
            y = by + star_height * star_sy,
            sx = 1, sy = 1,
            ox = txt_width * 0.5, oy = txt_height * 0.5,
            is_hoverable = false, is_clickable = false,
        })
    end

    if has_won then
        self:update_save_data()
    end
end

function Game:show_powerup()
    local powerup_width, powerup_height = self.images.powerup:getDimensions()
    local scale = 0.15
    local half_width = powerup_width * scale * 0.5
    local half_height = powerup_height * scale * 0.5
    local x = love.math.random(half_width, love.graphics.getWidth() - half_width)

    self.objects.powerup = Bubble({
        image = self.images.powerup,
        x = x, y = -half_height,
        sx = scale, sy = scale,
        ox = powerup_width * 0.5, oy = powerup_height * 0.5,
        color_name = "powerup",
    })
    table.insert(self.bubbles, self.objects.powerup)
end

function Game:update_save_data()
    local data = UserData.data.progress[self.difficulty]
    if data.current ~= self.level then return end

    data.current = data.current + 1
    if data.current > data.total then
        data.current = data.total

        -- if we reach the total level, unlock the next difficulty
        if self.difficulty == "easy" then
            UserData.data.progress["medium"].current = 1
        elseif self.difficulty == "medium" then
            UserData.data.progress["hard"].current = 1
        end
    end

    local scores_data = UserData.data.scores[self.difficulty]
    scores_data.current = scores_data.current + self.score

    UserData:save()
end

function Game:open_settings()
    self.is_paused = true
    self.start = false
    self.objects.shuffle.is_hoverable = false
    self.objects.shuffle.is_clickable = false
    self.objects.btn_shuffle.is_hoverable = false
    self.objects.btn_shuffle.is_clickable = false
    self.objects.settings.is_clickable = false
    self.objects.settings.is_hoverable = false

    local window_width, window_height = love.graphics.getDimensions()
    local half_window_width = window_width * 0.5
    local half_window_height = window_height * 0.5

    local bg_width, bg_height = self.images_common.bg_box:getDimensions()
    local bg_sx = (window_width - 64)/bg_width
    local bg_sy = (half_window_height)/bg_height

    local font = Resources.pause_font
    local text = "PAUSED"

    self.objects.bg_box = Button({
        image = self.images_common.bg_box,
        x = half_window_width, y = half_window_height,
        sx = bg_sx, sy = bg_sy,
        ox = bg_width * 0.5, oy = bg_height * 0.5,
        is_hoverable = false, is_clickable = false,
        font = font,
        text_color = {0, 1, 0},
        text = text,
        ty = half_window_height - bg_height * bg_sy * 0.5 + font:getHeight() * 0.75,
        tox = font:getWidth(text) * 0.5,
        toy = 0,
    })
    local bg_box = self.objects.bg_box

    local btn_scale = 0.5
    local sound_width, sound_height = self.images_common.sound_on:getDimensions()
    local btn_y = bg_box.ty + font:getHeight() * 1.25 + sound_height * btn_scale * 0.5

    self.objects.btn_sound = Button({
        image = self.images_common.sound_on,
        x = window_width * 0.4,
        y = btn_y,
        sx = btn_scale, sy = btn_scale,
        ox = sound_width * 0.5, oy = sound_height * 0.5,
        is_hoverable = true, is_clickable = true,
    })
    local btn_sound = self.objects.btn_sound

    local bgm_width, bgm_height = self.images_common.bgm_on:getDimensions()
    self.objects.btn_bgm = Button({
        image = self.images_common.bgm_on,
        x = window_width * 0.6,
        y = btn_y,
        sx = btn_scale, sy = btn_scale,
        ox = bgm_width * 0.5, oy = bgm_height * 0.5,
        is_hoverable = true, is_clickable = true,
    })
    local btn_bgm = self.objects.btn_bgm

    local gap = 16

    local resume_width, resume_height = self.images_common.btn_resume:getDimensions()
    self.objects.btn_resume = Button({
        image = self.images_common.btn_resume,
        x = half_window_width,
        y = btn_bgm.y + bgm_height * btn_scale + gap,
        sx = 0.5, sy = 0.5,
        ox = resume_width * 0.5, oy = resume_height * 0.5,
        is_clickable = true, is_hoverable = true
    })

    local restart_width, restart_height = self.images_common.btn_restart:getDimensions()
    self.objects.btn_restart = Button({
        image = self.images_common.btn_restart,
        x = half_window_width,
        y = self.objects.btn_resume.y + resume_height * 0.5 + gap,
        sx = 0.5, sy = 0.5,
        ox = restart_width * 0.5, oy = restart_height * 0.5,
        is_clickable = true, is_hoverable = true
    })

    local main_menu_width, main_menu_height = self.images_common.btn_main_menu:getDimensions()
    self.objects.btn_main_menu = Button({
        image = self.images_common.btn_main_menu,
        x = half_window_width,
        y = self.objects.btn_restart.y + restart_height * 0.5 + gap,
        sx = 0.5, sy = 0.5,
        ox = main_menu_width * 0.5, oy = main_menu_height * 0.5,
        is_clickable = true, is_hoverable = true
    })

    self.objects.btn_resume.on_clicked = function()
        self.objects.bg_box = nil
        self.objects.btn_sound = nil
        self.objects.btn_bgm = nil
        self.objects.btn_resume = nil
        self.objects.btn_restart = nil
        self.objects.btn_main_menu = nil
        self.is_paused = false
        self.start = true
        self.objects.shuffle.is_hoverable = true
        self.objects.shuffle.is_hoverable = true
        self.objects.btn_shuffle.is_clickable = true
        self.objects.btn_shuffle.is_clickable = true
        self.objects.settings.is_clickable = true
        self.objects.settings.is_hoverable = true
    end

    self.objects.btn_restart.on_clicked = function()
        local next_state = require("game")
        StateManager:switch(next_state, self.difficulty, self.level)
    end

    self.objects.btn_main_menu.on_clicked = function()
        local next_state = require("menu")
        StateManager:switch(next_state, self.difficulty)
    end

    btn_sound.on_clicked = function()
        if btn_sound.image == self.images_common.sound_on then
            btn_sound.image = self.images_common.sound_mute
        else
            btn_sound.image = self.images_common.sound_on
        end

        for key, source in ipairs(self.sources) do
            if key ~= "bgm_gameplay" then
                local volume = source:getVolume()
                source:setVolume(math.abs(volume - 1))
            end
        end
    end

    btn_bgm.on_clicked = function()
        if btn_bgm.image == self.images_common.bgm_on then
            btn_bgm.image = self.images_common.bgm_mute
        else
            btn_bgm.image = self.images_common.bgm_on
        end

        local volume = self.sources.bgm_gameplay:getVolume()
        self.sources.bgm_gameplay:setVolume(math.abs(volume - 1))
    end
end

function Game:update(dt)
    if self.bgm_timer then self.bgm_timer:update(dt) end

    if self.is_game_over then
        for i = 1, #self.win_lose_buttons do
            local btn = self.win_lose_buttons[i]
            if btn then
                btn:update(dt)
            end
        end
        return
    end

    if self.powerups then
        self.powerups_timer = self.powerups_timer + dt
        if self.powerups_timer >= 10 then
            self.powerups_timer = 0
            self.powerups = false
        else
            self.remaining_shots = 3
        end
    end

    local p = self.objects.powerup
    if p then
        p.vy = 64
        p.r = p.r + dt
    end

    local obj_ready_go = self.objects.txt_ready_go
    if (not self.is_paused) and (not self.showing_info) and (obj_ready_go.alpha <= 0) then
        self.game_timer = self.game_timer - dt
        if self.game_timer <= 0 then
            self.game_timer = 0
            self:game_over()
        end
    end

    if not self.is_game_over and #self.bubbles == 0 then
        self:game_over(true)
    end

    local th = self.objects.time_holder
    if th then
        local str = Utils.sec_to_time_str(self.game_timer)
        th.text = string.format("Time: %s", str)
    end

    local ts = self.objects.score_holder
    if ts and self.score > 0 then
        ts.text = string.format("Score: %d", self.score)
    end

    if not self.start then
        self.ready_timer:update(dt)
        if self.ready_fade_timer then
            self.ready_fade_timer:update(dt)
        end
    end

    if self.wait_timer and not self.has_match then
        self.wait_timer:update(dt)
    end

    local border_height = self.images_common.bubble:getHeight()
    for _, border in ipairs(self.border) do
        self._top = border.y + border_height * border_scale * 0.5
    end
    self:check_hanging()

    local obj_input = self.waiting_for_input
    if obj_input then
        obj_input.is_hovered = true
    end

    local shooter = self.objects.shooter
    if self.start and shooter then
        local mx, my = love.mouse.getPosition()
        local r = Utils.get_angle(shooter, mx, my)
        self.rotation = r
        r = mathx.clamp(r, MIN_ANGLE, MAX_ANGLE)
        self.objects.shooter.r = r

        local ammo = self.objects.ammo
        if ammo then
            local is_static = ammo.vx == 0 and ammo.vy == 0
            if is_static then
                self.objects.ammo.r = r
            end
            ammo:update(dt)

            if not is_static then
                for _, other in ipairs(self.bubbles) do
                    if other ~= ammo then
                        local is_hit = ammo:check_collision(other)
                        if is_hit then
                            self:after_shoot()
                            break
                        end
                    end
                end

                for _, other in ipairs(self.border) do
                    if other ~= ammo then
                        local is_hit = ammo:check_collision(other, true)
                        if is_hit then
                            self:after_shoot()
                            break
                        end
                    end
                end
            end
        end
    end

    for i = #self.pop_timers, 1, -1 do
        local timer = self.pop_timers[i]
        if not timer:expired() then
            timer:update(dt)
        else
            table.remove(self.pop_timers, i)

            if #self.pop_timers == 0 then
                self.has_match = false
                self:resolve_post_shoot()
            end
        end
    end

    for i = #self.bubbles, 1, -1 do
        local bubble = self.bubbles[i]
        if bubble.is_dead then
            table.remove(self.bubbles, i)
        end
    end

    if self.border_move_timer then
        self.border_move_timer:update(dt)
    end

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:update(dt)
        end
    end

    --get the bubble that is in the lowest pos
    local lowest_bubble, lowest_y = nil, 0
    for _, bubble in ipairs(self.bubbles) do
        if bubble ~= self.objects.powerup and not bubble.should_fall then
            if bubble.y > lowest_y then
                lowest_bubble = bubble
                lowest_y = bubble.y
            end
        end
    end

    if lowest_bubble then
        local threshold = shooter.y - shooter.oy * shooter.sy
        if lowest_y + lowest_bubble.rad * lowest_bubble.sy >= threshold then
            local obj_heart = self.objects["heart_" .. self.hearts]
            if obj_heart then
                obj_heart.image = self.images_common.heart_empty
            end
            self.hearts = self.hearts - 1

            if self.hearts > 0 then
                self:wrong_answer(-self.increase * push_back[self.difficulty])
            else
                self:game_over()
            end
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

    if self.is_targeting then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.setLineWidth(4)
        for i = 3, #self.target_path do
            local v = self.target_path[i]
            local x1, y1 = v[1]:unpack()
            local x2, y2 = v[2]:unpack()
            love.graphics.line(x1, y1, x2, y2)
        end
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)
    end

    for _, border in ipairs(self.border) do
        love.graphics.draw(border.image, border.x, border.y, 0, border.scale, border.scale, border.ox, border.oy)
    end

    for _, bubble in ipairs(self.bubbles) do
        bubble:draw()
    end

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn then
            btn:draw()
        end
    end

    if self.pending_score then
        love.graphics.setColor(1, 0, 0, self.pending_score.alpha)
        local tmp_font = love.graphics.getFont()
        love.graphics.setFont(Resources.score_font)
        love.graphics.print(self.pending_score.text, self.pending_score.x, self.pending_score.y)
        love.graphics.setFont(tmp_font)
        love.graphics.setColor(1, 1, 1, 1)
    end
    -- local shooter = self.objects.shooter
    -- local threshold = shooter.y - shooter.oy * shooter.sy
    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.line(0, threshold, love.graphics.getWidth(), threshold)
    -- love.graphics.setColor(1, 1, 1, 1)
end

function Game:mousepressed(mx, my, mb)
    if self.is_game_over then
        for i = 1, #self.win_lose_buttons do
            local btn = self.win_lose_buttons[i]
            if btn and btn.mousepressed then
                local res = btn:mousepressed(mx, my, mb)
                if res then return end
            end
        end
        return
    end

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn and btn.mousepressed then
            local res = btn:mousepressed(mx, my, mb)
            if res then return end
        end
    end

    if self.start and self.can_shoot and not self.has_match then
        self.is_targeting = true
        self:update_target_path(mx , my)
    end
end

function Game:mousereleased(mx, my, mb)
    if self.is_game_over then
        for i = 1, #self.win_lose_buttons do
            local btn = self.win_lose_buttons[i]
            if btn and btn.mousereleased then
                local res = btn:mousereleased(mx, my, mb)
                if res then return end
            end
        end
        return
    end

    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn and btn.mousereleased then
            local res = btn:mousereleased(mx, my, mb)
            if res then return end
        end
    end

    if self.objects.shooter then
        local r = Utils.get_angle(self.objects.shooter, mx, my)
        if not (r >= MIN_ANGLE and r <= MAX_ANGLE) then
            self.is_targeting = false
            tablex.clear(self.target_path)
            return
        end
    end

    if self.start and self.is_targeting and not self.has_match then
        self.is_targeting = false
        if self.can_shoot and self.remaining_shots > 0 then
            self.can_shoot = false
            self:shoot(mx, my)
            self.remaining_shots = self.remaining_shots - 1
        end
    end
end

function Game:mousemoved(mx, my, dmx, dmy, istouch)
    if not self.is_targeting then return end
    if dmx ~= 0 or dmy ~= 0 then
        self:update_target_path(mx, my)
    end
end

function Game:keypressed(key)
    -- if key == "b" then
    --     local next_state = require("menu")
    --     StateManager:switch(next_state, self.difficulty)
    -- end
    -- if key == "q" then
    --     local bg_question = self.objects.bg_question
    --     if bg_question then
    --         bg_question.alpha = 0.1
    --         bg_question.text_alpha = 0.1
    --         for i = 1, self.n_choices do self.objects["choice_" .. i].alpha = 0.1 end
    --     end
    -- elseif key == "p" then
    --     self:open_settings()
    -- elseif key == "w" then
    --     self:game_over(true)
    -- elseif key == "l" then
    --     self:game_over()
    -- elseif key == "u" then
    --     self:show_powerup()
    -- elseif key == "n" then
    --     local next_state = require("game")
    --     self.level = self.level + 1
    --     if self.level > UserData.data.progress[self.difficulty].total then
    --         if self.difficulty == "easy" then
    --             self.difficulty = "medium"
    --         elseif self.difficulty == "medium" then
    --             self.difficulty = "hard"
    --         end
    --         self.level = UserData.data.progress[self.difficulty].current
    --     end
    --     StateManager:switch(next_state, self.difficulty, self.level)
    -- end

    local obj_input = self.waiting_for_input
    if obj_input then
        if key == "backspace" then
            local byteoffset = utf8.offset(obj_input.text, -1)
            if byteoffset then
                obj_input.text = string.sub(obj_input.text, 1, byteoffset - 1)
            end
        elseif key == "return" then
            love.keyboard.setKeyRepeat(false)
            love.keyboard.setTextInput(false)
            obj_input.value = obj_input.text
            self:check_answer(obj_input)
            self.waiting_for_input = nil
        end
    end
end

function Game:textinput(text)
    local obj_input = self.waiting_for_input
    if not obj_input then return end
    if #obj_input.text > self.max_answer_length then return end

    obj_input.text = obj_input.text .. text

    local font = Resources.font
    local padding = 64
    local window_width = love.graphics.getWidth()
    local choice_width, choice_height = self.images_common.box_choice:getDimensions()
    local choice_sx = (window_width - padding * 2)/choice_width
    local _, wrap_choice = font:getWrap(obj_input.text, obj_input.limit)
    local n = #wrap_choice

    if n > 1 then
        local choice_sy = obj_input.sy
        local txt_width = font:getWidth(obj_input.text)
        local txt_height = font:getHeight()

        local text_x = window_width * 0.5 - choice_width * choice_sx * 0.5 + txt_width * 0.5
        local text_y = obj_input.y - choice_height * choice_sy * 0.5 + txt_height * 0.5 + 8
        local tsx = (choice_width * choice_sx)/(txt_width + padding)
        local tsy = (choice_height * choice_sy)/(font:getHeight() * n)

        obj_input.tx = text_x
        obj_input.ty = text_y
        obj_input.tox = txt_width * 0.5
        obj_input.toy = txt_height * 0.5
        obj_input.tsx = tsx
        obj_input.tsy = tsy
        obj_input.is_printf = true
    end
end

function Game:mousefocus(focus)
    if not focus then
        self.is_targeting = false
        tablex.clear(self.target_path)
    end
end

function Game:exit()
    for _, source in pairs(self.sources) do
        source:stop()
    end
end

return Game
