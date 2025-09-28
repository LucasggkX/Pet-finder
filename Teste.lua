local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI = {
    Titulo = "LKZ Hub",
    link = "https://lucasggkx.github.io/LKZ-Hub/",
    Debug = false
}

function gotoBest()
    local loadingScreenGui = nil
    local progressValue = 0
    local scriptCompleted = false
    local animationConnections = {}
    local brainrotPS = "-"

    local COLORS = {
        PRIMARY = Color3.fromRGB(255, 215, 0),
        SECONDARY = Color3.fromRGB(200, 200, 200),
        BACKGROUND = Color3.fromRGB(0, 0, 0),
        TEXT_DIM = Color3.fromRGB(120, 120, 120),
        PROGRESS_BG = Color3.fromRGB(40, 40, 40),
    }

    local UI = {
        TITLE_HEIGHT = 50,
        PROGRESS_WIDTH = 400,
        PROGRESS_HEIGHT = 16,
        STATUS_HEIGHT = 22,
        LINK_HEIGHT = 20,
        PS_HEIGHT = 30,
    }

    local function createTween(object, tweenInfo, properties)
        local tween = TweenService:Create(object, tweenInfo, properties)
        table.insert(animationConnections, tween)
        return tween
    end

    local function cleanupAnimations()
        for _, tween in pairs(animationConnections) do
            if tween then
                pcall(function() tween:Cancel() end)
            end
        end
        animationConnections = {}
    end

    local function updateGuiProgress(stepName, progress, distance, maxDistance)
        if not loadingScreenGui then return end
        
        if distance and maxDistance and maxDistance > 0 then
            local distanceProgress = math.max(0, (maxDistance - distance) / maxDistance * 100)
            progressValue = math.clamp(math.floor(distanceProgress), 0, 100)
        else
            progressValue = math.clamp(progress or 0, 0, 100)
        end
        
        local elements = {
            progressBar = loadingScreenGui.BackgroundFrame.Container.ProgressContainer.ProgressBar,
            percentageLabel = loadingScreenGui.BackgroundFrame.Container.ProgressContainer.PercentageLabel,
            stepLabel = loadingScreenGui.BackgroundFrame.Container.StepLabel,
            psLabel = loadingScreenGui.BackgroundFrame.PSLabel,
        }
        
        elements.progressBar.Size = UDim2.new(progressValue / 100, 0, 1, 0)
        elements.percentageLabel.Text = progressValue .. "%"
        
        if stepName then
            elements.stepLabel.Text = "Status: " .. stepName
        end
        
        local distText = ""
        if distance and type(distance) == "number" then
            distText = " | Distance: " .. math.floor(distance) .. "m"
        end
        elements.psLabel.Text = "Brainrot Target: " .. brainrotPS .. distText
    end

    local function createFullScreenGui()
        if loadingScreenGui then
            loadingScreenGui:Destroy()
        end

        loadingScreenGui = Instance.new("ScreenGui")
        loadingScreenGui.Name = "lkz-hub"
        loadingScreenGui.Parent = playerGui
        loadingScreenGui.ResetOnSpawn = false
        loadingScreenGui.IgnoreGuiInset = true
        loadingScreenGui.DisplayOrder = 9999999

        local function antiFake()
            loadingScreenGui:GetPropertyChangedSignal("Name"):Connect(function()
                loadingScreenGui.Name = "lkz-hub"
            end)
            loadingScreenGui.AncestryChanged:Connect(function()
                if loadingScreenGui.Parent ~= playerGui then
                    loadingScreenGui.Parent = playerGui
                end
            end)
        end
        antiFake()

        local backgroundFrame = Instance.new("Frame")
        backgroundFrame.Name = "BackgroundFrame"
        backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
        backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
        backgroundFrame.BackgroundColor3 = COLORS.BACKGROUND
        backgroundFrame.BorderSizePixel = 0
        backgroundFrame.Parent = loadingScreenGui

        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(0, 500, 0, 260)
        container.Position = UDim2.new(0.5, -250, 0.5, -130)
        container.BackgroundTransparency = 1
        container.Parent = backgroundFrame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, 0, 0, UI.TITLE_HEIGHT)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = GUI.Titulo
        titleLabel.TextColor3 = COLORS.PRIMARY
        titleLabel.TextSize = 38
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.Parent = container

        local stepLabel = Instance.new("TextLabel")
        stepLabel.Name = "StepLabel"
        stepLabel.Size = UDim2.new(1, 0, 0, UI.STATUS_HEIGHT)
        stepLabel.Position = UDim2.new(0, 0, 0, UI.TITLE_HEIGHT + 10)
        stepLabel.BackgroundTransparency = 1
        stepLabel.Text = "Status: "
        stepLabel.TextColor3 = COLORS.SECONDARY
        stepLabel.TextSize = 20
        stepLabel.Font = Enum.Font.GothamMedium
        stepLabel.TextXAlignment = Enum.TextXAlignment.Center
        stepLabel.Parent = container

        local progressContainer = Instance.new("Frame")
        progressContainer.Name = "ProgressContainer"
        progressContainer.Size = UDim2.new(0, UI.PROGRESS_WIDTH, 0, UI.PROGRESS_HEIGHT)
        progressContainer.Position = UDim2.new(0.5, -UI.PROGRESS_WIDTH/2, 0, UI.TITLE_HEIGHT + UI.STATUS_HEIGHT + 40)
        progressContainer.BackgroundColor3 = COLORS.PROGRESS_BG
        progressContainer.BorderSizePixel = 0
        progressContainer.Parent = container

        local progressCorner = Instance.new("UICorner")
        progressCorner.CornerRadius = UDim.new(0, UI.PROGRESS_HEIGHT/2)
        progressCorner.Parent = progressContainer

        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(0, 0, 1, 0)
        progressBar.Position = UDim2.new(0, 0, 0, 0)
        progressBar.BackgroundColor3 = COLORS.PRIMARY
        progressBar.BorderSizePixel = 0
        progressBar.Parent = progressContainer

        local progressBarCorner = Instance.new("UICorner")
        progressBarCorner.CornerRadius = UDim.new(0, UI.PROGRESS_HEIGHT/2)
        progressBarCorner.Parent = progressBar

        local percentageLabel = Instance.new("TextLabel")
        percentageLabel.Name = "PercentageLabel"
        percentageLabel.Size = UDim2.new(0, 60, 0, 30)
        percentageLabel.Position = UDim2.new(1, 10, 0, -8)
        percentageLabel.BackgroundTransparency = 1
        percentageLabel.Text = "0%"
        percentageLabel.TextColor3 = COLORS.PRIMARY
        percentageLabel.TextSize = 16
        percentageLabel.Font = Enum.Font.GothamBold
        percentageLabel.TextXAlignment = Enum.TextXAlignment.Left
        percentageLabel.Parent = progressContainer

        local linkBtn = Instance.new("TextButton")
        linkBtn.Name = "LinkBtn"
        linkBtn.Size = UDim2.new(0, 300, 0, UI.LINK_HEIGHT)
        linkBtn.Position = UDim2.new(0.5, -150, 1, 30)
        linkBtn.BackgroundTransparency = 1
        linkBtn.Text = "Clique para copiar: " .. GUI.link
        linkBtn.TextColor3 = COLORS.TEXT_DIM
        linkBtn.TextSize = 14
        linkBtn.Font = Enum.Font.GothamMedium
        linkBtn.TextXAlignment = Enum.TextXAlignment.Center
        linkBtn.TextYAlignment = Enum.TextYAlignment.Center
        linkBtn.Parent = container

        linkBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(GUI.link)
            end
            linkBtn.Text = "Copiado!"
            spawn(function()
                task.wait(1)
                linkBtn.Text = "Clique para copiar: " .. GUI.link
            end)
        end)

        local psLabel = Instance.new("TextLabel")
        psLabel.Name = "PSLabel"
        psLabel.Size = UDim2.new(0, 320, 0, UI.PS_HEIGHT) 
        psLabel.Position = UDim2.new(0, 390, 0, 290)
        psLabel.BackgroundTransparency = 1
        psLabel.Text = "Brainrot Target: -"
        psLabel.TextColor3 = COLORS.PRIMARY
        psLabel.TextSize = 16
        psLabel.Font = Enum.Font.GothamBold
        psLabel.TextXAlignment = Enum.TextXAlignment.Right
        psLabel.TextYAlignment = Enum.TextYAlignment.Top
        psLabel.Parent = backgroundFrame
    end

    local function cleanupGui()
        cleanupAnimations()
        if loadingScreenGui then
            local fadeInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local elements = loadingScreenGui:GetDescendants()
            for _, element in pairs(elements) do
                if element:IsA("GuiObject") then
                    spawn(function()
                        createTween(element, fadeInfo, {
                            BackgroundTransparency = 1,
                            TextTransparency = 1
                        }):Play()
                    end)
                end
            end
            task.wait(0.7)
            loadingScreenGui:Destroy()
            loadingScreenGui = nil
        end
    end

    createFullScreenGui()
    
    if GUI.Debug then
    cleanupGui()
    end
    
    updateGuiProgress("Starting...", 0)
    
    local localPlayer = game:GetService("Players").LocalPlayer
    local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local human = localCharacter:WaitForChild("Humanoid")
    human:ChangeState(Enum.HumanoidStateType.Dead)

    updateGuiProgress("Waiting for respawn...", 10)
    local character = player.CharacterAdded:Wait()
    task.wait(0.35)

    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    local backpack = player:WaitForChild("Backpack")

    local function EquipGrapple()
        updateGuiProgress("Equipping Grapple Hook", 20)
        
        humanoid:UnequipTools()
        task.wait(0.1)
        
        local grapple = backpack:FindFirstChild("Grapple Hook")
        if grapple then
            humanoid:EquipTool(grapple)
            task.wait(0.3)
            return true
        else
            return false
        end
    end

    local function getBestBrainrotPosition()
        updateGuiProgress("Scanning Brainrots", 30)
        
        local plots = workspace:FindFirstChild("Plots")
        if not plots then 
            return nil, nil 
        end

        local bestBrainrot, bestEarning = nil, 0
        local desc = "-"
        
        for _, plot in ipairs(plots:GetChildren()) do
            local isOwnPlot = false
            for _, d in ipairs(plot:GetDescendants()) do
                if d:IsA("TextLabel") and type(d.Text) == "string" and d.Text:find(player.DisplayName) then
                    isOwnPlot = true
                    break
                end
            end
            if not isOwnPlot then
                for _, d in ipairs(plot:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Text and d.Text:find("/s") then
                        local txt = d.Text:gsub(",", "")
                        local a, b = txt:match("([%d%.]+)([kKmMbB]?)")
                        local earning = tonumber(a) or 0
                        if b then
                            b = b:lower()
                            if b == "k" then earning = earning * 1e3
                            elseif b == "m" then earning = earning * 1e6
                            elseif b == "b" then earning = earning * 1e9 end
                        end
                        local p = d.Parent
                        while p and not p:IsA("Model") do
                            p = p.Parent
                        end
                        if p and earning > bestEarning then
                            local part = p:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                bestEarning = earning
                                bestBrainrot = part
                                desc = d.Text
                            end
                        end
                    end
                end
            end
            task.wait(0.01)
        end
        
        brainrotPS = (desc and tostring(desc) or "-")
        updateGuiProgress("Best brainrot found", 40)
        return bestBrainrot and bestBrainrot.Position or nil, bestBrainrot
    end

    local function fullStop()
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
            for _ = 1, 3 do
                task.wait()
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.RotVelocity = Vector3.new(0,0,0)
            end
        end
        if humanoid then
            humanoid:Move(Vector3.new(0,0,0))
            pcall(function() humanoid:MoveTo(hrp.Position) end)
        end
    end

    local function equipQuantumClonerAndUse()
        updateGuiProgress("Using Quantum Cloner", 90)
        
        humanoid:UnequipTools()
        task.wait(0.01)
        
        local cloner = backpack:FindFirstChild("Quantum Cloner")
        if cloner then
            humanoid:EquipTool(cloner)
            task.wait(0.01)
            pcall(function()
                ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/UseItem"):FireServer()
            end)
            task.wait(0.01)
            pcall(function()
                ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/QuantumCloner/OnTeleport"):FireServer()
            end)
            task.wait(0.1)
            humanoid:UnequipTools()
            scriptCompleted = true
            return true
        else
            return false
        end
    end

    local function startGrappleSystem()
        task.spawn(function()
            while not scriptCompleted do
                local c, hrp_check, hum_check = character, hrp, humanoid
                if c and hrp_check and hum_check then
                    local bp = player:FindFirstChild("Backpack")
                    if bp and not c:FindFirstChild("Grapple Hook") then
                        local t = bp:FindFirstChild("Grapple Hook")
                        if t then
                            pcall(function()
                                hum_check:EquipTool(t)
                            end)
                        end
                    end
                end
                task.wait(0.05)
            end
        end)

        task.spawn(function()
            while not scriptCompleted do
                pcall(function()
                    local pkg = ReplicatedStorage:FindFirstChild("Packages")
                    if pkg then
                        local net = require(pkg:WaitForChild("Net"))
                        local fire = net:RemoteEvent("UseItem")
                        fire:FireServer(1.9832406361897787)
                    end
                end)
                task.wait(0.05)
            end
        end)
    end

    local function GoToBestBrainrot()
        task.delay(15, function()
            if not scriptCompleted then
                updateGuiProgress("ERROR - Timeout", 100)
                task.wait(2)
                cleanupGui()
                fullStop()
            end
        end)
    
        if not EquipGrapple() then
            updateGuiProgress("Grapple Hook not found", 100)
            task.wait(2)
            cleanupGui()
            return false
        end

        local targetPos, brainrotPart = getBestBrainrotPosition()
        if not targetPos or not brainrotPart then
            updateGuiProgress("No Brainrot available", 100)
            task.wait(2)
            cleanupGui()
            return false
        end

        local initialDistance = (hrp.Position - brainrotPart.Position).Magnitude
        local maxDistance = initialDistance

        updateGuiProgress("Moving to brainrot", 50, initialDistance, maxDistance)

        startGrappleSystem()

        local speed = 170
        local xOptions = {-465, -353}
        local closestX = xOptions[1]
        for i = 1, #xOptions do
            if math.abs(brainrotPart.Position.X - xOptions[i]) < math.abs(brainrotPart.Position.X - closestX) then
                closestX = xOptions[i]
            end
        end

        local desiredAltitude = math.max(57, brainrotPart.Position.Y + 2)
        local phase = "ascend"
        local completed = false
        local startTime = tick()
        local phaseTimeout = 0

        local function handleTargetLost()
            updateGuiProgress("Target lost - stopping", 100)
            task.wait(1)
            cleanupGui()
            return false
        end

        while not completed and (tick() - startTime) < 120 do
            if not player.Character or not player.Character.Parent then
                task.wait(0.1)
                startTime = tick()
                phaseTimeout = 0
            else
                humanoid = player.Character:FindFirstChild("Humanoid") or humanoid
                hrp = player.Character:FindFirstChild("HumanoidRootPart") or hrp
                if not humanoid or not hrp then
                    task.wait(0.05)
                else
                    local dist = nil
                    if brainrotPart and brainrotPart.Parent and brainrotPart:IsDescendantOf(workspace) then
                        dist = (hrp.Position - brainrotPart.Position).Magnitude
                    else
                        handleTargetLost()
                        return false
                    end
                    
                    phaseTimeout = phaseTimeout + 0.03
                    
                    if phase == "ascend" then
                        updateGuiProgress("Ascending to height", 55, dist, maxDistance)
                    elseif phase == "moveX" then
                        updateGuiProgress("Adjusting X position", 60, dist, maxDistance)
                    elseif phase == "moveZ" then
                        updateGuiProgress("Adjusting Z position", 65, dist, maxDistance)
                    elseif phase == "closestX" then
                        updateGuiProgress("Moving to safe X", 70, dist, maxDistance)
                    elseif phase == "brainY" then
                        updateGuiProgress("Adjusting final height", 75, dist, maxDistance)
                    elseif phase == "toBrainrot" then
                        updateGuiProgress("Moving to Brainrot", 80, dist, maxDistance)
                    end
                    
                    if phase == "ascend" then
                        local dy = desiredAltitude - hrp.Position.Y
                        if math.abs(dy) > 1 then
                            local vy = math.clamp(dy * 6, -speed, speed)
                            hrp.Velocity = Vector3.new(0, vy, 0)
                        else
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            phase = "moveX"
                            phaseTimeout = 0
                        end
                        
                        if phaseTimeout > 10 then
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            phase = "moveX"
                            phaseTimeout = 0
                        end
                        
                    elseif phase == "moveX" then
                        if not brainrotPart or not brainrotPart.Parent or not brainrotPart:IsDescendantOf(workspace) then
                            handleTargetLost()
                            return false
                        end
                        local dx = targetPos.X - hrp.Position.X
                        local dy = desiredAltitude - hrp.Position.Y
                        if math.abs(dx) > 1.5 then
                            local dirX = dx > 0 and 1 or -1
                            local vy = 0
                            if math.abs(dy) > 1 then
                                vy = math.clamp(dy * 6, -20, 20)
                            end
                            hrp.Velocity = Vector3.new(dirX * speed, vy, 0)
                        else
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            phase = "moveZ"
                            phaseTimeout = 0
                        end
                        
                        if phaseTimeout > 8 then
                            phase = "moveZ"
                            phaseTimeout = 0
                        end
                        
                    elseif phase == "moveZ" then
                        if not brainrotPart or not brainrotPart.Parent or not brainrotPart:IsDescendantOf(workspace) then
                            handleTargetLost()
                            return false
                        end
                        local dz = targetPos.Z - hrp.Position.Z
                        local dy = desiredAltitude - hrp.Position.Y
                        if math.abs(dz) > 1.5 then
                            local dirZ = dz > 0 and 1 or -1
                            local vy = 0
                            if math.abs(dy) > 1 then
                                vy = math.clamp(dy * 6, -20, 20)
                            end
                            hrp.Velocity = Vector3.new(hrp.Velocity.X, vy, dirZ * speed)
                        else
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            phase = "closestX"
                            phaseTimeout = 0
                        end
                        
                        if phaseTimeout > 8 then
                            phase = "closestX"
                            phaseTimeout = 0
                        end
                        
                    elseif phase == "closestX" then
                        local dx = closestX - hrp.Position.X
                        local dy = desiredAltitude - hrp.Position.Y
                        if math.abs(dx) > 1 then
                            local dir = dx > 0 and 1 or -1
                            local vy = 0
                            if math.abs(dy) > 1 then
                                vy = math.clamp(dy * 6, -20, 20)
                            end
                            hrp.Velocity = Vector3.new(dir * speed, vy, 0)
                        else
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            phase = "brainY"
                            phaseTimeout = 0
                        end
                        
                        if phaseTimeout > 8 then
                            phase = "brainY"
                            phaseTimeout = 0
                        end
                        
                    elseif phase == "brainY" then
                        if not brainrotPart or not brainrotPart.Parent or not brainrotPart:IsDescendantOf(workspace) then
                            handleTargetLost()
                            return false
                        end
                        local targetY = brainrotPart.Position.Y + 2
                        local dy = targetY - hrp.Position.Y
                        if math.abs(dy) > 1 then
                            local vy = math.clamp(dy * 6, -speed, speed)
                            hrp.Velocity = Vector3.new(0, vy, 0)
                        else
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            phase = "toBrainrot"
                            phaseTimeout = 0
                        end
                        
                        if phaseTimeout > 8 then
                            phase = "toBrainrot"
                            phaseTimeout = 0
                        end
                        
                    elseif phase == "toBrainrot" then
                    speed = 40
                        if not brainrotPart or not brainrotPart.Parent or not brainrotPart:IsDescendantOf(workspace) then
                            handleTargetLost()
                            return false
                        end
                        pcall(function() humanoid:MoveTo(brainrotPart.Position) end)
                        
                        local moveStart = tick()
                        while (tick() - moveStart) < 1 do
                            if not player.Character or not player.Character.Parent then break end
                            humanoid = player.Character:FindFirstChild("Humanoid") or humanoid
                            hrp = player.Character:FindFirstChild("HumanoidRootPart") or hrp
                            if not brainrotPart or not brainrotPart.Parent or not brainrotPart:IsDescendantOf(workspace) then
                                handleTargetLost()
                                return false
                            end
                            local dir3 = brainrotPart.Position - hrp.Position
                            local horizontal = Vector3.new(dir3.X, 0, dir3.Z)
                            local hv = Vector3.new(0,0,0)
                            if horizontal.Magnitude > 0 then
                                hv = horizontal.Unit * speed
                            end
                            local dy = (brainrotPart.Position.Y + 2) - hrp.Position.Y
                            local vy = math.clamp(dy * 6, -speed, speed)
                            hrp.Velocity = Vector3.new(hv.X, vy, hv.Z)
                            task.wait(0.03)
                        end
                        
                        updateGuiProgress("Final positioning", 85)
                        fullStop()
                        
                        pcall(function() humanoid:MoveTo(brainrotPart.Position) end)
                        local mtStart = tick()
                        while (tick() - mtStart) < 0.3 do
                            task.wait(0.03)
                        end
                        if hrp then hrp.Velocity = Vector3.new(0,0,0) end
                        
                        scriptCompleted = true
                        humanoid:UnequipTools()
                        task.wait(0.2)
                        
                        pcall(function() equipQuantumClonerAndUse() end)
                        task.wait(0.4)
                        pcall(function() humanoid:MoveTo(brainrotPart.Position) end)
                        completed = true
                        updateGuiProgress("Completed", 100)
                        task.wait(0.2)
                        cleanupGui()
                    end
                end
            end
            task.wait(0.03)
        end

        if not completed then
            if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
            pcall(equipQuantumClonerAndUse)
            task.wait(0.2)
        end

        updateGuiProgress("Completed", 100)
        task.wait(0.7)
        cleanupGui()
        return true
    end
    
    GoToBestBrainrot()
end

_G.activeGuis = {
    control = false
}
_G.superJump = false
_G.additionalSpeed = false
_G.ativo = false
_G.FloatV1 = false
_G.FloatV2 = false
_G.bestESP = false
_G.upstairs = false
_G.SemiInv = false
_G.PlayerESP = false
_G.BaseESP = false
_G.Fly = false
_G.PlayerESPColor = Color3.fromRGB(0,255,0)

local heartbeatConnection
local canToggle = true
local originalTransparencies = {}
local originalCanCollide = {}
local originalGreenParts = {}

function buy(I)
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/CoinsShopService/RequestBuy"):InvokeServer(I)
end

_G.setupGuis = function()  
local isMobile = game:GetService("UserInputService").TouchEnabled
local UserInputService = game:GetService("UserInputService")  
local RunService = game:GetService("RunService")  
local Players = game:GetService("Players")  
  
local LocalPlayer = Players.LocalPlayer  
  
local mainScreenGui = Instance.new("ScreenGui")  
mainScreenGui.Name = "LKZ_HUB_Modern"  
mainScreenGui.Parent = game.CoreGui  
mainScreenGui.ResetOnSpawn = false  
mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  
  
local mainContainer = Instance.new("Frame")  
mainContainer.Name = "MainContainer"  
if isMobile then 
mainContainer.Size = UDim2.new(0.4, 0, 0.65, 0)  
else
mainContainer.Size = UDim2.new(0.4, 0, 0.45, 0) 
end
mainContainer.Active = true
mainContainer.AnchorPoint = Vector2.new(0.5,0.5)
mainContainer.Draggable = true
mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)  
mainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)  
mainContainer.BorderSizePixel = 0  
mainContainer.ClipsDescendants = true  
mainContainer.Visible = false  
mainContainer.Parent = mainScreenGui  
  
local mainCorner = Instance.new("UICorner")  
mainCorner.CornerRadius = UDim.new(0, 16)  
mainCorner.Parent = mainContainer  
  
local mainStroke = Instance.new("UIStroke")  
mainStroke.Color = Color3.fromRGB(70, 130, 255)  
mainStroke.Thickness = 1  
mainStroke.Transparency = 0.7  
mainStroke.Parent = mainContainer  
  
local gradient = Instance.new("UIGradient")  
gradient.Color = ColorSequence.new{  
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),  
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))  
}  
gradient.Rotation = 45  
gradient.Parent = mainContainer  
  
local miniButton = Instance.new("ImageButton")  
miniButton.Name = "ToggleButton"  
miniButton.Size = UDim2.new(0, 65, 0, 65)
miniButton.AnchorPoint = Vector2.new(0.5, 0.5)
miniButton.Position = UDim2.new(0.5, -275, 0.5, -150)  
miniButton.Active = true
miniButton.Draggable = true
miniButton.BorderSizePixel = 0  
miniButton.Image = "rbxassetid://88557808889639"  
miniButton.ImageColor3 = Color3.fromRGB(255, 255, 255)  
miniButton.ScaleType = Enum.ScaleType.Fit  
miniButton.Parent = mainScreenGui  
  
local miniCorner = Instance.new("UICorner")  
miniCorner.CornerRadius = UDim.new(0, 12)  
miniCorner.Parent = miniButton  
  
local isVisible = false  
  
miniButton.MouseButton1Click:Connect(function()  
    isVisible = not isVisible  
    mainContainer.Visible = isVisible  
end)  
  
local header = Instance.new("Frame")  
header.Name = "Header"  
header.Size = UDim2.new(1, 0, 0, 60)  
header.Position = UDim2.new(0, 0, 0, 0)  
header.BackgroundColor3 = Color3.fromRGB(70, 130, 255)  
header.BorderSizePixel = 0  
header.Parent = mainContainer  
  
local headerCorner = Instance.new("UICorner")  
headerCorner.CornerRadius = UDim.new(0, 16)  
headerCorner.Parent = header  
  
local headerGradient = Instance.new("UIGradient")  
headerGradient.Color = ColorSequence.new{  
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 130, 255)),  
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 160, 255))  
}  
headerGradient.Rotation = 90  
headerGradient.Parent = header  
  
local headerMask = Instance.new("Frame")  
headerMask.Size = UDim2.new(1, 0, 0, 20)  
headerMask.Position = UDim2.new(0, 0, 1, -20)  
headerMask.BackgroundColor3 = Color3.fromRGB(70, 130, 255)  
headerMask.BorderSizePixel = 0  
headerMask.Parent = header  
  
local title = Instance.new("TextLabel")  
title.Name = "Title"  
title.Text = "LKZ HUB"  
title.Size = UDim2.new(0.5, 0, 1, 0)  
title.Position = UDim2.new(0, 20, 0, 0)  
title.BackgroundTransparency = 1  
title.TextColor3 = Color3.fromRGB(255, 255, 255)  
title.Font = Enum.Font.GothamBold  
if isMobile then 
title.TextSize = 30
else
title.TextSize = 40
end
title.TextXAlignment = Enum.TextXAlignment.Left  
title.TextYAlignment = Enum.TextYAlignment.Center  
title.Parent = header  
  
local bestLabel = Instance.new("TextLabel")  
bestLabel.Name = "BestLabel"  
bestLabel.Text = "Best: -"  
bestLabel.Size = UDim2.new(0.48999998, 0, 1, 0)  
bestLabel.Position = UDim2.new(0.5, 0, 0, 0)  
bestLabel.BackgroundTransparency = 1  
bestLabel.TextColor3 = Color3.fromRGB(255, 215, 0)  
bestLabel.Font = Enum.Font.Gotham  
bestLabel.TextSize = 22
bestLabel.TextXAlignment = Enum.TextXAlignment.Right  
bestLabel.TextYAlignment = Enum.TextYAlignment.Center  
bestLabel.Parent = header  
  
local tabsFrame = Instance.new("ScrollingFrame")  
tabsFrame.Name = "TabsFrame"  
tabsFrame.Size = UDim2.new(1, -20, 0, 40)  
tabsFrame.Position = UDim2.new(0, 10, 0, 70)  
tabsFrame.BackgroundTransparency = 1  
tabsFrame.ScrollBarThickness = 2  
tabsFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255)  
tabsFrame.BorderSizePixel = 0  
tabsFrame.ScrollingDirection = Enum.ScrollingDirection.X  
tabsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  
tabsFrame.Parent = mainContainer  
  
local tabsList = Instance.new("UIListLayout")  
tabsList.FillDirection = Enum.FillDirection.Horizontal  
tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Left  
tabsList.VerticalAlignment = Enum.VerticalAlignment.Center  
tabsList.Padding = UDim.new(0, 5)  
tabsList.SortOrder = Enum.SortOrder.LayoutOrder  
tabsList.Parent = tabsFrame

tabsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()  
    tabsFrame.CanvasSize = UDim2.new(0, tabsList.AbsoluteContentSize.X + 10, 0, 0)  
end)  
  
local contentFrame = Instance.new("Frame")  
contentFrame.Name = "ContentFrame"  
contentFrame.Size = UDim2.new(1, -20, 1, -120)  
contentFrame.Position = UDim2.new(0, 10, 0, 120)  
contentFrame.BackgroundTransparency = 1  
contentFrame.Parent = mainContainer  
  
local tabs = {}  
local pages = {}  
local currentTab = nil
  
local function createTab(name)  
    local tabButton = Instance.new("TextButton")  
    tabButton.Name = name .. "Tab"  
    tabButton.Text = name  
    if isMobile then 
    tabButton.Size = UDim2.new(0.165306806, 0, 0.8, 0) 
    else 
    tabButton.Size = UDim2.new(0.17206806, 0, 0.8, 0) 
    end
    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)  
    tabButton.BorderSizePixel = 0  
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 190)  
    tabButton.Font = Enum.Font.Gotham  
    tabButton.TextSize = 14  
    tabButton.LayoutOrder = #tabs + 1  
    tabButton.Parent = tabsFrame  
  
    local tabCorner = Instance.new("UICorner")  
    tabCorner.CornerRadius = UDim.new(0, 8)  
    tabCorner.Parent = tabButton  
  
    local page = Instance.new("ScrollingFrame")  
    page.Name = name .. "Page"  
    page.Size = UDim2.new(1, 0, 1, 0)  
    page.Position = UDim2.new(0, 0, 0, 0)  
    page.BackgroundTransparency = 1  
    page.ScrollBarThickness = 4  
    page.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255)  
    page.BorderSizePixel = 0  
    page.CanvasSize = UDim2.new(0, 0, 0, 0)  
    page.Visible = false
    page.Parent = contentFrame  
  
    local pageList = Instance.new("UIListLayout")  
    pageList.FillDirection = Enum.FillDirection.Vertical  
    pageList.HorizontalAlignment = Enum.HorizontalAlignment.Center  
    pageList.VerticalAlignment = Enum.VerticalAlignment.Top  
    pageList.Padding = UDim.new(0, 8)  
    pageList.SortOrder = Enum.SortOrder.LayoutOrder  
    pageList.Parent = page  
  
    pageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()  
        page.CanvasSize = UDim2.new(0, 0, 0, pageList.AbsoluteContentSize.Y + 10)  
    end)  
  
    table.insert(tabs, tabButton)  
    table.insert(pages, page)  
  
    tabButton.MouseButton1Click:Connect(function()  
        for _, p in ipairs(pages) do  
            p.Visible = false  
        end  
        for _, t in ipairs(tabs) do  
            t.BackgroundColor3 = Color3.fromRGB(35, 35, 45)  
            t.TextColor3 = Color3.fromRGB(180, 180, 190)  
        end  
        page.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)  
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentTab = tabButton
    end)  
  
    if currentTab == nil then  
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)  
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
        currentTab = tabButton
    end  
  
    return page  
end 

local helperPage = createTab("Helper")
local movementPage = createTab("Movement")  
local miscPage = createTab("Misc")
local espPage = createTab("ESP") 
local creditsPage = createTab("Credits")  

local function enableMobileDesync()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    
    local success = pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        local packages = ReplicatedStorage:WaitForChild("Packages", 5)
        if not packages then return end
        
        local netFolder = packages:WaitForChild("Net", 5)
        if not netFolder then return end
        
        local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
        local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
        
        if not useItemRemote or not teleportRemote then return end

        local toolNames = {"Quantum Cloner", "Brainrot", "brainrot"}
        local tool = nil
        
        for _, toolName in ipairs(toolNames) do
            tool = backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
            if tool then break end
        end
        
        if not tool then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    tool = item
                    break
                end
            end
        end
        
        if tool and tool.Parent == backpack then
            humanoid:EquipTool(tool)
            task.wait(0.5)
        end

        if setfflag then
            setfflag("WorldStepMax", "-9999999999")
        end
        
        task.wait(0.2)
        useItemRemote:FireServer()
        task.wait(1)
        teleportRemote:FireServer()
        task.wait(2)
        
        if setfflag then
            setfflag("WorldStepMax", "-1")
        end
    end)
    
    return success
end

local function createToggle(name, parent, callback)  
    local toggleFrame = Instance.new("Frame")  
    toggleFrame.Name = name .. "Toggle"  
    toggleFrame.Size = UDim2.new(0.959999979, 0, 0.195000008, 0)  
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)  
    toggleFrame.BorderSizePixel = 0
    toggleFrame.LayoutOrder = #parent:GetChildren() + 1  
    toggleFrame.Parent = parent  
  
    local toggleCorner = Instance.new("UICorner")  
    toggleCorner.CornerRadius = UDim.new(0, 12)  
    toggleCorner.Parent = toggleFrame  
  
    local toggleStroke = Instance.new("UIStroke")  
    toggleStroke.Color = Color3.fromRGB(50, 50, 60)  
    toggleStroke.Thickness = 1  
    toggleStroke.Parent = toggleFrame  
  
    local toggleLabel = Instance.new("TextLabel")  
    toggleLabel.Name = "Label"  
    toggleLabel.Text = name  
    toggleLabel.Size = UDim2.new(1, -60, 1, 0)  
    toggleLabel.Position = UDim2.new(0, 15, 0, 0)  
    toggleLabel.BackgroundTransparency = 1  
    toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)  
    toggleLabel.Font = Enum.Font.Gotham  
    toggleLabel.TextSize = 16  
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left  
    toggleLabel.TextYAlignment = Enum.TextYAlignment.Center  
    toggleLabel.Parent = toggleFrame  
  
    local switchFrame = Instance.new("Frame")  
    switchFrame.Name = "Switch"  
    switchFrame.Size = UDim2.new(0, 40, 0, 20)  
    switchFrame.Position = UDim2.new(1, -50, 0.5, -10)  
    switchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)  
    switchFrame.BorderSizePixel = 0  
    switchFrame.Parent = toggleFrame  
  
    local switchCorner = Instance.new("UICorner")  
    switchCorner.CornerRadius = UDim.new(0, 10)  
    switchCorner.Parent = switchFrame  
  
    local switchKnob = Instance.new("Frame")  
    switchKnob.Name = "Knob"  
    switchKnob.Size = UDim2.new(0, 16, 0, 16)  
    switchKnob.Position = UDim2.new(0, 2, 0, 2)  
    switchKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)  
    switchKnob.BorderSizePixel = 0  
    switchKnob.Parent = switchFrame  
  
    local knobCorner = Instance.new("UICorner")  
    knobCorner.CornerRadius = UDim.new(0, 8)  
    knobCorner.Parent = switchKnob  
  
    local button = Instance.new("TextButton")  
    button.Size = UDim2.new(1, 0, 1, 0)  
    button.BackgroundTransparency = 1  
    button.Text = ""  
    button.Parent = toggleFrame  
  
    local isEnabled = false  
  
    button.MouseButton1Click:Connect(function()  
        isEnabled = not isEnabled  
        switchKnob.Position = isEnabled and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)  
        switchFrame.BackgroundColor3 = isEnabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(60, 60, 70)  
        toggleStroke.Color = isEnabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(50, 50, 60)  
  
        if callback then  
            callback(isEnabled)  
        end  
    end)  
  
    button.MouseEnter:Connect(function()  
        toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)  
    end)  
  
    button.MouseLeave:Connect(function()  
        toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)  
    end)  
  
    return toggleFrame, function() return isEnabled end, function(state)  
        isEnabled = state  
        switchKnob.Position = isEnabled and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)  
        switchFrame.BackgroundColor3 = isEnabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(60, 60, 70)  
        toggleStroke.Color = isEnabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(50, 50, 60)  
    end  
end  

local function createParagraph(title, text, parent)
    local paragraphFrame = Instance.new("Frame")
    paragraphFrame.Name = title .. "Paragraph"
    paragraphFrame.Size = UDim2.new(1, -10, 0, 0)
    paragraphFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    paragraphFrame.BorderSizePixel = 0
    paragraphFrame.LayoutOrder = #parent:GetChildren() + 1
    paragraphFrame.Parent = parent

    local paragraphCorner = Instance.new("UICorner")
    paragraphCorner.CornerRadius = UDim.new(0, 12)
    paragraphCorner.Parent = paragraphFrame

    local paragraphStroke = Instance.new("UIStroke")
    paragraphStroke.Color = Color3.fromRGB(50, 50, 60)
    paragraphStroke.Thickness = 1
    paragraphStroke.Parent = paragraphFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(70, 130, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = paragraphFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, -20, 0, 50) -- largura fixa, altura inicial
    textLabel.Position = UDim2.new(0, 10, 0, 35)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.RichText = true -- ESSENCIAL para suportar \n
    textLabel.Parent = paragraphFrame

    local function updateSize()
        local bounds = textLabel.TextBounds
        textLabel.Size = UDim2.new(1, -20, 0, bounds.Y)
        paragraphFrame.Size = UDim2.new(1, -10, 0, bounds.Y + 45)
    end

    updateSize()
    textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)

    return paragraphFrame
end

local function createButton(name, parent, callback)  
    local buttonFrame = Instance.new("Frame")  
    buttonFrame.Name = name .. "Button"  
    buttonFrame.Size = UDim2.new(0.959999979, 0, 0.195000008, 0)  
    buttonFrame.BackgroundColor3 = Color3.fromRGB(70, 130, 255)   
    buttonFrame.BorderSizePixel = 0
    buttonFrame.LayoutOrder = #parent:GetChildren() + 1  
    buttonFrame.Parent = parent  
  
    local buttonCorner = Instance.new("UICorner")  
    buttonCorner.CornerRadius = UDim.new(0, 12)  
    buttonCorner.Parent = buttonFrame  
  
    local buttonLabel = Instance.new("TextLabel")  
    buttonLabel.Text = name  
    buttonLabel.Size = UDim2.new(1, 0, 1, 0)  
    buttonLabel.BackgroundTransparency = 1  
    buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
    buttonLabel.Font = Enum.Font.GothamBold  
    buttonLabel.TextSize = 16  
    buttonLabel.Parent = buttonFrame  
  
    local button = Instance.new("TextButton")  
    button.Size = UDim2.new(1, 0, 1, 0)  
    button.BackgroundTransparency = 1  
    button.Text = ""  
    button.Parent = buttonFrame  
  
    button.MouseButton1Click:Connect(function()  
        if callback then  
            callback()  
        end  
    end)  
  
    button.MouseEnter:Connect(function()  
        buttonFrame.BackgroundColor3 = Color3.fromRGB(255, 140, 0)  
    end)  
  
    button.MouseLeave:Connect(function()  
        buttonFrame.BackgroundColor3 = Color3.fromRGB(70, 130, 255)  
    end)  
  
    return buttonFrame, buttonLabel, buttonFrame
end  

local jumpToggle = createToggle("Super Jump", movementPage, function(enabled)  
    _G.superJump = enabled  
end)  
  
local speedToggle = createToggle("Speed Boost", movementPage, function(enabled)  
    _G.additionalSpeed = enabled  
end)  

local upstairsToggle = createToggle("Upstairs", helperPage, function(enabled)  
    _G.upstairs = enabled  
end)  
  
local floatV2Toggle = createToggle("Float V2", helperPage, function(enabled)  
    buy("Boogie Bomb")  
    _G.FloatV2 = enabled  
end)  
  
local floatV1Toggle = createToggle("Float V1", helperPage, function(enabled)  
    _G.FloatV1 = enabled  
end)  

local isDesyncOnCooldown = false  
local desyncBtn, desyncLabel, desyncBTNF

desyncBtn, desyncLabel, desyncBTNF = createButton("Mobile Desync: Ready", helperPage, function() 
    buy("Quantum Cloner")  
    if isDesyncOnCooldown then return end  
    isDesyncOnCooldown = true  
    desyncLabel.Text = "Mobile Desync: Activating..."
    pcall(function()  
        task.spawn(function()  
            enableMobileDesync()  
        end)  
    end)  
    task.wait(2)
    desyncLabel.Text = "Mobile Desync: Active"  
    task.delay(15, function()  
        isDesyncOnCooldown = false
        desyncLabel.Text = "Mobile Desync: Ready"
    end)
end)

task.spawn(function()
    while task.wait(0.01) do
        if isDesyncOnCooldown then
            if desyncLabel.Text == "Mobile Desync: Activating..." then
                desyncBTNF.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
            else
                desyncBTNF.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            end
        else
            desyncBTNF.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        end
    end
end)

local espBaseToggle = createToggle("ESP Base", espPage, function(enabled)  
    _G.BaseESP = enabled  
end)  
  
local espPlayerToggle = createToggle("ESP Players", espPage, function(enabled)  
    _G.PlayerESP = enabled  
end)  
  
local espBrainrotToggle = createToggle("ESP Best Brainrot", espPage, function(enabled)  
    _G.bestESP = enabled  
    if not enabled and currentESP then  
        currentESP:Destroy()  
        currentESP = nil  
    end  
end)  

function createColorPicker(name, parent)
    local frame = Instance.new("Frame")
    frame.Name = name .. "ColorPicker"
    frame.Size = UDim2.new(0.959999979, 0, 0.195000008, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = #parent:GetChildren() + 1
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 60)
    stroke.Thickness = 1
    stroke.Parent = frame
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = "Esp Player Color Picker"
    label.Size = UDim2.new(0.6, -20, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame
    local openBtn = Instance.new("TextButton")
    openBtn.Name = "Open"
    openBtn.Size = UDim2.new(0, 36, 0, 36)
    openBtn.Position = UDim2.new(0.898999989, 0, 0.075000003, 0)
    openBtn.BackgroundColor3 = _G.PlayerESPColor or Color3.fromRGB(0,255,0)
    openBtn.BorderSizePixel = 0
    openBtn.AutoButtonColor = false
    openBtn.Text = ""
    openBtn.TextTransparency = 1
    openBtn.Parent = frame
    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0, 8)
    openCorner.Parent = openBtn
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Name = "MiniPicker"
    pickerFrame.Size = UDim2.new(0, 240, 0, 120)
    pickerFrame.Position = UDim2.new(0.5, -120, 0.5, -60)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    pickerFrame.Visible = false
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Parent = mainContainer
    local pfCorner = Instance.new("UICorner")
    pfCorner.CornerRadius = UDim.new(0, 12)
    pfCorner.Parent = pickerFrame
    local colors = {
        Color3.fromRGB(0,255,0),
        Color3.fromRGB(255,0,0),
        Color3.fromRGB(0,0,255),
        Color3.fromRGB(255,255,0),
        Color3.fromRGB(255,0,255),
        Color3.fromRGB(0,255,255),
        Color3.fromRGB(255,165,0),
        Color3.fromRGB(128,0,128),
        Color3.fromRGB(0,128,0),
        Color3.fromRGB(128,128,0),
        Color3.fromRGB(0,128,128),
        Color3.fromRGB(128,0,0),
        Color3.fromRGB(0,0,128),
        Color3.fromRGB(192,192,192),
        Color3.fromRGB(255,192,203),
        Color3.fromRGB(60,179,113),
        Color3.fromRGB(70,130,180),
        Color3.fromRGB(210,105,30),
        Color3.fromRGB(244,164,96),
        Color3.fromRGB(75,0,130)
    }
    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, -10, 1, -10)
    grid.Position = UDim2.new(0, 5, 0, 5)
    grid.BackgroundTransparency = 1
    grid.Parent = pickerFrame
    local uiGrid = Instance.new("UIGridLayout")
    uiGrid.CellSize = UDim2.new(0, 40, 0, 40)
    uiGrid.CellPadding = UDim2.new(0, 6, 0, 6)
    uiGrid.FillDirection = Enum.FillDirection.Horizontal
    uiGrid.Parent = grid
    for i, col in ipairs(colors) do
        local cbtn = Instance.new("TextButton")
        cbtn.Size = UDim2.new(0, 40, 0, 40)
        cbtn.BackgroundColor3 = col
        cbtn.BorderSizePixel = 0
        cbtn.AutoButtonColor = false
        cbtn.Text = ""
        cbtn.Parent = grid
        local ccorner = Instance.new("UICorner")
        ccorner.CornerRadius = UDim.new(0, 8)
        ccorner.Parent = cbtn
        cbtn.MouseButton1Click:Connect(function()
            _G.PlayerESPColor = col
            openBtn.BackgroundColor3 = col
            if _G.LKZ_ESPCOLOR_EVENT then
                pcall(function() _G.LKZ_ESPCOLOR_EVENT:Fire(col) end)
            end
        end)
    end
    openBtn.MouseButton1Click:Connect(function()
        pickerFrame.Visible = not pickerFrame.Visible
    end)
    return frame
end

local colorPicker = createColorPicker("PlayerESP", espPage)

local canToggle = true  
local controlToggle = createToggle("Control Panel", miscPage, function(enabled)  
    if not canToggle then return end  
    _G.activeGuis = _G.activeGuis or {}  
    _G.activeGuis.control = enabled  
    if enabled then  
        canToggle = false  
        task.spawn(function()  
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Obama9282921781/Rjdhdidjdj/refs/heads/main/Protected_4809522785054226.lua.txt"))()  
            local ajjanGui = nil  
            while not ajjanGui do  
                ajjanGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("AjjanGui")  
                task.wait()  
            end  
            ajjanGui.Name = "LKZ-HUB"  
            local lbl = ajjanGui.Frame.TextLabel  
            lbl.Text = "By Lucasggk1"  
            task.wait(1)  
            canToggle = true  
        end)  
    else  
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("LKZ-HUB")  
        if gui then gui:Destroy() end  
    end  
end)  
  
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
local Anim = Instance.new("Animation")  
Anim.AnimationId = "rbxassetid://127212897044971"  
  
local Track  
local FallConn  
  
local function setSemiInvisible(state)  
    if not Character or not Character:FindFirstChild("Humanoid") then return end  
    if state then  
        if not Track or not Track.IsPlaying then  
            Track = Character.Humanoid.Animator:LoadAnimation(Anim)  
            Track.Priority = Enum.AnimationPriority.Action  
            Track:Play(0)  
            while Track.TimePosition < 0.1 do  
                task.wait()  
            end  
        end  
        if FallConn then FallConn:Disconnect() end  
        FallConn = RunService.Stepped:Connect(function()  
            for _, BasePart in pairs(Character:GetDescendants()) do  
                if BasePart:IsA("BasePart") and BasePart.Name ~= "HumanoidRootPart" and BasePart.CanCollide then  
                    BasePart.CanCollide = false  
                    BasePart:AddTag("WasCollidable")  
                end  
            end  
        end)  
    else  
        if FallConn then FallConn:Disconnect() FallConn = nil end  
        if Track then Track:Stop() end  
        for _, BasePart in ipairs(Character:GetDescendants()) do  
            if BasePart:IsA("BasePart") and BasePart.Name ~= "HumanoidRootPart" and BasePart:HasTag("WasCollidable") then  
                BasePart.CanCollide = true  
                BasePart:RemoveTag("WasCollidable")  
            end  
        end  
    end  
end  
  
LocalPlayer.CharacterAdded:Connect(function(newChar)  
    Character = newChar  
    Character:WaitForChild("Humanoid")  
    _G.SemiInv = false  
    setSemiInvisible(false)  
end)  
  
local semiInvToggle = createToggle("Semi Invisible", miscPage, function(enabled)  
    _G.SemiInv = enabled  
    setSemiInvisible(enabled)  
end)  
  
local flyToggle = createToggle("Fly", miscPage, function(enabled)  
    _G.Fly = enabled  
end)  

createParagraph("credits ", "\u{1F451} LKZ - Owner & Lead Developer\n\u{26A1}\u{FE0F} ZenithExility - Co-Developer\n\u{1F680} KaiolaKaio - Tester & Promoter\n\u{1F3A9} Hobo - Tester & Promoter\n\u{1F987} Mgmfz - Tester & Promoter", creditsPage)

local isGoToBestOnCooldown = false  
local gotoBestBtn, gotoBestLabel, BTNF
gotoBestBtn, gotoBestLabel, BTNF = createButton("Go to Best: Ready", miscPage, function() 
    if isGoToBestOnCooldown then return end  
  
    buy("Grapple Hook")  
    buy("Quantum Cloner")  
    isGoToBestOnCooldown = true  
    pcall(function()  
        task.spawn(function()  
            gotoBest()  
        end)  
    end)  
  
    for i = 15, 1, -1 do  
        gotoBestLabel.Text = "Go to Best: " .. i .. "s"  
        task.wait(1)  
    end  
  
    gotoBestLabel.Text = "Go to Best: Ready"  
    BTNF.BackgroundColor3 = Color3.fromRGB(70, 130, 255)   
    isGoToBestOnCooldown = false  
end)

task.spawn(function()
while task.wait(0.01) do
if not isGoToBestOnCooldown then
BTNF.BackgroundColor3 = Color3.fromRGB(70, 130, 255)   
else
BTNF.BackgroundColor3 = Color3.fromRGB(255, 140, 0)  
end
end
end)

task.spawn(function()  
    while task.wait(1) do  
        local plots = workspace:FindFirstChild("Plots")  
        if not plots then continue end  
  
        local bestEarning, bestDesc = 0, "-"  
        for _, plot in ipairs(plots:GetChildren()) do  
            local plotSign = plot:FindFirstChild("PlotSign")  
            local isOwnPlot = false  
  
            if plotSign then  
                local textLabel = plotSign:FindFirstChild("SurfaceGui") and plotSign.SurfaceGui:FindFirstChild("Frame") and plotSign.SurfaceGui.Frame:FindFirstChild("TextLabel")  
                if textLabel and textLabel.Text:find(LocalPlayer.DisplayName) then  
                    isOwnPlot = true  
                end  
            end  
  
            if not isOwnPlot then  
                for _, d in ipairs(plot:GetDescendants()) do  
                    if d:IsA("TextLabel") and d.Text and d.Text:find("/s") then  
                        local txt = d.Text:gsub(",", "")  
                        local a, b = txt:match("([%d%.]+)([kKmMbB]?)")  
                        local earning = tonumber(a) or 0  
                        if b then  
                            b = b:lower()  
                            if b == "k" then earning = earning * 1e3  
                            elseif b == "m" then earning = earning * 1e6  
                            elseif b == "b" then earning = earning * 1e9 end  
                        end  
                        if earning > bestEarning then  
                            bestEarning = earning  
                            bestDesc = d.Text  
                        end  
                    end  
                end  
            end  
        end  
  
        if bestLabel and bestLabel.Parent then  
            bestLabel.Text = "Best: " .. bestDesc  
        end  
    end  
end)  
end


_G.setupGuis()

task.spawn(function()
    if game.CoreGui:FindFirstChild("LKZ_Hub") then
        game.CoreGui.LKZ_Hub:Destroy()
    end
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local canJump = true
    local setupChar = function(char)
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        UserInputService.JumpRequest:Connect(function()
            if _G.superJump and canJump then
                canJump = false
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 90, hrp.Velocity.Z)
                task.delay(1.5, function() canJump = true end)
            end
        end)
        RunService.RenderStepped:Connect(function()
            if _G.additionalSpeed then
                local dir = hum.MoveDirection
                hrp.Velocity = Vector3.new(dir.X * 27, hrp.Velocity.Y, dir.Z * 27)
            end
            if _G.upstairs then
                local y = hrp.Position.Y
                local targetY
                if y >= -4 and y <= 11 then
                    targetY = 7
                elseif y >= 12 and y <= 28 then
                    targetY = 24
                elseif y > 28 then
                    hrp.Velocity = Vector3.new(0,0,0)
                    hum.JumpPower = 0
                    return
                end
                local remaining = targetY - y
                local velY = math.clamp(remaining * 5, 0, 40)
                local dir = hum.MoveDirection
                hrp.Velocity = Vector3.new(dir.X * 15, velY, dir.Z * 15)
                if y < targetY - 0.5 then
                    hum.JumpPower = 0
                else
                    hum.JumpPower = 0
                end
            else
                hum.JumpPower = 50
            end
        end)
    end
    if player.Character then setupChar(player.Character) end
    player.CharacterAdded:Connect(setupChar)
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local backpack = player:WaitForChild("Backpack")
local hrp = character:WaitForChild("HumanoidRootPart")

task.spawn(function()
    while task.wait(0.1) do
        if not player.Character then
            player.CharacterAdded:Wait()
        else
            character = player.Character
            humanoid = character:WaitForChild("Humanoid")
            hrp = character:WaitForChild("HumanoidRootPart")
            backpack = player:WaitForChild("Backpack")
        end
    end
end)

local useRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/UseItem")

local targetSize = Vector3.new(0.6399999260902405,0.7299998998641968,0.4700000882148742)
local tol = 0.09

local function approx(a,b,t)
    return math.abs(a.X-b.X)<=t and math.abs(a.Y-b.Y)<=t and math.abs(a.Z-b.Z)<=t
end

local function findHandle()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and v.Name == "Handle" and approx(v.Size, targetSize, tol) then
            return v
        end
    end
    return nil
end

local function equipBoogie()
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name ~= "Boogie Bomb" then
            tool.Parent = backpack
        end
    end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Boogie Bomb" then
            humanoid:EquipTool(tool)
            return tool
        end
    end
end

task.spawn(function()
    while task.wait() do
        if _G.FloatV2 then
            local handle = findHandle()
            if handle then
                handle.CanCollide = true
                handle.Anchored = true
                handle.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 4.35, hrp.Position.Z)
            else
                useRemote:FireServer()
                equipBoogie()
                useRemote:FireServer()
            end
        else
            task.wait(0.1)
        end
    end
end)

local LocalPlayer = game:GetService("Players").LocalPlayer

local currentBillboard = nil
local currentHighlightParts = {}
local lastBestD = nil
local lastBestDesc = nil

local function clearBestESP()
    if currentBillboard then
        pcall(function() currentBillboard:Destroy() end)
        currentBillboard = nil
    end
    for part, hl in pairs(currentHighlightParts) do
        pcall(function() hl:Destroy() end)
    end
    currentHighlightParts = {}
    lastBestD = nil
    lastBestDesc = nil
end

task.spawn(function()
    while task.wait(0.3) do
        if _G.bestESP then
            local bestD = nil
            local bestEarning = 0
            local bestDesc = "-"
            for _, plot in ipairs((workspace:FindFirstChild("Plots") and workspace.Plots:GetChildren()) or {}) do
                local plotSign = plot:FindFirstChild("PlotSign")
                local isOwnPlot = false
                if plotSign then
                    for _, d in ipairs(plotSign:GetDescendants()) do
                        if d:IsA("TextLabel") and type(d.Text) == "string" and d.Text:find(LocalPlayer.DisplayName) then
                            isOwnPlot = true
                            break
                        end
                    end
                end
                if not isOwnPlot then
                    for _, d in ipairs(plot:GetDescendants()) do
                        if d:IsA("TextLabel") and d.Text and d.Text:find("/s") then
                            local txt = d.Text:gsub(",", "")
                            local a, b = txt:match("([%d%.]+)([kKmMbB]?)")
                            local earning = tonumber(a) or 0
                            if b then
                                b = b:lower()
                                if b == "k" then earning = earning * 1e3
                                elseif b == "m" then earning = earning * 1e6
                                elseif b == "b" then earning = earning * 1e9 end
                            end
                            if earning > bestEarning then
                                bestEarning = earning
                                bestD = d
                                bestDesc = d.Text
                            end
                        end
                    end
                end
            end

            if not bestD then
                if lastBestD then
                    clearBestESP()
                end
            else
                if bestD == lastBestD then
                    if currentBillboard and lastBestDesc ~= bestDesc then
                        lastBestDesc = bestDesc
                        pcall(function()
                            local frame = currentBillboard:FindFirstChildWhichIsA("Frame", true)
                            if frame then
                                local lbl = frame:FindFirstChildWhichIsA("TextLabel", true)
                                if lbl then lbl.Text = string.format("%s | %s | %s", nameLbl and nameLbl.Text or "Unknown", rarityLbl and rarityLbl.Text or "", genLbl and genLbl.Text or "") end
                            end
                        end)
                    end
                else
                    clearBestESP()
                    lastBestD = bestD
                    lastBestDesc = bestDesc

                    local p = bestD.Parent
                    while p and not p:IsA("Model") do
                        p = p.Parent
                    end

                    local attach = nil
                    local genLbl = nil
                    local rarityLbl = nil
                    local nameLbl = nil
                    local baseObj = nil

                    if p then
                        for _, v in ipairs(p:GetDescendants()) do
                            if not attach and v:IsA("Attachment") then attach = v end
                            if not genLbl and v.Name == "Generation" and v:IsA("TextLabel") then genLbl = v end
                            if not rarityLbl and v.Name == "Rarity" and v:IsA("TextLabel") then rarityLbl = v end
                            if not nameLbl and v.Name == "DisplayName" and v:IsA("TextLabel") then nameLbl = v end
                            if not baseObj and v:IsA("BasePart") and v.Name == "Base" then baseObj = v end
                        end
                    end

                    local parentPart = nil
                    if attach and attach.Parent and attach.Parent:IsA("BasePart") then
                        parentPart = attach.Parent
                    elseif baseObj and baseObj.Parent then
                        parentPart = baseObj
                    elseif p then
                        parentPart = p:FindFirstChildWhichIsA("BasePart", true)
                    end

                    if parentPart then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "BestAnimalESP"
                        billboard.AlwaysOnTop = true
                        billboard.Size = UDim2.new(0, 180, 0, 36)
                        billboard.StudsOffset = Vector3.new(0, 3.2, 0)
                        billboard.Adornee = parentPart
                        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Global
                        billboard.Parent = parentPart

                        local back = Instance.new("Frame")
                        back.BackgroundTransparency = 0.18
                        back.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
                        back.Size = UDim2.new(1, 0, 1, 0)
                        back.ZIndex = 1
                        back.Parent = billboard

                        local uicorner = Instance.new("UICorner")
                        uicorner.CornerRadius = UDim.new(0, 10)
                        uicorner.Parent = back

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.new(1, 1, 0)
                        textLabel.TextScaled = true
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.Text = string.format("%s | %s | %s", nameLbl and nameLbl.Text or "Unknown", rarityLbl and rarityLbl.Text or "", genLbl and genLbl.Text or "")
                        textLabel.ZIndex = 2
                        textLabel.Parent = back

                        currentBillboard = billboard

                        if p then
                            for _, d in ipairs((baseObj and baseObj:GetDescendants()) or (p and p:GetDescendants()) or {}) do
                                if d:IsA("BasePart") then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "ESP_Deco"
                                    hl.FillColor = Color3.fromRGB(0, 100, 255)
                                    hl.OutlineColor = Color3.fromRGB(0, 60, 200)
                                    hl.FillTransparency = 0
                                    pcall(function() hl.Parent = d end)
                                    currentHighlightParts[d] = hl
                                end
                            end
                        end
                    end
                end
            end
        else
            if lastBestD then
                clearBestESP()
            end
        end
    end
end)

task.spawn(function()
    local plots = workspace:WaitForChild("Plots")
    while task.wait(0.05) do
        if _G.upstairs then
            for _, plot in ipairs(plots:GetChildren()) do
                local decorations = plot:FindFirstChild("Decorations")
                if decorations then
                    local children = decorations:GetChildren()
                    local specificIndexes = {27,31,32,33,34,35}
                    for _, index in ipairs(specificIndexes) do
                        local part = children[index]
                        if part and part:IsA("BasePart") and not originalCanCollide[part] then
                            originalCanCollide[part] = part.CanCollide
                            originalTransparencies[part] = part.Transparency
                            part.CanCollide = false
                            part.Transparency = 0.85
                            break
                        end
                    end
                end
                for _, part in ipairs(plot:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local col = part.Color
                        if math.floor(col.R*255) == 52 and math.floor(col.G*255) == 142 and math.floor(col.B*255) == 64 then
                            if not originalGreenParts[part] then
                                originalGreenParts[part] = {CanCollide = part.CanCollide, Transparency = part.Transparency}
                                part.CanCollide = false
                                part.Transparency = 1
                            end
                        end
                        if (part.Size == Vector3.new(6,0.25,6) or part.Size == Vector3.new(4,0.25,4)) and not originalCanCollide[part] then
                            originalCanCollide[part] = part.CanCollide
                            originalTransparencies[part] = part.Transparency
                            part.CanCollide = false
                            part.Transparency = 0.85
                        end
                    end
                end
            end
        else
            for part, info in pairs(originalGreenParts) do
                if part and part.Parent then
                    part.CanCollide = info.CanCollide
                    part.Transparency = info.Transparency
                end
            end
            for part, canCollide in pairs(originalCanCollide) do
                if part and part.Parent then
                    part.CanCollide = canCollide
                    part.Transparency = originalTransparencies[part] or part.Transparency
                end
            end
            originalCanCollide = {}
            originalTransparencies = {}
            originalGreenParts = {}
        end
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if _G.FloatV1 and hrp then
        hrp.Velocity = cam.CFrame.LookVector * 25
    end
end)

task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local ESPMap = {}
    local PlayerConns = {}
    local BaseESPMap = {}
    local LastTimes = {}

    local function destroyESP(obj)
        local t = ESPMap[obj]
        if not t then return end
        if t.conns then for _, c in ipairs(t.conns) do pcall(function() c:Disconnect() end) end end
        if t.highlight then pcall(function() t.highlight:Destroy() end) end
        if t.billboard then pcall(function() t.billboard:Destroy() end) end
        ESPMap[obj] = nil
    end

    local function createESP(character, name)
        if not character or ESPMap[character] then return end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = _G.PlayerESPColor or Color3.fromRGB(0,255,0)
        highlight.FillTransparency = 0.23
        highlight.OutlineColor = Color3.fromRGB(240, 240, 240)
        highlight.OutlineTransparency = 0.19
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = character
        billboard.Size = UDim2.new(0, 150, 0, 36)
        billboard.StudsOffset = Vector3.new(0, 3.2, 0)
        billboard.AlwaysOnTop = true
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Global
        billboard.Parent = character

        local back = Instance.new("Frame")
        back.BackgroundColor3 = Color3.fromRGB(34, 36, 44)
        back.BackgroundTransparency = 0.23
        back.Size = UDim2.new(1, 0, 1, 0)
        back.ZIndex = 1
        back.Parent = billboard

        local uicorner = Instance.new("UICorner")
        uicorner.CornerRadius = UDim.new(0, 10)
        uicorner.Parent = back

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1,1)
        label.BackgroundTransparency = 1
        label.TextColor3 = _G.PlayerESPColor or Color3.fromRGB(0,255,0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamSemibold
        label.Text = name
        label.ZIndex = 2
        label.Parent = back

        local conns = {}
        conns[#conns+1] = character.AncestryChanged:Connect(function(_, parent)
            if not parent then destroyESP(character) end
        end)

        ESPMap[character] = {highlight = highlight, billboard = billboard, conns = conns}
    end

    local function watchPlayer(plr)
        if PlayerConns[plr] then return end
        PlayerConns[plr] = {}
        PlayerConns[plr][#PlayerConns[plr]+1] = plr.CharacterAdded:Connect(function(char)
            if _G.PlayerESP then createESP(char, plr.DisplayName) end
        end)
        if plr.Character and _G.PlayerESP then createESP(plr.Character, plr.DisplayName) end
    end

    local function unwatchPlayers()
        for plr, conns in pairs(PlayerConns) do
            for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
            PlayerConns[plr] = nil
        end
        for obj in pairs(ESPMap) do destroyESP(obj) end
    end

    local function createBillboard(parent, color)
        local bb = Instance.new("BillboardGui")
        bb.Adornee = parent
        bb.Size = UDim2.new(0, 160, 0, 28)
        bb.StudsOffset = Vector3.new(0, 0, 0)
        bb.AlwaysOnTop = true
        bb.ZIndexBehavior = Enum.ZIndexBehavior.Global
        bb.Parent = parent

        local back = Instance.new("Frame")
        back.BackgroundTransparency = 0.18
        back.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
        back.Size = UDim2.new(1, 0, 1, 0)
        back.ZIndex = 5
        back.Parent = bb

        local uicorner = Instance.new("UICorner")
        uicorner.CornerRadius = UDim.new(0, 10)
        uicorner.Parent = back

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.TextStrokeTransparency = 0.75
        label.Font = Enum.Font.GothamMedium
        label.TextScaled = true
        label.ZIndex = 6
        label.Parent = back

        return bb, label
    end

    local function createBaseESP(plot)
        if BaseESPMap[plot] then return end
        local sign = plot:FindFirstChild("PlotSign")
        if not sign then return end
        local textLabel = sign:FindFirstChildWhichIsA("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
        if textLabel and textLabel.Text == "Empty Base" then return end

        local block = plot.Purchases.PlotBlock.Main

        local attachment = Instance.new("Attachment")
        attachment.Parent = block
        attachment.WorldPosition = Vector3.new(block.Position.X, -6, block.Position.Z)

        local bb, label = createBillboard(attachment, Color3.fromRGB(255, 255, 255))
        BaseESPMap[plot] = {gui = bb, label = label, attachment = attachment}
    end

    local function removeBaseESP(plot)
        if BaseESPMap[plot] then
            if BaseESPMap[plot].gui then BaseESPMap[plot].gui:Destroy() end
            if BaseESPMap[plot].attachment then BaseESPMap[plot].attachment:Destroy() end
            BaseESPMap[plot] = nil
            LastTimes[plot] = nil
        end
    end

    local function updateBaseESP()
        if not _G.BaseESP then
            for plot in pairs(BaseESPMap) do removeBaseESP(plot) end
            return
        end
        for _, plot in pairs(workspace.Plots:GetChildren()) do
            if plot:FindFirstChild("Purchases") then
                createBaseESP(plot)
                local data = BaseESPMap[plot]
                if data then
                    local block = plot.Purchases.PlotBlock.Main
                    local lockedText = block:FindFirstChild("BillboardGui") and block.BillboardGui:FindFirstChild("Locked")
                    local remainText = block:FindFirstChild("BillboardGui") and block.BillboardGui:FindFirstChild("RemainingTime")
                    local currentTime = remainText and remainText.Text or "??"

                    if lockedText and lockedText.Text == "Locked:" then
                        if LastTimes[plot] and LastTimes[plot].value == currentTime then
                            LastTimes[plot].counter = LastTimes[plot].counter + 0.2
                        else
                            LastTimes[plot] = {value = currentTime, counter = 0}
                        end

                        if LastTimes[plot].counter >= 2 then
                            data.label.Text = "Open: 0s"
                            data.label.TextColor3 = Color3.fromRGB(50, 255, 50)
                        else
                            data.label.Text = "Locked: " .. currentTime
                            data.label.TextColor3 = Color3.fromRGB(255, 50, 50)
                        end
                    else
                        data.label.Text = "Open: 0s"
                        data.label.TextColor3 = Color3.fromRGB(50, 255, 50)
                        LastTimes[plot] = {value = "Open: 0s", counter = 0}
                    end
                end
            end
        end
    end

    local function refreshAllESP()
        if not _G.BaseESP then
            for plot in pairs(BaseESPMap) do removeBaseESP(plot) end
            return
        end
        for _, plot in pairs(workspace.Plots:GetChildren()) do
            removeBaseESP(plot)
        end
        updateBaseESP()
    end

    Players.PlayerAdded:Connect(function(plr)
        if plr ~= LocalPlayer then watchPlayer(plr) end
        task.wait(0.1)
        refreshAllESP()
    end)

    Players.PlayerRemoving:Connect(function()
        task.wait(0.1)
        refreshAllESP()
    end)

    workspace.Plots.ChildAdded:Connect(function()
        task.wait(0.1)
        refreshAllESP()
    end)

    workspace.Plots.ChildRemoved:Connect(function()
        task.wait(0.1)
        refreshAllESP()
    end)

    if _G.LKZ_ESPCOLOR_EVENT == nil then
        if game.CoreGui:FindFirstChild("LKZ_HUB_Modern") then
            local root = game.CoreGui:FindFirstChild("LKZ_HUB_Modern")
            local evt = Instance.new("BindableEvent")
            evt.Name = "LKZ_ESPCOLOR_EVENT"
            evt.Parent = root
            _G.LKZ_ESPCOLOR_EVENT = evt
        else
            local evt = Instance.new("BindableEvent")
            evt.Name = "LKZ_ESPCOLOR_EVENT"
            evt.Parent = game:GetService("CoreGui")
            _G.LKZ_ESPCOLOR_EVENT = evt
        end
    end

    if _G.LKZ_ESPCOLOR_EVENT then
        _G.LKZ_ESPCOLOR_EVENT.Event:Connect(function(color)
            for _, t in pairs(ESPMap) do
                pcall(function()
                    if t.highlight then t.highlight.FillColor = color end
                    if t.billboard then
                        for _, d in pairs(t.billboard:GetDescendants()) do
                            if d:IsA("TextLabel") then
                                d.TextColor3 = color
                            end
                        end
                    end
                end)
            end
        end)
    end

    while task.wait(0.2) do
        if _G.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then watchPlayer(plr) end
            end
        else
            unwatchPlayers()
        end
        updateBaseESP()
    end
end)

local gThread
local rThread

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera

local hrp
local getMove

local function fetchChar()
    local c = LocalPlayer.Character
    if not c or not c.Parent then return end
    hrp = c:WaitForChild("HumanoidRootPart")
    getMove = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local hum = c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

local function startGrapple()
    if gThread then return end
    gThread = task.spawn(function()
        while _G.Fly do
            local c, hrp, hum = fetchChar()
            if c and hrp and hum then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp and not c:FindFirstChild("Grapple Hook") then
                    local t = bp:FindFirstChild("Grapple Hook")
                    if t then
                        pcall(function()
                            hum:EquipTool(t)
                        end)
                    end
                end
            end
            task.wait(0.05)
        end
        gThread = nil
    end)
end

local function startRemote()
    if rThread then return end
    rThread = task.spawn(function()
        while _G.Fly do
            pcall(function()
                local pkg = ReplicatedStorage:FindFirstChild("Packages")
                if pkg then
                    local net = require(pkg:WaitForChild("Net"))
                    local fire = net:RemoteEvent("UseItem")
                    fire:FireServer(1.9832406361897787)
                end
            end)
            task.wait(0.05)
        end
        rThread = nil
    end)
end

local function onCharacterAdded()
    fetchChar()
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
    fetchChar()
end

RunService.RenderStepped:Connect(function()
    if not _G.Fly or not hrp or not getMove then return end
    local mv = getMove:GetMoveVector()
    local vel = Vector3.new(0,0,0)
    if mv.X ~= 0 then vel = vel + cam.CFrame.RightVector * mv.X * 170 end
    if mv.Z ~= 0 then vel = vel - cam.CFrame.LookVector * mv.Z * 170 end
    hrp.AssemblyLinearVelocity = vel
end)

task.spawn(function()
    while true do
        if _G.Fly then
            if not gThread then startGrapple() end
            if not rThread then startRemote() end
        else
            if gThread then task.cancel(gThread) gThread = nil end
            if rThread then task.cancel(rThread) rThread = nil end
        end
        task.wait(0.2)
    end
end)
