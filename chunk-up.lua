local yLimit = 20 -- Define the y limit for the script
local startFuelLevel = turtle.getFuelLevel()

-- Check if there's a chest behind the turtle to begin with
local function checkChest()
  turtle.turnLeft()
  turtle.turnLeft()
  local result = turtle.inspect()
  turtle.turnRight()
  turtle.turnRight()
  return result
end

-- Function to drop all items except fuel
local function dropItems()
  for i=1,16 do
    turtle.select(i)
    if not turtle.refuel(0) then -- If it's not fuel
      turtle.drop() -- Drop the item
    end
  end
end

-- Unload items to the chest behind
local function unloadToChest()
  turtle.turnLeft()
  turtle.turnLeft()
  dropItems()
  turtle.turnLeft()
  turtle.turnLeft()
end

-- Refuel from inventory or chest if needed
local function refuelIfNeeded()
  if turtle.getFuelLevel() < (turtle.getFuelLimit() - startFuelLevel) / 2 then
    if not turtle.refuel() then
      unloadToChest()
      turtle.suck(startFuelLevel / 2) -- Get coal out of the chest
      turtle.refuel()
    end
  end
end

-- Check for space in the inventory and refuel if needed
local function manageInventory()
  local itemSpace = 0
  for i=1,16 do
    if turtle.getItemCount(i) == 0 then
      itemSpace = itemSpace + 1
    end
  end
  if itemSpace < 2 then -- If less than 2 slots are free, go unload
    unloadToChest()
  end
  refuelIfNeeded()
end

-- Mine in an upward 8x8 block
local function mineUpwards()
  for y=1,yLimit do
    for i=1,8 do
      for j=1,7 do -- We go to 7 because we move forward first before starting to mine
        if not turtle.forward() then
          turtle.dig()
          turtle.forward()
        end
        manageInventory()
      end
      if i < 8 then -- On the last column, don't turn
        if i % 2 == 1 then -- Zigzag pattern
          turtle.turnRight()
          if not turtle.forward() then
            turtle.dig()
            turtle.forward()
          end
          manageInventory()
          turtle.turnRight()
        else
          turtle.turnLeft()
          if not turtle.forward() then
            turtle.dig()
            turtle.forward()
          end
          manageInventory()
          turtle.turnLeft()
        end
      end
    end
    turtle.digUp()
    turtle.up()
    manageInventory()
    if y % 2 == 0 then -- After going up, turn around if needed to continue the pattern
      turtle.turnRight()
      turtle.turnRight()
    end
  end
end

-- Main function to execute the program
local function main()
  if not checkChest() then
    print("Please place a chest behind the turtle to begin.")
    return
  end
  mineUpwards()
  -- Return to the starting position at the bottom
  for y=1,yLimit do
    turtle.down()
  end
end

main() -- Run the main function
