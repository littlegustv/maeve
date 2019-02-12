package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIButton;
#if neko
	import neko.vm.Thread;
#elseif cpp
	import cpp.vm.Thread;
#end

import Objects;

class ConnectState extends FlxState
{
  var client:mphx.client.Client;
  var connection_attempts:Int = 0;
  
  // var rooms:Array<FlxText>;
  // var room_index = 0;

  var PORT:Int = 8000;
  var HOST:String = "127.0.0.1";

  #if ( neko || cpp )
  var clients:Array<mphx.connection.IConnection> = new Array();
  var server:mphx.server.impl.Server;

  function start_server() {
		var HOST = "127.0.0.1";
    var PORT = 8000;

    server = new mphx.server.impl.Server( HOST, PORT );

    server.onConnectionAccepted = function ( reason:String, sender:mphx.connection.IConnection ) {
      trace("SERVER: Connection Accepted: ", reason);
    };

    server.onConnectionClose =function ( reason:String, sender:mphx.connection.IConnection ) {
      trace("SERVER: Connection Closed: ", reason);
      // server.broadcast( "Leave", {id: clients.indexOf(sender) });
    };

    server.events.on("Register", function( data:Dynamic, sender:mphx.connection.IConnection )
    {
      trace( "SERVER: Registered: ", data);
      clients.push(sender);
      sender.send("Registered", { id: clients.indexOf(sender) });
      // server.broadcast( "Join", data );
    });

    server.events.on("Join", function( data:Dynamic, sender:mphx.connection.IConnection ) {
    	trace("SERVER: Join", data);
      server.broadcast( "Join", data );
    });
    
    server.events.on("PlayerData", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      server.broadcast( "PlayerUpdate", data );
    });

    server.start();
  }
  #end


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
    	trace("CLIENT: Connection Established");
      FlxG.switchState(new PlayState(client));
    };
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

		#if ( neko || cpp )
			var host_button = new FlxUIButton( 92, 80, "HOST", function () {
				Thread.create(this.start_server);
				// this.start_server();
			});
			add(host_button);
		#end
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