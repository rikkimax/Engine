module dpe.base;
import dpe.types;
import base.assetmanager;

import luad.all;
import luad.c.all;

import std.concurrency;
import std.algorithm : filterBidirectional;

import std.file;

class LuaManager {
	private {
		LuaState luaState;

		string[] luaFileNames;
	}

	this(lua_State* state, bool mainThread = false) {
		luaState = new LuaState(state);
		luaState.doString("if isMainThread == nil then isMainThread = " ~ (mainThread ? "true" : "false") ~ " end");
	}

	this(bool mainThread = false) {
		luaState = new LuaState();
		luaState.openLibs();

		luaopen_lanes_embedded(luaState.state, &load_lanes_lua);
		lua_pop(luaState.state, 1);

		luaState["isMainThread"] = mainThread;

		luaopen_base_engine(this);

		runLuaFile("entry_lua");
	}

	public {
		void iterateEngines() {
			luaState.get!LuaFunction("iterateEngines")();
		}

		@property LuaState state() {
			return luaState;
		}

		void runLuaFile(string name) {
			luaL_dostring(luaState.state, (cast(string)AssetManager[name] ~ "\0").ptr);
		}
	}

	private {
		void loadFilesLogic(string[] names...) {
			luaState.get!LuaFunction("loadFilesLogic")(names);
		}
	}
}

private {
	void luaopen_base_engine(LuaManager manager) {
		with(manager) {
			debug {
				luaState["DEBUG"] = true;
			} else {
				luaState["DEBUG"] = false;
			}

			version(Engine_2D) {
				luaState["Engine_2D"] = true;
				luaState["Engine_3D"] = false;
			} else version(Engine_3D) {
				luaState["Engine_3D"] = true;
				luaState["Engine_2D"] = false;
			} else {
				luaState["Engine_3D"] = false;
				luaState["Engine_2D"] = false;
			}

			luaState["changeEntity"] = &changeEntity;
			luaState["deleteEntity"] = &deleteEntity;
			luaState["createEntity"] = &createEntity;
			luaState["getEntityData"] = &getEntityData;
			luaState["runLuaFile"] = &runLuaFile;

			runLuaFile("base_lua");
			
			auto luaFiles = filterBidirectional!(function(string equals) {return equals[$-3 .. $] == "lua" && equals != "base_lua" && equals != "lanes_lua" && equals != "entry_lua";})(AssetManager.keys);
			string[] filesToRun;
			foreach(file; luaFiles) {
				filesToRun ~= file;
			}
			loadFilesLogic(filesToRun);
		}
	}

}

extern(C) {
	void luaopen_lanes_embedded(lua_State* L, lua_CFunction _luaopen_lanes);

	int load_lanes_lua(lua_State* L) {
		LuaManager manager = new LuaManager(L);
		manager.runLuaFile("lanes_lua");
		return 1;
	}

	/*
	 * When lua lanes loads up all libraries call this.
	 * Look in tools.c in function luaG_newstate for call to this
	 */
	int load_base_lua(lua_State* L) {
		LuaManager manager = new LuaManager(L);
		luaopen_base_engine(manager);
		return 1;
	}

	void changeEntity(uint entity, uint id, string valueId, LuaTypesVariant value);
	void deleteEntity(uint entity, uint id);
	void createEntity(uint entity, uint id);
	LuaTypesVariant getEntityData(uint entity, uint id, string valueId);
}