# This module will contain everything related to the Hello payload
# Hello has an opcode = 10, and it's the first message that the discord websocket api ever sends
# Not all the data of that message will be store, we will only need (for now afaik) the heartbeat_interval
# Example of Hello payload
#{
#  "t": null,
#  "s": null,
#  "op": 10,
#  "d": {
#    "heartbeat_interval": 41250,
#    "_trace": [
#      "[\"gateway-prd-us-east1-d-c8n7\",{\"micros\":0.0}]"
#    ]
#  }
#}
import std/json
import std/options
type HelloPayload* = ref object
    s*: Option[int]
    op*: int
    heartbeat_interval*: int

proc deserializeJsonHello*(json_node: JsonNode): HelloPayload =
    #TODO: s = 0, if in the payload s: null. (It is just how nim works). So change s to Option(int) and set it to none if s = 0
    if json_node["s"].getInt() == 0:
        return HelloPayload(op: json_node["op"].getInt(), heartbeat_interval: json_node["d"]["heartbeat_interval"].getInt(), s: none(int))
    else:
        return HelloPayload(op: json_node["op"].getInt(), heartbeat_interval: json_node["d"]["heartbeat_interval"].getInt(), s: some(json_node["s"].getInt()))
# Serialization should not be needed? I never send hello payloads to discord's api
