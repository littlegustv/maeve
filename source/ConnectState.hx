package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIButton;

import mphx.utils.Log;

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
  // var clients:Array<mphx.connection.IConnection> = new Array();
  var clients:Map<String, mphx.connection.IConnection> = new Map();
  var server:mphx.server.impl.Server;

  function makeID () {
		var id = "";
		var charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		for (i in 0...6)
		{
			id += charactersToUse.charAt(Math.floor(Math.random()*charactersToUse.length));
		}
		return id;
	}

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

    server.events.on("ClientRegister", function( data:Dynamic, sender:mphx.connection.IConnection )
    {
      trace( "SERVER: Registered: ", data);
      var id = makeID();
      clients.set(id, sender);
      sender.send("ServerRegister", { client_id: id });
      // server.broadcast( "Join", data );
    });

    server.events.on("Join", function( data:Dynamic, sender:mphx.connection.IConnection ) {
    	trace("SERVER: Join", data);
      server.broadcast( "Join", data );
    });

    server.events.on( "Shoot", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
    	server.broadcast( "Shoot", data );
    });
    
    server.events.on("PlayerData", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
    	// trace("PlayerData", data);
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

		// Log.debugLevel = DebugLevel.Errors | DebugLevel.Warnings | DebugLevel.Info | DebugLevel.Networking;
		Log.debugLevel = DebugLevel.Errors | DebugLevel.Warnings | DebugLevel.Info;

		var choose_host = new FlxUIInputText( 0, 32, 48, HOST, 8);
		add(choose_host);

		var choose_port = new FlxUIInputText(56, 32, 32, Std.string( PORT ), 8);
		add(choose_port);

		var connect_button = new FlxUIButton( 92, 28, "CONNECT", function () {
			HOST = choose_host.text;
			PORT = Std.parseInt( choose_port.text );
			connect();
		});
		add(connect_button);

		#if ( neko || cpp )
			var host_button = new FlxUIButton( 92, 50, "HOST", function () {
				connect_button.kill();
				Thread.create(this.start_server);
				connect();
				// this.start_server();
			});
			add(host_button);
		#end
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

}