Config = {}

-- Debug mode (ativa prints detalhados)
Config.Debug = true

-- Tempo de flutuação de preços (em milissegundos) - 5 minutos = 300000ms
Config.PriceFluctuationTime = 300000

-- Percentual máximo de variação de preço (15% = 0.15)
Config.MaxPriceVariation = 0.15

-- Localização da loja
Config.ShopLocation = {
    coords = vector3(1731.73, 6396.55, 34.8), -- Vangelico Jewelry
    heading = 309.73,
    blip = {
        sprite = 617,
        color = 5,
        scale = 0.8,
        label = "Joalheria Premium"
    }
}

-- Configuração do NPC
-- IMPORTANTE: Se o NPC não spawnar, tente um destes modelos que SEMPRE funcionam:
-- "a_m_y_business_01" (Homem de negócios - MAIS CONFIÁVEL)
-- "mp_m_shopkeep_01" (Vendedor genérico)
-- "s_m_y_dealer_01" (Vendedor)
-- "cs_gurk" (Gurk)
-- "s_m_m_jewelsec_01" (Segurança joalheria - padrão, mas pode dar timeout)
Config.NPCModel = "a_m_y_business_01"  -- Modelo mais confiável que carrega rápido
Config.NPCCoords = vector4(1731.07, 6395.71, 34.78, 352.47)

-- Zona de interação ox_target
Config.TargetZone = {
    coords = vector3(1731.73, 6396.55, 34.8),
    size = vector3(2.0, 2.0, 2.0),
    rotation = 310.0,
    debug = false
}

-- Configuração de itens e preços base
Config.Items = {
    -- Diamantes (alto valor)
    {id = 'diamond', name = 'Diamante Bruto', price = 8500, category = 'minerals'},
    {id = 'diamond_earring', name = 'Brincos de Diamante (Ouro)', price = 18500, category = 'jewelry'},
    {id = 'diamond_earring_silver', name = 'Brincos de Diamante (Prata)', price = 15000, category = 'jewelry'},
    {id = 'diamond_necklace_silver', name = 'Colar de Diamante (Prata)', price = 18000, category = 'jewelry'},
    {id = 'diamond_necklace', name = 'Colar de Diamante (Ouro)', price = 22000, category = 'jewelry'},
    {id = 'diamond_ring', name = 'Anel de Diamante (Ouro)', price = 19500, category = 'jewelry'},
    {id = 'diamond_ring_silver', name = 'Anel de Diamante (Prata)', price = 16000, category = 'jewelry'},
    
    -- Esmeraldas (valor médio-alto)
    {id = 'emerald', name = 'Esmeralda Bruta', price = 6500, category = 'minerals'},
    {id = 'emerald_earring', name = 'Brincos de Esmeralda (Ouro)', price = 14500, category = 'jewelry'},
    {id = 'emerald_earring_silver', name = 'Brincos de Esmeralda (Prata)', price = 11500, category = 'jewelry'},
    {id = 'emerald_necklace', name = 'Colar de Esmeralda (Ouro)', price = 17000, category = 'jewelry'},
    {id = 'emerald_necklace_silver', name = 'Colar de Esmeralda (Prata)', price = 14000, category = 'jewelry'},
    {id = 'emerald_ring', name = 'Anel de Esmeralda (Ouro)', price = 15500, category = 'jewelry'},
    {id = 'emerald_ring_silver', name = 'Anel de Esmeralda (Prata)', price = 12500, category = 'jewelry'},
    
    -- Rubis (valor médio-alto)
    {id = 'ruby', name = 'Rubi Bruto', price = 7000, category = 'minerals'},
    {id = 'ruby_earring', name = 'Brincos de Rubi (Ouro)', price = 15500, category = 'jewelry'},
    {id = 'ruby_earring_silver', name = 'Brincos de Rubi (Prata)', price = 12500, category = 'jewelry'},
    {id = 'ruby_necklace', name = 'Colar de Rubi (Ouro)', price = 18500, category = 'jewelry'},
    {id = 'ruby_necklace_silver', name = 'Colar de Rubi (Prata)', price = 15000, category = 'jewelry'},
    {id = 'ruby_ring', name = 'Anel de Rubi (Ouro)', price = 16500, category = 'jewelry'},
    {id = 'ruby_ring_silver', name = 'Anel de Rubi (Prata)', price = 13500, category = 'jewelry'},
    
    -- Safiras (MAIS VALIOSAS - pedras preciosas premium)
    {id = 'sapphire', name = 'Safira Bruta', price = 9500, category = 'minerals'},
    {id = 'sapphire_earring', name = 'Brincos de Safira (Ouro)', price = 20000, category = 'jewelry'},
    {id = 'sapphire_earring_silver', name = 'Brincos de Safira (Prata)', price = 16500, category = 'jewelry'},
    {id = 'sapphire_necklace', name = 'Colar de Safira (Ouro)', price = 24000, category = 'jewelry'},
    {id = 'sapphire_necklace_silver', name = 'Colar de Safira (Prata)', price = 19500, category = 'jewelry'},
    {id = 'sapphire_ring', name = 'Anel de Safira (Ouro)', price = 21000, category = 'jewelry'},
    {id = 'sapphire_ring_silver', name = 'Anel de Safira (Prata)', price = 17500, category = 'jewelry'},
    
    -- Metais preciosos (valor baixo-médio)
    {id = 'gold_earring', name = 'Brincos de Ouro', price = 3500, category = 'metals'},
    {id = 'gold_ring', name = 'Anel de Ouro', price = 3200, category = 'metals'},
    {id = 'goldchain', name = 'Corrente de Ouro', price = 4500, category = 'metals'},
    {id = 'goldingot', name = 'Lingote de Ouro', price = 5500, category = 'metals'},
    {id = 'silver_earring', name = 'Brincos de Prata', price = 1800, category = 'metals'},
    {id = 'silver_ring', name = 'Anel de Prata', price = 1500, category = 'metals'},
    {id = 'silverchain', name = 'Corrente de Prata', price = 2200, category = 'metals'},
    {id = 'silverearring', name = 'Brinco de Prata Simples', price = 1600, category = 'metals'},
    {id = 'silveringot', name = 'Lingote de Prata', price = 2800, category = 'metals'},
}

-- Textos da interface
Config.Lang = {
    openShop = "Vender Joias",
    sellSuccess = "Itens vendidos com sucesso!",
    sellFailed = "Falha ao vender itens!",
    noItems = "Você não tem itens para vender!",
    itemSold = "Item vendido!",
}

-- Função de debug
function DebugPrint(...)
    if Config.Debug then
        print("^3[JEWELRY-SHOP DEBUG]^7", ...)
    end
end