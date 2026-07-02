loadstring(game:HttpGet(-- Strong Man Simulator Script
-- Работает с большинством экзекьюторов (Synapse, Krnl, Fluxus и др.)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Настройки (можно менять под себя)
local Settings = {
    AutoClick = false,        -- Автокликер
    AutoTrain = false,        -- Авто тренировка
    AutoCollect = false,      -- Авто сбор монет
    AutoRebirth = false,      -- Авто ребирт
    ClickSpeed = 0.01,        -- Скорость кликов (сек)
    RebirthAt = 10,           -- Ребирт при уровне силы >=
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "Strong Man Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Функция создания кнопки
local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Функция получения игровых объектов
local function GetGameObjects()
    local player = LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local clickDetector = character:FindFirstChild("ClickDetector")
    local trainingArea = workspace:FindFirstChild("TrainingArea")
    local coinCollector = workspace:FindFirstChild("CoinCollector")
    
    return {
        Player = player,
        Character = character,
        Humanoid = humanoid,
        ClickDetector = clickDetector,
        TrainingArea = trainingArea,
        CoinCollector = coinCollector
    }
end

-- Автокликер
local clickLoop
local function ToggleAutoClick()
    Settings.AutoClick = not Settings.AutoClick
    
    if Settings.AutoClick then
        clickLoop = RunService.Heartbeat:Connect(function()
            local objects = GetGameObjects()
            if objects.ClickDetector then
                fireclickdetector(objects.ClickDetector)
            end
        end)
        print("AutoClick: ON")
    else
        if clickLoop then
            clickLoop:Disconnect()
            clickLoop = nil
        end
        print("AutoClick: OFF")
    end
end

-- Авто тренировка
local trainLoop
local function ToggleAutoTrain()
    Settings.AutoTrain = not Settings.AutoTrain
    
    if Settings.AutoTrain then
        trainLoop = RunService.Heartbeat:Connect(function()
            local objects = GetGameObjects()
            if objects.TrainingArea then
                -- Перемещение к тренировочной зоне
                local playerChar = objects.Character
                local rootPart = playerChar:FindFirstChild("HumanoidRootPart")
                if rootPart and objects.TrainingArea.PrimaryPart then
                    local targetPos = objects.TrainingArea.PrimaryPart.Position + Vector3.new(0, 5, 0)
                    rootPart.CFrame = CFrame.new(targetPos)
                end
            end
        end)
        print("AutoTrain: ON")
    else
        if trainLoop then
            trainLoop:Disconnect()
            trainLoop = nil
        end
        print("AutoTrain: OFF")
    end
end

-- Авто сбор монет
local collectLoop
local function ToggleAutoCollect()
    Settings.AutoCollect = not Settings.AutoCollect
    
    if Settings.AutoCollect then
        collectLoop = RunService.Heartbeat:Connect(function()
            local objects = GetGameObjects()
            if objects.CoinCollector then
                local playerChar = objects.Character
                local rootPart = playerChar:FindFirstChild("HumanoidRootPart")
                if rootPart and objects.CoinCollector.PrimaryPart then
                    local targetPos = objects.CoinCollector.PrimaryPart.Position + Vector3.new(0, 3, 0)
                    rootPart.CFrame = CFrame.new(targetPos)
                end
            end
        end)
        print("AutoCollect: ON")
    else
        if collectLoop then
            collectLoop:Disconnect()
            collectLoop = nil
        end
        print("AutoCollect: OFF")
    end
end

-- Авто ребирт
local function AutoRebirth()
    while Settings.AutoRebirth do
        wait(1)
        local player = LocalPlayer
        local strength = player:FindFirstChild("Strength") or player:FindFirstChild("Power")
        
        if strength and strength.Value >= Settings.RebirthAt then
            local rebirthButton = player.PlayerGui:FindFirstChild("RebirthButton")
            if rebirthButton then
                rebirthButton:FindFirstChild("ClickDetector") and fireclickdetector(rebirthButton:FindFirstChild("ClickDetector"))
                print("Rebirth performed at strength " .. strength.Value)
                wait(2)
            end
        end
    end
end

local function ToggleAutoRebirth()
    Settings.AutoRebirth = not Settings.AutoRebirth
    if Settings.AutoRebirth then
        spawn(AutoRebirth)
        print("AutoRebirth: ON")
    else
        print("AutoRebirth: OFF")
    end
end

-- Кнопки GUI
local yOffset = 40

CreateButton("Toggle AutoClick", yOffset, ToggleAutoClick)
yOffset = yOffset + 45

CreateButton("Toggle AutoTrain", yOffset, ToggleAutoTrain)
yOffset = yOffset + 45

CreateButton("Toggle AutoCollect", yOffset, ToggleAutoCollect)
yOffset = yOffset + 45

CreateButton("Toggle AutoRebirth", yOffset, ToggleAutoRebirth)
yOffset = yOffset + 45

-- Кнопка телепортации в тренировочную зону
CreateButton("Teleport to Training", yOffset, function()
    local training = workspace:FindFirstChild("TrainingArea")
    if training and training.PrimaryPart then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(training.PrimaryPart.Position + Vector3.new(0, 5, 0))
            end
        end
    end
end)

-- Кнопка телепортации к монетам
CreateButton("Teleport to Coins", yOffset + 45, function()
    local coins = workspace:FindFirstChild("CoinCollector")
    if coins and coins.PrimaryPart then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(coins.PrimaryPart.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Быстрый клик по горячей клавише
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        ToggleAutoClick()
    elseif input.KeyCode == Enum.KeyCode.Z then
        ToggleAutoTrain()
    elseif input.KeyCode == Enum.KeyCode.C then
        ToggleAutoCollect()
    elseif input.KeyCode == Enum.KeyCode.V then
        ToggleAutoRebirth()
    elseif input.KeyCode == Enum.KeyCode.T then
        local objects = GetGameObjects()
        if objects.TrainingArea then
            local root = objects.Character:FindFirstChild("HumanoidRootPart")
            if root and objects.TrainingArea.PrimaryPart then
                root.CFrame = CFrame.new(objects.TrainingArea.PrimaryPart.Position + Vector3.new(0, 5, 0))
            end
        end
    end
end)

print("✅ Script loaded! Хоткеи: X-AutoClick, Z-AutoTrain, C-AutoCollect, V-AutoRebirth, T-Teleport")))()
