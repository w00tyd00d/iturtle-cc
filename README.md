# ITurtle API

ITurtle is a wrapper library built to add iterative functionality ComputerCraft turtles in a declarative fashion. Many of the default turtle methods have been given a `count` parameter to allow repetition of the same instruction, along with the addition of many new quality of life functions to aid in complex turtle program development.
<br>

Want to mine out a whole chunk 100 layers down?
```lua
local t = require("iturtle")

local function mineLayer()
    t.loopSwap(function()
        t.dig(nil, 16, true)
    end, function()
        t.turnAroundRight(1, true)
    end, 16)
end

local function stageNewLayer()
    t.digDown(nil, 1, true)
    t.turnRight(2)
end

t.loopSwap(mineLayer, stageNewLayer, 100)
```
<br>

Check out the API [documentation](https://github.com/w00tyd00d/iturtle-cc/wiki) to learn more!

<br>

## Installation

You can download this repo as a .zip file and use it as a datapack. If you're unsure how to install datapacks, read the tutorial on the [Minecraft wiki](https://minecraft.fandom.com/wiki/Tutorials/Installing_a_data_pack).

Alternatively, you can download the source file directly using this command on any turtle in-game.
```
pastebin get NcpFJHhu iturtle.lua
```
Just bear in mind the datapack version gets automatically inserted into every turtle's ROM directory, and therefore doesn't take up memory on their drive.
