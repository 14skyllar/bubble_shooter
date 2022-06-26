local Resources = require("resources")

local Utils = {}

function Utils.load_images(current_scene_id)
    local images = {}
    for _, id in ipairs(Resources.images[current_scene_id]) do
        local path = string.format("assets/images/%s/%s.png", current_scene_id, id)
        local image = love.graphics.newImage(path)
        -- image:setFilter("nearest", "nearest") --for pixel art look
        images[id] = image
    end
    return images
end


return Utils
