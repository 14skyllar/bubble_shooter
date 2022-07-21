local Resources = {}

Resources.fonts = {
    roboto_bold = "roboto_bold.ttf"
}

Resources.images = {
    Menu = {
        "sparkle", "background", "title", "close", "btn_info", "gear", "box",
        "box_info", "box_easy", "box_medium", "box_hard", "button_play",
        "button_quit", "button_back", "button_settings", "button_scoreboard",
        "button_reset_levels", "button_easy", "button_medium", "button_hard",
        "button_arrow_left", "button_arrow_right", "text_settings",
        "text_volume", "text_difficulty", "text_scoreboard", "text_easy_score",
        "text_medium_score", "text_hard_score", "text_easy", "text_medium",
        "text_hard", "star_easy", "star_medium", "star_hard",
        "locked_star_easy", "locked_star_medium", "locked_star_hard", "knob",
        "slider_bg", "button_credits", "credits",
    },

    Game = {
        "background", "heart_empty", "bubble",
        "score_holder", "life_holder", "time_holder",
        "base", "text_ready_go", "shuffle", "box_choice",
        "bg_box", "text_lose", "whole_star",
        "text_level_cleared", "empty_star",
        "sound_on", "sound_mute", "bgm_on", "bgm_mute",
        "btn_resume", "btn_restart", "btn_main_menu",
        "btn_next", "btn_retry", "btn_stages",
    },

    Easy = {"heart", "label", "settings", "shooter", "bg_question", "bg_win_lose", "text_win", "powerup"},
    Medium = {},
    Hard = {},

    BubblesEasy = {},
    BubblesMedium = {},
    BubblesHard = {},
}

for i, str in ipairs(Resources.images.Easy) do
    Resources.images.Medium[i] = str
    Resources.images.Hard[i] = str
end

Resources.sources = {
    Menu = {
        {id = "bgm_gameplay", kind = "stream"},
        {id = "snd_buttons", kind = "static"},
    },

    Game = {
        {id = "snd_buttons", kind = "static"},
        {id = "snd_bubble_swap", kind = "static"},
        {id = "snd_bubble_pop", kind = "static"},
        {id = "snd_drop_bubbles", kind = "static"},
        {id = "snd_ready_go", kind = "stream"},
        {id = "bgm_level_cleared", kind = "stream"},
        {id = "bgm_gameplay", kind = "stream"},
    }
}

function Resources:init()
    local path = "assets/"
    local roboto_bold = self.fonts.roboto_bold
    self.font = love.graphics.newFont(path .. roboto_bold, 20)
    self.game_font = love.graphics.newFont(path .. roboto_bold, 16)
    self.wl_score_font = love.graphics.newFont(path .. roboto_bold, 38)
    self.pause_font = love.graphics.newFont(path .. roboto_bold, 26)
    self.score_font = love.graphics.newFont(path .. roboto_bold, 32)

    local bubbles_easy = love.filesystem.getDirectoryItems(path .. "images/BubblesEasy")
    for i, filename in ipairs(bubbles_easy) do
        self.images.BubblesEasy[i] = filename:sub(0, -5)
    end

    local bubbles_medium = love.filesystem.getDirectoryItems(path .. "images/BubblesMedium")
    for i, filename in ipairs(bubbles_medium) do
        self.images.BubblesMedium[i] = filename:sub(0, -5)
    end

    local bubbles_hard = love.filesystem.getDirectoryItems(path .. "images/BubblesHard")
    for i, filename in ipairs(bubbles_hard) do
        self.images.BubblesHard[i] = filename:sub(0, -5)
    end
end

return Resources
