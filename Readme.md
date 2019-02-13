Follow the instructions <a href="https://haxe.org/videos/tutorials/haxeflixel-tutorial-series/1-getting-started.html" target="_blank">here</a>, to install haxe and haxelib.

Install lime version 6.4.0 and openfl version 8.4.0 (haxelib install lime 6.4.0 and then haxelib set lime 6.4.0) 

Todo:
x- run server from game, if possible ('host'/'join' option)
	- weird cross-platform behavior
		- if neko hosts, html5 has to JOIN before they do, otherwise it doesn't work?
		x- neko/cpp clients are CRAZY laggy in updating other players (I guess in reading events from server?)
- add auto-opening doors
- add weapons station
	- eventually, abstract MP behavior and data (client_id, uid, when to send, etc.)
- add enemies (simple ship movement)
- add lighting sprites, (blue, yellow, red)
- improved tilemap
- fix bugs!
	- weird dead player spawn on connect (extra object being added somewhere?)