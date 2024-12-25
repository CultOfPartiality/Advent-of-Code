dofile("UsefulStuff.lua")


local function part1(fileName)

	-- Loop over each report
	local validReports = 0
	for line in io.lines(Script_path()..fileName) do
		
		-- Parse report into an array
		local report = {}
		for value in string.gmatch(line,"%d+") do
			table.insert(report, tonumber(value) )
		end

		-- 
		local inc, dec = true,true
		for i = 2,#report do
			diff = report[i] - report[i-1]
			if math.abs(diff) > 3 or diff == 0 then
				inc,dec = false,false
				break
			elseif diff > 0 then
				dec = false
			else
				inc = false
			end
		end
		if inc or dec then
			validReports = validReports + 1
		end
	end

	-- Return the number of valid reports
	return validReports
end

UnitTest(part1, "testcases/test1.txt",2)

local result = part1("input.txt")
assert(result == 299, "Wrong answer")
print("Part 1: " .. tostring(result))
