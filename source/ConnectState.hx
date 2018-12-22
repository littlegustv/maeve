package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIButton;

import Objects;

class ConnectState extends FlxState
{
  var client:mphx.client.Client;
  var connection_attempts:Int = 0;
  
  var rooms:Array<FlxText>;
  var room_index = 0;

  var PORT:Int = 8000;
  var HOST:String = "127.0.0.1";

  function connect () {
		client = new mphx.client.Client( HOST, PORT );
    client.onConnectionError = function (error:Dynamic) {
      trace("On Connection Error:", error.keys, connection_attempts);
      connection_attempts += 1;
      if (connection_attempts <= 10) {
        client.connect();
      }
    };
    client.onConnectionClose = function (error:Dynamic) {
      trace("Connection Closed:", error);
    };
    client.onConnectionEstablished = function () {
      FlxG.switchState(new RoomState(client));
    };
    // client.events.on("RoomsData", function (data:Dynamic) {
    // 	trace("ROOMS LIST: ", data.rooms);
    // 	rooms = new Array<FlxText>();
    // 	for (i in 0...data.rooms.length) {
    // 		var room = new FlxText(0, ( i + 1 ) * 10, 0, data.rooms[i], 8);
    // 		rooms.push(room);
    // 		add(room);
    // 	}
    // });
    // client.events.on("JoinedRoom", function (data) {
    // 	trace("joined room!!");
    // 	FlxG.switchState(new PlayState(client));
    // });
    client.connect();
  }

	override public function create():Void
	{
		super.create();

		var choose_host = new FlxUIInputText( 0, 64, 48, HOST, 8);
		add(choose_host);

		var choose_port = new FlxUIInputText(56, 64, 32, Std.string( PORT ), 8);
		add(choose_port);

		var connect_button = new FlxUIButton( 92, 60, "CONNECT", function () {
			HOST = choose_host.text;
			PORT = Std.parseInt( choose_port.text );
			connect();
		});
		add(connect_button);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// if (FlxG.keys.pressed.ANY) {
		// 	FlxG.switchState(new PlayState());
		// }

		// if (FlxG.keys.justPressed.UP) {
		// 	rooms[room_index].color = FlxColor.WHITE;
		// 	room_index = (room_index - 1) % rooms.length;
		// 	rooms[room_index].color = FlxColor.RED;
		// }
		// if (FlxG.keys.justPressed.DOWN) {
		// 	rooms[room_index].color = FlxColor.WHITE;
		// 	room_index = (room_index + 1) % rooms.length;
		// 	rooms[room_index].color = FlxColor.RED;
		// }

		// if (FlxG.keys.justPressed.ENTER) {
		// 	client.send("JoinRoom", { room: rooms[room_index].text } );
		// }

	}

}