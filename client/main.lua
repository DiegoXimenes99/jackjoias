local QBCore = exports['qb-core']:GetCoreObject()
local shopNPC = nil
local currentPrices = {}
local npcSpawned = false

-- Helper function para contar tabelas
local function TableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Inicializar preços ao carregar o cliente
CreateThread(function()
    for _, item in ipairs(Config.Items) do
        currentPrices[item.id] = item.price
    end
    DebugPrint("Preços inicializados no cliente")
end)

-- Criar Blip no mapa
CreateThread(function()
    local blip = AddBlipForCoord(Config.ShopLocation.coords)
    SetBlipSprite(blip, Config.ShopLocation.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.ShopLocation.blip.scale)
    SetBlipColour(blip, Config.ShopLocation.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.ShopLocation.blip.label)
    EndTextCommandSetBlipName(blip)
    DebugPrint("Blip criado nas coordenadas:", Config.ShopLocation.coords)
end)

-- Função para carregar modelo (método correto)
local function LoadModel(model)
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    
    if not IsModelInCdimage(modelHash) then
        DebugPrint("ERRO: Modelo não existe no jogo:", model)
        return false
    end
    
    if HasModelLoaded(modelHash) then
        DebugPrint("Modelo já estava carregado:", model)
        return true
    end
    
    DebugPrint("Requisitando modelo:", model, "Hash:", modelHash)
    RequestModel(modelHash)
    
    local attempts = 0
    local maxAttempts = 100 -- 10 segundos (100 * 100ms)
    
    while not HasModelLoaded(modelHash) do
        Wait(100)
        attempts = attempts + 1
        
        if attempts % 10 == 0 then
            DebugPrint("Ainda carregando modelo... Tentativa:", attempts)
        end
        
        if attempts >= maxAttempts then
            DebugPrint("ERRO: Timeout ao carregar modelo:", model, "após", attempts * 100, "ms")
            return false
        end
    end
    
    DebugPrint("Modelo carregado com sucesso após", attempts * 100, "ms")
    return true
end

-- Criar NPC da loja (MÉTODO CORRIGIDO)
CreateThread(function()
    -- Aguardar o jogo carregar completamente
    while not NetworkIsSessionStarted() do
        Wait(100)
    end
    
    Wait(2000) -- Aguardar 2 segundos extras para garantir
    
    DebugPrint("========================================")
    DebugPrint("INICIANDO SPAWN DO NPC DA JOALHERIA")
    DebugPrint("========================================")
    DebugPrint("Modelo configurado:", Config.NPCModel)
    DebugPrint("Coordenadas:", Config.NPCCoords.x, Config.NPCCoords.y, Config.NPCCoords.z)
    DebugPrint("Heading:", Config.NPCCoords.w)
    
    -- Carregar o modelo
    if not LoadModel(Config.NPCModel) then
        DebugPrint("========================================")
        DebugPrint("FALHA CRÍTICA: Não foi possível carregar o modelo!")
        DebugPrint("Tente trocar Config.NPCModel para um destes:")
        DebugPrint("  - a_m_y_business_01")
        DebugPrint("  - s_m_y_dealer_01")
        DebugPrint("  - mp_m_shopkeep_01")
        DebugPrint("  - cs_gurk")
        DebugPrint("========================================")
        return
    end
    
    local pedModel = GetHashKey(Config.NPCModel)
    
    -- Criar o NPC
    DebugPrint("Criando NPC...")
    shopNPC = CreatePed(
        4, -- PED_TYPE_CIVMALE
        pedModel,
        Config.NPCCoords.x,
        Config.NPCCoords.y,
        Config.NPCCoords.z - 1.0,
        Config.NPCCoords.w,
        false, -- isNetwork
        true   -- thisScriptCheck
    )
    
    -- Verificar se foi criado
    if not DoesEntityExist(shopNPC) then
        DebugPrint("========================================")
        DebugPrint("ERRO CRÍTICO: CreatePed retornou um NPC inválido!")
        DebugPrint("Entity ID:", shopNPC)
        DebugPrint("========================================")
        SetModelAsNoLongerNeeded(pedModel)
        return
    end
    
    DebugPrint("✓ NPC criado com sucesso! Entity ID:", shopNPC)
    
    -- Aguardar o NPC estar completamente carregado
    local timeout = 0
    while not DoesEntityExist(shopNPC) and timeout < 50 do
        Wait(100)
        timeout = timeout + 1
    end
    
    if not DoesEntityExist(shopNPC) then
        DebugPrint("ERRO: NPC desapareceu após criação!")
        SetModelAsNoLongerNeeded(pedModel)
        return
    end
    
    -- Configurações do NPC
    DebugPrint("Configurando propriedades do NPC...")
    
    SetEntityAsMissionEntity(shopNPC, true, true)
    SetPedFleeAttributes(shopNPC, 0, 0)
    SetPedDiesWhenInjured(shopNPC, false)
    SetPedKeepTask(shopNPC, true)
    SetBlockingOfNonTemporaryEvents(shopNPC, true)
    SetEntityInvincible(shopNPC, true)
    FreezeEntityPosition(shopNPC, true)
    SetPedCanRagdoll(shopNPC, false)
    SetPedCanBeTargetted(shopNPC, false)
    SetPedCanBeDraggedOut(shopNPC, false)
    
    -- Liberar o modelo
    SetModelAsNoLongerNeeded(pedModel)
    
    npcSpawned = true
    
    local coords = GetEntityCoords(shopNPC)
    DebugPrint("✓ NPC configurado com sucesso!")
    DebugPrint("  Posição final:", coords.x, coords.y, coords.z)
    DebugPrint("  Heading:", GetEntityHeading(shopNPC))
    DebugPrint("  Congelado:", IsEntityPositionFrozen(shopNPC))
    
    -- Aguardar antes de configurar ox_target
    Wait(1000)
    
    -- Configurar ox_target
    DebugPrint("Configurando ox_target...")
    
    local targetSuccess, targetError = pcall(function()
        exports.ox_target:addLocalEntity(shopNPC, {
            {
                name = 'jewelry_shop',
                icon = 'fas fa-gem',
                label = Config.Lang.openShop,
                distance = 3.0,
                onSelect = function()
                    DebugPrint("========================================")
                    DebugPrint("PLAYER CLICOU NO NPC!")
                    DebugPrint("Iniciando abertura da loja...")
                    DebugPrint("========================================")
                    OpenShop()
                end
            }
        })
    end)
    
    if targetSuccess then
        DebugPrint("✓ ox_target configurado no NPC com sucesso!")
        DebugPrint("Tente interagir com o NPC usando ox_target (olhe para ele e pressione a tecla)")
    else
        DebugPrint("⚠ Falha ao configurar ox_target no NPC:", targetError)
        DebugPrint("Criando zona de backup...")
        
        -- Criar zona de backup
        local zoneSuccess, zoneError = pcall(function()
            exports.ox_target:addBoxZone({
                coords = vector3(Config.NPCCoords.x, Config.NPCCoords.y, Config.NPCCoords.z),
                size = vector3(2.5, 2.5, 2.5),
                rotation = Config.NPCCoords.w,
                debug = Config.Debug,
                options = {
                    {
                        name = 'jewelry_shop_zone',
                        icon = 'fas fa-gem',
                        label = Config.Lang.openShop,
                        distance = 3.0,
                        onSelect = function()
                            DebugPrint("========================================")
                            DebugPrint("PLAYER CLICOU NA ZONA!")
                            DebugPrint("Iniciando abertura da loja...")
                            DebugPrint("========================================")
                            OpenShop()
                        end
                    }
                }
            })
        end)
        
        if zoneSuccess then
            DebugPrint("✓ Zona ox_target criada como backup!")
            DebugPrint("Fique próximo ao NPC e use ox_target")
        else
            DebugPrint("✗ ERRO ao criar zona de backup:", zoneError)
            DebugPrint("VERIFIQUE se ox_target está funcionando!")
        end
    end
    
    DebugPrint("========================================")
    DebugPrint("SPAWN DO NPC CONCLUÍDO!")
    DebugPrint("Vá até a Vangelico Jewelry para testar")
    DebugPrint("Coordenadas: -622, -230, 38")
    DebugPrint("========================================")
end)

-- Thread para monitorar o NPC
CreateThread(function()
    while true do
        Wait(10000) -- Verificar a cada 10 segundos
        
        if npcSpawned and shopNPC then
            if not DoesEntityExist(shopNPC) then
                DebugPrint("⚠ ALERTA: NPC foi deletado! ID:", shopNPC)
                npcSpawned = false
                shopNPC = nil
            end
        end
    end
end)

-- Função para abrir a loja
function OpenShop()
    DebugPrint("========================================")
    DebugPrint("FUNÇÃO OpenShop() CHAMADA!")
    DebugPrint("========================================")
    
    -- Solicitar inventário e preços do servidor
    DebugPrint("Solicitando inventário do jogador...")
    QBCore.Functions.TriggerCallback('jewelry-shop:server:getInventory', function(inventory, prices)
        DebugPrint("✓ Callback getInventory retornou")
        DebugPrint("Itens no inventário:", inventory and #inventory or 0)
        DebugPrint("Preços disponíveis:", prices and TableLength(prices) or 0)
        
        if not inventory or not prices then
            DebugPrint("✗ ERRO: Dados não foram recebidos do servidor!")
            QBCore.Functions.Notify("Erro ao abrir loja", 'error')
            return
        end
        
        -- Abrir NUI
        DebugPrint("Enviando comando para abrir NUI...")
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openShop",
            inventory = inventory,
            prices = prices,
            items = Config.Items
        })
        
        DebugPrint("✓ SetNuiFocus(true, true) executado")
        DebugPrint("✓ SendNUIMessage executado")
        DebugPrint("========================================")
    end)
end

-- NUI Callbacks
RegisterNUICallback('closeShop', function(data, cb)
    DebugPrint("Fechando loja")
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellItems', function(data, cb)
    DebugPrint("========================================")
    DebugPrint("PROCESSANDO VENDA")
    DebugPrint("Total de itens no carrinho:", #data.cart)
    DebugPrint("Valor total a receber: $" .. data.total)
    DebugPrint("========================================")
    
    QBCore.Functions.TriggerCallback('jewelry-shop:server:sellItems', function(success, message, soldItems)
        if success then
            DebugPrint("✓ Venda realizada com sucesso!")
            QBCore.Functions.Notify(message or Config.Lang.sellSuccess, 'success')
        else
            DebugPrint("✗ Falha na venda:", message)
            QBCore.Functions.Notify(message or Config.Lang.sellFailed, 'error')
        end
        cb({success = success, message = message, soldItems = soldItems or {}})
    end, data.cart, data.total)
end)

-- Atualizar preços quando o servidor notificar
RegisterNetEvent('jewelry-shop:client:updatePrices', function(newPrices)
    DebugPrint("Recebendo atualização de preços do servidor")
    currentPrices = newPrices
    
    -- Se a NUI estiver aberta, atualizar os preços
    SendNUIMessage({
        action = "updatePrices",
        prices = newPrices
    })
end)

-- Comandos de debug
if Config.Debug then
    RegisterCommand('spawnjewelrynpc', function()
        DebugPrint("Comando: Forçando respawn do NPC...")
        
        if DoesEntityExist(shopNPC) then
            DeleteEntity(shopNPC)
            DebugPrint("NPC anterior deletado")
        end
        
        npcSpawned = false
        shopNPC = nil
        
        -- Recarregar o recurso é mais confiável
        ExecuteCommand('restart jewelry-shop')
    end, false)
    
    RegisterCommand('checkjewelrynpc', function()
        DebugPrint("========================================")
        DebugPrint("STATUS DO NPC")
        DebugPrint("========================================")
        
        if shopNPC and DoesEntityExist(shopNPC) then
            local coords = GetEntityCoords(shopNPC)
            local heading = GetEntityHeading(shopNPC)
            local model = GetEntityModel(shopNPC)
            local health = GetEntityHealth(shopNPC)
            
            DebugPrint("✓ NPC EXISTE!")
            DebugPrint("  Entity ID:", shopNPC)
            DebugPrint("  Modelo:", model)
            DebugPrint("  Vida:", health)
            DebugPrint("  Posição:", coords.x, coords.y, coords.z)
            DebugPrint("  Heading:", heading)
            DebugPrint("  Congelado:", IsEntityPositionFrozen(shopNPC))
            
            -- Teleportar o jogador para o NPC
            local ped = PlayerPedId()
            SetEntityCoords(ped, coords.x + 2.0, coords.y, coords.z)
            DebugPrint("Você foi teleportado para perto do NPC")
        else
            DebugPrint("✗ NPC NÃO EXISTE!")
            DebugPrint("  shopNPC value:", shopNPC)
            DebugPrint("  npcSpawned:", npcSpawned)
            DebugPrint("Use /spawnjewelrynpc para tentar recriar")
        end
        
        DebugPrint("========================================")
    end, false)
    
    -- Comando para testar a NUI diretamente
    RegisterCommand('testjewelryui', function()
        DebugPrint("Comando: Abrindo NUI diretamente (teste)")
        OpenShop()
    end, false)
    
    -- Comando para ir até a loja
    RegisterCommand('tpjewelry', function()
        local ped = PlayerPedId()
        SetEntityCoords(ped, Config.NPCCoords.x + 2.0, Config.NPCCoords.y, Config.NPCCoords.z)
        DebugPrint("Teleportado para a joalheria!")
    end, false)
end

-- Cleanup ao descarregar o recurso
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if DoesEntityExist(shopNPC) then
            DeleteEntity(shopNPC)
            DebugPrint("NPC removido ao descarregar recurso")
        end
        SetNuiFocus(false, false)
    end
end)