module ec3d.database.camera;
version(Engine_3D) {

	import ec3d.base;

	import dpe.types;

	class CameraData : EngineData {
		double x;
		double y;
		double z;
		double width;
		double height;
		double length;
		double rotation;

		this(uint id) {
			super(id, EntityDataTypes.Camera);
		}

		protected {
			override void setSpecial(string name, LuaTypesVariant value) {
				switch(name) {
					case "x":
						x = value.get!(double);
						break;
					case "y":
						y = value.get!(double);
						break;
					case "z":
						z = value.get!(double);
						break;
					case "width":
						width = value.get!(double);
						break;
					case "height":
						height = value.get!(double);
						break;
					case "length":
						length = value.get!(double);
						break;
					case "rotation":
						rotation = value.get!(double);
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
					case "length":
						return LuaTypesVariant(length);
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