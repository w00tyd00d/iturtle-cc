local API = require("iturtle")

local DIRECTIONS = {
    north   = true,
    east    = true,
    south   = true,
    west    = true
}

local MOVE_ACTIONS  = {
    left    = true,
    right   = true,
    forward = true,
    back    = true,
    down    = true,
    up      = true
}


local ARGS = {...}

local function compass_repsonse()
    local direction = API.getDirection()

    if not direction then
        print("Compass currently unregistered.")
        return
    end

    print("Current facing direction is:", direction)
end


if #ARGS == 0 then
    print("Usages:")
    print("it compass <direction>")
    print("it face <direction>")
    print("it go <direction> <distance>")
    print("it navigate <local|to> <x> <y> <z>")
    return
end

if #ARGS == 1 then
    if ARGS[1] == "compass" then
        print("Registers turtle's facing direction.")
        print("Must be north, south, east, or west.")
        compass_repsonse()

    elseif ARGS[1] == "face" then
        print("Sets facing direction based on compass.")
        print("Must be north, south, east, or west.")
        compass_repsonse()

    elseif ARGS[1] == "navigate" then
        print("Moves the turtle to a specific point.\n")
        print("Can be global coordinates (gps required) or can be local coordinates based on the turtle's rotation.")

    elseif ARGS[1] == "go" then
        print("Same as normal 'go' program.")
        prin("Uses ITurtle API for compass tracking.")
    end

    return
end

if #ARGS == 2 then
    if ARGS[1] == "navigate" then
        if ARGS[2] == "local" then
            print("Moves the turtle locally.")
            print("Equivalent to using: /tp ^x ^y ^z")

        elseif ARGS[2] == "to" or ARGS[2] == "global" then
            print("Moves the turtle to a coordinate.")
            print("Equivalent to using: /tp x y z")
            print("Requires functioning gps in range.")
        end
    end
end

-- #ARGS > 2

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

elseif ARGS[1] == "navigate" then
    if ARGS[2] == "local" then
        local x = tonumber(ARGS[3])
        local y = ARGS[4] == nil and 0 or tonumber(ARGS[4])
        local z = ARGS[5] == nil and 0 or tonumber(ARGS[5])

        if not x or not y or not z then
            print("Must use valid numbers.")
            return
        end

        API.navigateLocal(x, y, z)

    elseif ARGS[2] == "to" or ARGS[2] == "global" then
        local x = tonumber(ARGS[3])
        local y = ARGS[4] == nil and 0 or tonumber(ARGS[4])
        local z = ARGS[5] == nil and 0 or tonumber(ARGS[5])

        if not x or not y or not z then
            print("Must use valid numbers.")
            return
        end

        local sx, sy, sz = gps.locate()

        if not sx then
            print("No valid gps data found.")
            return
        end

        API.navigateToPoint(x, y, z)
    end

elseif ARGS[1] == "go" then
    local action

    for i=2, #ARGS do
        local arg = ARGS[i]
        local num = tonumber(arg)

        if not MOVE_ACTIONS[arg] and ((not num) or (num and num < 0)) then
            print("Must use valid directions or numbers.")
            return
        end
    end

    for i=2, #ARGS do
        local arg = ARGS[i]
        
        if MOVE_ACTIONS[arg] then
            arg = arg == "left" and "turnLeft" or arg
            arg = arg == "right" and "turnRight" or arg
            if action then 
                API[action]() 
            end
            action = arg
        elseif tonumber(arg) ~= nil and action then
            local _, res = API.loop(function()
                if API.getFuelLevel() == 0 then
                    return "Out of fuel"
                end
                API[action]()
            end, nil, tonumber(arg))

            if res then
                print(res)
                return
            end
            
            action = nil
        else
            print("No such direction:", arg)
            print("Try: forward, back, up, down")
        end

    end

    if action then API[action]() end
end