if not turtle then
  print("Not a turtle. Doing nothing.")
  return
else
  print("Turtle doot doot time.")
end

local itemCache = {}

-- rotate until we see a modem block
local function findModem()
  for i = 1, 4 do
    turtle.turnRight()
    local ok, block = turtle.inspect()
    if ok and block.name == "computercraft:wired_modem_full" then
      return
    end
  end
  error("No modem.")
  -- TODO: maybe handling for horizontal shits?
end

local function multinum(...)
  local args = table.pack(...) -- pack everything into a table

  if args.n == 0 then return end -- if there's nothing, return nothing.

  local out = {n = 0} -- initialize table
  for i = 1, #args do
    -- for each input, convert to number and add to the table
    out[i] = tonumber(args[i])
    -- increase the number of values recieved
    out.n = out.n + 1
  end

  return table.unpack(out, 1, out.n)
end

-- grab 16 items from a chest.

-- find modem block, turn left.  Scan top and front until all turtles are final.
local function determinePosition()
  local lbl = "[0,0,0,0,0]" -- computer label, add f to end if finalized.
  local pos = {x = 0, y = 0, charx = 0, chary = 0, final = 0}
  -- returns 5 numbers if used with string.match
  local matcher = "^%[(%d+),(%d+),(%d+),(%d+),(%d+)%]$"
  -- formats 5 numbers into a string to be matched
  local formatter = "[%d,%d,%d,%d,%d]"

  -- Turn to the left, so the top left turtle is 0, 0
  findModem()
  turtle.turnLeft()

  -- Actually detemine the position
  repeat
    -- positions which can be read and compared later
    local tempPos1 = {}
    local tempPos2 = {}

    -- check turtles
    local top = peripheral.call("top", "getLabel")
    local isTop, block = turtle.inspectUp()
    local front = peripheral.call("front", "getLabel")
    local isFront, block2 = turtle.inspect()

    if isTop
    and block.name:find("computercraft")
    and block.name:find("turtle") then
      -- if the top is a turtle
      local x, y, cx, cy, f = string.match(tostring(top), matcher)
      if x then
        -- hope what these few lines do here are obvious...
        x = tonumber(x)
        y = tonumber(y)
        cx = tonumber(cx)
        cy = tonumber(cy)
        f = tonumber(f)

        --[[
          Y Position: a number from 0-8, which states the pixel within the
          character that we are at.

          Char Y Position: a number, starting from 0, stating which character we
          are at, along the Y axis.

          Final: If the turtle above has a finalized location
        ]]
        tempPos1 = {
          x = x,
          y = (y + 1) % 9 == 0 and 0 or y + 1,
          charx = cx,
          chary = (y + 1) % 9 == 0 and cy + 1 or cy,
          final = f
        }
      else
        -- if the top is a turtle, but we couldn't obtain the position, we
        -- should wait.
        tempPos1 = {
          x = false,
          y = false,
          charx = false,
          chary = false,
          final = 0
        }
      end
    else
      -- if the top is not a turtle, say we are at y = 0, chary = 0
      -- and set the others to "unknown" (false)
      print("Nothing on top, set top to 1")
      tempPos1 = {
        x = false,
        y = 0,
        charx = false,
        chary = 0,
        final = 1
      }
    end


    if isFront
    and block2.name:find("computercraft")
    and block2.name:find("turtle") then
      -- if the front is a turtle...
      -- match the numbers in front
      local x, y, cx, cy, f = string.match(tostring(front), matcher)

      -- if there was a match (the turtle is a part of the array)
      if x then
        x = tonumber(x)
        y = tonumber(y)
        cx = tonumber(cx)
        cy = tonumber(cy)
        f = tonumber(f)

        --[[
          X Position: a number from 0-5, which states the pixel within the
          character that we are at.

          Char X Position: a number, starting from 0, stating which character we
          are at, along the X axis.

          Final: If the turtle in front has a finalized location
        ]]
        tempPos2 = {
          x = (x + 1) % 6 == 0 and 6 and 0 or x + 1,
          y = y,
          charx = (x + 1) % 6 == 0 and cx + 1 or cx,
          chary = cy,
          final = f
        }
      else -- the turtle was not a part of the array
        tempPos2 = {
          x = false,
          y = false,
          charx = false,
          chary = false,
          final = 0
        }
      end
    else
      -- if nothing, then we are at x = 1
      print("Nothing in front, set front to 1")
      tempPos2 = {
        x = 0,
        y = false,
        charx = 0,
        chary = false,
        final = 1
      }
    end

    -- check the finality

    -- set everything depending on what was detected.

    -- since these vals are set to false if unknown, we can use the or op
    -- to select the one which is known.
    local x = tempPos1.x or tempPos2.x
    local y = tempPos1.y or tempPos2.y
    local charx = tempPos1.charx or tempPos2.charx
    local chary = tempPos1.chary or tempPos2.chary
    local fin = tempPos1.final == 1 and tempPos2.final == 1 and 1 or 0

    -- if everything was set (no false positives), set our label
    -- otherwise go back to the top.
    if x and y and charx and chary and fin == 1 then
      lbl = string.format(formatter, x, y, charx, chary, fin)
      os.setComputerLabel(lbl)
      break -- exit the loop, we're done here
    end

    -- set the label to what we know so far. Mostly debug purposes.
    os.setComputerLabel(string.format(formatter, x or -1, y or -1, charx or -1, chary or -1, 0))
    os.sleep() -- ToO LoNg WiThOuT yIeLdInG
  until pos.final == 1

  -- convert all return values to numbers
  return multinum(string.match(lbl, matcher))
end

-- grabs 16 items from the first chest it finds.
-- recommend either 16 wool colors or 16 concrete colors.
local function grabItems()
  local localName = peripheral.call("back", "getNameLocal")
  local chest


  -- find the first chest or shulker box.
  for _, name in ipairs(peripheral.getNames()) do
    if name:find("chest") or name:find("shulker") then
      chest = name
      break
    end
  end

  -- grab the items
  for i = 1, 16 do
    peripheral.call(chest, "pushItems", localName, i, 1, i)
  end
end

-- put our items in the cache so we can select them easier
local function cacheItems()
  for i = 1, 16 do
    itemCache[i] = turtle.getItemDetail(i)
  end
end

os.setComputerLabel(nil)
print("Getting Position")
print(determinePosition())
turtle.turnLeft()

-- check if we have 16 items already.
local get = 0
for i = 1, 16 do
  get = get + turtle.getItemCount(i)
end
if get == 0 then
  print("Grabbing items")
  grabItems()
elseif get == 16 then
  print("Items already grabbed. Doing nothing.")
else
  -- get is a number which is not 0 or 16 (a wrong number of items)
  error("Please empty turtle manually.")
end

cacheItems()

print("Ready.")
