local Colors = {}

local data = {
    red = {
        "AC", "AM", "BK", "CF", "CM", "ES", "FM", "LR", "MD", "NO", "NP", "PA",
        "PU", "TH", "U"
    },
    dark_blue = {
        "H", "P", "N", "O", "C", "S", "SE"
    },
    light_blue = {
        "AG", "AU", "BH", "CD", "CN", "CO", "CR", "CU", "DB", "DS", "FE", "HF",
        "HG", "HS", "IR", "MN", "MO", "MT", "NB", "NI", "OS", "PD", "PT", "RE",
        "RF", "RG", "RH", "RU", "SC", "SG", "TA", "TC", "TI", "V", "W", "Y",
        "ZN", "ZR"
    },
    green = {
        "AS", "B", "GE", "PO", "SB", "SI", "TE"
    },
    yellow_green = {
        "YB", "TM", "TB", "SM", "PM", "PR", "ND", "LU", "LE", "HO", "GD", "EU",
        "DY", "ER", "CE"
    },
    violet = {
        "BA", "BE", "CA", "MG", "RA", "SR"
    },
    orange = {
        "AL", "BI", "FI", "GA", "IN", "TL", "LV", "MC", "NH", "PB", "SN"
    },
    yellow = {
        "TS", "I", "F", "CL", "BR", "AT"
    },
    pink = {
        "CS", "FR", "K", "LI", "NA", "RB"
    },
    yellow_gold = {
        "AR", "HE", "KR", "NE", "OG", "RN", "XE"
    },
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
