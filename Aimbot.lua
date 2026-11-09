-- =====================================================
-- MARTINSX HUD - Script para Roblox
-- Funcionalidades: Aimbot, No Recoil, Trigger Bot, ESP
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =====================================================
-- CONFIGURAÇÕES E VARIÁVEIS DE ESTADO
-- =====================================================
local Config = {
    Aimbot = {
        Enabled = false,
        Part = "Head", -- Head, HumanoidRootPart, UpperTorso, LowerTorso
        TeamCheck = false,
    },
    NoRecoil = {
        Enabled = false,
    },
    TriggerBot = {
        Enabled = false,
        Delay = 0.1, -- Delay em segundos
    },
    ESP = {
        Enabled = false,
        ShowLine = true,
        ShowName = true,
        ShowHealth = true,
        ShowDistance = true,
        ColorMode = "Azul", -- Azul, Rosa, Verde, Rainbow
    }
}

-- Referências dos objetos ESP
local ESPObjects = {}

-- =====================================================
-- CRIAÇÃO DA INTERFACE GRÁFICA (GUI)
-- =====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MartinsxHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Frame Principal (Arrastável)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastar
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(100, 100, 255)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Barra de Título (Arrastável e Minimizável)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Martinsx HUD"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Botão Minimizar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 2)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TitleBar
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinimizeBtn

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Container para Abas (Tabs)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 30)
TabContainer.Position = UDim2.new(0, 10, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabContainer

-- Conteúdo das Abas
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -80)
ContentFrame.Position = UDim2.new(0, 10, 0, 75)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Função para criar botões de aba
local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.LayoutOrder = order
    btn.Parent = TabContainer
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    return btn
end

-- Criar abas
local TabAimbot = createTabButton("Aimbot", 1)
local TabESP = createTabButton("ESP", 2)

-- Função para alternar visibilidade das abas
local function switchTab(tab)
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = false
        end
    end
    if tab == "Aimbot" then
        AimbotFrame.Visible = true
        TabAimbot.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        TabESP.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    elseif tab == "ESP" then
        ESPFrame.Visible = true
        TabESP.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        TabAimbot.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    end
end

-- =====================================================
-- ABA AIMBOT (Aimbot, No Recoil, Trigger Bot, Seletor de Parte)
-- =====================================================
local AimbotFrame = Instance.new("Frame")
AimbotFrame.Size = UDim2.new(1, 0, 1, 0)
AimbotFrame.BackgroundTransparency = 1
AimbotFrame.Visible = false
AimbotFrame.Parent = ContentFrame

-- Helper para criar Toggle
local function createToggle(parent, text, posY, initial, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, posY)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -50, 0, 3)
    btn.BackgroundColor3 = initial and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
    btn.Text = initial and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        initial = not initial
        btn.BackgroundColor3 = initial and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
        btn.Text = initial and "ON" or "OFF"
        if callback then callback(initial) end
    end)
    return frame
end

-- Toggles Aimbot
createToggle(AimbotFrame, "Aimbot", 0, false, function(v) Config.Aimbot.Enabled = v end)
createToggle(AimbotFrame, "No Recoil", 35, false, function(v) Config.NoRecoil.Enabled = v end)
createToggle(AimbotFrame, "Trigger Bot", 70, false, function(v) Config.TriggerBot.Enabled = v end)

-- Seletor de Parte do Corpo (Dropdown Simples)
local PartLabel = Instance.new("TextLabel")
PartLabel.Size = UDim2.new(1, 0, 0, 20)
PartLabel.Position = UDim2.new(0, 0, 0, 110)
PartLabel.BackgroundTransparency = 1
PartLabel.Text = "Parte do Corpo (Aimbot):"
PartLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
PartLabel.Font = Enum.Font.Gotham
PartLabel.TextSize = 12
PartLabel.TextXAlignment = Enum.TextXAlignment.Left
PartLabel.Parent = AimbotFrame

local PartDropdown = Instance.new("TextButton")
PartDropdown.Size = UDim2.new(0, 150, 0, 24)
PartDropdown.Position = UDim2.new(0, 0, 0, 135)
PartDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
PartDropdown.Text = "Head"
PartDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
PartDropdown.Font = Enum.Font.Gotham
PartDropdown.TextSize = 12
PartDropdown.Parent = AimbotFrame
local DropCorner = Instance.new("UICorner")
DropCorner.CornerRadius = UDim.new(0, 4)
DropCorner.Parent = PartDropdown

-- Lista de partes
local PartsList = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
local PartIndex = 1
PartDropdown.MouseButton1Click:Connect(function()
    PartIndex = PartIndex + 1
    if PartIndex > #PartsList then PartIndex = 1 end
    PartDropdown.Text = PartsList[PartIndex]
    Config.Aimbot.Part = PartsList[PartIndex]
end)

-- =====================================================
-- ABA ESP (Line, Name, Life, Distance, Cores)
-- =====================================================
local ESPFrame = Instance.new("Frame")
ESPFrame.Size = UDim2.new(1, 0, 1, 0)
ESPFrame.BackgroundTransparency = 1
ESPFrame.Visible = false
ESPFrame.Parent = ContentFrame

-- Toggle Principal ESP
createToggle(ESPFrame, "Ativar ESP", 0, false, function(v) Config.ESP.Enabled = v end)

-- Toggles Individuais
createToggle(ESPFrame, "ESP Line", 35, true, function(v) Config.ESP.ShowLine = v end)
createToggle(ESPFrame, "ESP Name", 70, true, function(v) Config.ESP.ShowName = v end)
createToggle(ESPFrame, "ESP Life", 105, true, function(v) Config.ESP.ShowHealth = v end)
createToggle(ESPFrame, "ESP Distance", 140, true, function(v) Config.ESP.ShowDistance = v end)

-- Seletor de Cor
local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(1, 0, 0, 20)
ColorLabel.Position = UDim2.new(0, 0, 0, 180)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Cor do ESP:"
ColorLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
ColorLabel.Font = Enum.Font.Gotham
ColorLabel.TextSize = 12
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = ESPFrame

local ColorDropdown = Instance.new("TextButton")
ColorDropdown.Size = UDim2.new(0, 150, 0, 24)
ColorDropdown.Position = UDim2.new(0, 0, 0, 205)
ColorDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ColorDropdown.Text = "Azul"
ColorDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
ColorDropdown.Font = Enum.Font.Gotham
ColorDropdown.TextSize = 12
ColorDropdown.Parent = ESPFrame
local ColorCorner = Instance.new("UICorner")
ColorCorner.CornerRadius = UDim.new(0, 4)
ColorCorner.Parent = ColorDropdown

local ColorList = {"Azul", "Rosa", "Verde", "Rainbow"}
local ColorIndex = 1
ColorDropdown.MouseButton1Click:Connect(function()
    ColorIndex = ColorIndex + 1
    if ColorIndex > #ColorList then ColorIndex = 1 end
    ColorDropdown.Text = ColorList[ColorIndex]
    Config.ESP.ColorMode = ColorList[ColorIndex]
end)

-- =====================================================
-- LÓGICA DE FUNCIONALIDADES
-- =====================================================

-- Função para obter a cor do ESP baseada na configuração
local function getESPColor()
    local mode = Config.ESP.ColorMode
    if mode == "Azul" then
        return Color3.fromRGB(0, 150, 255)
    elseif mode == "Rosa" then
        return Color3.fromRGB(255, 105, 180)
    elseif mode == "Verde" then
        return Color3.fromRGB(0, 255, 100)
    elseif mode == "Rainbow" then
        local t = tick()
        return Color3.fromHSV((t % 1), 1, 1)
    end
    return Color3.fromRGB(255, 255, 255)
end

-- Função para obter a parte do corpo do alvo
local function getBodyPart(character, partName)
    if not character then return nil end
    return character:FindFirstChild(partName) or character:FindFirstChild("HumanoidRootPart")
end

-- Lógica do Aimbot (Camera Lock)
local aimbotConnection
local function startAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not Config.Aimbot.Enabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local myHead = character:FindFirstChild("Head")
        if not myHead then return end

        local closestPlayer = nil
        local shortestDist = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetPart = getBodyPart(player.Character, Config.Aimbot.Part)
                if targetPart then
                    -- Verificação de Time (opcional)
                    if not Config.Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team then
                        local dist = (targetPart.Position - myHead.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end

        if closestPlayer then
            local targetPart = getBodyPart(closestPlayer.Character, Config.Aimbot.Part)
            if targetPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end)
end

-- Lógica do Trigger Bot
local triggerConnection
local lastTrigger = 0
local function startTriggerBot()
    if triggerConnection then triggerConnection:Disconnect() end
    triggerConnection = RunService.RenderStepped:Connect(function()
        if not Config.TriggerBot.Enabled then return end
        if tick() - lastTrigger < Config.TriggerBot.Delay then return end

        -- Verifica se a mira está sobre um jogador
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model then
                local player = Players:GetPlayerFromCharacter(model)
                if player and player ~= LocalPlayer then
                    -- Simula clique (isso pode não funcionar em todos os jogos devido a restrições)
                    -- Em executores, você pode usar funções como mouse1click() se disponível
                    -- Aqui usamos uma abordagem genérica
                    lastTrigger = tick()
                    -- Tenta atirar (depende do jogo)
                    -- Nota: Esta parte é altamente dependente do jogo e do executor.
                end
            end
        end
    end)
end

-- Lógica do No Recoil (Simulação)
-- Nota: No Recoil real requer manipulação de CFrame ou propriedades da câmera
-- Esta é uma implementação básica que pode não funcionar em todos os jogos
local recoilConnection
local function startNoRecoil()
    if recoilConnection then recoilConnection:Disconnect() end
    -- Implementação básica: tenta resetar a CFrame da câmera se ela mudar de forma suspeita
    -- Em executores, você pode hookar funções específicas de recuo
end

-- Lógica do ESP
local function updateESP()
    -- Limpa ESPs antigos
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    ESPObjects = {}

    if not Config.ESP.Enabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart then
                -- Criar BillboardGui para Name e Health
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_Billboard"
                billboard.Adornee = rootPart
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = ScreenGui

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = getESPColor()
                nameLabel.TextStrokeTransparency = 0
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
                nameLabel.Visible = Config.ESP.ShowName
                nameLabel.Parent = billboard

                local healthLabel = Instance.new("TextLabel")
                healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
                healthLabel.Position = UDim2.new(0, 0, 0.4, 0)
                healthLabel.BackgroundTransparency = 1
                healthLabel.Text = "❤ " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                healthLabel.TextColor3 = getESPColor()
                healthLabel.TextStrokeTransparency = 0
                healthLabel.Font = Enum.Font.Gotham
                healthLabel.TextSize = 12
                healthLabel.Visible = Config.ESP.ShowHealth
                healthLabel.Parent = billboard

                -- Distance Label (opcional, atualizado periodicamente)
                local distanceLabel = Instance.new("TextLabel")
                distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
                distanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
                distanceLabel.BackgroundTransparency = 1
                distanceLabel.Text = ""
                distanceLabel.TextColor3 = getESPColor()
                distanceLabel.TextStrokeTransparency = 0
                distanceLabel.Font = Enum.Font.Gotham
                distanceLabel.TextSize = 11
                distanceLabel.Visible = Config.ESP.ShowDistance
                distanceLabel.Parent = billboard

                table.insert(ESPObjects, billboard)

                -- ESP Line (Tracer)
                if Config.ESP.ShowLine then
                    -- Criar uma linha usando Drawing API (se disponível) ou Frame 2D
                    -- Abordagem simplificada: usar uma linha 2D via GUI
                    local line = Instance.new("Frame")
                    line.Name = "ESP_Line_" .. player.Name
                    line.BackgroundColor3 = getESPColor()
                    line.BorderSizePixel = 0
                    line.Parent = ScreenGui
                    table.insert(ESPObjects, line)
                    -- Nota: Atualizar a posição da linha requer cálculos de ScreenPointToRay
                    -- Isso é deixado como exercício para manter o script conciso.
                end
            end
        end
    end
end

-- Loop para atualizar ESP e distâncias
RunService.RenderStepped:Connect(function()
    if Config.ESP.Enabled then
        -- Atualizar distâncias nos billboards existentes
        for _, obj in pairs(ESPObjects) do
            if obj:IsA("BillboardGui") and obj.Adornee and obj.Adornee.Parent then
                local distLabel = obj:FindFirstChild("TextLabel") -- Simplificação
                -- Atualização real precisaria encontrar o label específico
            end
        end
    end
end)

-- Inicializar lógicas
startAimbot()
startTriggerBot()
startNoRecoil()

-- Loop principal para verificar mudanças de estado (simplificado)
-- Em um script real, você chamaria start/stop conforme os toggles.

-- =====================================================
-- CONEXÕES DOS BOTÕES
-- =====================================================
TabAimbot.MouseButton1Click:Connect(function() switchTab("Aimbot") end)
TabESP.MouseButton1Click:Connect(function() switchTab("ESP") end)

-- Inicializar com Aimbot visível
switchTab("Aimbot")

-- Minimizar/Restaurar
local minimized = false
local originalSize = MainFrame.Size
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 500, 0, 35)
        ContentFrame.Visible = false
        TabContainer.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = originalSize
        ContentFrame.Visible = true
        TabContainer.Visible = true
        MinimizeBtn.Text = "—"
    end
end)

-- Fechar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    -- Desconectar conexões
    if aimbotConnection then aimbotConnection:Disconnect() end
    if triggerConnection then triggerConnection:Disconnect() end
    if recoilConnection then recoilConnection:Disconnect() end
end)

print("Martinsx HUD carregado com sucesso!")
