dofile("UsefulStuff.lua")

local function part2(fileName)
	local list1 = {}
	local list2 = {}

	for line in io.lines(Script_path() .. fileName) do
		local parser = string.gmatch(line, "(%d+)")
		table.insert(list1, parser())
		local num = parser()
		list2[num] = (list2[num] or 0) + 1
	end

	local total = 0
	for _,v in ipairs(list1) do
		total = total + v * (list2[v] or 0)
	end
	return total
end

assert(part2("testcases/test1.txt") == 31, "Test 1 failed")
local result = part2("input.txt")
assert(result == 18805872, "Wrong answer")
print("Part 2: " .. tostring(result))
