module ec2d.database.entity2ddata;
version(Engine_2D) {

	import ec2d.base;

	import dpe.types;

	import std.variant : VariantException;
	debug {
		import std.stdio;
	}

	class Entity2DData : EngineData {
		bool enabled;
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
				try {
					switch(name) {
						case "enabled":
							enabled = value.get!(bool);
							break;
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
				} catch (VariantException ve) {
					debug {
						writeln(ve);
					}
				}
			}
			
			override LuaTypesVariant getSpecial(string name) {
				switch(name) {
					case "enabled":
						return LuaTypesVariant(enabled);
						break;
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