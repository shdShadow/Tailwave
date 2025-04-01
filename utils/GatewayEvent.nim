import std/json
type GatewayEvent = object
    op_code: int
    data: JsonNode
    sequence_number: int
    t: string


