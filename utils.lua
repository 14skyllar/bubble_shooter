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

function Utils.load_sources(current_scene_id)
    local sources = {}
    for _, data in ipairs(Resources.sources[current_scene_id]) do
        local id = data.id
        local path = string.format("assets/sources/%s.ogg", id)
        local source = love.audio.newSource(path, data.kind)
        sources[id] = source
    end
    return sources
end

function Utils.get_angle(obj, x, y)
    local dx = obj.x - x
    local dy = obj.y - y
    local r = -math.atan2(dx, dy)
    return r
end

function Utils.sec_to_time_str(seconds)
  local min = math.floor((seconds % 3600)/60)
  local sec = math.floor((seconds % 60))
  return string.format("%02d:%02d", min, sec)
end

return Utils
