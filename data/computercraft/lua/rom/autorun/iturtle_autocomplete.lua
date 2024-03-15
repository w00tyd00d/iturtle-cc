local completion = require("cc.shell.completion")

local function get_locations()
    local data
    if fs.exists("/.iturtle.dat") then
        local file = fs.open("/.iturtle.dat", "r")
        data = textutils.unserialize(file.readAll())
        file.close()
    end

    if not data or not data.locations then return {} end

    local res = {}
    for k,v in pairs(data.locations) do
        table.insert(res, k)
    end

    return res
end

local BASE_SUB      = {"compass", "face", "go", "location", "navigate", "version"}
local NAVIGATE_SUB  = {"local", "to", "global"}
local CARDINALS     = {"north", "east", "south", "west"}
local MOVE_ACTIONS  = {"left", "right", "forward", "back", "down", "up"}
local GET_SET       = {"get", "set", "delete"}

local iturtle_tree =
-- tree_node    = {{choice_list}, additional_tags}
{
    it          = {BASE_SUB, add_space = true},
    compass     = {CARDINALS},
    face        = {CARDINALS},
    location    = {GET_SET, add_space = true},
    get         = {get_locations},
    delete      = {get_locations},
    navigate    = {NAVIGATE_SUB, add_space = true},
    to          = {get_locations},
    go          = {MOVE_ACTIONS, add_space = true, loop = true},
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
    local branch

    if subcmd and tree[subcmd] and tree[subcmd].loop then
        branch = tree[subcmd]
    elseif tree[prev] then
        branch = tree[prev]
    end

    local choices = branch and branch[1] or {}

    if type(choices) == "function" then
        choices = choices()
    end

    return choice_impl(text, choices, branch and branch.add_space or false)
end

shell.setCompletionFunction("rom/programs/turtle/it.lua", completion.build(
    { choice_tree, iturtle_tree, many = true }
))