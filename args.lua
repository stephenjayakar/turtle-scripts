-- This file supports only named args
-- Given "--x 2 --y asdf" as args, it'll return a table with `{x = 2, y = "asdf"}

function parseArgs()
    local returnTable = {}
    if #arg % 2 ~= 0 then
        panic("the args provided were the wrong length. this script only works with named args")
    end
    for i=1,math.floor(#arg / 2) do
        local keyIndex = i * 2 - 1
        local valueIndex = keyIndex + 1
        returnTable[arg[keyIndex]] = arg[valueIndex]
    end
    return returnTable
end

