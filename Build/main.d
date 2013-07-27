module main;

import base.assetmanager;

import dpe.base;
import dpe.types;

import luad.all;

import std.concurrency : register, thisTid;
import std.datetime : StopWatch;
import core.time : TickDuration;

version(Posix) {
	pragma(lib, "dl");
}

LuaManager luaManager;
struct TickRateCounter {
	ulong ticksSum;
	ushort tickCount;
	ulong fps;

	void update(ulong time) {
		tickCount++;
		ticksSum += time;
		fps = ticksSum / tickCount;
	}
}
TickRateCounter tickRate;

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
	version(Posix) {
		pragma(lib, "GL");
		pragma(lib, "X11");
		pragma(lib, "Xcursor");
		pragma(lib, "Xrandr");
		pragma(lib, "Xinerama");
		pragma(lib, "png");
		pragma(lib, "jpeg");
	}

	import ec2d.base;
	import ec2d.database.base;
	import ec2d.database.entity2ddata;
	import ec2d.assetmanager_allegro;

	import allegro5.allegro;
	import allegro5.allegro_image;

	import std.stdio;

	ALLEGRO_DISPLAY* allegroDisplay;


	void main() {
		register(GraphicsThreadName, thisTid);

		setupGame();
		gameLoop();

		/*AssetManagerStore am = new AssetManagerStore();

		LuaManager ldf = new LuaManager(true);
		ldf.iterateEngines();

		writeln("Press enter when lua operations is finished");
		readln();
		writeln("entities: ", getEntities());*/
	}

	extern(C) {
		void setupGame() {
			allegroDisplay = null;

			if (!al_init()) {
				writeln("failed to initialise allegro!");
				return;
			}
			AssetManager = new AssetManagerAllegroStore("assets");

			luaManager = new LuaManager(true);

			// get config to create it
			struct Config {
				ushort width = 800;
				ushort height = 600;
			};
			Config config;

			allegroDisplay = al_create_display(config.width, config.height);
			if (!allegroDisplay) {
				writeln("failed to create display!");
				return;
			}
			
			if (!al_init_image_addon()) {
				writeln("failed to initialise al_init_image_addon");
				return;
			}

			al_clear_to_color(al_map_rgb(0,0,0));

			al_flip_display();
		}

		void gameLoop() {
			StopWatch sw;

			while(true) {
				sw.start();

				// first we need to process the entities
				luaManager.iterateEngines();
				// next we need to take said models and draw them.

				// foreach entity that is enabled
				foreach(Entity2DData e; cast(Entity2DData[uint])getEntities()[EntityDataTypes.Entity2DData]) {
					if (e.enabled) {
						// draw on window
						auto bitmap = (cast(AssetManagerAllegroStore)AssetManager).getBitmap(e.image);
						if (bitmap !is null) {
							al_draw_bitmap(bitmap, e.x, e.y, 0);
						}
					}
				}

				// swap buffers
				al_flip_display();
				sw.stop();

				tickRate.update(TickDuration.ticksPerSec / sw.peek().length);
				if (tickRate.ticksSum > TickDuration.ticksPerSec) {
					tickRate.ticksSum -= TickDuration.ticksPerSec;
					tickRate.tickCount = 0;
				}
				sw.reset();

				writeln(tickRate.fps);
				al_rest(0.005);
			}
		}
	}
}