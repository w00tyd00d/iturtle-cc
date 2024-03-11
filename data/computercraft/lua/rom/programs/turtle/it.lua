local API = require("iturtle")

local DIRECTIONS = {
    north = true,
    east = true,
    south = true,
    west = true
}

local ARGS = {...}

if #ARGS == 0 then
    print("Usages:")
    print("it compass <direction>")
    print("it face <direction>")
    print("it shift <left|right> [count]")

    return
end

if #ARGS == 1 then
    if ARGS[1] == "compass" then
        print("Registers turtle's facing direction.")
        print("Must be north, south, east, or west.")

    elseif ARGS[1] == "face" then
        print("Sets facing direction based on compass.")
        print("Must be north, south, east, or west.")

    return
end

if ARGS[1] == "compass" then
    if not DIRECTIONS[ARGS[2]] then
        print("Must be north, south, east, or west.")
        return
    end
    API.registerDirection(ARGS[2])

elseif ARGS[1] == "face" then
    if not DIRECTIONS[ARGS[2]] then
        print("Must be north, south, east, or west.")
        return
    end
    API.setDirection(ARGS[2])
end