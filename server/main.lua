local QBCore = exports['qb-core']:GetCoreObject()
local currentPrices = {}

-- Inicializar preços base
for _, item in ipairs(Config.Items) do
    currentPrices[item.id] = item.price
end

DebugPrint("Servidor iniciado - Preços base configurados")

-- Sistema de flutuação de preços
CreateThread(function()
    while true do
        Wait(Config.PriceFluctuationTime) -- 5 minutos
        
        DebugPrint("Iniciando flutuação de preços...")
        local priceChanges = {}
        
        for itemId, basePrice in pairs(currentPrices) do
            -- Gera variação aleatória entre -15% e +15%
            local variation = (math.random() - 0.5) * 2 * Config.MaxPriceVariation
            local newPrice = math.floor(basePrice * (1 + variation))
            
            -- Garantir que o preço não fique muito baixo
            if newPrice < 100 then
                newPrice = 100
            end
            
            currentPrices[itemId] = newPrice
            priceChanges[itemId] = {
                old = basePrice,
                new = newPrice,
                change = variation > 0 and 'up' or 'down'
            }
            
            DebugPrint(string.format("Item: %s | Preço antigo: $%d | Novo preço: $%d | Variação: %.2f%%", 
                itemId, basePrice, newPrice, variation * 100))
        end
        
        -- Notificar todos os clientes sobre a mudança de preços
        TriggerClientEvent('jewelry-shop:client:updatePrices', -1, currentPrices)
        DebugPrint("Preços atualizados e enviados para todos os clientes")
    end
end)

-- Callback: Obter inventário do jogador e preços
QBCore.Functions.CreateCallback('jewelry-shop:server:getInventory', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        DebugPrint(string.format("ERRO: Player [%d] não encontrado", source))
        cb(nil, nil)
        return
    end
    
    -- Pegar itens do inventário do jogador
    local inventory = exports.ox_inventory:GetInventoryItems(source)
    local playerItems = {}
    
    -- Filtrar apenas itens que a loja aceita
    for _, invItem in pairs(inventory) do
        for _, acceptedItem in ipairs(Config.Items) do
            if invItem.name == acceptedItem.id and invItem.count > 0 then
                table.insert(playerItems, {
                    name = invItem.name,
                    amount = invItem.count,
                    slot = invItem.slot
                })
                break
            end
        end
    end
    
    DebugPrint(string.format("Player [%d] tem %d itens vendáveis no inventário", source, #playerItems))
    cb(playerItems, currentPrices)
end)

-- Callback: Processar venda
QBCore.Functions.CreateCallback('jewelry-shop:server:sellItems', function(source, cb, cart, total)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        DebugPrint(string.format("ERRO: Player [%d] não encontrado ao tentar vender", source))
        cb(false, "Erro ao processar venda", {})
        return
    end
    
    DebugPrint(string.format("Player [%d] tentando vender por $%d", source, total))
    
    -- Verificar se todos os itens ainda têm o mesmo preço (anti-exploit)
    local verifiedTotal = 0
    for _, cartItem in ipairs(cart) do
        local currentPrice = currentPrices[cartItem.id]
        if not currentPrice then
            DebugPrint(string.format("ERRO: Item %s não encontrado na lista de preços", cartItem.id))
            cb(false, "Item inválido", {})
            return
        end
        verifiedTotal = verifiedTotal + (currentPrice * cartItem.quantity)
    end
    
    -- Adicionar margem de tolerância de 1% para diferenças de arredondamento
    if math.abs(verifiedTotal - total) > (total * 0.01) then
        DebugPrint(string.format("ALERTA: Divergência de preços detectada! Cliente: $%d | Servidor: $%d", 
            total, verifiedTotal))
        cb(false, "Preços mudaram, por favor atualize a página", {})
        return
    end
    
    -- Verificar e remover itens do inventário
    local soldItems = {}
    for _, cartItem in ipairs(cart) do
        local removed = exports.ox_inventory:RemoveItem(source, cartItem.id, cartItem.quantity)
        
        if not removed then
            DebugPrint(string.format("ERRO: Falha ao remover item %s x%d do player [%d]", 
                cartItem.id, cartItem.quantity, source))
            
            -- Reverter itens já removidos
            for _, soldItem in ipairs(soldItems) do
                exports.ox_inventory:AddItem(source, soldItem.id, soldItem.quantity)
            end
            
            cb(false, "Você não tem esses itens no inventário", {})
            return
        end
        
        DebugPrint(string.format("Item removido: %s x%d do player [%d]", 
            cartItem.id, cartItem.quantity, source))
        
        table.insert(soldItems, {
            id = cartItem.id,
            quantity = cartItem.quantity
        })
    end
    
    -- Adicionar dinheiro ao jogador
    if not Player.Functions.AddMoney('cash', total, "jewelry-shop-sale") then
        DebugPrint(string.format("ERRO: Falha ao adicionar dinheiro ao player [%d]", source))
        
        -- Reverter itens removidos
        for _, soldItem in ipairs(soldItems) do
            exports.ox_inventory:AddItem(source, soldItem.id, soldItem.quantity)
        end
        
        cb(false, "Erro ao processar pagamento", {})
        return
    end
    
    DebugPrint(string.format("Dinheiro adicionado: $%d ao player [%d]", total, source))
    DebugPrint(string.format("Venda finalizada com sucesso para player [%d]. Total: $%d | Itens: %d", 
        source, total, #soldItems))
    
    cb(true, Config.Lang.sellSuccess, soldItems)
end)

-- Comando para resetar preços (DEBUG)
if Config.Debug then
    QBCore.Commands.Add('resetprices', 'Resetar preços da joalheria (ADMIN)', {}, false, function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.PlayerData.job.name == 'admin' or QBCore.Functions.HasPermission(source, 'admin') then
            for _, item in ipairs(Config.Items) do
                currentPrices[item.id] = item.price
            end
            TriggerClientEvent('jewelry-shop:client:updatePrices', -1, currentPrices)
            TriggerClientEvent('QBCore:Notify', source, 'Preços resetados!', 'success')
            DebugPrint(string.format("Preços resetados por player [%d]", source))
        end
    end, 'admin')
    
    QBCore.Commands.Add('checkprices', 'Ver preços atuais da joalheria (ADMIN)', {}, false, function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.PlayerData.job.name == 'admin' or QBCore.Functions.HasPermission(source, 'admin') then
            print("^2========== PREÇOS ATUAIS ==========^7")
            for itemId, price in pairs(currentPrices) do
                print(string.format("^3%s^7: $%d", itemId, price))
            end
            print("^2====================================^7")
        end
    end, 'admin')
end