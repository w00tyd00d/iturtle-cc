local completion = require "cc.shell.completion"

local DIRECTIONS = {"north", "east", "south", "west"}

local it_tree = {
    it =        {{"compass", "face", "shift"}, true},
    compass =   {DIRECTIONS, false},
    face =      {DIRECTIONS, false},
    shift =     {{"left", "right"}, true}
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
    local prev = previous and previous[#previous]
    if tree[prev] then
        local choices, add_space = table.unpack(tree[prev])
        return choice_impl(text, choices, add_space)
    end
end

shell.setCompletionFunction("rom/programs/turtle/it.lua", completion.build(
    { choice_tree, it_tree, many = true }
))