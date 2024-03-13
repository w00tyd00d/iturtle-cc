local completion = require("cc.shell.completion")

local CARDINALS     = {"north", "east", "south", "west"}
local MOVE_ACTIONS  = {"left", "right", "forward", "back", "down", "up"}

local function get_locations()
    local data
    if fs.exists("/.iturtle.dat") then
        local file = fs.open("/.iturtle.dat", "r")
        data = textutils.unserialize(file.readAll())
        file.close()
    end

    if not data then return {} end

    local res = {}
    for k,v in pairs(data.directions) do
        table.insert(res, k)
    end

    return res
end

local iturtle_tree =
-- tree_node    = {loops, {subcommands}, add_space}
{
    it          = {nil, {"compass", "face", "navigate", "go"}, true},
    compass     = {nil, CARDINALS, false},
    face        = {nil, CARDINALS, false},
    navigate    = {nil, {"local", "to", "global"}, true},
    to          = {nil, get_locations, false}
    go          = {true, MOVE_ACTIONS, true}
}

local function choice_impl(text, choices, add_space)
    local results = {}
    for n = 1, #choices do
        local option = choices[n]
        if #option + (add_space and 1 or 0) > #text and option:sub(1, #text) == text then
            local result = option:sub(#text + 1)
            if add_space then
                table.insert(results, result .. " ")
            else
                table.insert(results, result)
            end
        end
    end
    return results
end

local function choice_tree(shell, text, previous, tree)
    local prev = previous[#previous]
    local subcmd = previous[2]

    if subcmd and tree[subcmd] and tree[subcmd][1] == true then
        local choices, add_space = table.unpack(tree[subcmd], 2)
    elseif tree[prev] then
        local choices, add_space = table.unpack(tree[prev], 2)
    end

    if type(choices) == "function" then
        choices = choices()
    end
    
    return choices and choice_impl(text, choices, add_space) or {}
end

shell.setCompletionFunction("rom/programs/turtle/it.lua", completion.build(
    { choice_tree, iturtle_tree, many = true }
))