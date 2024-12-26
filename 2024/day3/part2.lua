dofile("UsefulStuff.lua")

local function part2(fileName)
	local total = 0
	local isDo = true

	for memory in io.lines(Script_path() .. fileName) do
		-- Lua doesn't support real regex, so need to step through looking for either options
		-- Originally did this by trimming the start of the string, but have adapted to use a
		-- cursor "index"
		local index = 1
		while index do
			if memory:sub(index,index+3) == "do()" then
				isDo = true
			elseif memory:sub(index,index+6) == "don't()" then
				isDo = false
			elseif isDo then
				local sub = memory:sub(index, (memory:find(")",index) or -1) )
				local a,b = sub:match("^mul%((%d+),(%d+)%)")
				if b then
					total = total + a*b
				end
			end
			index = memory:find("[dm][ou]",index+1)
		end
	end

	return total
end

UnitTest(part2, "testcases/test2.txt", 48)
UnitTest(part2, "input.txt", 74361272)

local result = part2("input.txt")
print("Part 2: " .. tostring(result))
