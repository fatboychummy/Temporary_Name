local bcolors = {
  white = 0,
  orange = 1,
  magenta = 2,
  lightBlue = 3,
  yellow = 4,
  lime = 5,
  pink = 6,
  gray = 7,
  lightGray = 8,
  cyan = 9,
  purple = 10,
  blue = 11,
  brown = 12,
  green = 13,
  red = 14,
  black = 15
}

for i = 0, 5 do
  for o = 0, 8 do
    peripheral.call("bottom", "transmit", 1, 1, {
      x = i,
      y = o,
      xchar = 0,
      ychar = 0,
      color = i
    })
  end
end

--[[
while true do
  io.write("> ")
  local inp = io.read()
  os.sleep(1)
  peripheral.call("bottom", "transmit", 1, 1, bcolors[inp] or 15)
  print(bcolors[inp] or 15)
end
]]
