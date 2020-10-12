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
    for _,v in pairs(RoutingTable) do
        if v[1] == ToFind then
            return v[2]
        end
    end
end
local function MsgRec(componentId, receiverAddress, senderAddress, port, distance, message)
    local MsgData = serialization.unserialize(message)
    if MsgData["Type"] == "msg" then
        local ToForward = MsgData["To"]
        local FwrdAddr = FindAddrs(ToForward)
        modem.send(FwrdAddr, Port, message)
    elseif MsgData["Type"] == "cmd" then
        local To = MsgData["To"]
        local FwrdAddr = FindAddrs(To)
        local Response = {}
        if To == "1" then
            if MsgData["Data"]["cmd"] == "AddRoute" then
                table.insert(RoutingTable,MsgData["Data"]["args"])
                local f = io.open("/Routing","w")
                f:write(serialization.serialize(RoutingTable))
                f:close()
                local Response = {}
                Response["Type"] = "res"
                Response["Sender"] = "1"
                Response["To"] = MsgData["Data"]["args"][1]
                Response["Data"] = RoutingTable
                local SerialzedResponse = serialization.serialize(Response)
                modem.send(senderAddress, Port, SerialzedResponse)
            end
        else
            Response = message
            local SerialzedResponse = serialization.serialize(Response)
            modem.send(FwrdAddr, Port, SerialzedResponse)
        end
    elseif MsgData["Type"] == "req" then
        local Sender = MsgData["Sender"]
        local To = MsgData["To"]
        local FwrdAddr = FindAddrs(To)
        local Response = {}
        if To == "1" then
            Response["Type"] = "res"
            Response["Sender"] = "1"
            Response["To"] = Sender
            Response["Data"] = RoutingTable
            local SerialzedResponse = serialization.serialize(Response)
            modem.send(senderAddress, Port, SerialzedResponse)
        else
            Response = message
            local SerialzedResponse = serialization.serialize(Response)
            modem.send(FwrdAddr, Port, SerialzedResponse)
        end
    end
end
--Listener(s)
local MainLisener = event.listen("modem_message",MsgRec)
--Start
modem.open(Port)
--Exit
event.pull("key_down")
event.cancel(MainLisener)