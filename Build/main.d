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

		writeln("entities: ", getEntities());
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

		writeln("Press enter when lua operations is finished");
		readln();
		writeln("entities: ", getEntities());
	}
}