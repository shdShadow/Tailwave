import ws, std/async, json, std/asyncdispatch
import GatewayEvent
import os
# GLOBALS
var first_event: GatewayEvent = nil
var discord_websocket: WebSocket
# PROTOTYPES
proc ReceiveMessage(): Future[void] {.async.}
proc HandleMessage(message: system.string): Future[void] {.async.}
proc MaintainHeartbeat(): Future[void] {.async.}
proc RunConnection*(): Future[void] {.async.}

proc RunConnection*(): Future[void] {.async.} =
    discord_websocket = await newWebSocket("wss://gateway.discord.gg/?v=10&encoding=json")
    await all(ReceiveMessage(), MaintainHeartbeat())

proc ReceiveMessage(): Future[void] {.async.} =
    while true:
        echo "Im receving a message"
        await HandleMessage(await discord_websocket.receiveStrPacket())
    

proc HandleMessage(message: string): Future[void] {.async.} =
    echo "I have handled a message"
    echo message
    let hello = convertJson(message)
    if first_event == nil :
        first_event = hello
        echo first_event.d.heartbeat_interval

proc MaintainHeartbeat(): Future[void] {.async.} =
    while true:
        echo "Im trying to send an Heartbeat"
        if first_event != nil:
            discard discord_websocket.send(first_event.forgeJsonString())
            echo "Sent Heartbeat!"
            sleep(first_event.d.heartbeat_interval)
            echo "Sent Heartbeat"
        else:
            echo "I couldn't the event is null"


    