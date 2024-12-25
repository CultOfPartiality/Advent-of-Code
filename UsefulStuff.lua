function Script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*[/\\])") or "./"
end

function UnitTest(func,args,answer)
	result = func(args)

	if result ~= answer then
		print("Unit test failed! Expected "..answer.." but got "..result)
		assert(false,"Unit test failed")
	else
		print("Unit test passed")
	end
end



-- Shallow table copy.
--
-- Might be worth reading up about this further.
-- Here maybe: https://gist.github.com/tylerneylon/81333721109155b2d244
function Copy(table)
	local newTable = {}
	for key, value in pairs(table) do
		newTable[key] = value
	end
	return newTable
end