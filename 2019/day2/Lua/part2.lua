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
	-- self.memory = {}
	-- self.instructionPointer = 1
	return o
end

function Copy(obj, seen)
        if type(obj) ~= 'table' then return obj end
        if seen and seen[obj] then return seen[obj] end
        local s = seen or {}
        local res = setmetatable({}, getmetatable(obj))
        s[obj] = res
        for k, v in pairs(obj) do res[Copy(k, s)] = Copy(v, s) end
        return res
    end

local function part2(fileName)
	
	local compTemplate = Computer:new()
	for line in io.lines(Script_path() .. fileName) do
		for val in line:gmatch("%d+") do
			compTemplate.memory[#compTemplate.memory+1] = tonumber(val)
		end
	end


    for noun = 0,99 do
        for verb = 0,99 do
            local comp = Computer:new()
            comp.memory = Copy(compTemplate.memory)
            -- local comp = Copy(compTemplate) -- Can't get this working, there's still some pointer?
            comp.memory[2] = noun
	        comp.memory[3] = verb
            if comp:run() == 19690720 then
                return 100*noun + verb
            end
        end
    end
end

UnitTest(part2, "../input.txt", 3376, "Part 2")
