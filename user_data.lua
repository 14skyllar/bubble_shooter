local JSON = require("libs.json.json")

local UserData = {
    filename = "data.json",
    data = {
        main_volume = 1,
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

return UserData
