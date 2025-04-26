import std/json
type GatewayData* = ref object 
    heartbeat_interval* : int
type GatewayEvent* = ref object
    op*: int
    # TODO: GatewayData is too generic. It will never just be the heartbeat interval
    d*: GatewayData
    s*: int
    t*: string

proc convertJson*(json: string): GatewayEvent = 
    var json_object = parseJson(json)
    return GatewayEvent(op: json_object["op"].getInt(), s:json_object["s"].getInt(), d: GatewayData(heartbeat_interval: json_object["d"]["heartbeat_interval"].getInt()), t: json_object["t"].getStr())

proc forgeJsonString*(event: GatewayEvent): string = 
    var sequence = ""
    if event.s == 0:
        let json_string = %*
            {"op":1, "d": nil}
        return json_string.pretty(0)
    else: 
        let json_string = %*
            {"op":1, "d": $event.s}
        #sequence = $event.s
        return json_string.pretty(0)




