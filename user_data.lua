local JSON = require("libs.json.json")

local UserData = {
    filename = "data.json",
    data = {
        main_volume = 1,

        levels = {
            easy = {},
            medium = {},
            hard = {},
        }
    },
}

function UserData:init()
    if not love.filesystem.getInfo(self.filename) then
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
    local levels = UserData.data.levels
    for i = 1, 20 do
        if i <= 10 then levels.easy[i] = i == 1 end
        if i <= 15 then levels.medium[i] = false end
        if i <= 20 then levels.hard[i] = false end
    end
end

UserData:reset_levels()

return UserData
