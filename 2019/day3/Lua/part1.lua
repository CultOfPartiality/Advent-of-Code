dofile("UsefulStuff.lua")

local function part1(fileName)
	local paths = {}
	for line in io.lines(Script_path() .. fileName) do
		local instructions = {}
		for dir,steps in line:gmatch("(%w)([^,]+)") do
			local instr = {}
			instr.dir = dir
			instr.steps = tonumber(steps)
			instructions[#instructions+1] = instr
		end
		paths[#paths+1] = instructions
	end
	local points = {}
	local closest = math.maxinteger
	for index,path in ipairs(paths) do
		local coords = {0,0}
		for _,step in ipairs(path) do
			while step.steps > 0 do
				if step.dir == "U" then
					coords[1] = coords[1]+1
				elseif step.dir == "D" then
					coords[1] = coords[1]-1
				elseif step.dir == "L" then
					coords[2] = coords[2]-1
				elseif step.dir == "R" then
					coords[2] = coords[2]+1
				end
				local hash = coords[1]..","..coords[2]
				points[hash] = index | (points[hash] or 0)
				if points[hash] == 3 then
					local dist = math.abs(coords[1])+math.abs(coords[2])
					closest = math.min(closest,dist)
				end
				step.steps=step.steps-1
			end
		end
	end
	return closest
end

UnitTest(part1, "../testcases/test1.txt", 6)
UnitTest(part1, "../testcases/test2.txt", 159)
UnitTest(part1, "../testcases/test3.txt", 135)
UnitTest(part1, "../input.txt", 1674, "Part 1")

