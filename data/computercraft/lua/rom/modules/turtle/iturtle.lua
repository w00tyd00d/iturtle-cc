-- ITurtle v1.1 made by w00tyd00d

-- Simple turtle library wrapper for
-- running iterative movement scripts
-- in a declarative fashion.

local VERSION = "1.1"
local DATA_FILE = "/.iturtle.dat"
local ARGS = {...}
local API = {}


local CARDINAL_DIRECTIONS = {"north", "east", "south", "west"}
local OPPOSITE_DIRECTIONS = {
    north = "south",
    east = "west",
    south = "north",
    west = "east"
}

local _swap_stack = {}
local _timeout_stack = {}
local _current_direction

local function new_swap_tracker(bool)
    table.insert(_swap_stack, bool or false)
end

local function get_is_swapped()
    return _swap_stack[#_swap_stack]
end

local function toggle_swap_tracker()
    _swap_stack[#_swap_stack] = not _swap_stack[#_swap_stack]
end

local function pop_swap_tracker()
    table.remove(_swap_stack)
end

local function new_timeout_tracker(time)
    table.insert(_timeout_stack, time)
end

local function pop_timeout_tracker()
    table.remove(_timeout_stack)
end

local function get_timeout_tracker(idx)
    local time = _timeout_stack[idx or #_timeout_stack]
    if time then return math.max(0, time - os.clock()) end
end

local function get_is_timed_out(idx) 
    return os.clock() >= _timeout_stack[idx or #_timeout_stack]
end

local function save_data()
    local data = textutils.serialize({
        version = VERSION,
        direction = _current_direction
    })
    local file = fs.open(DATA_FILE, "w")
    file.write(data)
    file.close()
end

local function guard_clause(count)
    if count == "inf" then
        count = math.huge
    end
    
    count = tonumber(count) and count or 1

    if turtle == nil then
        printError("ITurtle module can only be used on turtle computers.")
        return
    elseif count < 0 then
        return
    end
    
    return count
end

setmetatable(API, {
    __index = function(tbl, key)
        if guard_clause() then
            return turtle[key]
        end
    end
})

-- New Methods

local function _loop(fn, stagingFn, count, swap)
    count = guard_clause(count or math.huge)
    if not count then return end

    new_swap_tracker(get_is_swapped())

    local iter = 0
    local result

    for i=1,count do
        iter = iter + 1
        
        result = fn()
        if result then break end
        
        if stagingFn and i ~= count then
            result = stagingFn()
            if result then break end
        end
        
        if swap then toggle_swap_tracker() end
    end

    pop_swap_tracker()

    return iter, result
end

local function _loop_until(fn, stagingFn, timeout, swap)
    timeout = guard_clause(timeout or math.huge)
    if not timeout then return end

    new_swap_tracker(get_is_swapped())
    new_timeout_tracker(os.clock() + timeout)

    local iter = 0
    local result

    repeat
        iter = iter + 1
        
        result = fn()
        if result then break end
        
        if get_is_timed_out() then break end
        
        if stagingFn then
            result = stagingFn()
            if result then break end
        end
        
        if swap then toggle_swap_tracker() end
    until
        get_is_timed_out()

    pop_swap_tracker()
    pop_timeout_tracker()

    return iter, result
end

function API.loop(fn, stagingFn, count)
    return _loop(fn, stagingFn, count)
end

function API.loopSwap(fn, stagingFn, count)
    return _loop(fn, stagingFn, count, true)
end

function API.loopUntil(fn, stagingFn, endFn, timeout)
    return _loop_until(fn, stagingFn, endFn, timeout)
end

function API.loopSwapUntil(fn, stagingFn, endFn, timeout)
    return _loop_until(fn, stagingFn, endFn, timeout, true)
end

function API.loopTimedOut(id)
    if not guard_clause() then return end

    return get_is_timed_out(id)
end

function API.loopTimeLeft(id)
    if not guard_clause() then return end

    return get_timeout_tracker(id)
end

function API.turnAroundLeft(count, dig)
    count = guard_clause(count)
    if not count then return end

    local faults = 0
    local res, total

    faults = faults + API.turnLeft()

    if dig then
        res, total = API.dig(nil, count, true) 
    else
        res, total = API.forward(count)
    end

    faults = faults + res
    faults = faults + API.turnLeft()

    return faults, total + 2
end

function API.turnAroundRight(count, dig)
    count = guard_clause(count)
    if not count then return end

    local faults = 0
    local res, total

    faults = faults + API.turnRight()

    if dig then
        res, total = API.dig(nil, count, true) 
    else
        res, total = API.forward(count)
    end

    faults = faults + res
    faults = faults + API.turnRight()

    return faults, total + 2
end

function API.shiftLeft(count, dig)
    count = guard_clause(count)
    if not count then return end

    local faults = 0
    local res, total

    if count == 0 then return faults, 0 end

    faults = faults + API.turnLeft()

    if dig then
        res, total = API.dig(nil, count, true) 
    else
        res, total = API.forward(count)
    end

    faults = faults + res
    faults = faults + API.turnRight()

    return faults, total + 2
end

function API.shiftRight(count, dig)
    count = guard_clause(count)
    if not count then return end

    local faults = 0
    local res, total

    if count == 0 then return faults, 0 end

    faults = faults + API.turnRight()

    if dig then
        res, total = API.dig(nil, count, true) 
    else
        res, total = API.forward(count)
    end

    faults = faults + res
    faults = faults + API.turnLeft()

    return faults, total + 2
end

local function _block_data(direction)
    if not guard_clause() then return end

    local bool,res
    if direction == nil then bool,res = turtle.inspect() end
    if direction == "up" then bool,res = turtle.inspectUp() end
    if direction == "down" then bool,res = turtle.inspectDown() end
    
    if not bool then return {} end
    
    return res
end

function API.blockData() return _block_data() end
function API.blockDataUp() return _block_data("up") end
function API.blockDataDown() return _block_data("down") end


function API.unregisterDirection()
    if not guard_clause() then return end

    if _current_direction then
        print("Unregistered current direction.")
        print("Compass disabled!")
    end

    _current_direction = nil
    
    if fs.exists(DATA_FILE) then
        fs.delete(DATA_FILE)
    end
end

function API.registerDirection(direction)
    if not guard_clause() then return end

    local dir_idx
    for i,d in ipairs(CARDINAL_DIRECTIONS) do
        if d == direction then 
            dir_idx = i
            break
        end
    end

    if not dir_idx then
        error("Invalid cardinal direction given.", 2)
    end

    if not _current_direction then
        print("Compass enabled!")
    end

    _current_direction = dir_idx
    print("Direction registered. Now facing "..API.getDirection()..".")
    print("Compass recalibrated.")
    
    save_data()
end

function API.getDirection()
    if not guard_clause() then return end

    if not _current_direction then
        printError("No direction has been registered!")
        return
    end
    
    return CARDINAL_DIRECTIONS[_current_direction]
end

function API.setDirection(direction)
    if not guard_clause() or not direction then return end

    if not _current_direction then
        printError("No direction has been registered!")
        return
    end

    local dir_idx
    for i,d in ipairs(CARDINAL_DIRECTIONS) do
        if d == direction then 
            dir_idx = i
            break
        end
    end

    if not dir_idx then
        error("Invalid cardinal direction given.", 2)
    end

    local diff = math.abs(_current_direction - dir_idx)
    if diff == 3 then
        if _current_direction == 1 then
            API.turnLeft()
        elseif _current_direction == 4 then
            API.turnRight()
        end
    else
        if dir_idx > _current_direction then API.turnRight(diff) end
        if dir_idx < _current_direction then API.turnLeft(diff) end
    end

    return API.getDirection() == direction
end

function API.navigateLocal(x, y, z, order)
    local dist = {
        {"x", x},
        {"y", y},
        {"z", z}
    }

    local function resolve_axis(axis)
        if axis == "x" then
            if dist[1][2] < 0 then
                local _, total = API.shiftLeft(math.abs(dist[1][2]))
                dist[1][2] = dist[1][2] + (total - 2)
            elseif dist[1][2] > 0 then
                local _, total = API.shiftRight(dist[1][2])
                dist[1][2] = dist[1][2] - (total - 2)
            end
        
        elseif axis == "y" then
            if dist[1][2] < 0 then
                local _, total = API.down(math.abs(dist[1][2]))
                dist[1][2] = dist[1][2] + total
            elseif dist[1][2] > 0 then
                local _, total = API.up(dist[1][2])
                dist[1][2] = dist[1][2] - total
            end
        
        elseif axis == "z" then
            if dist[1][2] < 0 then
                local _, total = API.back(math.abs(dist[1][2]))
                dist[1][2] = dist[1][2] + total
            elseif dist[1][2] > 0 then
                local _, total = API.forward(dist[1][2])
                dist[1][2] = dist[1][2] - total
            end
        end
    end

    if order then
        for i=1, math.min(3, #order) do
            local axis = order[i]
            resolve_axis(axis)
        end
    end

    while dist[1][2] ~= 0 or dist[2][2] ~= 0 or dist[3][2] ~= 0 do
        table.sort(dist, function(a,b) return a[2] ~= 0 and math.abs(a[2]) < math.abs(b[2]) end)
        resolve_axis(dist[1][1])
    end

    return true
end

function API.navigatePath(end_block, path_block, vert_block)
    if not guard_clause() then return end

    if not _current_direction then
        printError("No direction has been registered!")
        return
    end

    end_block = end_block or "minecraft:chiseled_stone_bricks"
    vert_block = vert_block or "minecraft:soul_sand"

    local direction = "forward"
    local block_data = API.blockDataDown

    API.loop(function()
        local block = block_data()
        
        local function query_next_direction()
            if path_block and block.name ~= path_block then
                return
            end

            if block.state and block.state.facing ~= nil then
                local cardinal = block.state.facing
                if block.name == "minecraft:magenta_glazed_terracotta" then
                    cardinal = OPPOSITE_DIRECTIONS[block.state.facing]
                end
                API.setDirection(cardinal)
            end
            
            direction = "forward"
            block_data = API.blockDataDown
        end

        if direction == "up" or direction == "down" then
            if block.name then
                query_next_direction()
            end
        else
            if block.name == end_block  then
                return true
            end

            if not block.name then
                direction = "down"
            elseif block.name == vert_block then
                direction = "up"
                block_data = API.blockDataUp
            else
                query_next_direction()
            end
        end

        API[direction]()
    end)
end

function API.navigateToPoint(x, y, z, order, persist)
    if not guard_clause() then return end

    if not _current_direction then
        printError("No direction has been registered!")
        return
    end

    -- Not necessarily proud of how big this came out lol
    -- Still works! -W

    local sx, sy, sz
    local cx, cz
    local calibrated
    local dist = {}

    local function refresh_data()
        print("Refreshing data!")
        sx, sy, sz = gps.locate()
        
        if not sx then
            printError("No stable GPS cluster found!")
            return
        end
        
        dist[1] = {"x", x - sx}
        dist[2] = {"y", y - sy}
        dist[3] = {"z", z - sz}
        
        return true
    end

    local function travel(action, count)
        -- Check if compass is calibrated correctly
        -- to save a lot of headache later
        if action == "forward" and not calibrated then
            cx, cz = sx, sz

            if API.forward() == 1 then return true end
            
            if not refresh_data() then return false, "gps" end

            if _current_direction == "north" and not sz < cz then return false, "compass" end
            if _current_direction == "south" and not sz > cz then return false, "compass" end
            if _current_direction == "east" and not sx > cx then return false, "compass" end
            if _current_direction == "west" and not sx < cx then return false, "compass" end

            print("Correctly calibrated!")
            calibrated = true
            count = count - 1
        end

        API.loop(function()
            return API[action]() == 1
        end, nil, count)

        return true
    end

    local function resolve_axis(data)
        local axis, distance = table.unpack(data)
        local action = "forward"
        local count

        print("Resolving axis", axis)

        if distance == 0 then return true end

        if axis == "x" then
            if distance < 0 then API.setDirection("west") end
            if distance > 0 then API.setDirection("east") end
            count = math.abs(distance)

        elseif axis == "y" then
            if distance < 0 then action = "down" end
            if distance > 0 then action = "up" end
            count = math.abs(distance)

        elseif axis == "z" then
            if distance < 0 then API.setDirection("north") end
            if distance > 0 then API.setDirection("south") end
            count = math.abs(distance)
        end

        local res, err = travel(action, count)
        
        if not res then
            if err == "compass" then
                printError("Compass not calibrated properly! Ending navigation.")
            end
            return
        end

        return true
    end

    if not refresh_data() then return end

    if order then
        for i=1, math.min(3, #order) do
            local key = {x=1, y=2, z=3}
            local axis = order[i]
            if not resolve_axis(dist[key[axis]]) then
                return false
            end
        end
    end

    while dist[1][2] ~= 0 or dist[2][2] ~= 0 or dist[3][2] ~= 0 do
        print("Sorting axes!")
        table.sort(dist, function(a,b) return a[2] > b[2] end)
        if not refresh_data() then return end

        repeat
            local choice = table.remove(dist)
            if not resolve_axis(choice) then
                return false
            end
        until dist[1] == nil

        if not refresh_data() then return end
    end

    return true
end

-- Wrapper Methods

local function _turn_direction(num)
    if _current_direction then
        _current_direction = ((_current_direction - 1 + num) % 4) + 1
        save_data()
    end
end

local function _move(count, action)
    count = guard_clause(count)
    if not count then return end

    local faults = 0

    for i=1,count do
        if action == "turnLeft" then _turn_direction(-1) end
        if action == "turnRight" then _turn_direction(1) end

        if not turtle[action]() then
            faults = faults + 1
            if action == "turnLeft" then _turn_direction(1) end
            if action == "turnRight" then _turn_direction(-1) end
        end
    end

    return faults, count
end

local function _attack(side, count, direction)
    count = guard_clause(count)
    if not count then return end

    local faults = 0

    for i=1,count do
        if not turtle[direction](side) then
            faults = faults + 1
        end
    end

    return faults, count
end

local function _dig(side, count, end_step, direction)
    count = guard_clause(count)
    if not count then return end

    local tbl = {
        forward = turtle.dig,
        up = turtle.digUp,
        down = turtle.digDown
    }

    local subcount = 0
    local faults   = 0

    for i=1,count do
        if not tbl[direction](side) then
            faults = faults + 1
        end
        if i < count or i == count and end_step then
            local res = API[direction]()
            subcount = subcount + 1
            faults = faults + res
        end
    end

    return faults, count + subcount
end

function API.forward(count) return _move(count, "forward") end
function API.back(count) return _move(count, "back") end
function API.up(count) return _move(count, "up") end
function API.down(count) return _move(count, "down") end
function API.turnLeft(count) return _move(count, get_is_swapped() and "turnRight" or "turnLeft") end
function API.turnRight(count) return _move(count, get_is_swapped() and "turnLeft" or "turnRight") end

function API.attack(side, count) return _attack(side, count, "attack") end
function API.attackUp(side, count) return _attack(side, count, "attackUp") end
function API.attackDown(side, count) return _attack(side, count, "attackDown") end

function API.dig(side, count, end_step) return _dig(side, count, end_step, "forward") end
function API.digUp(side, count, end_step) return _dig(side, count, end_step, "up") end
function API.digDown(side, count, end_step) return _dig(side, count, end_step, "down") end


if fs.exists(DATA_FILE) then
    local file = fs.open(DATA_FILE, "r")
    local data = textutils.unserialize(file.readAll())
    file.close()
    _current_direction = data.direction
end


return API