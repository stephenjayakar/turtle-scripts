require "args"

parsedArgs = parseArgs()

for k,v in pairs(parsedArgs) do
    print(k, v)
end
