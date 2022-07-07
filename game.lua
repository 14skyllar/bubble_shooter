local Bubble = require("bubble")
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

local n_choices = {
    easy = 4,
    medium = 2,
    hard = 4,
}

local game_timers = {
    easy = 5 * 60,
    medium = 4 * 60,
    hard = 3 * 60,
}

local scoring = {
    easy = 3,
    medium = 4,
    hard = 5,
}

local MIN_ANGLE, MAX_ANGLE = -0.9, 0.9

local fade_in_sec = 2
local fade_out_sec = 1
local info_show_dur = 1.5
local info_dur = 0.5
local wrong_dur = 1.5
local pop_dur = 1

--TODO remove these
fade_in_sec = 0.1
fade_out_sec = 0.1
info_show_dur = 0.1
info_dur = 0.1
wrong_dur = 0.1
pop_dur = 0.25

function Game:new(difficulty, level, hearts)
    local id = self:type()
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
        "base", "shooter", "ammo", "shuffle",
        "txt_ready_go",
        "bg_question", "bg_box", "bg_win_lose", "text_lose", "text_win",
        "text_level_cleared",
    }

    for i = 1, self.max_hearts do table.insert(self.objects_order, "heart_" .. i) end

    self.current_question = nil
    self.questions = tablex.copy(require("questions." .. difficulty))
    self.n_choices = n_choices[difficulty]
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
    local border_scale = 0.4
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
        x = gap * 5,
        y = self.objects.base.y - shuffle_height,
        sx = shuffle_scale, sy = shuffle_scale,
        ox = shuffle_width * 0.5, oy = shuffle_height * 0.5,
        is_clickable = false, is_hoverable = false
    })
    self.objects.shuffle.on_clicked = function() self:shuffle() end

    self.ready_timer = timer(fade_in_sec, function(progress)
        local txt_ready_go = self.objects.txt_ready_go
        txt_ready_go.alpha = progress
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

    self:create_bubbles(border_height, border_scale)
end

function Game:show_question()
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
    local choice_sx = (window_width - padding * 2)/choice_width
    local choice_sy = ((self.objects.bg_question.half_size.y - padding)/choice_height)/self.n_choices
    local ascii = 97

    local _, wrap = font:getWrap(self.current_question.question, limit)
    ty = ty + font:getHeight() * (#wrap + 2)

    for i = 1, self.n_choices do
        local key = "choice_" .. i
        local letter = string.char(ascii)
        local str_question = self.current_question[letter]
        local txt_width = font:getWidth(str_question)
        local txt_height = font:getHeight()

        self.objects[key] = Button({
            image = self.images_common.box_choice,
            x = half_window_width,
            y = ty + (choice_height + margin * 1.5) * choice_sy * (i - 1),
            sx = choice_sx,
            sy = choice_sy,
            ox = choice_width * 0.5,
            oy = choice_height * 0.5,
            font = font,
            text = str_question,
            tox = txt_width * 0.5,
            toy = txt_height * 0.5,
            value = letter,
        })
        self.objects[key].on_clicked = function()
            self:check_answer(self.objects[key])
        end

        ascii = ascii + 1
        if ascii > 100 then
            ascii = 97
        end
    end

    self.is_question = true
    self.can_shoot = true
end

function Game:check_answer(choice_obj)
    for i = 1, self.n_choices do
        local obj = self.objects["choice_" .. i]
        obj.is_hoverable = false
        obj.is_clickable = false
    end

    if choice_obj.value == self.current_question.answer then
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

    self.wait_timer = timer(info_show_dur,
        function(progress)
            obj_question.text_alpha = 1 - progress
            for i = 1, self.n_choices do
                self.objects["choice_" .. i].alpha = 1 - progress
            end
        end,
        function()
            obj_question.text = self.current_question.info
            obj_question.text_alpha = 1
            for i = 1, self.n_choices do self.objects["choice_" .. i] = nil end

            self.wait_timer = timer(info_dur, nil, function()
                self.objects.shuffle.is_hoverable = true
                self.objects.shuffle.is_clickable = true
                self.objects.settings.is_clickable = true
                self.objects.settings.is_hoverable = true
                self.objects.bg_question = nil
                self.remaining_shots = 3
                self.start = true
                self.is_question = false
                self:reload()
            end)
        end)
end

function Game:wrong_answer(increase)
    increase = increase or self.increase
    if #self.questions == 0 then
        self.questions = tablex.copy(require("questions." .. self.difficulty))
    end
    self.border_move = true

    self.objects.bg_question.alpha = 0.5
    for i = 1, self.n_choices do
        self.objects["choice_" .. i].alpha = 0.5
    end

    for _, border in ipairs(self.border) do border.target_y = border.y + increase end
    for _, bubble in ipairs(self.bubbles) do bubble.target_y = bubble.y + increase end
    self.border_y = self.border_y + increase
    self.border_move_timer = timer(wrong_dur,
        function(progress)
            for _, border in ipairs(self.border) do border.y = mathx.lerp(border.y, border.target_y, progress) end
            for _, bubble in ipairs(self.bubbles) do bubble.y = mathx.lerp(bubble.y, bubble.target_y, progress) end
        end,
        function()
            self:show_question()
        end)
end

function Game:create_bubbles(border_height, border_scale)
    local half_window_width = love.graphics.getWidth() * 0.5
    local bubble_scale = 2

    if self.difficulty == "easy" then
        for i = 0, self.rows - 1 do
            local cols = self.rows - i
            for j = 0, cols - 1 do
                local key = tablex.pick_random(self.bubbles_key)
                local image = self.images_bubbles[key]
                local width, height = image:getDimensions()

                local x = half_window_width - (cols * 0.5) * (width * bubble_scale)
                x = x + (width * bubble_scale) * j

                local y = self.border_y + (border_height * border_scale) + height * 0.5
                y = y + height * bubble_scale * i

                local bubble = Bubble({
                    image = image,
                    x = x, y = y,
                    sx = bubble_scale, sy = bubble_scale,
                    ox = width * 0.5, oy = height * 0.5,
                })

                table.insert(self.bubbles, bubble)
            end
        end
    elseif self.difficulty == "medium" then

    elseif self.difficulty == "hard" then

    end

    -- compress initial bubbles
    for _, bubble in ipairs(self.bubbles) do
        bubble.vy = -8
        bubble.y = bubble.y + bubble.vy * love.timer.getDelta()
        for _, border in ipairs(self.border) do
            bubble:check_collision(border, true)
        end
        bubble.vy = 0
    end
end

function Game:shuffle()
    local temp_images = {}
    for _, bubble in ipairs(self.bubbles) do
        table.insert(temp_images, bubble.image)
    end
    for _, bubble in ipairs(self.bubbles) do
        local new_image = tablex.take_random(temp_images)
        bubble.image = new_image
    end
end

function Game:after_shoot()
    local ammo = self.objects.ammo

    local stack = {ammo}
    local found = {}
    found[ammo] = true

    while #stack > 0 do
        local current = table.remove(stack, 1)
        local within_radius = current:get_within_radius(self.bubbles)
        for _, bubble in ipairs(within_radius) do
            if not found[bubble] then
                found[bubble] = true
                table.insert(stack, bubble)
            end
        end
    end

    local matches = #tablex.keys(found)
    if matches >= 3 then
        self.has_match = true
        for k in pairs(found) do
            for i = #self.bubbles, 1, -1 do
                local bubble = self.bubbles[i]
                if bubble == k then
                    local t = timer(pop_dur,
                        function(progress)
                            bubble.alpha = 1 - progress
                            ammo.alpha = 1 - progress
                        end,
                        function()
                            bubble.is_dead = true
                            ammo.is_dead = true
                        end)

                    table.insert(self.pop_timers, t)
                end
            end
        end
    end

    if ammo then
        table.insert(self.bubbles, ammo)
    end

    self.objects.ammo = nil

    if matches >= 3 then
        return
    end

    self:resolve_post_shoot()
end

function Game:resolve_post_shoot()
    if self.remaining_shots == 0 and not self.is_question then
        self.can_shoot = false
        self.wait_timer = timer(0.5, nil, function() self:show_question() end)
    else
        self:reload()
        self.can_shoot = true
    end
end

function Game:reload()
    local present_bubbles = {}
    for _, bubble in ipairs(self.bubbles) do
        table.insert(present_bubbles, bubble.image)
    end
    local image = tablex.pick_random(present_bubbles)
    local width, height = image:getDimensions()
    local bubble_scale = 2
    local shooter = self.objects.shooter

    self.objects.ammo = Bubble({
        image = image,
        x = shooter.x, y = shooter.y,
        sx = bubble_scale, sy = bubble_scale,
        ox = width * 0.5, oy = height * 0.75,
        main_oy = height * 0.5,
    })
end

function Game:update_target_path(mx, my)
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
end

function Game:game_over(has_won)
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
    local bg_sy = (half_window_height)/bg_height

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
        x = half_window_width, y = half_window_height + 48,
        sx = 1, sy = 1,
        ox = box_width * 0.5, oy = box_height * 0.5,
        is_hoverable = false, is_clickable = false,
    })
    local bg_win_lose = self.objects.bg_win_lose
    local font = Resources.wl_score_font
    local star_image

    if has_won then
        star_image = self.images_common.whole_star
        local score = scoring[self.difficulty]
        local win_width, win_height = self.images_common.text_win:getDimensions()
        local win_sx = (box_width - 32)/win_width
        local win_sy = (box_height * 0.35)/win_height
        local text = "SCORE: " .. score
        local y = bg_win_lose.y - bg_win_lose.half_size.y + win_height * win_sy

        self.objects.text_win = Button({
            image = self.images_common.text_win,
            x = bg_win_lose.x,
            y = y,
            sx = win_sx, sy = win_sy,
            ox = win_width * 0.5,
            oy = win_height * 0.5,
            is_clickable = false, is_hoverable = false,
            text_color = {1, 1, 1},
            text = text,
            font = font,
            tx = bg_win_lose.x,
            ty = y + font:getHeight(),
            tox = font:getWidth(text) * 0.5,
            toy = font:getHeight() * 0.25,
        })
    else
        star_image = self.images_common.empty_star
        local lose_width, lose_height = self.images_common.text_lose:getDimensions()
    end

    local star_width, star_height = star_image:getDimensions()
    local star_sx = has_won and 0.5 or 0.75
    local star_sy = has_won and 0.5 or 0.75
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
end

function Game:update(dt)
    if self.is_game_over then return end

    self.game_timer = self.game_timer - dt
    if self.game_timer <= 0 then
        self:game_over()
    end

    if #self.bubbles == 0 then
        self:game_over(true)
    end

    local th = self.objects.time_holder
    th.text = string.format("Time: %d", self.game_timer)

    if not self.start then
        self.ready_timer:update(dt)
        if self.ready_fade_timer then
            self.ready_fade_timer:update(dt)
        end
    end

    if self.wait_timer and not self.has_match then
        self.wait_timer:update(dt)
    end

    if self.start then
        local shooter = self.objects.shooter
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

    if self.border_move then
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
        if bubble.y > lowest_y then
            lowest_bubble = bubble
            lowest_y = bubble.y
        end
    end

    if lowest_bubble then
        local shooter = self.objects.shooter
        local threshold = shooter.y - shooter.oy * shooter.sy + 32
        if lowest_y + lowest_bubble.rad * lowest_bubble.sy >= threshold then
            local obj_heart = self.objects["heart_" .. self.hearts]
            if obj_heart then
                obj_heart.image = self.images_common.heart_empty
            end
            self.hearts = self.hearts - 1

            if self.hearts > 0 then
                self:wrong_answer(-self.increase * 3)
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
end

function Game:mousepressed(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn and btn.mousepressed then
            local res = btn:mousepressed(mx, my, mb)
            if res then
                btn.was_clicked = true
                return
            end
        end
    end

    if self.start and self.can_shoot and not self.has_match then
        self.is_targeting = true
        self:update_target_path(mx , my)
    end
end

function Game:mousereleased(mx, my, mb)
    for _, id in ipairs(self.objects_order) do
        local btn = self.objects[id]
        if btn and btn.was_clicked then
            btn.was_clicked = false
            return
        end
    end

    local r = Utils.get_angle(self.objects.shooter, mx, my)
    if not (r >= MIN_ANGLE and r <= MAX_ANGLE) then
        self.is_targeting = false
        tablex.clear(self.target_path)
        return
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
    if key == "w" then
        self:game_over(true)
    end
end

return Game
