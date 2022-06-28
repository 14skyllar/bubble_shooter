local Resources = {
    font = nil
}

Resources.fonts = {
    roboto_bold = "roboto_bold.ttf"
}

Resources.images = {
    MainMenu = {
        "background",
        "title",
        "box",
        "box_easy",
        "box_medium",
        "box_hard",
        "button_play",
        "button_quit",
        "button_back",
        "button_scoreboard",
        "button_settings",
        "button_reset_levels",
        "button_easy",
        "button_medium",
        "button_hard",
        "text_settings",
        "text_volume",
        "text_difficulty",
        "text_scoreboard",
        "text_easy_score",
        "text_medium_score",
        "text_hard_score",
        "text_easy",
        "text_medium",
        "text_hard",
        "logo_easy",
        "logo_medium",
        "logo_hard",
        "star_easy",
        "star_medium",
        "star_hard",
        "locked_star_easy",
        "locked_star_medium",
        "locked_star_hard",
    }
}

Resources.sources = {
    MainMenu = {
        -- {id = "bgm", kind = "stream"}
    }
}

function Resources:init()
    local path = "assets/"
    self.font = love.graphics.newFont(path .. self.fonts.roboto_bold, 20)
end

return Resources
