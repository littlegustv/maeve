class Main {
  var server:mphx.server.impl.Server;
  var clients:Array<mphx.connection.IConnection> = new Array();

  var rooms:Map<String, mphx.server.room.Room>;
  public function new ()
  {

    server = new mphx.server.impl.Server("192.168.1.22",8000);

    rooms = new Map<String, mphx.server.room.Room>();
    
    rooms["Default"] = new mphx.server.room.Room();
    server.rooms.push(rooms["Default"]);
    
    rooms["Test1"] = new mphx.server.room.Room();
    server.rooms.push(rooms["Test1"]);
    

    server.onConnectionAccepted = function ( reason:String, sender:mphx.connection.IConnection ) {
      trace("Connection Accepted: ", reason);
    };

    server.onConnectionClose =function ( reason:String, sender:mphx.connection.IConnection ) {
      trace("Connection Closed: ", reason);
      // server.broadcast( "Leave", {id: clients.indexOf(sender) });
    };

    server.events.on("Register", function( data:Dynamic, sender:mphx.connection.IConnection )
    {
      trace( "Registered: ", data);
      clients.push(sender);
      sender.send("Registered", {id: clients.indexOf(sender) });
      // server.broadcast( "Join", data );
    });

    server.events.on("Join", function( data:Dynamic, sender:mphx.connection.IConnection ) {
      sender.room.broadcast( "Join", data );
    });
    
    server.events.on("PlayerData", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      // trace('got PLAYER UPDATE yay');
      sender.room.broadcast( "PlayerUpdate", data );
    });

    server.events.on("GetRooms", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      var keys = [];
      for (key in rooms.keys()) {
        keys.push(key);
      }
      sender.send( "RoomsData", { rooms: keys } );
    });

    server.events.on("JoinRoom", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      if ( rooms.exists( data.room ) ) {
        sender.putInRoom( rooms[data.room] );
        sender.send("JoinedRoom");
      }
    });

    server.start();
  }
  public static function main ()
  {
    new Main();
  }
}