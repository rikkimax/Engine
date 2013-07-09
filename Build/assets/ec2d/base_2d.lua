if DEBUG then print("base_2d=here") end

EntityDataTypes = {
	["Null"] = 0,
	["Entity2DData"] = 1
}

EDT = EntityDataTypes

if DEBUG then print("base_2d=Entity data types") end

EntityDataModels = {
	[EDT.Entity2DData] = {
		-- D and lua need this don't change once init'd
		id = -1,
		type = EDT.Entity2DData,
		info = {
			-- D requires this info
			x = -1,
			y = -1,
			width = -1,
			height = -1,
			image = "",
			enabled = false
			-- internal state for Lua
		}
	}
}

EDM = EntityDataModels

if DEBUG then print("base_2d=Entity data models") end

EDM[EDT.Entity2DData]["new"] = function(id, x, y, width, height, image, enabled)
	if DEBUG then print("base_2d=New entity 2d data") end
	local ret = tableDeepCopy(EntityDataModels[EDT.Entity2DData])
	
	if not type(id) == "number" then
		return nil
	end
	ret.id = math.ceil(id)
	
	createEntity(ret.type, ret.id)
	
	if DEBUG then print("base_2d=created entity") end
	
	ret["x"] = x
	ret["y"] = y
	ret["width"] = width
	ret["height"] = height
	ret["image"] = image
	ret["enabled"] = enabled
	
	if DEBUG then print("base_2d=set vars") end
	return ret
end

EDM[EDT.Entity2DData]["delete"] = function(self)
	deleteEntity(self.type, self.id)
end

EntityDataModelsMetaData = {
	[EDT.Entity2DData] = {
		__index = function(t, k)
			return getEntityData(t.type, t.id, k)
		end,
		__newindex = function(t, k, v)
			if type(t.info[k]) == type(v) and v ~= nil then
				inact(t.type, t.id, k, t[k], v)
				changeEntity(t.type, t.id, k, v)
			else
				inact(t.type, t.id, k, nil, t.info[k])
				changeEntity(t.type, t.id, k, t.info[k])
			end
		end
	}
}

EDMMD = EntityDataModelsMetaData

setmetatable(EDM[EDT.Entity2DData], EDMMD[EDT.Entity2DData])

if DEBUG then print("base_2d=Entity data models meta data") end