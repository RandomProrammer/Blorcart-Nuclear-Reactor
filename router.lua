--API(s)
local component = require("component")
local event = require("event")
local serialization = require("serialization")
--Component(s)
local modem = component.modem
--Variable(s)
local Port = 78
--GetData
local SerilizeData = io.open("/Routing","r")
if not SerilizeData then
    local f = io.open("/Routing","w")
    local TempTable = {}
    f:write(serialization.serialize(TempTable))
    f:close()
end
local SerilizeData = io.open("/Routing","r")
local RoutingTable = serialization.unserialize(SerilizeData:read())
SerilizeData:close()
--Function(s)
local function FindAddrs(ToFind)

end
local function MsgRec(componentId, receiverAddress, senderAddress, port, distance, message)
    local MsgData = serialization.unserialize(message)
    if MsgData["Type"] == "msg" then
        local ToForward = MsgData["To"]
        local FwrdAddr = FindAddrs(ToForward)
        modem.send(FwrdAddr, Port, message)
    elseif MsgData["Type"] == "cmd" then
        local Sender = MsgData["Sender"]
        local FwrdAddr = FindAddrs(Sender)
        local Response = {}
        Response["Type"] = "res"
        Response["Sender"] = "1"
        Response["To"] = Sender
        Response["Data"] = "Instructions Not Supported"
        local SerialzedResponse = serialization.serialize(Response)
        modem.send(FwrdAddr, Port, SerialzedResponse)
    elseif MsgData["Type"] == "req" then
        local Sender = MsgData["Sender"]
        local FwrdAddr = FindAddrs(Sender)
        local Response = {}
        Response["Type"] = "res"
        Response["Sender"] = "1"
        Response["To"] = Sender
        Response["Data"] = RoutingTable
        local SerialzedResponse = serialization.serialize(Response)
        modem.send(FwrdAddr, Port, SerialzedResponse)
    end
end
--Listener(s)
local MainLisener = event.listen("modem_message",MsgRec)
--Start
modem.open(Port)
--Exit
event.pull("key_down")
event.cancel(MainLisener)