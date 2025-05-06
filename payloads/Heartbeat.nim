# This module will contain everything related to the Heartbeat payload
# This should not be confused with the HeartbeatACK payload
# Heartbeat is the payload that we send to maintain the connection open
# HeartbeatACK is the payload that the discord's api send to us that confirms that it received our Heartbeat so the we know our connection is not zombied
# TODO: Example
#{
#  "op": 1,
#  "d": 251
#}
import std/json
import std/options
type HeartbeatPayload* = ref object
    op*: int
    d*: Option[int]

proc serializeJsonHeartbeat*(heartbeat: HeartbeatPayload): string = 
    if heartbeat.d.isNone():
        let json_string = %*
            {"op":1, "d": nil}
        return json_string.pretty()
    else:
        let json_string = %*
            {"op":1, "d": heartbeat.d.get()}
        return json_string.pretty()

