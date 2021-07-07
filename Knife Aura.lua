local Range = 25

local Network;
local PlayerInfo;
local LocalPlayer;

for _, Val in next, getgc(true) do
  if type(Val) == "table" and rawget(Val, "send") then
      Network = Val;
  elseif type(Val) == "table" and rawget(Val, "getbodyparts") and rawget(Val, "getplayerhit") then
      PlayerInfo = Val
  elseif type(Val) == "table" and rawget(Val, "rootpart") and rawget(Val, "setmovementmode") then
      LocalPlayer = Val
  end
  if Network and PlayerInfo and LocalPlayer then
      break;
  end
end
warn(LocalPlayer)
local Players = getupvalue(PlayerInfo.getbodyparts, 1)


local function GetClosestEnemy()
  local ClosestDistance = math.huge
  local ClosestBodyParts, ClosestPlayer = nil, nil;

  local LLocalPlayer = game:GetService("Players").LocalPlayer
  local CurrentTeam = LLocalPlayer.Team

  for Player, BodyParts in next, Players do
      if Player.Team ~= CurrentTeam and BodyParts and BodyParts.rootpart then
          local Distance = (BodyParts.rootpart.Position - LocalPlayer.rootpart.Position).Magnitude
          if Distance < ClosestDistance then
              ClosestDistance = Distance
              ClosestPlayer = Player
              ClosestBodyParts = BodyParts
          end
      end
  end

  return ClosestPlayer, ClosestBodyParts, ClosestDistance
end

local function DamagePlayer(Player, BodyParts)
  Network:send("knifehit", Player, tick(), BodyParts.head)
end

game:GetService("RunService").RenderStepped:Connect(function(dT)
  local Player, BodyParts, Distance = GetClosestEnemy()

  if Distance < Range then
      DamagePlayer(Player, BodyParts)
  end
end)
