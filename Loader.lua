--[[
.nome
.raridade
.generation
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

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

local function GetUrl()
    local placeId = game.PlaceId
    local jobId = game.JobId
    return "https://lucasggkx.github.io/Pet-finder/?placeId=" .. placeId .. "&gameInstanceId=" .. jobId
end

local function GetPlayers()
    local current = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers or 0
    local icon = "👤"
    return icon .." ".. current .. "/" .. maxPlayers
end

local function Web(link, faixa)
    if #Players:GetPlayers() >= Players.MaxPlayers then return end
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if not req then return end
    local utcTime = os.date("!%Y-%m-%d %H:%M:%S")

    local function toBoldUnicode(str)
        local bold = {}
        for c in str:gmatch(".") do
            local code = c:byte()
            if c:match("%a") then
                if c:match("%u") then
                    table.insert(bold, utf8.char(code + 119743))
                else
                    table.insert(bold, utf8.char(code + 119737))
                end
            else
                table.insert(bold, c)
            end
        end
        return table.concat(bold)
    end

    local bigTitle = toBoldUnicode("🧠 " .. faixa.nome .. " | 💰 " .. faixa.generation .. " | " .. GetPlayers())
    local Psi = GetPlayers():gsub("👤", "")
    local data = {
        embeds = {{
            title = bigTitle,
            color = 0x000000,
            footer = { text = "LKZ JOINER • " .. utcTime .. " UTC" },
            fields = {
                { name = "📛 Brainrot Name", value = faixa.nome, inline = false },
                { name = "👥 Players", value = psi, inline = true },
                { name = "💰 Final Generation", value = faixa.generation, inline = true },
                { name = "🌐 Place ID", value = tostring(game.PlaceId), inline = false },
                { name = "🆔 Job ID", value = tostring(game.JobId), inline = false },
                { name = "💻 Join Script (PC)", value = "```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(" .. game.PlaceId .. ", \"" .. game.JobId .. "\", game.Players.LocalPlayer)\n```", inline = false },
                { name = "🔗 Join Link", value = "[Click to Join](" .. "https://lucasggkx.github.io/Pet-finder/?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId .. ")", inline = false },
            }
        }}
    }
    req({
        Url = link,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(data)
    })
end

--[[ === DEBUG === ]]--

repeat task.wait() until game:IsLoaded()

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

--[[ === SCRIPT === ]]--

local webhooks = {
    { _G.more_than_1Mi_less_than_5MI_Webhook, faixa1 },
    { _G.more_than_5Mi_less_than_10MI_Webhook, faixa2 },
    { _G.more_than_10Mi_less_than_999MI_Webhook, faixa3 }
}

for _, pair in ipairs(webhooks) do
    local link, faixa = pair[1], pair[2]
    if link ~= "" and faixa then
        Web(link, faixa)
    end
end

