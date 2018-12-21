class Main {
  var server:mphx.server.impl.Server;
  public function new ()
  {
    server = new mphx.server.impl.Server("127.0.0.1",8000);

    server.onConnectionAccepted = function (reason:String, sender:mphx.connection.IConnection) {
      trace("Connection Accepted: ", reason);
    };

    server.onConnectionClose =function (reason:String, sender:mphx.connection.IConnection) {
      trace("Connection Closed: ", reason);
    };

    server.events.on("Join", function(data:Dynamic,sender:mphx.connection.IConnection)
    {
      trace( "JOINED: ", data);
      server.broadcast( "Join", data );
    });
    server.start();
  }
  public static function main ()
  {
    new Main();
  }
}