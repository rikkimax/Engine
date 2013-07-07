print("entry=booting lua")

local lanes = require "lanes".configure()
local linda = lanes.linda()

print("entry=booted lua")

if isMainThread then
	-- can now run everything to boot it
	local e = EDM[EDT.Entity2DData].new(1, 3, 2)
	printTable(e, "entry=new entity")
	print("entry=y 1", e["y"])
	e["y"] = 10.3
	print("entry=y 2", e["y"])
	e:delete()
end