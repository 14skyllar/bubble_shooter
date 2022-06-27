local Dev = {
    is_enabled = false
}

function Dev:draw()
    if self.is_enabled then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("FPS: " .. love.timer.getFPS())
    end
end

function Dev:keypressed(key)
    if key == "`" then
        self.is_enabled = not self.is_enabled
    end
end

return Dev
