import ws, std/async, json
import GatewayEvent
# GLOBALS
var first_event: GatewayEvent = nil
var discord_websocket: WebSocket
# PROTOTYPES
proc ReceiveMessage(): Future[void] {.async.}
proc HandleMessage(message: system.string): Future[void] {.async.}
proc RunConnection*(): Future[void] {.async.}

proc RunConnection*(): Future[void] {.async.} =
    discord_websocket = await newWebSocket("wss://gateway.discord.gg/?v=10&encoding=json")
    await ReceiveMessage()

proc ReceiveMessage(): Future[void] {.async.} =
    HandleMessage(await discord_websocket.receiveStrPacket())

proc HandleMessage(message: string): Future[void] {.async.} =
    let temp =  parseJson(message)
    echo temp.pretty()

    let hello = convertJson(message)
    if first_event == nil :
        first_event = hello
        echo first_event.d.heartbeat_interval

proc MaintainHeartbeat(): Future[void] {.async.} =
    if first_event == null:
        return
    