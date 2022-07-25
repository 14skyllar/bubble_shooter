local StateManager = {
    current = nil
}

function StateManager:switch(next_state, ...)
    if self.current.exit then
        self.current:exit()
    end

    self.current = next_state(...)
    self.current:load(...)
end

function StateManager:load(...)
    self.current:load(...)
end

function StateManager:update(dt)
    self.current:update(dt)
end

function StateManager:draw()
    self.current:draw()
end

function StateManager:mousepressed(mx, my, mb)
    if self.current.mousepressed then
        self.current:mousepressed(mx, my, mb)
    end
end

function StateManager:mousereleased(mx, my, mb)
    if self.current.mousereleased then
        self.current:mousereleased(mx, my, mb)
    end
end

function StateManager:mousemoved(mx, my, dmx, dmy, istouch)
    if self.current.mousemoved then
        self.current:mousemoved(mx, my, dmx, dmy, istouch)
    end
end

function StateManager:keypressed(key)
    if self.current.keypressed then
        self.current:keypressed(key)
    end
end

function StateManager:textinput(text)
    if self.current.textinput then
        self.current:textinput(text)
    end
end

function StateManager:mousefocus(focus)
    if self.current.mousefocus then
        self.current:mousefocus(focus)
    end
end

return StateManager
