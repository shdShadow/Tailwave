import asyncdispatch, asynchttpserver, ws
import utils/GatewayConn
proc main() {.async.} =
    var ws = await newWebSocket("wss://gateway.discord.gg/?v=10&encoding=json")
    ReceiveMessage(ws)

waitFor(main())