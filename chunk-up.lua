-- Turtle mocks

-- Mock turtle if it doesn't exist
if turtle == nil then
    turtle = {
        inspect = function()
            -- Return a mock result, true if there is a "chest" (assuming a specific block ID)
            return true
        end,
        turnLeft = function()
        end,
        turnRight = function()
        end,
        forward = function()
            -- Assume the turtle moves forward successfully
            return true
        end,
        dig = function()
            -- Assume the turtle digs successfully
            return true
        end,
        getFuelLevel = function()
            -- Return a mock fuel level
            return 1000
        end
    }
end

-- Argument handling
--[[ 
Valid arguments
- xDim: how far "right" to go
  - DEFAULT: 16
- yDim: how far "high" to go 
  - DEFAULT: 30
- zDim: how far "deep" to go 
  - DEFAULT: 16
- --dropItems:
 ]]

require "args"
args = parseArgs({
    xDim = 16,
    yDim = 30,
    zDim = 16,
    dropItems = true,
})

-- constants ------------
-- assumes turning right, the table of all the direction vectors together
local xTable = {0, 1, 0, -1}
local zTable = {1, 0, -1, 0}

local startFuelLevel = turtle.getFuelLevel()
local x, y, z = 0, 0, 0
-- Array indexes start at 1 dear Lord
local xDirIndex, zDirIndex = 1, 1
local state = "mining"

-- Defined later
local dropOffAndReturn

local function xDir()
    return xTable[xDirIndex]
end

local function zDir()
    return zTable[zDirIndex]
end

local function checkChest()
    turtle.turnLeft()
    turtle.turnLeft()
    local result = turtle.inspect()
    turtle.turnRight()
    turtle.turnRight()
    return result
end

local function turnRight()
    turtle.turnRight()
    xDirIndex = xDirIndex % 4 + 1
    zDirIndex = zDirIndex % 4 + 1
end

local function turnLeft()
    turtle.turnLeft()
    xDirIndex = (xDirIndex - 2) % 4 + 1
    zDirIndex = (zDirIndex - 2) % 4 + 1
end

local function isFull()
    for i=1,16 do
        if turtle.getItemCount(i) == 0 then 
            return false
        end
    end
    return true
end

local function moveForward()
    -- Check if we should return
    if not args.dropItems and state == "mining" and isFull() then
        state = "returning"
        dropOffAndReturn()
    end

    -- Otherwise move forward
    if turtle.inspect() then
        turtle.dig()
    end
    turtle.forward()
    x = x + xDir()
    z = z + zDir()
end

local function moveUp()
    if turtle.inspectUp() then
        turtle.digUp()
    end
    turtle.up()
    y = y + 1
end
local function moveDown()
    if turtle.inspectDown() then
        turtle.digDown()
    end
    turtle.down()
    y = y - 1
end

local function moveTo(newX, newZ)
    local xDel = newX - x
    local zDel = newZ - z
    print("deltas", xDel, zDel)
    print("dir", xDir(), zDir())
    -- Do z movement first
    if zDel > 0 then
        -- left turn optimization
        if zDirIndex == 2 then
            turnLeft()
        else
            while zDir() ~= 1 do
                turnRight()
            end
        end
    end
    if zDel < 0 then
        -- left turn optimization
        if zDirIndex == 4 then
            turnLeft()
        else
            while zDir() ~= -1 do
                turnRight()
            end
        end
    end
    -- Now it's facing the right way
    for n = 1, math.abs(zDel) do
        print("move z")
        moveForward()
    end

    -- Now x movement
    if xDel > 0 then
        if xDirIndex == 3 then
            turnLeft()
        else
            while xDir() ~= 1 do
                turnRight()
            end
        end
    end
    if xDel < 0 then
        if xDirIndex == 1 then
            turnLeft()
        else
            while xDir() ~= -1 do
                turnRight()
            end
        end
    end
    -- Now it's facing the right way
    for n = 1, math.abs(xDel) do
        print("move x")
        moveForward()
    end
end

local function moveY(newY)
    while newY > y do
        moveUp()
    end
    while newY < y do 
        moveDown()
    end
end

-- Make this dropoff, and then return to its spot
local function returnToOrigin()
    -- move x & z 
    moveTo(0, 0)
    -- y value
    moveY(0)
    -- get rotation right
    -- TODO: you don't really need this as regardless you'll have to rotate to the chest.
    --[[ while not (zDir() == 1 and xDir() == 0) do
        turnRight()
    end ]]
end

local function dropAllToChest()
    -- TODO: write some type of rotation abstraction
    while zDir() ~= -1 do 
        turnRight()
    end
    -- drop everything
    for i=1,16 do 
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

dropOffAndReturn = function()
    -- save variables
    local oldX, oldY, oldZ = x, y, z
    local oldXDirIndex = xDirIndex

    -- return
    returnToOrigin()

    -- dropoff
    dropAllToChest()

    -- moveback
    moveTo(oldX, oldZ)
    moveY(oldY)
    -- Get rotation right
    while oldXDirIndex ~= xDirIndex do
        -- TODO: this is inefficient
        turnRight()
    end
    state = "mining"
end

local function main()
    -- Make sure there's a chest behind
  if not args.dropItems and not checkChest() then
    print("Please place a chest behind the turtle to begin.")
    return
  end

    -- Basic layer program
    while y < args.yDim do
        for N = 1, args.xDim do
            -- Figure out which side we're on. If we're on the origin side, go forward; otherwise, come back
            if z == 0 then
                moveTo(N - 1, args.zDim)
                moveTo(N, args.zDim)
            else
                moveTo(N - 1, 0)
                moveTo(N, 0)
            end

        end
        moveTo(0, 0)
        moveUp()
    end
    while y > 0 do
        moveDown()
    end
end

main()
