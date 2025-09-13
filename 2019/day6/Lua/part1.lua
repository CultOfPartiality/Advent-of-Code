dofile("UsefulStuff.lua")

local function part1(fileName)
	-- Parse the input data.
	local planets = {}
	for line in io.lines(Script_path() .. fileName) do
		for  planet, moon in line:gmatch("(%w+)%)(%w+)") do
			if(not planets[planet]) then
				planets[planet] = {
					orbits = nil,
					moons = {},
					orbitCount = 0
				}
			end
			if(not planets[moon]) then
				planets[moon] = {
					orbits = nil,
					moons = {},
					orbitCount = 0
				}
			end
			table.insert(planets[planet].moons,planets[moon])
			planets[moon].orbits = planets[planet]

		end
	end

	local totalOrbits = 0
	local function calcobits(planet)
		planet.orbitCount = planet.orbits.orbitCount + 1
		totalOrbits = totalOrbits + planet.orbitCount
		for _, moon in ipairs(planet.moons) do
			calcobits(moon)
		end
	end
	
	for _, moon in ipairs(planets["COM"].moons) do
		calcobits(moon)
	end
	return totalOrbits
end

UnitTest(part1, "../testcases/test1.txt", 42)
UnitTest(part1, "../input.txt", 402879, "Part 1")
