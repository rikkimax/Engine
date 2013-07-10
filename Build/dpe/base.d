module dpe.base;
import dpe.types;
import base.assetmanager;

import luad.all;
import luad.c.all;

import std.concurrency;
import std.algorithm : filterBidirectional;

import std.file;

import std.stdio;
import std.conv;

import core.memory;

private {
	__gshared LuaState*[] pastLuaStates;
}

class LuaManager {
	private {
		LuaState luaState;

		string[] luaFileNames;

		bool isMainThread;
	}

	this(lua_State* state, bool mainThread = false) {
		isMainThread = mainThread;

		luaState = LuaState.fromPointer(state);
		if (luaState is null) luaState = new LuaState(state);
		pastLuaStates ~= &luaState;

		load();
	}

	this(bool mainThread = false) {
		isMainThread = mainThread;

		luaState = new LuaState();
		pastLuaStates ~= &luaState;
		luaState.openLibs();

		luaopen_lanes_embedded(luaState.state, &load_lanes_lua);
		lua_pop(luaState.state, 1);

		luaState["isMainThread"] = mainThread;

		load();

		runLuaFile("entry_lua");
	}

	public {
		void iterateEngines() {
			luaState.get!LuaFunction("iterateEngines")();
		}

		@property LuaState state() {
			return luaState;
		}

		@property bool mainThread() {
			return isMainThread;
		}

		void runLuaFile(string name) {
			debug {
				if (luaL_dostring(luaState.state, (cast(string)AssetManager[name] ~ "\0").ptr) == 1) {
					writeln("ERROR", to!string(lua_tostring(luaState.state, -1)));
					//throw new Exception(to!string(lua_tostring(luaState.state, -1)));
				}
				lua_pop(luaState.state, 1);
			} else {
				luaL_dostring(luaState.state, (cast(string)AssetManager[name] ~ "\0").ptr);
				lua_pop(luaState.state, 1);
			}
		}

		void load() {
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
			
			luaState["load_base_lua"] = &open;
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
			
			basePostLoad();
		}
	}

	private {
		void loadFilesLogic(string[] names...) {
			luaState.get!LuaFunction("loadFilesLogic")(names);
		}

		void basePostLoad() {
			if (isMainThread) {
				luaState.get!LuaFunction("basePostLoad")();
			}
		}
	}
}

extern(C) {
	void luaopen_lanes_embedded(lua_State* L, lua_CFunction _luaopen_lanes);

	int load_lanes_lua(lua_State* L) {
		luaL_dostring(L, (cast(string)AssetManager["lanes_lua"] ~ "\0").ptr);
		return 1;
	}

	void changeEntity(uint entity, uint id, string valueId, LuaTypesVariant value);
	void deleteEntity(uint entity, uint id);
	void createEntity(uint entity, uint id);
	LuaTypesVariant getEntityData(uint entity, uint id, string valueId);

	int open(lua_State* L) {
		new LuaManager(L);
		return 0;
	}
}