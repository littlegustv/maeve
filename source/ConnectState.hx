package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;

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

  var PORT:Int = 8000;
  var HOST:String = "127.0.0.1";

  var hosting:Bool = false;

  var message:FlxText;

  /*
    Server code is only available on desktop platforms (probably?)
   */

  #if ( neko || cpp )
    var clients:Map<mphx.connection.IConnection, String> = new Map();
    var host:mphx.connection.IConnection;
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
      server = new mphx.server.impl.Server( HOST, PORT );

      server.onConnectionAccepted = function ( reason:String, sender:mphx.connection.IConnection ) {
        trace("[ SERVER ] Connection Accepted: ", reason);
      };

      server.onConnectionClose =function ( reason:String, sender:mphx.connection.IConnection ) {
        trace("[ SERVER ] Connection Closed: ", reason);
        server.broadcast( "Leave", { client_id: clients.get( sender ) } );
      };

      server.events.on("RegisterNewClient", function( data:Dynamic, sender:mphx.connection.IConnection )
      {
        var id = makeID();
        clients.set(sender, id);
        if ( data.hosting == true ) {
          trace( "[ SERVER ] Registered new HOST: ", id);
          this.host = sender;
        } else {
          trace( "[ SERVER ] Registered new CLIENT: ", id);
        }        
        sender.send("RegisterSuccessful", { client_id: id });
      });

      server.events.on("Join", function( data:Dynamic, sender:mphx.connection.IConnection ) {
        server.broadcast( "Join", data );
      });

      server.events.on( "Shoot", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      	server.broadcast( "Shoot", data );
      });
      
      server.events.on("PlayerData", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
        server.broadcast( "PlayerUpdate", data );
      });

      server.events.on("Station", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
        server.broadcast( "Station", data );
      });

      server.events.on("UnStation", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
        server.broadcast( "UnStation", data );
      });

      server.events.on("Alert", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
        server.broadcast( "Alert", data );
      });    

      server.events.on("CreateEnemy", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
        server.broadcast( "CreateEnemy", data );
      });    

      server.start();
    }
  #end


  function connect () {
    message.text = "Connecting...";
		client = new mphx.client.Client( HOST, PORT );
    client.onConnectionError = function (error:Dynamic) {
      trace("[ CLIENT ] Connection Error:", error.keys, connection_attempts);
      connection_attempts += 1;
      if (connection_attempts <= 3) {
        client.connect();
      } else {
        message.text = "Failed to connect.";
      }
    };
    client.onConnectionClose = function (error:Dynamic) {
      trace("[ CLIENT ] Connection Closed", error);
    };
    client.onConnectionEstablished = function () {
    	trace("[ CLIENT ] Connection Established");
      message.text = "Connection successful.";
      FlxG.switchState(new PlayState(client, hosting));
    };
    client.connect();
  }

	override public function create():Void
	{
		super.create();

    var title = new FlxText( 0, 16, FlxG.width, "Welcome to SHIPSVILLE" , 16 );
    title.alignment = FlxTextAlign.CENTER;
    add(title);

    var beta = new FlxText( FlxG.width / 3, 24, 128, "[ ALPHA ]", 8 );
    beta.setBorderStyle(OUTLINE, FlxColor.RED, 1);
    beta.angle = 30;
    beta.alignment = FlxTextAlign.CENTER;
    add( beta );

    message = new FlxText( 0, 144, FlxG.width );
    message.text = "";
    message.alignment = FlxTextAlign.CENTER;
    add( message );

		// Log.debugLevel = DebugLevel.Errors | DebugLevel.Warnings | DebugLevel.Info | DebugLevel.Networking;
		Log.debugLevel = DebugLevel.Errors | DebugLevel.Warnings | DebugLevel.Info;

		var choose_host = new FlxUIInputText( FlxG.width / 2 - 24, 64, 48, HOST, 8);
		add(choose_host);

		var choose_port = new FlxUIInputText( FlxG.width / 2 - 16, 80, 32, Std.string( PORT ), 8);
		add(choose_port);

		var connect_button = new FlxUIButton( FlxG.width / 2 - 40, 96, "CONNECT", function () {  
			HOST = choose_host.text;
			PORT = Std.parseInt( choose_port.text );
			connect();
		});
		add(connect_button);

		#if ( neko || cpp )
			var host_button = new FlxUIButton( FlxG.width / 2 - 40, 116, "HOST", function () {
				connect_button.kill();
				HOST = choose_host.text;
        this.hosting = true;
        Thread.create(this.start_server);
        connect();
			});
			add(host_button);
		#end
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

}