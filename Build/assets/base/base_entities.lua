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
		{function(id, action)
			-- is this the action?
			-- process the action
		end}
	}
}

function act(type1, id, action)
	-- args power of 3 in number
	-- actions of more then one entity
	-- entity n is doing x
	actionsLinda:send("controller", {type1, id, action})
end

local function actionController()
	-- controller for actions
	while(true) do
		local key, val = actionsLinda:receive(nil, "controller")
		if (val[1] == "UPDATE") then
			-- update our values
			actions = val[2]
		else
			local key2, val2 = actionsLinda:receive(nil, "done")
			-- do we need to do some modifications of the data given to the controller?
			-- or get more info?
			actionsLinda:send(val2, val)
		end
	end
end

local function actionWorker(id)
	-- a worker for actions
	actionsLinda:send("done", id)
	while(true) do
		local key, val = actionsLinda:receive(nil, id)
		if (val[1] == "UPDATE") then
			print("update")
			-- update our values
			actions = val[2]
		else
			-- do the task at hand
			for k, v in pairs(actions[val[1]]) do
				v(val[2], val[3])
			end
		end
		actionsLinda:send("done", id)
	end
end

interactions = {}

-- type1 / type2 is the id
-- action is the identifier for said action most likely a table
-- the action in the function is a complete one with any paramaters for it required
interactionsRequires = {
	[{"type1", "type2"}] = {
		{function(id1, id2, action)
			-- is this the action?
			-- process the action
		end}
	}
}

function interact(type1, id1, action, type2, id2)
	-- interactions between two entities
	-- entity 1 did x to entity 2
	interactionsLinda:send("controller", {type1, id1, action, type2, id2})
end

local function interactController()
	-- controller for interactions
	while(true) do
		local key, val = interactionsLinda:receive(nil, "controller")
		if (val[1] == "UPDATE") then
			interactions = val[3]
		else
			local key2, val2 = interactionsLinda:receive(nil, "done")
			-- do we need to do some modifications of the data given to the controller?
			-- or get more info?
			interactionsLinda:send(val2, val)
		end
	end
end

local function interactWorker(id)
	-- a worker for actions
	interactionsLinda:send("done", id)
	while(true) do
		local key, val = interactionsLinda:receive(nil, id)
		if (val[1] == "UPDATE") then
			interactions = val[3]
		else
			-- do the task at hand
			for k, v in pairs(interactions[{val[1], val[4]}]) do
				v(val[2], val[5], val[3])
			end
		end
		interactionsLinda:send("done", id)
	end
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
	inactionsLinda:send("controller", {type, id, valId, old, new})
end

local function inactionController()
	-- controller for inactions
	while(true) do
		local key, val = inactionsLinda:receive(nil, "controller")
		if (val[1] == "UPDATE") then
			inactions = val[3]
		else
			local key2, val2 = inactionsLinda:receive(nil, "done")
			-- do we need to do some modifications of the data given to the controller?
			-- or get more info?
			inactionsLinda:send(val2, val)
		end
	end
end

local function inactionWorker(id)
	-- a worker for actions
	inactionsLinda:send("done", id)
	while(true) do
		local key, val = inactionsLinda:receive(nil, id)
		if (val[1] == "UPDATE") then
			inactions = val[3]
		else
			-- do the task at hand
			for k, v in pairs(inactions[val[1]]) do
				v[val[3]](val[2], val[4], val[5])
			end
		end
		inactionsLinda:send("done", id)
	end
end

if isMainThread then
	function pushVarsToThreads()
		local tbl = {
			"UPDATE", actions, interactions, inactions
		}
		actionsLinda:send("controller", tbl)
		interactionsLinda:send("controller", tbl)
		inactionsLinda:send("controller", tbl)
		
		for i = 1, 100 do
			actionsLinda:send(tostring(i), tbl)
			interactionsLinda:send(tostring(i), tbl)
			inactionsLinda:send(tostring(i), tbl)
		end
	end


	-- somethings are just not copied to the new threads
	-- place them into here
	local globals = {
		globals = {
			actionsLinda = actionsLinda,
			interactionsLinda = interactionsLinda,
			inactionsLinda = inactionsLinda,
			printTable = printTable
		}
	}

	-- generate the controller threads
	lanes.gen("*", globals, actionController)()
	lanes.gen("*", globals, interactController)()
	lanes.gen("*", globals, inactionController)()

	-- generate the worker threads
	for i = 1, 100 do
		-- generate all the workers
		-- for each linda
		lanes.gen("*", globals, actionWorker)(tostring(i))
		lanes.gen("*", globals, interactWorker)(tostring(i))
		lanes.gen("*", globals, inactionWorker)(tostring(i))
	end
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