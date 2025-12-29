-- Vercore ESP - VERSÃO FINAL 100% CORRIGIDA (ZERO LAG + Sem ESP acumulado/congelado)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- === PEGA PlayerReg UMA VEZ SÓ ===
local GetFunction = function(Script, Line)
    for _, v in pairs(getgc()) do
        if typeof(v) == "function" and debug.info(v, "sl") then
            local src, lineNum = debug.info(v, "s"), debug.info(v, "l")
            if src:find(Script) and lineNum == Line then
                return v
            end
        end
    end
end

local SetInfraredEnabled = GetFunction("PlayerClient", 588)
local PlayerReg = debug.getupvalue(SetInfraredEnabled, 2)

-- === ESP Objects ===
local ESP_Objects = {}

-- === Cria Drawing ESP ===
local function CreateESP()
    local esp = Drawing.new("Text")
    esp.Size = 13
    esp.Color = Color3.new(1, 1, 1)
    esp.Outline = true
    esp.Center = true
    esp.Font = Drawing.Fonts.UI
    esp.Visible = false
    return esp
end

-- === Rainbow global (1x por frame) ===
local RainbowColor = Color3.new(1, 1, 1)
RunService.Heartbeat:Connect(function()
    local t = tick() * 2
    local r = math.sin(t) * 127 + 128
    local g = math.sin(t + 2) * 127 + 128
    local b = math.sin(t + 4) * 127 + 128
    RainbowColor = Color3.fromRGB(r, g, b)
end)

-- === UPDATE ESP (corrigido: remove ESP imediatamente quando jogador sai) ===
local function UpdateESP()
    local myPos = Camera.CFrame.Position
    local currentIds = {}  -- tabela temporária pra rastrear quem está vivo agora

    for id, playerData in pairs(PlayerReg) do
        if playerData and playerData.model and playerData.model:FindFirstChild("Head") and not playerData.sleeping then
            currentIds[id] = true  -- marca como ativo

            local esp = ESP_Objects[id]
            if not esp then
                esp = CreateESP()
                ESP_Objects[id] = esp
            end

            local head = playerData.model.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)

            -- Atualiza posição SEMPRE (evita congelamento)
            esp.Position = Vector2.new(pos.X, pos.Y)

            if onScreen then
                local distance = math.floor((myPos - head.Position).Magnitude)
                local weapon = playerData.equippedItem and playerData.equippedItem.type or "None"

                esp.Text = string.format("[%s] %d", weapon:lower(), distance)
                esp.Color = RainbowColor
                esp.Visible = true
            else
                esp.Visible = false
            end
        end
    end

    -- === LIMPEZA: Remove ESP de jogadores que não estão mais em PlayerReg ===
    for id, esp in pairs(ESP_Objects) do
        if not currentIds[id] then
            esp.Visible = false
            esp:Remove()           -- Remove o Drawing completamente
            ESP_Objects[id] = nil  -- Limpa da tabela
        end
    end
end

-- === LOOP PRINCIPAL ===
RunService.Heartbeat:Connect(UpdateESP)
