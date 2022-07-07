local Colors = {}

local data = {
    red = {
        "AC", "AL", "AM"
    },
    blue = {

    }
}

local cache = {}

function Colors.get_color(key)
    if cache[key] then
        return cache[key]
    end

    for color, names in pairs(data) do
        for _, name in ipairs(names) do
            if name == key then
                if not cache[key] then
                    cache[key] = color
                end
                return color
            end
        end
    end
    error(key .. " not found")
end

return Colors
