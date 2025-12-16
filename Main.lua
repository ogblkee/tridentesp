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

local Vercore = {}
Vercore.ESP_Objects = {}
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")

function Vercore:Create(className, properties)
    local success, object = pcall(Drawing.new, className)
    if not success or not object then return nil end
    for prop, value in next, properties or {} do
        if pcall(function() object[prop] = value end) == false then
            warn(": Invalid property :", prop)
        end
    end
    return object
end

function Vercore:GetPlayers()
    local players = {}
    for _, v in next, PlayerReg do
        if v and v.model and v.model.Head and not v.sleeping then
            table.insert(players, v)
        end
    end
    return players
end

function Vercore:SetupESP(player)
    Vercore.ESP_Objects[player.id] = Vercore:Create("Text", {
        Text = "[NONE]",
        Size = 10,
        Color = Color3.fromRGB(255, 0, 0),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Center = true,
        Visible = false
    })
end

function Vercore:UpdateText(esp, part, player, distance)
    local WeaponFound = player.equippedItem and player.equippedItem.type or "None"
    local name = player.name or "Unknown"
    esp.Text = string.format("%s [%s] %d", name, WeaponFound:lower(), math.floor(distance))
    esp.Color = Color3.fromRGB(255, 255, 255)
end

    for id, esp in next, Vercore.ESP_Objects do
        if not playerIds[id] then
            Vercore:HideESP(esp)
            Vercore.ESP_Objects[id] = nil
        end
    end
end

function Vercore:UpdatePosition(esp, part, player)
    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
    local distance = (cam.CFrame.Position - part.Position).Magnitude
if onScreen and distance <= 2000 then
    esp.Position = Vector2.new(pos.X, pos.Y)
    esp.Visible = true
    Vercore:UpdateText(esp, part, player, distance)
else
    Vercore:HideESP(esp)
end
function Vercore:UpdateText(esp, part, player, distance)
    local WeaponFound = player.equippedItem and player.equippedItem.type or "None"
    local name = player.name or "Unknown"
    esp.Text = string.format("%s [%s] %d", name, WeaponFound:lower(), math.floor(distance))

    -- Cor fixa branca
    esp.Color = Color3.fromRGB(255, 255, 255)
end


function Vercore:HideESP(esp)
    esp.Visible = false
end

rs.RenderStepped:Connect(function()
    Vercore:UpdateESP()
end)
