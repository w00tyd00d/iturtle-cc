local API = require("iturtle")

local ARGS = {...}

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
    local name = arg[0] or fs.getName(shell.getRunningProgram())

    print("Usages:")
    print(name, "version")
    print(name, "compass <direction>")
    print(name, "face <direction>")
    print(name, "go <direction> <distance>")
    print(name, "location <get|set|delete> <location>")
    print(name, "navigate <local|global> <x> <y> <z>")
    print(name, "navigate <to> <location>")
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

    elseif ARGS[1] == "location" then
        print("Access saved location database.")
        print("Used for coordinate bookmarking.")

    elseif ARGS[1] == "navigate" then
        print("Moves the turtle to a specific point.\n")
        print("Can be local position (same as /tp ^x ^y ^z) or if GPS is available, also supports global coordinates and saved locations.")

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
            print("Requires functioning GPS in range.")

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

        elseif ARGS[2] == "delete" then
            print("Delete a location from memory.")

        end

        return
    end
end

-- #ARGS > 2

local DIRECTIONS = {
    north   = true,
    east    = true,
    south   = true,
    west    = true
}

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
        
        if label == "*" then
            local res = ""

            for k,v in pairs(API.getAllLocations()) do
                local x, y, z = table.unpack(v)
                res = res..k.." : ("..x..", "..y..", "..z..")\n"
            end

            local _, height = term.getCursorPos()
            textutils.pagedPrint(res:sub(1,-2), height - 2)
            return
        end

        local x, y, z = API.getLocation(label)

        if not x then
            print("Must be a registered location.")
            return
        end

        print(label.." : ("..x..", "..y..", "..z..")")

    elseif ARGS[2] == "delete" then
        local label = ARGS[3]
        API.unregisterLocation(label)

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

        local fuel = tonumber(API.getFuelLevel())
        local distance = math.abs(x) + math.abs(y) + math.abs(z)

        if fuel and fuel < distance then
            print("Not enough fuel.")
            print("Fuel level  :", fuel)
            print("Fuel needed :", distance)
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
            print("No valid GPS data found.")
            return
        end

        local fuel = tonumber(API.getFuelLevel())
        local distance = math.abs(x - sx) + math.abs(y - sy) + math.abs(z - sz)

        if fuel and fuel < distance then
            print("Not enough fuel.")
            print("Fuel level  :", fuel)
            print("Fuel needed :", distance)
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

        local dx, dy, dz = API.getLocation(ARGS[3])
        if not dx then return end

        local sx, sy, sz = gps.locate()
        if not sx then
            print("No valid GPS data found.")
            return
        end

        local fuel = tonumber(API.getFuelLevel())
        local distance = math.abs(dx - sx) + math.abs(dy - sy) + math.abs(dz - sz)

        if fuel and fuel < distance then
            print("Not enough fuel.")
            print("Fuel level  :", fuel)
            print("Fuel needed :", distance)
            return
        end

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
    local ACTIONS = {
        fd       = API.forward,
        forward  = API.forward,
        forwards = API.forward,
        bk       = API.back,
        back     = API.back,
        up       = API.up,
        dn       = API.down,
        down     = API.down,
        lt       = API.turnLeft,
        left     = API.turnLeft,
        rt       = API.turnRight,
        right    = API.turnRight,
    }

    local cached_action
    
    local function do_cached_action()
        if cached_action then
            if cached_action() == 1 and API.getFuelLevel() == 0 then
                print("Out of fuel.")
                return false
            end
        end
        return true
    end

    for i=2, #ARGS do
        local arg = ARGS[i]
        local num = tonumber(arg)

        if not ACTIONS[arg] and ((not num) or (num and num < 0)) then
            print("Must use valid directions or numbers.")
            return
        end
    end

    for i=2, #ARGS do
        local arg = ARGS[i]
        
        if ACTIONS[arg] then
            if not do_cached_action() then
                return
            end
            cached_action = ACTIONS[arg]
        
        elseif tonumber(arg) ~= nil and cached_action then
            local _, res = API.loop(function()
                return not do_cached_action()
            end, nil, tonumber(arg))

            cached_action = nil
        else
            print("No such direction:", arg)
            print("Try: forward, back, up, down")
        end

    end

    do_cached_action()
end