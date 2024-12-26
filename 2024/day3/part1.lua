dofile("UsefulStuff.lua")

local function part1(fileName)
	local total = 0
	for memory in io.lines(Script_path() .. fileName) do
		for a, b in memory:gmatch("mul%((%d+),(%d+)%)") do
			total = total + a * b
		end
	end
	return total
end

UnitTest(part1, "testcases/test1.txt", 161)
UnitTest(part1, "input.txt", 175615763)

local result = part1("input.txt")
print("Part 1: " .. tostring(result))
