module ec2d.database.base;
version(Engine_2D) {

	import ec2d.database.entity2ddata;
	import ec2d.base;

	import dpe.types;

	import std.parallelism : parallel;
	import std.concurrency;

	import core.time : Duration, msecs;

	private{
		//entities[type][id]
		__gshared EngineData[uint][uint] entities;
	}

	EngineData[uint][uint] getEntities() {
		return entities;
	}

	extern(C) {
		void changeEntity(uint entity, uint id, string valueId, LuaTypesVariant value) {
			synchronized {
				EngineData ed = entities.get(entity, cast(EngineData[uint])null).get(id, null);
				if (!(ed is null)) {
					ed.set(valueId, value);
				}
			}
		}

		void deleteEntity(uint entity, uint id) {
			synchronized {
				entities.get(entity, cast(EngineData[uint])null).remove(id);
			}
		}

		void createEntity(uint entity, uint id) {
			synchronized {
				switch(entity) {
					case EntityDataTypes.Null:
						entities[entity][id] = new EngineDataDefault(id, entity);
						break;
					default:
						entities[entity][id] = new Entity2DData(id, entity);
						break;
				}
			}
		}

		LuaTypesVariant getEntityData(uint entity, uint id, string valueId) {
			synchronized {
				EngineData ed = entities.get(entity, cast(EngineData[uint])null).get(id, null);
				if (!(ed is null)) {
					return ed.get(valueId);
				}
				return LuaTypesVariant(Nil.init);
			}
		}

		uint[] getEntityIds(uint entity) {
			if (entities.get(entity, null) !is null)
				return entities.get(entity, null).keys;
			else
				return [];
		}

		LuaTypesVariant getSpareEntityId(uint entity) {
			if (entities.get(entity, null) !is null)
				if (entities[entity].length > 0)
					return LuaTypesVariant(entities[entity].keys[$]);
				else
					return LuaTypesVariant(1);
			else
				return LuaTypesVariant(Nil.init);
		}
	}
}