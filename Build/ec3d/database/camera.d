module ec3d.database.camera;
version(Engine_3D) {

	import ec3d.base;

	import dpe.types;

	class CameraData : EngineData {
		float x;
		float y;
		float z;
		float width;
		float height;
		float rotation;

		this(uint id) {
			super(id, EntityDataTypes.Camera);
		}

		
		protected {
			override void setSpecial(string name, LuaTypesVariant value) {
				switch(name) {
					case "x":
						x = value.get!(float);
						break;
					case "y":
						y = value.get!(float);
						break;
					case "z":
						z = value.get!(float);
						break;
					case "width":
						width = value.get!(float);
						break;
					case "height":
						height = value.get!(float);
						break;
					case "rotation":
						rotation = value.get!(float);
						break;
					default:
						break;
				}
			}
			
			override LuaTypesVariant getSpecial(string name) {
				switch(name) {
					case "x":
						return LuaTypesVariant(x);
						break;
					case "y":
						return LuaTypesVariant(y);
						break;
					case "z":
						return LuaTypesVariant(z);
						break;
					case "width":
						return LuaTypesVariant(width);
						break;
					case "height":
						return LuaTypesVariant(height);
						break;
					case "rotation":
						return LuaTypesVariant(rotation);
						break;
					default:
						return LuaTypesVariant(Nil.init);
						break;
				}
			}
		}
	}
}