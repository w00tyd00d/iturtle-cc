local completion = require("cc.shell.completion")

local iturtle_tree =
{
    it =        {{"compass", "face"}, true},
    compass =   {{"north", "east", "south", "west"}, false},
    face =      {{"north", "east", "south", "west"}, false}
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

-- We technically don't need this anymore, but I'm keeping it in case
-- of wanting to add branching options in the future
local function choice_tree(shell, text, previous, tree)
    local prev = previous and previous[#previous]
    if tree[prev] then
        local choices, add_space = table.unpack(tree[prev])
        return choice_impl(text, choices, add_space)
    end
end

shell.setCompletionFunction("rom/programs/turtle/it.lua", completion.build(
    { choice_tree, iturtle_tree, many = true }
))