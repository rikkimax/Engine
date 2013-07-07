module dpe.types;

import std.variant : Algebraic;
public import luad.base : Nil;

const string GraphicsThreadName = "GraphicsThreadName";

alias Algebraic!(double, uint, int, string, bool, Nil) LuaTypesVariant;

enum ThreadReceiveTypes {
	CreateEntity,
	DeleteEntity,
	ModifyEntity,
	GetEntity
}

abstract class EngineData {
	private {
			uint id;
			uint type;
			LuaTypesVariant[string] data;
	}

	this(uint id, uint type) {
		this.id = id;
		this.type = type;
	}

	void set(string name, LuaTypesVariant value) {
		synchronized {
			if (name == "id") {
				id = value.get!uint;
			} else if (name == "type") {
				type = value.get!uint;
			} else {
				data[name] = value;
				setSpecial(name, value);
			}
		}
	}

	LuaTypesVariant get(string name) {
		synchronized {
			if (name == "id") {
				return LuaTypesVariant(id);
			} else if (name == "type") {
				return LuaTypesVariant(type);
			}

			LuaTypesVariant ret = getSpecial(name);
			if (!ret.convertsTo!Nil)
				return ret;
			return data.get(name, LuaTypesVariant(Nil.init));
		}
	}

	void opIndexAssign(string name, LuaTypesVariant value) {
		synchronized {
			set(name, value);
		}
	}
	
	LuaTypesVariant opIndex(string name) {
		return get(name);
	}

	protected {
		void setSpecial(string name, LuaTypesVariant value);

		LuaTypesVariant getSpecial(string name);
	}
}

class EngineDataDefault : EngineData {
	this(uint id, uint type) {
		super(id, type);
	}

	override void setSpecial(string name, LuaTypesVariant value){}
	override LuaTypesVariant getSpecial(string name){return LuaTypesVariant(Nil.init);}
}