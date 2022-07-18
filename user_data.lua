local JSON = require("libs.json.json")

local UserData = {
    filename = "data.json",
    data = {
        main_volume = 1,

        progress = {
            easy = {current = 1, total = 10},
            medium = {current = 0, total = 15},
            hard = {current = 0, total = 20},
        },

        scores = {
            easy = {current = 0},
            medium = {current = 0},
            hard = {current = 0},
        },
    },
}

function UserData:init()
    if not love.filesystem.getInfo(self.filename) then
        UserData:reset_levels()
        local data = JSON.encode(self.data)
        love.filesystem.write(self.filename, data)
        pretty.print(self.data)
    else
        local str_data = love.filesystem.read(self.filename)
        self.data = JSON.decode(str_data)
        print("loaded save data")
        pretty.print(self.data)
    end

    love.audio.setVolume(self.data.main_volume)
end

function UserData:save()
    local data = JSON.encode(self.data)
    love.filesystem.write(self.filename, data)
    print("saved save data")
    pretty.print(self.data)
end

function UserData:reset_levels()
    local progress = UserData.data.progress
    progress.easy.current = 1
    progress.medium.current = 0
    progress.hard.current = 0
    print("levels reset")

    local score = UserData.data.scores
    score.easy.current = 0
    score.medium.current = 0
    score.hard.current = 0
    print("scores reset")
end

return UserData
