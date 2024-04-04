-- Turtle mocks
local turtle = {
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
    -- Add more turtle methods as needed for your script
}
-- end turtle mocks


-- constants
------------
local yLimit = 20 -- Define the y limit for the script
local dim = 3
-- assumes turning right
local xTable = {0, 1, 0, -1}
local zTable = {1, 0, -1, 0}

local startFuelLevel = turtle.getFuelLevel()
local x, y, z = 0, 0, 0
-- Array indexes start at 1 dear Lord
local xDirIndex,zDirIndex = 1, 1

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

local function moveForward()
   if turtle.inspect() then
      turtle.dig()
   end
   turtle.forward()
   x = x + xDir()
   z = z + zDir()
end

local function goto(newX, newZ)
   local xDel = newX - x
   local zDel = newZ - z
   print("deltas", xDel, zDel)
   print("dir", xDir(), zDir())
   -- Do z movement first
   if zDel > 0 then
      while zDir() ~= 1 do
         turnRight()
      end
   end
   if zDel < 0 then
      while zDir() ~= -1 do
         turnRight()
      end
   end
   -- Now it's facing the right way
   for n=1,math.abs(zDel) do
      moveForward()
   end

   -- Now x movement
   if xDel > 0 then
      while xDir() ~= 1 do
         turnRight()
      end
   end
   if xDel < 0 then
      while xDir() ~= -1 do
         turnRight()
      end
   end
   -- Now it's facing the right way
   for n=1,math.abs(xDel) do
      moveForward()
   end
end

local function main()
  -- Make sure there's a chest behind
  if not checkChest() then
    print("Please place a chest behind the turtle to begin.")
    return
  end

  goto(0, 4)
  goto(1, 4)

  goto(1, 0)
  goto(2, 0)
  goto(2, 4)
  goto(0, 0)
end

main()
