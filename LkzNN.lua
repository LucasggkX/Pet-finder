task.spawn(
    function()
        if game.PlaceId ~= 109983668079237 then
            return
        end
        if
            workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Codes") and
                workspace.Map.Codes:FindFirstChild("Main") and
                workspace.Map.Codes.Main:FindFirstChild("SurfaceGui") and
                workspace.Map.Codes.Main.SurfaceGui:FindFirstChild("MainFrame") and
                workspace.Map.Codes.Main.SurfaceGui.MainFrame:FindFirstChild("PrivateServerMessage") and
                workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.Visible == true
         then
            return
        end

        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local w1 = "https://1.lucasemanuelguimaraes20.workers.dev/"
        local w2 = "https://5.lucasemanuelguimaraes20.workers.dev/"
        local w3 = "https://10.lucasemanuelguimaraes20.workers.dev/"
        local w4 = "https://30.lucasemanuelguimaraes20.workers.dev/"

        local enviados = {}

        local function gerarHash(texto)
            local soma = 0
            for i = 1, #texto do
                local b = string.byte(texto, i)
                if b then
                    soma = soma + b
                end
            end
            return tostring(soma)
        end

        local function enviarWebhook(discordData, web)
            if not web or type(web) ~= "string" or web == "" then
                return
            end
            pcall(
                function()
                    local timestamp = math.floor(os.time())
                    local userId = tostring(LocalPlayer.UserId)
                    local hash = gerarHash(userId .. ":" .. timestamp .. ":Webhookzinha123@")
                    HttpService:RequestAsync(
                        {
                            Url = web,
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = HttpService:JSONEncode(
                                {
                                    userId = userId,
                                    timestamp = timestamp,
                                    hash = hash,
                                    dados = discordData
                                }
                            )
                        }
                    )
                end
            )
        end

        local function parseValue(str)
            if not str or type(str) ~= "string" then
                return 0
            end
            str = str:gsub("%$", ""):gsub("%s", "")
            local num, suf = str:match("([%d%.]+)([KMB]?)")
            num = tonumber(num) or 0
            if suf == "K" then
                num = num * 1e3
            elseif suf == "M" then
                num = num * 1e6
            elseif suf == "B" then
                num = num * 1e9
            end
            return num
        end

        local function GetAll(minStr, maxStr)
            local minVal, maxVal = parseValue(minStr), parseValue(maxStr)
            if minVal > maxVal then
                minVal, maxVal = maxVal, minVal
            end
            local animals = {}
            local plotsFolder = workspace:FindFirstChild("Plots")
            if not plotsFolder then
                return animals
            end

            for _, plot in ipairs(plotsFolder:GetChildren()) do
                local textLabel =
                    plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("SurfaceGui") and
                    plot.PlotSign.SurfaceGui:FindFirstChild("Frame") and
                    plot.PlotSign.SurfaceGui.Frame:FindFirstChild("TextLabel")

                if textLabel and textLabel.Text and textLabel.Text ~= (LocalPlayer.DisplayName .. "'s Base") then
                    local animalPodiums = plot:FindFirstChild("AnimalPodiums")
                    if animalPodiums then
                        for _, podium in ipairs(animalPodiums:GetChildren()) do
                            local base = podium:FindFirstChild("Base")
                            local spawn = base and base:FindFirstChild("Spawn")
                            local attach = spawn and spawn:FindFirstChild("Attachment")
                            local overhead = attach and attach:FindFirstChild("AnimalOverhead")
                            if overhead then
                                local stolen = overhead:FindFirstChild("Stolen")
                                if not (stolen and (stolen.Text == "CRAFTING" or stolen.Text == "IN MACHINE")) then
                                    local gen = overhead:FindFirstChild("Generation")
                                    local rarity = overhead:FindFirstChild("Rarity")
                                    local name = overhead:FindFirstChild("DisplayName")
                                    if gen and rarity and name and gen.Text and name.Text and rarity.Text then
                                        local value = parseValue(gen.Text)
                                        if value >= minVal and value <= maxVal then
                                            table.insert(
                                                animals,
                                                {nome = name.Text, raridade = rarity.Text, generation = gen.Text}
                                            )
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
            local total = Players.MaxPlayers or 0
            return tostring(#Players:GetPlayers()) .. "/" .. tostring(total)
        end

        local function Web(animals, web, faixaNome, faixaTitulo)
            if typeof(animals) ~= "table" or #animals == 0 then
                return
            end
            if #Players:GetPlayers() >= (Players.MaxPlayers or 0) then
                return
            end

            local contar = {}
            for _, a in ipairs(animals) do
                if a.nome and a.generation then
                    local key = a.nome .. "|" .. a.generation
                    contar[key] = (contar[key] or 0) + 1
                end
            end

            local novos = {}
            for key, qty in pairs(contar) do
                if not enviados[key] then
                    enviados[key] = true
                    local nome, generation = key:match("(.+)|(.+)")
                    table.insert(novos, {nome = nome, generation = generation, quantidade = qty})
                end
            end

            if #novos == 0 then
                return
            end

            local utcTime = os.date("!%H:%M:%S")
            local animalsText = ""
            for i, animal in ipairs(novos) do
                animalsText = animalsText .. "ðŸ”¥ " .. animal.nome .. " â€” " .. animal.generation
                if animal.quantidade > 1 then
                    animalsText = animalsText .. " - " .. animal.quantidade .. "x"
                end
                if i < #novos then
                    animalsText = animalsText .. "\n"
                end
            end

            local discordData = {
                embeds = {
                    {
                        title = "ðŸ”¥ " .. faixaTitulo,
                        description = animalsText,
                        color = 3447003,
                        fields = {
                            {name = "ðŸ“Š Server Info", value = GetPlayers(), inline = false},
                            {name = "ðŸ†” Job ID", value = "```" .. tostring(game.JobId) .. "```", inline = false},
                            {
                                name = "ðŸ”— Join Server",
                                value = "[CLIQUE PARA ENTRAR](https://lucasggkx.github.io/Pet-finder/?placeId=" ..
                                    game.PlaceId .. "&gameInstanceId=" .. game.JobId .. ")",
                                inline = false
                            }
                        },
                        footer = {text = "LKZ NOTIFIER ðŸ”¥ | Secret Scanner " .. faixaNome .. " | Hoje Ã s " .. utcTime}
                    }
                }
            }

            enviarWebhook(discordData, web)
        end

        repeat
            task.wait()
        until game:IsLoaded()

        task.spawn(
            function()
                while task.wait(5) do
                    pcall(
                        function()
                            Web(GetAll("1M/s", "4.99M/s"), w1, "1M-5M", "MEDIUM VALUE SECRETS DETECTED (1M-5M)")
                            Web(GetAll("5M/s", "9.99M/s"), w2, "5M-10M", "HIGH VALUE SECRETS DETECTED (5M-10M)")
                            Web(GetAll("10M/s", "29.99M/s"), w3, "10M-30M", "ULTRA VALUE SECRETS DETECTED (10M-30M)")
                            Web(GetAll("30M/s", "5B/s"), w4, "30M-5B", "SUPREME VALUE SECRETS DETECTED (30M-5B)")
                        end
                    )
                end
            end
        )
    end
)
