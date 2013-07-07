module ec2d.database.base;
version(Engine_2D) {

	//import ec3d.database.camera;
	import ec2d.base;

	import dpe.types;

	import std.parallelism : parallel;
	import std.concurrency;

	import core.time : Duration, msecs;

	private {
		EngineData[] entities;
	}

	EngineData[] getEntities() {
		return entities;
	}

	void entityModify(uint entity, uint id, string valueId, LuaTypesVariant value) {
		foreach(e; entities) {
			if (e.get("id") == id && e.get("type") == entity) {
				e.set(valueId, value);
				return;
			}
		}
	}

	void entityDelete(uint entity, uint id) {
		uint index;
		bool did = false;
		foreach(i, ref e; parallel(entities)) {
			if (e.get("id") == id && e.get("type") == entity) {
				index = cast(uint)i;
				did = true;
				break;
			}
		}
		if (did) {
			if (entities.length > index + 1)
				entities = entities[0 .. index] ~ entities[index + 1 .. $];
			else
				entities.length--;
		}
	}

	void entityCreate(uint entity, uint id) {
		switch(entity) {
			//case EntityDataTypes.Camera:
			//	entities ~= new CameraData(id);
			//	break;
			default:
				entities ~= new EngineDataDefault(id, entity);
				break;
		}
	}

	extern(C) LuaTypesVariant getEntityData(uint entity, uint id, string valueId) {
		foreach(e; entities) {
			if (e.get("id") == id && e.get("type") == entity) {
				return e.get(valueId);
			}
		}
		return LuaTypesVariant(Nil.init);
	}	

	bool entityThreadListen(Duration timeout = msecs(5)) {
							return receiveTimeout(timeout,
							(ThreadReceiveTypes action, uint entity, uint id) {
		  						if (action == ThreadReceiveTypes.CreateEntity)
									entityCreate(entity, id);
		                      	else if (action == ThreadReceiveTypes.DeleteEntity)
		                      		entityDelete(entity, id);
							},
							(ThreadReceiveTypes action, uint entity, uint id, string valueId, LuaTypesVariant value) {
		                      	if (action == ThreadReceiveTypes.ModifyEntity)
		                      		entityModify(entity, id, valueId, value); 
							},
							(ThreadReceiveTypes action, uint entity, uint id, string valueId) {
		                      	if (action == ThreadReceiveTypes.GetEntity)
		                      		getEntityData(entity, id, valueId);
							});
	}
}