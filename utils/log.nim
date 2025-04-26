import std/terminal
import json
proc printLogInfoHeader*():void =
    stdout.styledWrite(fgWhite, bgBlack, styleUnderscore, styleBright, "INFO => ")
proc printLogPayload*(message: JsonNode):void =
    stdout.styledWriteLine(fgCyan, bgBlack, styleUnderscore, styleBright, " PAYLOAD => ")
    stdout.styledWriteLine(fgCyan, message.pretty())

