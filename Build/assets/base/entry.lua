if DEBUG then print("entry=booting lua") end

if DEBUG then print("entry=Powering engine types", "Engine_3D: " .. tostring(Engine_3D), "Engine_2D: " .. tostring(Engine_2D)) end

if DEBUG then print("entry=booted lua") end

if isMainThread then
	-- can now run everything to boot it
	local e = EDM[EDT.Entity2DData].new(1, 3, 2)
	printTable(e, "entry=new entity")
	print("entry=y 1", e["y"])
	e["y"] = 10.3
	print("entry=y 2", e["y"])
	e:delete()
	
	-- remember to push all changes to the entity models to the threads
	-- before using them
	pushVarsToThreads()
	act("TestEntity", 7, "saying hi")
end