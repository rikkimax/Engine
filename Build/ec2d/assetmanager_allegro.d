module ec2d.assetmanager_allegro;

import base.assetmanager;

import allegro5.allegro;
import allegro5.allegro_memfile;

class AssetManagerAllegroStore : AssetManagerStore {
	private {
		ALLEGRO_BITMAP*[string] bitmaps;
	}

	version(hasCompiledAssets) {
		this() {
			super();
		}
		
		this(string[] directories...) {
			super(directories);
		}
	} else {
		this() {
			super();
		}
		
		this(string[] directories...) {
			super(directories);
		}
	}

	public {
		ALLEGRO_BITMAP* getBitmap(string filename) {
			return bitmaps.get(filename, null);
		}
	}

	override void loadFile(string file, string filename) {
		super.loadFile(file, filename);
		string format = "";

		if (filename.length > 3) {
			switch (filename[$-3 .. $]) {
				case "png":
					format = "png";
					break;
				case "bmp":
					format = "bmp";
					break;
				case "pcx":
					format = "pcx";
					break;
				case "tga":
					format = "tga";
					break;
				default:
					break;
			}
		}
		if (filename.length > 4) {
			if (filename[$-4 .. $] == "jpeg") {
				format = "jpeg";
			}
		}

		if (format != "") {
			bitmaps[filename] = al_load_bitmap_f(al_open_memfile(this[filename].ptr, this[filename].length, "r\0".ptr), (format ~ "\0").ptr);
		}
	}
}