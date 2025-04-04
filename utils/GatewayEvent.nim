import std/json
type GatewayData* = ref object 
    heartbeat_interval* : int
type GatewayEvent* = ref object
    op*: int
    d*: GatewayData
    s*: int
    t*: string

proc convertJson*(json: string): GatewayEvent = 
    var json_object = parseJson(json)
    return GatewayEvent(op: json_object["op"].getInt(), s:json_object["s"].getInt(), d: GatewayData(heartbeat_interval: json_object["d"]["heartbeat_interval"].getInt()), t: json_object["t"].getStr())


