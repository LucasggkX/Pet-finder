--[[
.nome
.raridade
.generation
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function parseValue(str)
    if not str then return 0 end
    str = str:gsub("%$", ""):gsub("/s", "")
    local num, suf = str:match("([%d%.]+)([MK]?)")
    num = tonumber(num) or 0
    if suf == "K" then num = num * 1000
    elseif suf == "M" then num = num * 1000000 end
    return num
end

local function Best(minStr, maxStr)
    local minVal = parseValue(minStr)
    local maxVal = parseValue(maxStr)
    if minVal > maxVal then minVal, maxVal = maxVal, minVal end
    local bestAnimal = nil
    local bestValue = -math.huge
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local animalPodiums = plot:FindFirstChild("AnimalPodiums")
        if animalPodiums then
            for _, podium in ipairs(animalPodiums:GetChildren()) do
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                local attach = spawn and spawn:FindFirstChild("Attachment")
                if attach then
                    local overhead = attach:FindFirstChild("AnimalOverhead")
                    if overhead then
                        local stolen = overhead:FindFirstChild("Stolen")
                        if not (stolen and (stolen.Text == "FUSING" or stolen.Text == "IN MACHINE")) then
                            local gen = overhead:FindFirstChild("Generation")
                            local rarity = overhead:FindFirstChild("Rarity")
                            local name = overhead:FindFirstChild("DisplayName")
                            if gen and rarity and name then
                                local value = parseValue(gen.Text)
                                if value >= minVal and value <= maxVal and value > bestValue then
                                    bestValue = value
                                    bestAnimal = {
                                        nome = name.Text,
                                        raridade = rarity.Text,
                                        generation = gen.Text
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestAnimal
end

local faixa1 = Best("1M/s", "5M/s")
local faixa2 = Best("5M/s", "10M/s")
local faixa3 = Best("10M/s", "999.9M/s")

if faixa1 then
    print("1M/s -> 5M/s: " .. faixa1.nome .. " - " .. faixa1.generation)
end

if faixa2 then
    print("5M/s -> 10M/s: " .. faixa2.nome .. " - " .. faixa2.generation)
end

if faixa3 then
    print("10M/s -> 999.9M/s: " .. faixa3.nome .. " - " .. faixa3.generation)
end
