-- Vercore ESP - VERSÃO OTIMIZADA (ZERO LAG) - Trident Survival / Mirage HvH

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- === PEGA PlayerReg UMA VEZ SÓ (não em loop) ===
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
local PlayerReg = debug.getupvalue(SetInfraredEnabled, 2)  -- Pega UMA VEZ

-- === ESP Objects ===
local ESP_Objects = {}

-- === Cria Drawing (otimizado) ===
local function CreateESP()
    return Drawing.new("Text", {
        Size = 13,
        Color = Color3.new(1, 1, 1),
        Outline = true,
        OutlineColor = Color3.new(0, 0, 0),
        Center = true,
        Visible = false,
        Font = Drawing.Fonts.UI
    })
end

-- === Cache de cor rainbow (calcula UMA vez por frame, não por jogador) ===
local RainbowColor
RunService.Heartbeat:Connect(function()
    local t = tick() * 2
    local r = math.sin(t) * 127 + 128
    local g = math.sin(t + 2) * 127 + 128
    local b = math.sin(t + 4) * 127 + 128
    RainbowColor = Color3.fromRGB(r, g, b)
end)

-- === UPDATE ESP (otimizado) ===
local function UpdateESP()
    local myPos = Camera.CFrame.Position

    for id, playerData in pairs(PlayerReg) do
        if playerData and playerData.model and playerData.model:FindFirstChild("Head") and not playerData.sleeping then
            local esp = ESP_Objects[id]
            if not esp then
                esp = CreateESP()
                ESP_Objects[id] = esp
            end

            local head = playerData.model.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local distance = math.floor((myPos - head.Position).Magnitude)
                local weapon = playerData.equippedItem and playerData.equippedItem.type or "None"

                esp.Text = string.format("[%s] %d", weapon:lower(), distance)
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Color = RainbowColor
                esp.Visible = true
            else
                esp.Visible = false
            end
        else
            -- Jogador saiu/morreu
            if ESP_Objects[id] then
                ESP_Objects[id].Visible = false
                ESP_Objects[id]:Remove()
                ESP_Objects[id] = nil
            end
        end
    end
end

-- === LOOP PRINCIPAL (Heartbeat = menos pesado que RenderStepped) ===
RunService.Heartbeat:Connect(UpdateESP)
