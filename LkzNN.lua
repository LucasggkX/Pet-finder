if game.PlaceId ~= 109983668079237 then return end
if workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.Visible == true then return end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local w1 = "https://1-5.lucasemanuelguimaraes20.workers.dev/"
local w2 = "https://5-10.lucasemanuelguimaraes20.workers.dev/"
local w3 = "https://10-superior.lucasemanuelguimaraes20.workers.dev/"

local enviados = {}

local function gerarHash(texto)
local soma = 0
for i = 1, #texto do
soma = soma + string.byte(texto, i)
end
return tostring(soma)
end

local function enviarWebhook(discordData, web)
local timestamp = math.floor(os.time())
local userId = tostring(LocalPlayer.UserId)
local hash = gerarHash(userId .. ":" .. timestamp .. ":Webhookzinha123@")
pcall(function()
HttpService:RequestAsync({
Url = web,
Method = "POST",
Headers = {["Content-Type"] = "application/json"},
Body = HttpService:JSONEncode({userId = userId, timestamp = timestamp, hash = hash, dados = discordData})
})
end)
end

local function parseValue(str)
if not str then return 0 end
str = str:gsub("%$", ""):gsub("/s", "")
local num, suf = str:match("([%d%.]+)([KMB]?)")
num = tonumber(num) or 0
if suf == "K" then num = num * 1e3
elseif suf == "M" then num = num * 1e6
elseif suf == "B" then num = num * 1e9
end
return num
end

local function GetAll(minStr, maxStr)
local minVal = parseValue(minStr)
local maxVal = parseValue(maxStr)
if minVal > maxVal then minVal, maxVal = maxVal, minVal end
local animals = {}
local plotsFolder = workspace:FindFirstChild("Plots")
if not plotsFolder then return animals end

for _, plot in ipairs(plotsFolder:GetChildren()) do  
    local textLabel = plot:FindFirstChild("PlotSign")   
        and plot.PlotSign:FindFirstChild("SurfaceGui")   
        and plot.PlotSign.SurfaceGui:FindFirstChild("Frame")   
        and plot.PlotSign.SurfaceGui.Frame:FindFirstChild("TextLabel")  
    if textLabel and textLabel.Text ~= LocalPlayer.DisplayName .. "'s Base" then  
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
                        if not (stolen and (stolen.Text == "CRAFTING" or stolen.Text == "IN MACHINE")) then  
                            local gen = overhead:FindFirstChild("Generation")  
                            local rarity = overhead:FindFirstChild("Rarity")  
                            local name = overhead:FindFirstChild("DisplayName")  
                            if gen and rarity and name then  
                                local value = parseValue(gen.Text)  
                                if value >= minVal and value <= maxVal then  
                                    table.insert(animals, {nome = name.Text, raridade = rarity.Text, generation = gen.Text})  
                                end  
                            end  
                        end  
                    end  
                end  
            end  
        end  
    end  
end  
return animals

end

local function GetPlayers()
return #Players:GetPlayers() .. "/" .. (Players.MaxPlayers or 0)
end

local function Web(animals, web, faixaNome, faixaTitulo)
if #animals == 0 or #Players:GetPlayers() >= Players.MaxPlayers then return end
local novos = {}
for _, a in ipairs(animals) do
if not enviados[a.nome] then
enviados[a.nome] = true
table.insert(novos, a)
end
end
if #novos == 0 then return end

local utcTime = os.date("!%H:%M:%S")  
local animalsText = ""  
for i, animal in ipairs(novos) do  
    animalsText = animalsText .. "🔥 " .. animal.nome .. " — " .. animal.generation  
    if i < #novos then animalsText = animalsText .. "\n" end  
end  

local discordData = {  
    embeds = {{  
        title = "🔥 " .. faixaTitulo,  
        description = animalsText,  
        color = 3447003,  
        fields = {  
            {name = "📊 Server Info", value = GetPlayers(), inline = false},  
            {name = "🆔 Job ID", value = "```" .. tostring(game.JobId) .. "```", inline = false},  
            {name = "🔗 Join Server", value = "[CLIQUE PARA ENTRAR](https://lucasggkx.github.io/Pet-finder/?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId .. ")", inline = false}  
        },  
        footer = {text = "LKZ NOTIFIER 🔥 | Secret Scanner " .. faixaNome .. " | Hoje às " .. utcTime}  
    }}  
}  
enviarWebhook(discordData, web)

end

repeat task.wait() until game:IsLoaded()

task.spawn(function()
while true do
task.wait(5)
Web(GetAll("1M/s", "4.99M/s"), w1, "1M-5M", "MEDIUM VALUE SECRETS DETECTED (1M-5M)")
Web(GetAll("5M/s", "9.99M/s"), w2, "5M-10M", "HIGH VALUE SECRETS DETECTED (5M-10M)")
Web(GetAll("10M/s", "5B/s"), w3, "10M-5B", "ULTRA VALUE SECRETS DETECTED (10M-5B)")
end
end)
