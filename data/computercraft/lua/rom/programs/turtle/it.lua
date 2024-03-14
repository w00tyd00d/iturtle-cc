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

local function version_respons()
    print("ITurtle Library Version "..API.getVersion())
end

local function compass_repsonse()
    local direction = API.getDirection()

    if not direction then
        print("Compass currently unregistered.")
        return
    end

    print("Current facing direction is:", direction)
end

local function order_response()
    print("Initial order must be string of axes.")
    print("Eg: xyz, yx, zxy, y")
end

if #ARGS == 0 then
    print("Usages:")
    print("it version")
    print("it compass <direction>")
    print("it face <direction>")
    print("it go <direction> <distance>")
    print("it navigate <local|global> <x> <y> <z>")
    print("it navigate <to> <location>")
    return
end

-- Doesn't matter how many more args it has
if ARGS[1] == "version" then
    print("ITurtle Library Version "..API.getVersion())
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
        print("Uses ITurtle API for compass tracking.")
    end

    return
end

if #ARGS == 2 then
    if ARGS[1] == "navigate" then
        if ARGS[2] == "local" then
            print("Move the turtle based on rotation.")
            print("Equivalent to using: /tp ^x ^y ^z")

        elseif ARGS[2] == "global" then
            print("Move the turtle to a coordinate.")
            print("Equivalent to using: /tp x y z")
            print("Requires functioning gps in range.")

        elseif ARGS[2] == "to" then
            print("Move the turtle to a known location.")
            print("Requires location to be registered.")

        end
       
        return

    elseif ARGS[1] == "location" then
        if ARGS[2] == "get" then
            print("Get coordinates of a known location.")
            print("Requires location to be registered.")

        elseif ARGS[2] == "set" then
            print("Record coordinates of a location.")

        end

        return
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

elseif ARGS[1] == "location" then

    if ARGS[2] == "set" then
        local label = ARGS[3]
        local x, y, z

        if ARGS[4] then
            x = tonumber(ARGS[4])
            y = tonumber(ARGS[5])
            z = tonumber(ARGS[6])

            if not x or not y or not z then
                print("Must use valid coordinates.")
                return
            end

            API.registerLocation(label, x, y, z)
            return
        end

        API.registerLocation(label)    

    elseif ARGS[2] == "get" then
        local label = ARGS[3]
        local x, y, z = API.getLocation(label)

        if not x then
            print("Must be a registered location.")
            return
        end

        -- ADD SUPPORT FOR WILDCARD CHAR : *
        -- WILL RETURN ALL RESULTS

        print(label.." : ("..x..", "..y..", "..z..")")
    end
    

elseif ARGS[1] == "navigate" then
    
    if ARGS[2] == "local" then
        local x = tonumber(ARGS[3])
        local y = ARGS[4] == nil and 0 or tonumber(ARGS[4])
        local z = ARGS[5] == nil and 0 or tonumber(ARGS[5])

        if not x or not y or not z then
            print("Must use valid numbers.")
            return
        end

        local order = ARGS[6]

        if order then
            if #order > 3 then
                order_response()
                return
            end

            local valid = {x = true, y = true, z = true}
            local seen  = {}

            for char in order:gmatch(".") do
                if not valid[char] or seen[char] then
                    order_response()
                    return
                end
                seen[char] = true
            end
        end

        API.navigateLocal(x, y, z, order)

    elseif ARGS[2] == "global" then
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

        local order = ARGS[6]

        if order then
            if #order > 3 then
                order_response()
                return
            end

            local valid = {x = true, y = true, z = true}
            local seen  = {}

            for char in order:gmatch(".") do
                if not valid[char] or seen[char] then
                    order_response()
                    return
                end
                seen[char] = true
            end
        end

        API.navigateToPoint(x, y, z, order)

    elseif ARGS[2] == "to" then
        local order = ARGS[4]

        if order then
            if #order > 3 then
                order_response()
                return
            end

            local valid = {x = true, y = true, z = true}
            local seen  = {}

            for char in order:gmatch(".") do
                if not valid[char] or seen[char] then
                    order_response()
                    return
                end
                seen[char] = true
            end
        end

        API.navigateToLocation(ARGS[3], order)
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