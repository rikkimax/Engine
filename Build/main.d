module main;

import base.assetmanager;

import dpe.base;
import dpe.types;

import luad.all;

import std.concurrency : register, thisTid;

version(Posix) {
	pragma(lib, "dl");
}

version(Engine_3D) {

	import ec3d.base;
	import ec3d.database.base;
	import ec3d.database.camera;

	import std.stdio;

	void main() {
		register(GraphicsThreadName, thisTid);
		AssetManagerStore am = new AssetManagerStore();

		LuaManager ldf = new LuaManager(true);
		ldf.iterateEngines();

		writeln("before lua: ", getEntities());

		bool last = true;
		while (last) {
			last = entityThreadListen();
			if (getEntities().length > 0) {
				writeln("after lua: ", getEntities());
				foreach(en; getEntities()) {
					writeln("after lua: ", en.get("id"), ": ", en.get("x"));
				}
			}
		}
	}
} else version(Engine_2D) {

	import ec2d.base;
	import ec2d.database.base;

	import std.stdio;

	void main() {
		register(GraphicsThreadName, thisTid);
		AssetManagerStore am = new AssetManagerStore();

		LuaManager ldf = new LuaManager(true);
		ldf.iterateEngines();

		bool last = true;
		while (last) {
			last = entityThreadListen();
			if (getEntities().length > 0) {
				writeln("after lua: ", getEntities());
				foreach(en; getEntities()) {
					writeln("after lua: ", en.get("id"), ": ", en.get("x"));
				}
			}
		}
	}
}