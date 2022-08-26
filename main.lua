require("libs.batteries"):export()

-- local Dev = require("dev")
local Game = require("game")
local Menu = require("menu")
local Resources = require("resources")
local StateManager = require("state_manager")
local UserData = require("user_data")

local canvas
-- local scale_x, scale_y

function love.load()
    UserData:init()
    Resources:init()

    -- local window_width, window_height = love.graphics.getDimensions()
    local target_width, target_height = 1080, 1920

    -- scale_x = target_width/window_width
    -- scale_y = target_height/window_height

    canvas = love.graphics.newCanvas(target_width, target_height)

    -- to start in main menu, comment the next two lines
    -- StateManager.current = Game("easy", 1)

    -- then uncomment this
    StateManager.current = Menu()

    StateManager:load()
end

function love.update(dt)
    StateManager:update(dt)
end

function love.draw()
    love.graphics.setCanvas(canvas)
        love.graphics.clear()

        love.graphics.push()
            -- love.graphics.scale(scale_x, scale_y)
            StateManager:draw()
        love.graphics.pop()
    love.graphics.setCanvas()

    love.graphics.draw(canvas)

    -- Dev:draw()
end

function love.mousepressed(mx, my, mb)
    StateManager:mousepressed(mx, my, mb)
end

function love.mousereleased(mx, my, mb)
    StateManager:mousereleased(mx, my, mb)
end

function love.mousemoved(mx, my, dmx, dmy, istouch)
    StateManager:mousemoved(mx, my, dmx, dmy, istouch)
end

function love.keypressed(key)
    -- Dev:keypressed(key)
    StateManager:keypressed(key)
end

function love.textinput(text)
    StateManager:textinput(text)
end

function love.mousefocus(focus)
    StateManager:mousefocus(focus)
end

function love.quit()
    UserData:save()
end
