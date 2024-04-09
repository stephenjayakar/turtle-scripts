-- This file supports only named args
-- Given "--x 2 --y asdf" as args, it'll return a table with `{x = 2, y = "asdf"}

function panic(message)
    print(message)
    exit()
end

function parseArgs(defaults)
    local returnTable = defaults
    if #arg % 2 ~= 0 then
        panic("the args provided were the wrong length. this script only works with named args")
    end
    for i=1,math.floor(#arg / 2) do
        local keyIndex = i * 2 - 1
        local valueIndex = keyIndex + 1
        local key = arg[keyIndex]
        local value = arg[valueIndex]
        if tonumber(value) then
            value = tonumber(value)
        end
        -- Key Validation: format has to be --string
        if string.sub(key, 1, 1) ~= "-" or string.sub(key, 2, 2) ~= "-" then 
            panic("one of the arguments was malformed")
        end
        returnTable[string.sub(key, 3)] = value
    end
    return returnTable
end

