import ws, std/async, json, std/asyncdispatch
import GatewayEvent
import os
import std/terminal
import log
# GLOBALS
var first_event: GatewayEvent = nil
var discord_websocket: WebSocket
# PROTOTYPES
proc ReceiveMessage(): Future[void] {.async.}
proc HandleMessage(message: system.string): Future[void] {.async.}
proc MaintainHeartbeat(): Future[void] {.async.}
proc RunConnection*(): Future[void] {.async.}

proc RunConnection*(): Future[void] {.async.} =
    # Creates a new websocket
    discord_websocket = await newWebSocket("wss://gateway.discord.gg/?v=10&encoding=json")
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
    if "op" in payload:
        let opCode = payload["op"].getInt()
        if opCode == 11:
            echo "Received Heartbeat ACK!"
    # first_event is used to get the heartbeat interval. It's the first message that the discord websocket ever sends to us
    if first_event == nil :
        # Returns a GetawayEvent, which is just an object containing the various data of the payload
        let hello = convertJson(message)
        first_event = hello
        printLogInfoHeader()
        echo "The heartbeat interval is: ", first_event.d.heartbeat_interval
    else :
        echo "We didnt parse because we didn't know how to do it"

# Procedure used to maintain the discord websocket open
proc MaintainHeartbeat(): Future[void] {.async.} =
    while true:
        if first_event != nil:
            # Creates a json string which rapresent an Heartbeat payload
            # TODO: change this to ForgeHeartbeat
            echo first_event.forgeJsonString()
            discard discord_websocket.send(first_event.forgeJsonString())
            printLogInfoHeader()
            echo "Sent Heartbeat!"
            # Sleep for the amount of time specified by the Heartbea Interval saved in the first_vent, expressed in milliseconds
            await sleepAsync(first_event.d.heartbeat_interval)
        else:
            # It should never event this branch (hopefully)
            echo "I couldn't the event is null"


    
