dofile("UsefulStuff.lua")

local function part2(fileName)
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
        local stepCount = 0
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
                stepCount = stepCount+1
				local hash = coords[1]..","..coords[2]
                points[hash] = points[hash] or {math.maxinteger,math.maxinteger}
				points[hash][index] = math.min(stepCount,points[hash][index])
				if index == 2 and points[hash][1] < math.maxinteger and points[hash][2] < math.maxinteger then
					local dist = math.abs(points[hash][1])+math.abs(points[hash][2])
					closest = math.min(closest,dist)
				end
				step.steps=step.steps-1
			end
		end
	end
	return closest
end

UnitTest(part2, "../testcases/test1.txt", 30)
UnitTest(part2, "../testcases/test2.txt", 610)
UnitTest(part2, "../testcases/test3.txt", 410)
UnitTest(part2, "../input.txt", 14012 , "Part 2")

