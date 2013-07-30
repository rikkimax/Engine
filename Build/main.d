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
	float wait = 0.005;
	ulong ticksSinceFpsChange = 0;

	private {
		ulong lastFps;
		ulong bestFps;
		float bestWait;
		bool decreased = true;
		ushort decreasedAttracts = false;
		ubyte waitDiffLevel = 0;
		float[] waitDiff = [0.001, 0.0001, 0.00001];
	}

	void update(ulong ticksPerSec, ulong time) {
		lastFps = fps;

		// update fps
		tickCount++;
		ticksSum += ticksPerSec / time;
		fps = ticksSum / tickCount;

		// update ticks since change
		if (fps != lastFps) {
			ticksSinceFpsChange = 0;
		} else {
			ticksSinceFpsChange++;
		}

		// update our best fps
		if (fps > bestFps) {
			bestFps = fps;
			bestWait = wait;
			if (decreased) {
				wait -= waitDiff[waitDiffLevel];
			} else {
				wait += waitDiff[waitDiffLevel];
			}
		} else {
			if (decreased) {
				wait += waitDiff[waitDiffLevel];
				if (decreased)
					decreasedAttracts++;
				else
					decreasedAttracts = 0;
				decreased = false;
			} else {
				wait -= waitDiff[waitDiffLevel];
				if (!decreased)
					decreasedAttracts++;
				else
					decreasedAttracts = 0;
				decreased = true;
			}
		}

		if (ticksSinceFpsChange > 50) {
			bestFps = fps;
			waitDiffLevel++;
			if (waitDiffLevel > 2) {
				waitDiffLevel = 0;
				if (!decreased)
					decreasedAttracts++;
				else
					decreasedAttracts = 0;
				decreased = true;
			}
		}

		if (decreasedAttracts > 150) {
			waitDiffLevel++;
			decreasedAttracts = 0;
			if (waitDiffLevel > 2) {
				waitDiffLevel = 0;
				decreased = true;
			}
		}

		debug {
			writeln("FPS counter and wait debug info: ", tickRate.fps, " ", tickRate.wait, " " , tickRate.ticksSinceFpsChange, " ", tickRate.ticksSum, " ", tickRate.tickCount);
		}
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
		debug {
			import core.stdc.signal;
			import core.runtime;
			extern(C) void sig_handler(int signo) nothrow {
				try {
					writeln();
					writeln("Entity state: ", getEntities());
					writeln("\nBest fps is ", tickRate.bestFps, " and wait ", tickRate.bestWait);
					writeln();
					Runtime.terminate();
				} catch(Exception e){}
			}
			signal(SIGINT, &sig_handler);
		}

		register(GraphicsThreadName, thisTid);

		setupGame();
		gameLoop();

		/*AssetManager = new AssetManagerStore("assets");

		LuaManager ldf = new LuaManager(true);
		ldf.iterateEngines();

		writeln("Press enter when lua operations is finished");
		readln();
		writeln("entities: ", getEntities());
		writeln(ec2d.database.base.getSpareEntityId(1));*/
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
			StopWatch seconds;
			seconds.start();

			while(true) {
				sw.start();

				// first we need to process the entities
				luaManager.iterateEngines();
				// next we need to take said models and draw them.

				al_clear_to_color(al_map_rgb(0, 0, 0));

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

				tickRate.update(TickDuration.ticksPerSec, sw.peek().length);
				sw.reset();

				al_rest(tickRate.wait);

				// reset ticks every second
				if (seconds.peek().length > TickDuration.ticksPerSec) {
					seconds.reset();
					tickRate.ticksSum = 0;
					tickRate.tickCount = 0;
				}
			}

			seconds.stop();
		}
	}
}