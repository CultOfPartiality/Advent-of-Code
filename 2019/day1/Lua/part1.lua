dofile("UsefulStuff.lua")

local function part1(fileName)
	local total = 0
	for memory in io.lines(Script_path() .. fileName) do
		total = total + math.floor(memory/3)-2
	end
	return total
end

UnitTest(part1, "../testcases/test1.txt", 34241)
UnitTest(part1, "../input.txt", 3291356)

local result = part1("../input.txt")
print("Part 1: " .. tostring(result))
