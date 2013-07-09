if isMainThread then
	--local lanes = lanes

	local actionsLinda = actionsLinda
	local interactionsLinda = interactionsLinda
	local inactionsLinda = inactionsLinda
end

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
	actionsLinda:send("controller", {type1, id, action})
end

local function actionController()
	-- controller for actions
end

local function actionWorker()
	-- a worker for actions
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
	interactionsLinda:send("controller", {type1, id1, action, type2, id2})
end

local function interactController()
	-- controller for interactions
end

local function interactWorker()
	-- a worker for actions
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
end

local function inactionWorker()
	-- a worker for actions
end

if isMainThread then
	-- generate the controller threads
	lanes.gen("*", {on_state_create = load_base_lua}, actionController)()
	lanes.gen("*", {on_state_create = load_base_lua}, interactController)()
	lanes.gen("*", {on_state_create = load_base_lua}, inactionController)()

	-- generate the worker threads
	for i = 0, 9 do
		-- generate all the workers
		-- for each linda
		lanes.gen("*", {on_state_create = load_base_lua}, actionWorker)()
		lanes.gen("*", {on_state_create = load_base_lua}, interactWorker)()
		lanes.gen("*", {on_state_create = load_base_lua}, inactionWorker)()
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