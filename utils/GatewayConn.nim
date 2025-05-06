import ws, std/async, json, std/asyncdispatch
import std/options
import ../GatewayClient
import std/terminal
import log
import ../payloads/Hello
import ../payloads/Heartbeat
# GLOBALS
var client = newGatewayClient()
var discord_websocket: WebSocket
# PROTOTYPES
proc ReceiveMessage(): Future[void] {.async.}
proc HandleMessage(message: system.string): Future[void] {.async.}
proc MaintainHeartbeat(): Future[void] {.async.}
proc RunConnection*(): Future[void] {.async.}

proc RunConnection*(): Future[void] {.async.} =
    # Creates a new websocket
    discord_websocket = await newWebSocket("wss://gateway.discord.gg/?v=10&encoding=json")
    client.ws = discord_websocket
    # Execute and await every asynchronous procedure
    await all(ReceiveMessage(), MaintainHeartbeat())

# This function simply receive every message that the websocket receives. It doesn not handle them
proc ReceiveMessage(): Future[void] {.async.} =
    while true:
        printLogInfoHeader()
        echo "Waiting for a message"
        await HandleMessage(await discord_websocket.receiveStrPacket())
    

proc HandleMessage(message: string): Future[void] {.async.} =
    printLogInfoHeader()
    echo "Received a new message! Handling message!"
    # Creates a JsonNode with parseJson
    let payload = parseJson(message)
    printLogPayload(payload) # Temporary logic.
    # For debug reasons only, it checks if the current parsed json has opcode = 11 (Heartbeat ACK)
    # Parse payload into the correct class
    # 10 => Hello. Contains the heartbeat interval
    # 11 => Heartbeat ACK
    if "op" in payload:
        let opCode = payload["op"].getInt()
        case opCode:
            of 10:
                # Serialize this into an object: HelloPayload
                # This switch branch is executed only once (hopefully). Discord's api should never send to us two Hello payloads. The check is made just in case something goes wrong
                client.first_event = some(deserializeJsonHello(payload))
                client.sequence_number = client.first_event.get().s
                printLogInfoHeader()
                echo "The heartbeat interval is: ", client.first_event.get().heartbeat_interval
            of 11:
                #TODO serialization
                printLogInfoHeader()
                echo "Received HeartbeatACK"
            else:
                # TODO: Error because of unrecognized payload
                printErrorHeader()
                echo "Unrecognized payload. Shutting down"
                system.quit()
    else:
        #TODO: Print an error. If a payload does not have an opcode, it means that either discord has changed their package formation or something is currently wrong with their api
        printErrorHeader()
        echo "Unrecognized payload structure. Shutting down"
        system.quit()
    # first_event is used to get the heartbeat interval. It's the first message that the discord websocket ever sends to us

# Procedure used to maintain the discord websocket open
proc MaintainHeartbeat(): Future[void] {.async.} =
    while true:
        if client.first_event.isSome():
            # Creates a json string which rapresent an Heartbeat payload
            let heartbeat = HeartbeatPayload(op:1, d: client.sequence_number)
            discard discord_websocket.send(heartbeat.serializeJsonHeartbeat())
            printLogInfoHeader()
            echo "Sent Heartbeat!"
            echo heartbeat.serializeJsonHeartbeat()
            # Sleep for the amount of time specified by the Heartbea Interval saved in the first_vent, expressed in milliseconds
            await sleepAsync(client.first_event.get().heartbeat_interval)
        #else:
            # It should never event this branch (hopefully)
            echo "I couldn't the event is null"


    
