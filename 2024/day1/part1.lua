function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*[/\\])") or "./"
end

function part1(fileName)
	list1 = {}
	list2 = {}

	for line in io.lines(script_path() .. fileName) do
		parser = string.gmatch(line, "(%d+)")
		table.insert(list1, parser())
		table.insert(list2, parser())
	end

	table.sort(list1)
	table.sort(list2)

	total = 0
	for index = 1, #list1 do
		total = total + math.abs(list1[index] - list2[index])
	end
	return total
end

assert(part1("testcases/test1.txt") == 11, "Test 1 failed")
result = part1("input.txt")
assert(result == 3714264, "Wrong answer")
print("Part 1: " .. tostring(result))
