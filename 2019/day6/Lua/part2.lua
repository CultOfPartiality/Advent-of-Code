dofile("UsefulStuff.lua")

local function part2(fileName)
	-- Parse the input data.
	local planets = {}
	for line in io.lines(Script_path() .. fileName) do
		for  planet, moon in line:gmatch("(%w+)%)(%w+)") do
			if(not planets[planet]) then
				planets[planet] = {
					orbits = nil,
					moons = {},
					distfromCOM = 0
				}
			end
			if(not planets[moon]) then
				planets[moon] = {
					orbits = nil,
					moons = {},
					distfromCOM = 0
				}
			end
			table.insert(planets[planet].moons,planets[moon])
			planets[moon].orbits = planets[planet]
		end
	end

	-- Recursivly calculate distance from "COM"
	local function calcdist(planet)
		planet.distfromCOM = planet.orbits.distfromCOM + 1
		for _, moon in ipairs(planet.moons) do
			calcdist(moon)
		end
	end
	for _, moon in ipairs(planets["COM"].moons) do
		calcdist(moon)
	end

	local transfers = 0
	while planets["YOU"].orbits ~= planets["SAN"].orbits do
		local furthest = (planets["YOU"].distfromCOM > planets["SAN"].distfromCOM) and planets["YOU"] or planets["SAN"]
		furthest.distfromCOM = furthest.distfromCOM - 1
		furthest.orbits = furthest.orbits.orbits
		transfers = transfers+1
	end
	return transfers
end

UnitTest(part2, "../testcases/test2.txt", 4)
UnitTest(part2, "../input.txt", 484, "Part 2")
