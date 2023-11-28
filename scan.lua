local geo = peripheral.wrap("back")

local minStrength = 5

local interestingOres = {
    "minecraft:diamond_ore",
    "minecraft:deepslate_diamond_ore",
}

local function contains(t, elem, isKey)
    for k, v in pairs(t) do
        if (key and k == elem) or (not key and v == elem) then
            return true
        end
    end
    return false
end

local function min(t, cmp)
    local min = t[1]
    for _, v in ipairs(t) do
        if cmp(v, min) then
            min = v
        end
    end
    return min
end

local function flatten(t)
    local flat = {}
    for _, innerT in pairs(t) do
        for _, v in pairs(innerT) do
            flat[#flat + 1] = v
        end
    end
    return flat
end

local function mag(vec)
    return math.sqrt(vec.x*vec.x + vec.y*vec.y + vec.z*vec.z)
end

local function empty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

local function vec2dir(vec)
    local x = math.abs(vec.x)
    local y = math.abs(vec.y)
    local z = math.abs(vec.z)
    if x > 0.6 then
        if vec.x < 0 then
            return "west"
        else
            return "east"
        end
    elseif z > 0.6 then
        if vec.z < 0 then
            return "north"
        else
            return "south"
        end
    elseif y > 0.6 then
        if vec.y < 0 then
            return "down"
        else
            return "up"
        end
    else
        return "nowhere"
    end
end

local function scan(radius, filter)
    local scanData
    while scanData == nil do
        scanData = geo.scan(radius)
    end

    local grouping = {}
    for _, block in ipairs(scanData) do
        local coords = grouping[block.name]
        if contains(filter, block.name) then
            coords = coords or {}
            coords[#coords + 1] = {x = block.x, y = block.y, z = block.z}
            grouping[block.name] = coords
        end
    end

    return grouping
end

local strength = 8
while true do
    local scanResults = scan(math.min(strength, 16), interestingOres)
    if not empty(scanResults) then
        local closest = min(flatten(scanResults), function(a, b) return mag(a) < mag(b) end)
        print(string.format("radius: %d, distance: %.2f, go %s", strength, mag(closest), vec2dir(closest)))
        strength = math.min(math.max(math.floor(1.3 * mag(closest)), 5), 16)
    else
        print(string.format("current radius: %d, no ores found", strength))
        strength = math.min(strength * 1.5, 16)
    end
end