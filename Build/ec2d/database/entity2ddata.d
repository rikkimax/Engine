module ec2d.database.entity2ddata;
version(Engine_2D) {

	import ec2d.base;

	import dpe.types;
	import std.stdio;
	class Entity2DData : EngineData {
		double x;
		double y;
		double width;
		double height;
		string image;

		this(uint id, uint entity = EntityDataTypes.Entity2DData) {
			super(id, entity);
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
					case "width":
						width = value.get!(double);
						break;
					case "height":
						height = value.get!(double);
						break;
					case "image":
						image = value.get!(string);
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
					case "width":
						return LuaTypesVariant(width);
						break;
					case "height":
						return LuaTypesVariant(height);
						break;
					case "image":
						return LuaTypesVariant(image);
						break;
					default:
						return LuaTypesVariant(Nil.init);
						break;
				}
			}
		}
	}
}