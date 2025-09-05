dofile("UsefulStuff.lua")

local function part1(fileName)
	local total = 0
	for fuel in io.lines(Script_path() .. fileName) do
        subTotal = 0
        fuel = tonumber(fuel)
        while(fuel > 0) do
            fuel = math.floor(fuel/3)-2
            if(fuel > 0) then
                subTotal = subTotal + fuel
            end
        end
        total = total + subTotal
	end
	return total
end

UnitTest(part1, "../testcases/test1.txt", 51316)
UnitTest(part1, "../input.txt", 4934153)

local result = part1("../input.txt")
print("Part 2: " .. tostring(result))
