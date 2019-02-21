Follow the instructions <a href="https://haxe.org/videos/tutorials/haxeflixel-tutorial-series/1-getting-started.html" target="_blank">here</a>, to install haxe and haxelib.

Install lime version 6.4.0 and openfl version 8.4.0 (haxelib install lime 6.4.0 and then haxelib set lime 6.4.0) 

Todo:
x- run server from game, if possible ('host'/'join' option)
	x- weird cross-platform behavior
		x- if neko hosts, html5 has to JOIN before they do, otherwise it doesn't work?
		x- neko/cpp clients are CRAZY laggy in updating other players (I guess in reading events from server?)
x- add auto-opening doors
x- add weapons station
	x- improve camera location, maybe change scaling, rotation? (wider view...)
	x- server event for use/stop using, and check to make sure only one can use at a time
	x- improve visibiliy/appearance of weapon, projectiles
- add enemies (simple ship movement)
x- add lighting sprites, (blue, yellow, red)
- improved tilemap
	x- some external decor (fins, engines)
	- improve collisions (if possible)
- fix bugs!
	x- on register, load all existing players (so you don't have to wait for them to start moving... )
	x- weird dead player spawn on connect (extra object being added somewhere?) ... haven't seen in a while?
	x- positions of objects! (especially for locking-onto station)
	- better error handling for connection problems (host vs connect, e.g.)
	- spawn handling (avoid stacking on top of each other)

Station
 x- walk around inside ship
 x- weapon stations
 - enemy patterns
 - damage and repair
 - active shield (knob you can turn to aim shields from center of station, maybe - to start?)
 - fighters
