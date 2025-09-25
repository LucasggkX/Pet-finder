local LocalPlayer = game:GetService("Players").LocalPlayer

local function parseValue(str)
    str = str:gsub("%$", ""):gsub("/s", "")
    local num, suf = str:match("([%d%.]+)([KM]?)")
    num = tonumber(num) or 0
    if suf == "K" then num = num * 1e3
    elseif suf == "M" then num = num * 1e6 end
    return num
end

local function formatValue(str)
    str = str:gsub("%$", ""):gsub("/s", "")
    local num, suf = str:match("([%d%.]+)([KM]?)")
    return "$"..num..suf.."/s"
end

local myPlot
for _, plot in ipairs(workspace.Plots:GetChildren()) do
    local plotSign = plot:FindFirstChild("PlotSign")
    if plotSign then
        local tl = plotSign:FindFirstChild("SurfaceGui") and plotSign.SurfaceGui:FindFirstChild("Frame") and plotSign.SurfaceGui.Frame:FindFirstChild("TextLabel")
        if tl and tl.Text:find(LocalPlayer.DisplayName) then
            myPlot = plot
            break
        end
    end
end

if myPlot then
    local animals = {}
    local animalPodiums = myPlot:FindFirstChild("AnimalPodiums")
    if animalPodiums then
        for _, podium in ipairs(animalPodiums:GetChildren()) do
            local base = podium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            local attach = spawn and spawn:FindFirstChild("Attachment")
            if attach then
                local overhead = attach:FindFirstChild("AnimalOverhead")
                if overhead then
                    local gen = overhead:FindFirstChild("Generation")
                    local name = overhead:FindFirstChild("DisplayName")
                    local mut = overhead:FindFirstChild("Mutation")
                    if gen and name then
                        local key = formatValue(gen.Text).."|"..name.Text
                        if not animals[key] then
                            animals[key] = {
                                ps = formatValue(gen.Text),
                                nome = name.Text,
                                quantidade = 0,
                                mutacao = mut and mut.Text ~= "" and mut.Text ~= "Gold" and mut.Text or "Normal",
                                valor = parseValue(gen.Text)
                            }
                        end
                        animals[key].quantidade += 1
                    end
                end
            end
        end
    end

    local lista = {}
    for _, a in pairs(animals) do
        table.insert(lista, a)
    end
    table.sort(lista, function(a,b) return a.valor > b.valor end)

    local texto = "Tenho:\n```\nP/S        | Nome                      | Qtd | Mutação\n"
    for _, a in ipairs(lista) do
        texto = texto .. string.format("%-10s | %-25s | %-3d | %-10s\n", a.ps, a.nome, a.quantidade, a.mutacao)
    end
    texto = texto .. "```"
    setclipboard(texto)
end
