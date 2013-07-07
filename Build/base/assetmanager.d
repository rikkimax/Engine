module base.assetmanager;

import std.file;
import std.string : lastIndexOf, toLower;

static if (__traits(compiles, {import assets;})) {
	version = hasCompiledAssets;
	import assets;
}

class AssetManagerStore {
	private {
		string[] directories;
		ubyte[][string] values;
	}

	version(hasCompiledAssets) {
		this() {
			foreach (i, name; assetNames) {
				values[name] = cast(ubyte[])*assetValues[i];
			}
		}
		
		this(string[] directories...){
			this.directories = directories;
			foreach (i, name; assetNames) {
				values[name] = cast(ubyte[])*assetValues[i];
			}
			loadDifferentSized();
		}
	} else {
		this() {
		}

		this(string[] directories...){
			this.directories = directories;
			loadAll();
		}
	}

	ubyte[] opIndex(string index) {
		synchronized {
			return values.get(index, cast(ubyte[])[]);
		}
	}

	public {
		void loadAll() {
			synchronized {
				directories.length = 0;
				// load everything from file system
				string[] files;
				string[] filenames;
				foreach(directory; directories) {
					if (exists(directory) && isDir(directory)) {
						foreach (entry; dirEntries(directory, SpanMode.breadth)) {
							if (isFile(entry))
								files ~= entry;
						}
					}
				}
				foreach(file; files){
					string t = file;
					if (lastIndexOf(t, "/") > 0)
						t = t[lastIndexOf(t, "/") + 1.. $];
					if (lastIndexOf(t, "\"") > 0)
						t = t[lastIndexOf(t, "\")") + 1 .. $];
					t = t.replace(".", "_");
					filenames ~= t;
				}
				for (int i = 0; i < files.length; i++) {
					string file = files[i];
					string filename = filenames[i];
					loadFile(file, filename);
				}
			}
		}

		void loadDifferentSized() {
			synchronized {
				// load up anything that is of a different size
				string[] files;
				string[] filenames;
				foreach(directory; directories) {
					if (exists(directory) && isDir(directory)) {
						foreach (entry; dirEntries(directory, SpanMode.breadth)) {
							if (isFile(entry))
								files ~= entry;
						}
					}
				}
				foreach(file; files){
					string t = file;
					if (lastIndexOf(t, "/") > 0)
						t = t[lastIndexOf(t, "/") + 1.. $];
					if (lastIndexOf(t, "\"") > 0)
						t = t[lastIndexOf(t, "\"") + 1 .. $];
					t = t.replace(".", "_");
					filenames ~= t;
				}
				for (int i = 0; i < files.length; i++) {
					string file = files[i];
					string filename = filenames[i];
					if (getSize(file) != values.get(filename, []).length) {
						loadFile(file, filename);
					}
				}
			}
		}

		@property string[] keys() {
			synchronized {
				return values.keys;
			}
		}
	}

	private {
		void loadFile(string file, string filename) {
			if (isFile(file) && exists(file)) {
				ubyte[] ret;
				foreach(b; cast(ubyte[]) read(file)) {
					ret ~= b;
				}
				values[filename] = ret;
		    }
		}
	}
}

__gshared AssetManagerStore AssetManager;

static this() {
	AssetManager = new AssetManagerStore("assets");
}

private pure string replace(string text, string oldText, string newText, bool caseSensitive = true, bool first = false) {
	string ret;
	string tempData;
	bool stop;
	foreach(char c; text) {
		if (tempData.length > oldText.length && !stop) {
			ret ~= tempData;
			tempData = "";
		}
		if (((oldText[0 .. tempData.length] != tempData && caseSensitive) || (oldText[0 .. tempData.length].toLower() != tempData.toLower() && !caseSensitive)) && !stop) {
			ret ~= tempData;
			tempData = "";
		}
		tempData ~= c;
		if (((tempData == oldText && caseSensitive) || (tempData.toLower() == oldText.toLower() && !caseSensitive)) && !stop) {
			ret ~= newText;
			tempData = "";
			stop = first;
		}
	}
	if (tempData != "") {
		ret ~= tempData;        
	}
	return ret;
}
