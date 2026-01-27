local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Revaultron | Reality Compromised",
   LoadingTitle = "Revaultron - Reality Compromised",
   LoadingSubtitle = "by spectral",
   ConfigurationSaving = { Enabled = true, FolderName = "RevHub", FileName = "RECMP_Config" },
   KeySystem = false, -- Set this to true to use their key system
   KeySettings = {
      Title = "Revaultron Key System",
      Subtitle = "",
      Note = "Join our Discord for the key!",
      FileName = "RealityKey",
      SaveKey = true,
      GrabKeyFromSite = false, -- Set this to true if you use a Pastebin link
      Key = {"12345"} -- The key is now 12345
   }
})

-- Global States
_G.HitboxEnabled = false
_G.ChamsEnabled = false
_G.LagServer = false
_G.CamlockActive = false
_G.AutoKillActive = false
_G.InfDash = false
_G.AtAmmo = false
_G.ManualMoney = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local Camera = workspace.CurrentCamera

-------------------------------------------------------------------------------
-- UI INDICATORS
-------------------------------------------------------------------------------
local function CreateIndicator(text, position)
    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 220, 0, 90)
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    frame.Visible = false
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(40, 40, 40)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LineHeight = 1.4
    label.RichText = true
    return frame
end

local CamUI = CreateIndicator("Rev's Camlock\nF3: Terminate\nRight Click: Lock On", UDim2.new(1, -240, 1, -110))
local KillUI = CreateIndicator("Rev's Boss Autokill\nF7: Terminate\nP: Buy Ammo / Back", UDim2.new(0, 20, 1, -110))

-------------------------------------------------------------------------------
-- GLOBAL INPUT LISTENER (F3, F7, P, Q)
-------------------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- F3: Terminate Camlock
    if input.KeyCode == Enum.KeyCode.F3 then
        _G.CamlockActive = false
        CamUI.Visible = false
    end
    
    -- F7: Terminate AutoKill (CRITICAL FIX)
    if input.KeyCode == Enum.KeyCode.F7 then
        _G.AutoKillActive = false
        _G.AtAmmo = false
        KillUI.Visible = false
        -- Stop movement immediately
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
    
    -- P: Ammo Station Toggle
    if input.KeyCode == Enum.KeyCode.P and _G.AutoKillActive then
        _G.AtAmmo = not _G.AtAmmo
        if _G.AtAmmo then
            local station = workspace:FindFirstChild("AmmoStation", true)
            if station and LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = station.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end

    -- Q: Glide Dash
    if input.KeyCode == Enum.KeyCode.Q and _G.InfDash then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum then
            local direction = hum.MoveDirection
            if direction.Magnitude == 0 then direction = hrp.CFrame.LookVector end
            local velocity = Instance.new("BodyVelocity")
            velocity.MaxForce = Vector3.new(1, 0, 1) * 50000
            velocity.Velocity = direction * 105
            velocity.Parent = hrp
            task.delay(0.18, function() if velocity then velocity:Destroy() end end)
        end
    end
end)

-------------------------------------------------------------------------------
-- BOSS TOOLS TAB
-------------------------------------------------------------------------------
local BossTab = Window:CreateTab("Boss Tools", nil)

BossTab:CreateToggle({
   Name = "Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value)
      _G.HitboxEnabled = Value
      if not Value then return end
      local bossFolder = workspace:WaitForChild("BossPlayers")
      local function setupBoss(bossCharacter)
          if not bossCharacter:FindFirstChild("Head") then bossCharacter.ChildAdded:Wait() end
          local head = bossCharacter.Head
          local humanoid = bossCharacter:FindFirstChildOfClass("Humanoid")
          local rootPart = bossCharacter:FindFirstChild("HumanoidRootPart")
          if not humanoid or not rootPart then return end
          head.Size = Vector3.new(20, 20, 20)
          head.Transparency = 1
          head.CanTouch = true
          head.CanCollide = false
          head.Massless = true
          humanoid.HipHeight = 3.0
          rootPart.Anchored = false
          humanoid:ChangeState(Enum.HumanoidStateType.Running)
          head.Touched:Connect(function(part)
              if not _G.HitboxEnabled then return end
              if part:IsDescendantOf(bossCharacter) then return end
              local char = part:FindFirstAncestorOfClass("Model")
              if char and Players:GetPlayerFromCharacter(char) then
                  humanoid:TakeDamage(50) 
              end
          end)
      end
      task.spawn(function()
          while _G.HitboxEnabled do
              for _, boss in ipairs(bossFolder:GetChildren()) do
                  if boss:IsA("Model") and boss:FindFirstChild("Head") and boss.Head.Size.X < 19 then setupBoss(boss) end
              end
              task.wait(2)
          end
      end)
   end,
})

BossTab:CreateToggle({
   Name = "Boss Chams",
   CurrentValue = false,
   Callback = function(Value)
      _G.ChamsEnabled = Value
      task.spawn(function()
         while _G.ChamsEnabled do
            for _, boss in ipairs(workspace.BossPlayers:GetChildren()) do
               if not boss:FindFirstChild("BossCham") then
                  local h = Instance.new("Highlight", boss)
                  h.Name = "BossCham"
                  h.FillColor = Color3.fromRGB(0, 255, 0)
                  h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
               end
               boss.BossCham.Enabled = true
            end
            task.wait(2)
         end
         for _, boss in ipairs(workspace.BossPlayers:GetChildren()) do
            if boss:FindFirstChild("BossCham") then boss.BossCham.Enabled = false end
         end
      end)
   end,
})

BossTab:CreateToggle({
   Name = "No Dash Cooldown",
   CurrentValue = false,
   Callback = function(Value) _G.InfDash = Value end,
})

BossTab:CreateSection("Misc Boss Tools")

BossTab:CreateButton({
   Name = "Rev's Camlock",
   Callback = function()
      _G.CamlockActive = true
      CamUI.Visible = true
      task.spawn(function()
          local conn
          conn = RunService.RenderStepped:Connect(function()
             if not _G.CamlockActive then conn:Disconnect() return end
             if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local closest, dist = nil, math.huge
                for _, b in pairs(workspace.BossPlayers:GetChildren()) do
                   local h = b:FindFirstChild("Head")
                   if h then
                      local d = (LocalPlayer.Character.HumanoidRootPart.Position - h.Position).Magnitude
                      if d < dist then dist = d closest = b end
                   end
                end
                if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Head.Position) end
             end
          end)
      end)
   end,
})

BossTab:CreateButton({
   Name = "Rev's Auto Boss Kill (Very Glitchy)",
   Callback = function()
      _G.AutoKillActive = true
      KillUI.Visible = true
      task.spawn(function()
         while _G.AutoKillActive do
            if not _G.AutoKillActive then break end -- Extra safety break
            if not _G.AtAmmo then
                local target, dist = nil, math.huge
                for _, b in pairs(workspace.BossPlayers:GetChildren()) do
                   local r = b:FindFirstChild("HumanoidRootPart")
                   if r then
                      local d = (LocalPlayer.Character.HumanoidRootPart.Position - r.Position).Magnitude
                      if d < dist then dist = d target = b end
                   end
                end
                if target and _G.AutoKillActive and LocalPlayer.Character then
                   LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Head.Position + Vector3.new(0, 45, 0), target.Head.Position)
                   LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero
                end
            end
            task.wait()
         end
      end)
   end,
})

-------------------------------------------------------------------------------
-- FARMING TAB
-------------------------------------------------------------------------------
local FarmTab = Window:CreateTab("Farming", nil)

FarmTab:CreateButton({
   Name = "Become Janitor",
   Callback = function() game:GetService("ReplicatedStorage").Misc.SetupJanitor:FireServer() end,
})

FarmTab:CreateButton({
   Name = "Infinite Money (Become Janitor First!)",
   Callback = function()
       _G.ManualMoney = true
       task.spawn(function()
           while _G.ManualMoney do
               local mop = LocalPlayer.Character:FindFirstChild("Mop")
               if mop then mop.CleanBlood:FireServer("Small") mop.CleanBlood:FireServer("Large") end
               task.wait()
           end
       end)
   end,
})

-------------------------------------------------------------------------------
-- TROLLING TAB
-------------------------------------------------------------------------------
local TrollTab = Window:CreateTab("Trolling", nil)

TrollTab:CreateToggle({
   Name = "Server Lag (Must Own 'Lock In')",
   CurrentValue = false,
   Callback = function(Value)
      _G.LagServer = Value
      task.spawn(function()
         while _G.LagServer do
            game:GetService("ReplicatedStorage").EmoteEvents.RemoteEvents.PlayEmote:FireServer("Lock In")
            task.wait()
         end
      end)
   end,
})

-------------------------------------------------------------------------------
-- MISC TAB
-------------------------------------------------------------------------------
local MiscTab = Window:CreateTab("Miscellaneous", nil)

MiscTab:CreateButton({
   Name = "Infinite Yield",
   Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end,
})

MiscTab:CreateButton({
   Name = "Teleport to the Lobby",
   Callback = function()
       local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("SpawnLocation")
       if lobby then LocalPlayer.Character.HumanoidRootPart.CFrame = (lobby:IsA("Model") and lobby:GetModelCFrame()) or lobby.CFrame end
   end,
})

MiscTab:CreateButton({
   Name = "Teleport to Farthest Player",
   Callback = function()
       local farthest, maxDist = nil, 0
       for _, p in pairs(Players:GetPlayers()) do
           if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
               local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
               if d > maxDist then maxDist = d farthest = p end
           end
       end
       if farthest then LocalPlayer.Character.HumanoidRootPart.CFrame = farthest.Character.HumanoidRootPart.CFrame end
   end,
})

MiscTab:CreateButton({
   Name = "No E Hold",
   Callback = function()
       for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end
   end,
})
