DEBUG = true

if DEBUG then print("base=lua start loading") end

iterateEngines = function()
	if DEBUG then print("base=iterateEngines called") end
	createEntity(1, 7)
	changeEntity(1, 7, "x", 1.5)
end

loadFilesLogic = function(files)
	if DEBUG then printTable(files, "base=loadFilesLogic called with") end
	files2 = {}
	for i = 1, #files do
		runLuaFile(files[i])
	end
end

if DEBUG then print("base=lua loaded") end

--local func = function()
--	print("got it")
--	changeEntity(1, 7, "x", 4)
--end
--createEntity(1, 1)
--changeEntity(1, 1, "x", 3)
--lanes.gen("", {globals={myVar="myValue"}}, func)()

-- Copy a table deeply and values.
function tableDeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tableDeepCopy(orig_key)] = tableDeepCopy(orig_value)
        end
        setmetatable(copy, tableDeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Copy a table deeply and values while printing out its value.
function printTable(orig, msg, level)
	print(msg)
    local orig_type = type(orig)
    local copy
    if level == nil then
    	level = 0
    end
    local levelValue = ""
    for i=1, level do
    	levelValue = levelValue .. "\t"
    end
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            if type(orig_value) ~= 'table' then
            	print(levelValue .. orig_key .. ":", orig_value)
            else
            	print(levelValue .. orig_key .. ":", orig_value)
            end
            copy[printTable(orig_key, nil, level+1)] = printTable(orig_value, nil, level+1)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end