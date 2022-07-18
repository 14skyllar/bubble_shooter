local UserData = require("user_data")

local Dev = {
    is_enabled = false
}

function Dev:draw()
    if self.is_enabled then
        love.graphics.setColor(1, 0, 0, 0.4)
        love.graphics.print("FPS: " .. love.timer.getFPS())

        local w, h = love.graphics.getDimensions()
        love.graphics.line(w * 0.5, 0, w * 0.5, h)
        love.graphics.line(0, h * 0.5, w, h * 0.5)
    end
end

function Dev:keypressed(key)
    if key == "`" then
        self.is_enabled = not self.is_enabled
    elseif key == "d" then
        love.filesystem.remove(UserData.filename)
    elseif key == "r" then
        love.event.quit("restart")
    end
end

return Dev
