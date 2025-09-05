dofile("UsefulStuff.lua")

local function part1(fileName)
	
	for memory in io.lines(Script_path() .. fileName) do
		
	end
	return 1
end

UnitTest(part1, "../testcases/test1.txt", 3500)
UnitTest(part1, "../input.txt", 7594646)

local result = part1("../input.txt")
print("Part 1: " .. tostring(result))
