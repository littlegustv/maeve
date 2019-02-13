class Main {
  var clients:Map<String, mphx.connection.IConnection> = new Map();
  var server:mphx.server.impl.Server;
  var rooms:Map<String, mphx.server.room.Room>;

  function makeID () {
    var id = "";
    var charactersToUse = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (i in 0...6)
    {
      id += charactersToUse.charAt(Math.floor(Math.random()*charactersToUse.length));
    }
    return id;
  }
  
  public function new ()
  {
    var HOST = "127.0.0.1";
    var PORT = 8000;

    server = new mphx.server.impl.Server( HOST, PORT );

    rooms = new Map<String, mphx.server.room.Room>();
    
    rooms["Default"] = new mphx.server.room.Room();
    server.rooms.push(rooms["Default"]);
    
    rooms["Test1"] = new mphx.server.room.Room();
    server.rooms.push(rooms["Test1"]);
    

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
    
    server.events.on("PlayerData", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      // trace("PlayerData", data);
      server.broadcast( "PlayerUpdate", data );
    });

    server.events.on("GetRooms", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      var keys = [];
      for (key in rooms.keys()) {
        keys.push(key);
      }
      trace('getting rooms: ', keys);
      var result = sender.send( "RoomsData", { rooms: keys } );
      trace('hello!', result);
    });

    server.events.on("JoinRoom", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      if ( rooms.exists( data.room ) ) {
        sender.putInRoom( rooms[data.room] );
        sender.send("JoinedRoom");
      }
    });

    server.events.on( "CreateRoom", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
      if ( !rooms.exists( data.room ) ) {
        rooms[data.room] = new mphx.server.room.Room();
        server.rooms.push( rooms[data.room] );
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