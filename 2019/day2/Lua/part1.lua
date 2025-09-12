dofile("UsefulStuff.lua")

Computer = {
	memory = {},
	instructionPointer = 1, -- Arrays start from 1 ;(

	run = function (self)
		repeat
			local currentInstruction = self.memory[self.instructionPointer]
			if currentInstruction == 1 then self:add()
			elseif currentInstruction == 2 then self:mul()
			end
		until currentInstruction == 99
		return self.memory[1]
	end,

	add = function (self)
		local paramIndex1 = 1+self.memory[self.instructionPointer+1]
		local paramIndex2 = 1+self.memory[self.instructionPointer+2]
		local paramIndex3 = 1+self.memory[self.instructionPointer+3]
		self.memory[paramIndex3] = self.memory[paramIndex1]+self.memory[paramIndex2]
		self.instructionPointer = self.instructionPointer + 4
	end,

	mul = function (self)
		local paramIndex1 = 1+self.memory[self.instructionPointer+1]
		local paramIndex2 = 1+self.memory[self.instructionPointer+2]
		local paramIndex3 = 1+self.memory[self.instructionPointer+3]
		self.memory[paramIndex3] = self.memory[paramIndex1]*self.memory[paramIndex2]
		self.instructionPointer = self.instructionPointer + 4
	end,
}

function Computer:new()
	local o = {}
	setmetatable(o,self)
	self.__index = self
	self.memory = {}
	self.instructionPointer = 1
	return o
end

local function part1(fileName)
	
	local comp = Computer:new()
	for line in io.lines(Script_path() .. fileName) do
		for val in line:gmatch("%d+") do
			comp.memory[#comp.memory+1] = tonumber(val)
		end
	end

	if fileName == "../input.txt" then
		comp.memory[2] = 12
		comp.memory[3] = 2
	end
	
	return comp:run()
end

UnitTest(part1, "../testcases/test1.txt", 3500)
UnitTest(part1, "../input.txt", 7594646, "Part 1")
