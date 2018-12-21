class Main {
  var server:mphx.server.impl.Server;
  var clients:Array<mphx.connection.IConnection> = new Array();
  public function new ()
  {
    server = new mphx.server.impl.Server("192.168.1.22",8000);

    server.onConnectionAccepted = function ( reason:String, sender:mphx.connection.IConnection ) {
      trace("Connection Accepted: ", reason);
    };

    server.onConnectionClose =function ( reason:String, sender:mphx.connection.IConnection ) {
      trace("Connection Closed: ", reason);
      server.broadcast( "Leave", {id: clients.indexOf(sender) });
    };

    server.events.on("Register", function( data:Dynamic, sender:mphx.connection.IConnection )
    {
      trace( "Registered: ", data);
      clients.push(sender);
      sender.send("Registered", {id: clients.indexOf(sender) });
      // server.broadcast( "Join", data );
    });

    server.events.on("Join", function( data:Dynamic, sender:mphx.connection.IConnection ) {
      server.broadcast( "Join", data );
    });
    
    server.events.on("PlayerData", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      // trace('got PLAYER UPDATE yay');
      server.broadcast( "PlayerUpdate", data );
    });

    server.start();
  }
  public static function main ()
  {
    new Main();
  }
}