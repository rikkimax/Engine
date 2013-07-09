entities = {}

-- required for entities to work
entityRequires = {
	id = -1,
	type = -1
}

actions = {}

-- type is the id
-- action is the identifier for said action most likely a table
-- the action in the function is a complete one with any paramaters for it required
actionsRequires = {
	["type"] = {
		["action"] = function(id, action)
		end
	}
}

function act(type1, id, action)
	-- args power of 3 in number
	-- actions of more then one entity
	-- entity n is doing x
end

interactions = {}

-- type1 / type2 is the id
-- action is the identifier for said action most likely a table
-- the action in the function is a complete one with any paramaters for it required
interactionsRequires = {
	[{"type1", "type2"}] = {
		["action"] = function(id1, id2, action)
		end
	}
}

function interact(type1, id1, action, type2, id2)
	-- interactions between two entities
	-- entity 1 did x to entity 2
end

inactions = {}

-- type is the id
-- valId is the value id of it
-- old is the old value and new is the new of it
inactionsRequires = {
	["type"] = {
		["valId"] = function(id, old, new)
		end
	}
}

function inact(type, id, valId, old, new)
	-- changes within an entity
end

local lanes = lanes
local inactionsLinda = inactionsLinda
		
function test()
	print("ran", lanes)
	
	lanes.gen("*", test2)()
	
	while(true) do
		local key, val = inactionsLinda:receive(nil, "val")
		printTable(val, key)
	end
end

function test2()
	print("ran2")
end

if isMainThread then
	lanes.gen("*", test)()
	inactionsLinda:send("val", {1, 2})
end


-- remember to copy the lindas to make it visible in the new thread
	
--local actionsLinda = actionsLinda
--local interactionsLinda = interactionsLinda
--local inactionsLinda = inactionsLinda
			
--function test()
--	print("ran")
--	while(true) do
--		local key, val = inactionsLinda:receive(nil, "val")
--		printTable(val, key)
--	end
--end

-- lanes.gen("*", test)()
-- inactionsLinda:send("val", {1, 2})