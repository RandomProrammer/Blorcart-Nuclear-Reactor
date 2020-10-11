--API(s)
local component = require("component")
local event = require("event")
local serialization = require("serialization")
local io = require("io")
--Component(s)
local modem = component.modem
--Function(s)
local function MsgRec(componentId, receiverAddress, senderAddress, port, distance, message)
    
end
--Listener(s)
local MainLisener = event.listen("modem_message",MsgRec)
--Exit
print("Test")
event.pull("key_down")
event.cancel(MainLisener)