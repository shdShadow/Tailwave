import ws
import std/options
import payloads/Hello
type
  GatewayClient* = ref object
    seq*: Option[int]
    ws*: WebSocket  # Assuming you use a websocket lib
    sessionId*: Option[int]
    first_event*: Option[HelloPayload]
    sequence_number*: Option[int]
proc newGatewayClient*():GatewayClient =
    return GatewayClient(
        seq: none(int),
        ws: nil,
        sessionId: none(int),
        first_event: none(HelloPayload)
    )
