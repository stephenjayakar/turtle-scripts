require "args"

parsedArgs = parseArgs({x = 2})

for k,v in pairs(parsedArgs) do
    print(k, v)
    print(v + 2)
end
