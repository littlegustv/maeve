Follow the instructions <a href="https://haxe.org/videos/tutorials/haxeflixel-tutorial-series/1-getting-started.html" target="_blank">here</a>, to install haxe and haxelib.

Install lime version 6.4.0 and openfl version 8.4.0 (haxelib install lime 6.4.0 and then haxelib set lime 6.4.0) 

Collaboration checklist:
- code cleanup
	- more modular enemy-spawn, console systems
	- more modular, consistent client/server communication
- better error handling for connection problems (host vs connect, e.g.)
- spawn handling (avoid stacking on top of each other)
	- spawn 'objects' i.e. teleporter pads
	- if NOT host, on JOIN get a list of existing players
	- don't spawn on occupied pads?
- improved tilemap
	- improve collisions (if possible)