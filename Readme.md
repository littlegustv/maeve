Follow the instructions <a href="https://haxe.org/videos/tutorials/haxeflixel-tutorial-series/1-getting-started.html" target="_blank">here</a>, to install haxe and haxelib.

#### Oscar's detailed Windows install
(that works without specifying any library version numbers)

After installing haxe and haxelib:
 - haxelib install openfl
 - haxelib git mphx https://github.com/galoyo/mphx.git
 
Install Visual Studio Community 2017, adding the following components:
 - Under Workloads, check "Desktop development with C++"
 - Under Individual components, make sure "VC++ 2017 version 15.9 v14.16 latest v141 tools" is checked
 
**lime test windows** should now work without any other customization.

*For in-progress testing, I recommend **lime test neko** which is a faster build.  Executable files can be found in the 'exports/platform/bin/' directories, for testing multiple connections.*

#### Benny's specific library versions:
 - lime: 7.2.1
 - openfl: 8.8.0
 - flixel: git [ https://github.com/littlegustv/flixel.git ]
 - flixel-ui: 2.3.2
 - flixel-addons: 2.7.3
 - mphx: git [ https://github.com/galoyo/mphx.git ]

#### TODO LIST:

Server:
 - http://old.haxe.org/doc/neko/client_server
 - (more threading for handling high server load)
 - SSL server to allow for websockets to connect

Game:
 - enemy behavior and wave spawning
 - better ship damage effect & repair action
 - personal fighters
 - more/better weapon types

Visuals:
 - new sprites!
 - new tileset!
 - new tilemap layout for main ship!

Misc:
 - chat wheel!
 - ability to quit/rejoin/rehost from with game
 - volume control/toggle

Bugs:
 - Player "Join:" sync: [ in-flight projectiles, ... ]