local network
local trajectory
local gamelogic
local getbodyparts
local camera
local heartbeat

local Settings = {
    ["HitPart"] = "Head"
}

for i,v in pairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "getbodyparts") then
        getbodyparts = v.getbodyparts
    end
    if type(v) == "function" then
        if debug.getinfo(v).name == "trajectory" then
            trajectory = v
        end
for i2,v2 in pairs(debug.getupvalues(v)) do
if type(v2) == "table" and rawget(v2, "send") then
network = v2;
end
if type(v2) == "table" and rawget(v2, "gammo") then
gamelogic = v2;
end
            if type(v2) == "table" and rawget(v2, "basecframe") then
                camera = v2
            end
end
    end
end

if not (network and trajectory and gamelogic and getbodyparts) then
    return
end

spawn(function()
    while true do
        heartbeat = game:GetService("RunService").Heartbeat:Wait()
    end
end)

local GetTarget = function()
local closestdist = math.huge
local closestplr
local closestplrbody

for i,v in pairs(game:GetService("Players"):GetPlayers()) do
    local target_body = getbodyparts(v)
if target_body and rawget(target_body, "rootpart") and v ~= game:GetService("Players").LocalPlayer and v.Team.Name ~= game:GetService("Players").LocalPlayer.Team.Name then
local f = game.Workspace.CurrentCamera:WorldToScreenPoint(target_body.rootpart.Parent["Head"].Position)
local f2 = Vector2.new(f.X, f.Y)
local mouseloc = Vector2.new(game:GetService("Players").LocalPlayer:GetMouse().X, game:GetService("Players").LocalPlayer:GetMouse().Y)
local dist = (f2 - mouseloc).Magnitude
if dist < closestdist then
closestdist = dist
closestplr = v
closestplrbody = target_body.rootpart.Parent
end
end
end

if closestplr and closestplrbody then if closestplrbody:FindFirstChild("Head") then return closestplrbody, closestplr end end
return
end

local __old = network.send
network.send = function(self, ...)
    local args = { ... }
    if args[1] == "newbullets" then
        local target, playertarget = GetTarget()
        print(target, playertarget)
        if target and playertarget then
            local playerposition = camera.basecframe.Position
            args[2]["firepos"] = playerposition
            args[2]["camerapos"] = playerposition
            
            for i,v in pairs(args[2]["bullets"]) do
                v[1] = trajectory(playerposition, Vector3.new(0, game.Workspace.Gravity, 0), target[Settings["HitPart"]].Position, gamelogic.currentgun.data.bulletspeed)
            end
            
            __old(self, unpack(args))
            
            if Settings["Undetectable"] then
local totaltimewaited = 0
repeat
totaltimewaited = totaltimewaited + heartbeat
until totaltimewaited >= ((target[Settings["HitPart"]].Position - playerposition).Magnitude / gamelogic.currentgun.data.bulletspeed)
            end
            
            for i,v in pairs(args[2]["bullets"]) do
if target and v[2] then
    local bullethitarguments = {
        "bullethit",
        playertarget, 
        target[Settings["HitPart"]].Position, 
        target[Settings["HitPart"]], 
        v[2]
    }
network.send(self, unpack(bullethitarguments))
end
            end

    return
        end
    end
    if args[1] == "chatted" then
        local message = args[2]
        if string.find(message:lower(), "sethitpart") then
            for w in message:gmatch('[^:%s]+') do
                if w ~= "sethitpart" then
                    Settings["HitPart"] = w
                end
            end
            return
        end
        if string.find(message:lower(), "setundetectable") then
            for w in message:gmatch('[^:%s]+') do
                if w ~= "setundetectable" then
                    if w:lower() == "true" then
                        Settings["Undetectable"] = true
                    elseif w:lower() == "false" then
                        Settings["Undetectable"] = false
                    end
                end
            end
            return
        end
    end
    return __old(self, unpack(args))
end
