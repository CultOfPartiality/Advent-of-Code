dofile("UsefulStuff.lua")


local function part2(fileName)

	local function report_valid(report)
		local inc, dec = true,true
		for i = 2,#report do
			local diff = report[i] - report[i-1]
			if math.abs(diff) > 3 or diff == 0 then
				inc,dec = false,false
				break
			elseif diff > 0 then
				dec = false
			else
				inc = false
			end
		end
		return inc or dec
	end

	-- Loop over each report
	local validReports = 0
	for line in io.lines(Script_path()..fileName) do

		-- Parse report into an array
		local report = {}
		for value in string.gmatch(line,"%d+") do
			table.insert(report, tonumber(value) )
		end

		-- Check validity, and if not try removing each item and seeing if the report
		-- becomes valid
		local valid = report_valid(report)
		for i = 1,#report do
			if valid then break end
			local reducedReport = Copy(report)
			table.remove(reducedReport,i)
			valid = report_valid(reducedReport)
		end
		if valid then
			validReports = validReports+1
		end
	end

	-- Return the number of valid reports
	return validReports
end

UnitTest(part2, "testcases/test1.txt",4)

local result = part2("input.txt")
assert(result == 364, "Wrong answer")
print("Part 2: " .. tostring(result))
