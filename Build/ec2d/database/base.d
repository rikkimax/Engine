module ec2d.database.base;
version(Engine_2D) {

	//import ec3d.database.camera;

	import ec2d.database.entity2ddata;
	import ec2d.base;

	import dpe.types;

	import std.parallelism : parallel;
	import std.concurrency;

	import core.time : Duration, msecs;

	private {
		__gshared EngineData[] entities;
	}

	EngineData[] getEntities() {
		return entities;
	}

	extern(C) {
		void changeEntity(uint entity, uint id, string valueId, LuaTypesVariant value) {
			synchronized {
				foreach(e; entities) {
					if (e.get("id") == id && e.get("type") == entity) {
						e.set(valueId, value);
						return;
					}
				}
			}
		}

		void deleteEntity(uint entity, uint id) {
			synchronized {
				uint index;
				bool did = false;
				foreach(i, ref e; parallel(entities)) {
					if (!did)
						if (e.get("id") == id && e.get("type") == entity) {
							index = cast(uint)i;
							did = true;
							//break; // cannot break out of a parallel loop bug in concurrency
						}
				}
				if (did) {
					if (entities.length > index + 1)
						entities = entities[0 .. index] ~ entities[index + 1 .. $];
					else
						entities.length--;
				}
			}
		}

		void createEntity(uint entity, uint id) {
			synchronized {
				switch(entity) {
					//case EntityDataTypes.Camera:
					//	entities ~= new CameraData(id);
					//	break;
					default:
						entities ~= new Entity2DData(id, entity);
						break;
				}
			}
		}

		LuaTypesVariant getEntityData(uint entity, uint id, string valueId) {
			synchronized {
				foreach(e; entities) {
					if (e.get("id") == id && e.get("type") == entity) {
						return e.get(valueId);
					}
				}
				return LuaTypesVariant(Nil.init);
			}
		}
	}
}