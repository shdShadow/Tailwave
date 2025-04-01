import ws, std/async
# PROTOTYPES
proc ReceiveMessage*(ws: WebSocket): Future[void] {.async.}
proc HandleMessage(message: system.string): Future[void] {.async.}
proc ReceiveMessage*(ws: WebSocket): Future[void] {.async.} =
    HandleMessage(await ws.receiveStrPacket())

proc HandleMessage(message: string): Future[void] {.async.} =
    echo message