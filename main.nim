import asyncdispatch, asynchttpserver, ws
import utils/GatewayConn
proc main() {.async.} =
    await RunConnection()

waitFor(main())
