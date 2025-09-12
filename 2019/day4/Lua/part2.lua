dofile("UsefulStuff.lua")

local function isvalidnumber_andnextnumber(innumber)
	local number = innumber
	local matchedPair = false
	local increasing = true
    local lastNumber = -1
	for i = 1,5 do
		local lsn = number % 10
		number = math.floor(number/10)
		local msn = number % 10
        local nextNumber = math.floor(number/10) % 10
        matchedPair = (matchedPair) or ( lsn == msn and not (lsn == lastNumber or msn == nextNumber))
        lastNumber = lsn
		increasing = increasing and (msn <= lsn)
		-- This optimisaiton is not "required" like it is in PowerShell, lua still works it out checking 
		-- every number in ~0.190s. With it though, it takes 0.001s
		if not increasing then
			for j = i, 1, -1 do
				number = number*10 + msn
			end
			innumber = number-1
			break
		end
	end
	return (matchedPair and increasing), (innumber+1)
end

local function part2(fileName)
	-- Parse the input data.
	--#TODO Lua - work out how to just parse one line easily into two values 
	local startVal,endVal
	for line in io.lines(Script_path() .. fileName) do
		for  a, b in line:gmatch("(%d+)-(%d+)") do
			startVal = tonumber(a)
			endVal = tonumber(b)
		end
	end

	-- For each number, work out if it's valid
	local total = 0
	local valid
	local i = startVal
	while i <= endVal do
		valid,i = isvalidnumber_andnextnumber(i)
		if valid then
			total = total + 1
		end
	end
	return total
end

UnitTest(part2, "../input.txt", 1462, "Part 2")
