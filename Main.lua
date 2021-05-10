--[[
    Era of Althea
    I don't understand this game and think that it's shit (also Sowd likes it YIKES).

    Did you know that 90% of "developers" on v3rm have never heard of the script dumper?
    
    DemonSlayer, I beg you... PLEASE DON'T SKID THIS TOO LOL
]]

-- Define variables

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/LegoHacks/Utilities/main/UI.lua"))();
local moderators = game:HttpGet("https://raw.githubusercontent.com/LegoHacks/Era-of-Althea/master/Moderators.txt"):split("\n");

local players = game:GetService("Players");
local runService = game:GetService("RunService");
local tweenService = game:GetService("TweenService");
local client = players.LocalPlayer;

-- "Anti cheat" bypass

do
    local isA = game.IsA;
    local mt = debug.getmetatable(game);
    local nc = mt.__namecall;
    local idx = mt.__index;
    local newIdx = mt.__newindex;

    setreadonly(mt, false);

    mt.__namecall = newcclosure(function(self, ...)
        if (checkcaller()) then return nc(self, ...) end;

        local method = getnamecallmethod();

        if (method == "Kick" or (method == "ClearAllChildren" and self == client.Character)) then
            return wait(10e16); --> Good anti cheat moment
        elseif (method == "FireServer" and self.Name == "UpdateLocation") then
            return; --> I do such a significant amount of trolling.
        end;

        return nc(self, ...);
    end);

    mt.__index = newcclosure(function(self, key)
        if (checkcaller()) then return idx(self, key) end;

        if (isA(self, "Humanoid") and key == "WalkSpeed") then
            return 16;
        elseif (isA(self, "Humanoid") and key == "JumpPower") then
            return 50;
        end;

        return idx(self, key);
    end);

    mt.__newindex = newcclosure(function(self, key, value)
        if (checkcaller()) then return newIdx(self, key, value) end;

        if (isA(self, "Humanoid") and key == "WalkSpeed" and library.flags.walkSpeedEnabled) then
            value = library.flags.walkSpeed;
        elseif (isA(self, "Humanoid") and key == "JumpPower" and library.flags.jumpPowerEnabled) then
            value = library.flags.jumpPower;
        end

        return newIdx(self, key, value);
    end);

    setreadonly(mt, true);
end;

-- Anti moderator

for i, v in next, players:GetPlayers() do
    if (table.find(moderators, tostring(v.UserId))) then
        return client:Kick("\n[Moderator Detected]\n" .. v.Name);
    end;
end;

players.PlayerAdded:Connect(function(player)
    if (table.find(moderators, tostring(player.UserId))) then
        return client:Kick("\n[Moderator Detected]\n" .. player.Name);
    end;
end);

-- Main script

local function getClosestMob()
    local distance, mob = math.huge;

    for i, v in next, workspace.NPCS:GetChildren() do
        if (v.Name ~= "Dire Wolf" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Hitbox") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0) then --> Can't kill dire wolf fsr, Idfk.
            local distanceFromChar = client:DistanceFromCharacter(v.HumanoidRootPart.Position);

            if (distanceFromChar < distance) then
                distance = distanceFromChar;
                mob = v;
            end;
        end;
    end;

    return mob;
end;

local function attack()
    if (not client.Character or not client.Character:FindFirstChild("Client")) then return end;
    client.Character.Client.Events.LightAttack:FireServer("SecretCode"); --> Devs are fucking autistic, kthx.
end;

local autoFarmTab = library:CreateWindow("Auto Farm");

autoFarmTab:AddToggle({
    text = "Enabled";
    flag = "autofarming";
    callback = function(enabled)
        if (not enabled) then return end;

        while library.flags.autofarming do
            local mob = getClosestMob();

            if (mob) then
                pcall(function()
                    tweenService:Create(client.Character.HumanoidRootPart, TweenInfo.new(((client.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position)).Magnitude / 100), {CFrame = mob.PrimaryPart.CFrame * CFrame.new(0, 12, 0)}):Play();
                    if (not library.flags.aura) then
                        attack();
                    end;
                end);
            end;

            wait();
        end;
    end;
});

autoFarmTab:AddToggle({
    text = "Kill Aura";
    flag = "aura";
    callback = function(enabled)
        if (not enabled) then return end;

        while library.flags.aura do
            attack();
            wait();
        end;
    end;
});

local characterTab = library:CreateWindow("Character")

characterTab:AddToggle({
    text = "WalkSpeed";
    flag = "walkSpeedEnabled";
    callback = function(enabled)
        if (not enabled) then return end;

        while library.flags.walkSpeedEnabled do
            if (client.Character and client.Character:FindFirstChild("Humanoid")) then
                client.Character.Humanoid.WalkSpeed = (library.flags.walkSpeed or 16);
            end;

            wait();
        end;
    end;
});

characterTab:AddSlider({
    text = "WalkSpeed";
    flag = "walkSpeed";
    min = 16;
    max = 250;
});

characterTab:AddToggle({
    text = "JumpPower";
    flag = "jumpPowerEnabled";
    callback = function(enabled)
        if (not enabled) then return end;

        while library.flags.walkSpeedEnabled do
            if (client.Character and client.Character:FindFirstChild("Humanoid")) then
                client.Character.Humanoid.JumpPower = (library.flags.jumpPower or 50);
            end;

            wait();
        end;
    end;
});

characterTab:AddSlider({
    text = "JumpPower";
    flag = "jumpPower";
    min = 50;
    max = 250;
});

runService.RenderStepped:Connect(function()
    if (client.Character and library.flags.autofarming) then
        for i, v in next, client.Character:GetDescendants() do
            if (not v:IsA("BasePart")) then continue end;
            v.CanCollide = false;
        end;
    end;
end);

library:Init();
