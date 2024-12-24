function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*[/\\])") or "./"
end

function part2(fileName)
	list1 = {}
	list2 = {}

	for line in io.lines(script_path() .. fileName) do
		parser = string.gmatch(line, "(%d+)")
		table.insert(list1, parser())
		num = parser()
		list2[num] = (list2[num] or 0) + 1
	end

	total = 0
	for _,v in ipairs(list1) do
		total = total + v * (list2[v] or 0)
	end
	return total
end

assert(part2("testcases/test1.txt") == 31, "Test 1 failed")
result = part2("input.txt")
assert(result == 18805872, "Wrong answer")
print("Part 2: " .. tostring(result))
