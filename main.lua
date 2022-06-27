require("libs.batteries"):export()

local Dev = require("dev")
local MainMenu = require("main_menu")
local UserData = require("user_data")

local current_scene
local canvas
-- local scale_x, scale_y

function love.load()
    UserData:init()

    -- local window_width, window_height = love.graphics.getDimensions()
    local target_width, target_height = 1080, 1920

    -- scale_x = target_width/window_width
    -- scale_y = target_height/window_height

    canvas = love.graphics.newCanvas(target_width, target_height)

    current_scene = MainMenu()
    current_scene:load()
end

function love.update(dt)
    current_scene:update(dt)
end

function love.draw()
    love.graphics.setCanvas(canvas)
        love.graphics.clear()

        love.graphics.push()
            -- love.graphics.scale(scale_x, scale_y)
            current_scene:draw()
        love.graphics.pop()
    love.graphics.setCanvas()

    love.graphics.draw(canvas)

    Dev:draw()
end

function love.mousepressed(mx, my, mb)
    current_scene:mousepressed(mx, my, mb)
end

function love.mousereleased(mx, my, mb)
    current_scene:mousereleased(mx, my, mb)
end

function love.keypressed(key)
    Dev:keypressed(key)
end

function love.quit()
    UserData:save()
end
