-- ITurtle v1.0.1 made by w00tyd00d

-- Simple turtle library wrapper for
-- running iterative movement scripts
-- in a declarative fashion.

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

    elseif ARGS[1] == "shift" then
        print("Shifts the turtle left or right.")
    end

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

elseif ARGS[1] == "shift" then
    if ARGS[2] ~= "left" and ARGS[2] ~= "right" then
        print("Direction must be left or right.")
        return
    end

    local count = ARGS[3] and tonumber(ARGS[3]) or 1
    count = math.max(0, count)

    if ARGS[2] == "left" then
        API.shiftLeft(count)
    else
        API.shiftRight(count)
    end
end