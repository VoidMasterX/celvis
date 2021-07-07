local Services = {
Players = game:GetService("Players"),
UserInputService = game:GetService("UserInputService"),
RunService = game:GetService("RunService"),
}

local Local = {
Player = Services.Players.LocalPlayer,
Mouse = Services.Players.LocalPlayer:GetMouse(),
}

local Other = {
Camera = workspace.CurrentCamera,
BeamPart = Instance.new("Part", workspace)
}

Other.BeamPart.Name = "BeamPart"
Other.BeamPart.Transparency = 1

local Settings = {
StartColor = Color3.new(0, 0.6, 1),
EndColor = Color3.new(1, 0, 0),
StartWidth = 0.1,
EndWidth = 0.05,
ShowImpactPoint = false,
ImpactTransparency = 10,
ImpactColor = Color3.new(0, 0.6, 1),
Time = 1,
}

local funcs = {}
local Silent = false

function funcs:Beam(v1, v2)
local colorSequence = ColorSequence.new({
ColorSequenceKeypoint.new(0, Settings.StartColor),
ColorSequenceKeypoint.new(1, Settings.EndColor),
})
local Part = Instance.new("Part", Other.BeamPart)
Part.Size = Vector3.new(1, 1, 1)
Part.Transparency = 1
Part.CanCollide = false
Part.CFrame = CFrame.new(v1)
Part.Anchored = true
local Attachment = Instance.new("Attachment", Part)
local Part2 = Instance.new("Part", Other.BeamPart)
Part2.Size = Vector3.new(1, 1, 1)
Part2.Transparency = ShowImpactPoint and Settings.ImpactTransparency or 1
Part2.CanCollide = false
Part2.CFrame = CFrame.new(v2)
Part2.Anchored = true
Part2.Color = Settings.ImpactColor
local Attachment2 = Instance.new("Attachment", Part2)
local Beam = Instance.new("Beam", Part)
Beam.FaceCamera = true
Beam.Color = colorSequence
Beam.Attachment0 = Attachment
Beam.Attachment1 = Attachment2
Beam.LightEmission = 6
Beam.LightInfluence = 1
Beam.Width0 = Settings.StartWidth
Beam.Width1 = Settings.EndWidth
delay(Settings.Time, function()
for i = 0.5, 1, 0.02 do
wait()
Beam.Transparency = NumberSequence.new(i)
end
Part:Destroy()
Part2:Destroy()
end)
end

function funcs:getclosest()
   local target
   local closest = math.huge
   for i, v in pairs(Services.Players:GetPlayers()) do
       if v and v.Character and v.Character:FindFirstChild("Head") and v ~= Local.Player then
           local pos, vis = Other.Camera:WorldToScreenPoint(v.Character:FindFirstChild("Head").Position)
           pos = Vector2.new(pos.X, pos.Y)
           local mousepos = Vector2.new(Local.Mouse.X, Local.Mouse.Y)
           local newdist = (pos - mousepos).magnitude
           if newdist < closest then
               closest = newdist
               target = v
           end
       end
   end
   return target
end

Services.RunService.RenderStepped:Connect(function()
if Services.UserInputService:IsMouseButtonPressed(0) then
if Local.Player.Character and Local.Player.Character:FindFirstChild("Head") then
if Silent then
local closest = funcs:getclosest()
if closest and closest.Character and closest.Character:FindFirstChild("Head") then
funcs:Beam(Other.Camera and Other.Camera.Position or Local.Player.Character:FindFirstChild("Head").Position, closest.Character:FindFirstChild("Head").Position)
end
else
funcs:Beam(Other.Camera and Other.Camera.CFrame.p or Local.Player.Character:FindFirstChild("Head").Position, Local.Mouse.Hit.Position)
end
end
end
end)
