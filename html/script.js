let cart = [];
let playerInventory = [];
let allItems = [];
let currentFilter = 'all';
let currentPrices = {};
let currentPriceFilter = 'all';

// Função para obter o ícone do item (agora retorna imagem)
function getItemIcon(itemId) {
    // No FiveM NUI, o caminho é relativo ao ui_page (index.html)
    // Como ui_page é 'html/index.html', assets/ já está no mesmo nível
    const imagePath = 'assets/' + itemId + '.png';
    
    // Debug: testar se a imagem existe
    const testImg = new Image();
    testImg.src = imagePath;
    testImg.onload = function() {
        console.log('[JEWELRY-SHOP NUI] ✅ Imagem carregou:', imagePath);
    };
    testImg.onerror = function() {
        console.error('[JEWELRY-SHOP NUI] ❌ Falha ao carregar:', imagePath);
        console.error('[JEWELRY-SHOP NUI] URL completa:', testImg.src);
    };
    
    return imagePath;
}

// Listener de mensagens da NUI
window.addEventListener('message', function(event) {
    const data = event.data;
    
    console.log('[JEWELRY-SHOP NUI] Mensagem recebida:', data);
    console.log('[JEWELRY-SHOP NUI] Base URL:', window.location.href);
    console.log('[JEWELRY-SHOP NUI] Origin:', window.location.origin);
    
    if (data.action === 'openShop') {
        console.log('[JEWELRY-SHOP NUI] Abrindo loja...');
        console.log('[JEWELRY-SHOP NUI] Itens do inventário:', data.inventory ? data.inventory.length : 0);
        console.log('[JEWELRY-SHOP NUI] Preços disponíveis:', data.prices ? Object.keys(data.prices).length : 0);
        
        playerInventory = data.inventory || [];
        currentPrices = data.prices || {};
        allItems = data.items || [];
        
        if (playerInventory.length === 0) {
            console.log('[JEWELRY-SHOP NUI] ⚠ Jogador não tem itens para vender');
        }
        
        renderProducts();
        renderPricesTable();
        $('#app').fadeIn(300);
        
        console.log('[JEWELRY-SHOP NUI] ✓ Loja aberta com sucesso!');
    }
    
    if (data.action === 'updatePrices') {
        console.log('[JEWELRY-SHOP NUI] Preços atualizados');
        updatePrices(data.prices);
    }
});

// Renderizar tabela de preços
function renderPricesTable() {
    const list = $('#pricesList');
    list.empty();
    
    // Filtrar itens por categoria
    const filteredItems = currentPriceFilter === 'all' 
        ? allItems 
        : allItems.filter(function(item) { return item.category === currentPriceFilter; });
    
    console.log('[JEWELRY-SHOP NUI] Renderizando tabela de preços:', filteredItems.length, 'itens (filtro:', currentPriceFilter + ')');
    
    // Ordenar por preço (maior para menor)
    filteredItems.sort(function(a, b) {
        const priceA = currentPrices[a.id] || a.price;
        const priceB = currentPrices[b.id] || b.price;
        return priceB - priceA;
    });
    
    // Identificar os 3 mais caros e 3 mais baratos
    const topExpensive = filteredItems.slice(0, 3);
    const topCheap = filteredItems.slice(-3).reverse();
    
    filteredItems.forEach(function(item, index) {
        const price = currentPrices[item.id] || item.price;
        const iconPath = getItemIcon(item.id);
        
        // Traduzir categoria
        let categoryName = item.category;
        if (item.category === 'minerals') categoryName = 'Minérios';
        else if (item.category === 'jewelry') categoryName = 'Joias';
        else if (item.category === 'metals') categoryName = 'Metais';
        
        // Verificar se é mais caro ou mais barato
        let badge = '';
        if (topExpensive.includes(item)) {
            badge = '<span class="price-badge expensive">💎 MAIS CARO</span>';
        } else if (topCheap.includes(item)) {
            badge = '<span class="price-badge cheap">💰 MAIS BARATO</span>';
        }
        
        const priceItem = $('<div class="price-item' + (badge ? ' has-badge' : '') + '">' +
            '<div class="price-item-icon">' +
                '<img src="' + iconPath + '" alt="' + item.name + '" onerror="this.style.display=\'none\'; this.parentElement.innerHTML=\'💎\';">' +
            '</div>' +
            '<div class="price-item-info">' +
                '<div class="price-item-name">' + item.name + badge + '</div>' +
                '<div class="price-item-category">' + categoryName + '</div>' +
            '</div>' +
            '<div class="price-item-value">$' + price.toLocaleString() + '</div>' +
        '</div>');
        
        list.append(priceItem);
    });
}

// Atualizar preços
function updatePrices(newPrices) {
    allItems = allItems.map(function(item) {
        return {
            id: item.id,
            name: item.name,
            category: item.category,
            price: newPrices[item.id] || item.price
        };
    });
    
    // Atualizar preços no carrinho
    cart = cart.map(function(item) {
        return {
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            maxAmount: item.maxAmount,
            price: newPrices[item.id] || item.price
        };
    });
    
    renderProducts();
    renderPricesTable();
    renderCart();
}

// Renderizar produtos (itens do inventário do jogador)
function renderProducts() {
    const grid = $('#productsGrid');
    grid.empty();
    
    // Filtrar itens do inventário que o jogador possui
    const inventoryItems = playerInventory.filter(function(invItem) {
        // Verificar se o item está na lista de itens aceitos
        const itemConfig = allItems.find(function(i) { return i.id === invItem.name; });
        if (!itemConfig) return false;
        
        // Aplicar filtro de categoria
        if (currentFilter !== 'all' && itemConfig.category !== currentFilter) return false;
        
        return true;
    });
    
    console.log('[JEWELRY-SHOP NUI] Renderizando', inventoryItems.length, 'itens do inventário (filtro:', currentFilter + ')');
    
    if (inventoryItems.length === 0) {
        grid.html('<div style="grid-column: 1/-1; text-align: center; color: rgba(203, 213, 225, 0.9); padding: 2rem;">Você não tem itens para vender nesta categoria</div>');
        return;
    }
    
    inventoryItems.forEach(function(invItem) {
        const itemConfig = allItems.find(function(i) { return i.id === invItem.name; });
        const price = currentPrices[invItem.name] || itemConfig.price;
        const iconPath = getItemIcon(invItem.name);
        
        const card = $('<div class="product-card" data-item-id="' + invItem.name + '">' +
            '<div class="product-icon">' +
                '<img src="' + iconPath + '" alt="' + itemConfig.name + '" onerror="console.error(\'[JEWELRY-SHOP NUI] Falha ao carregar imagem:\', this.src); this.style.display=\'none\'; this.nextElementSibling.style.display=\'block\';">' +
                '<span class="fallback-icon" style="display:none;">💎</span>' +
            '</div>' +
            '<div class="product-name">' + itemConfig.name + '</div>' +
            '<div class="product-stock">Você tem: ' + invItem.amount + '</div>' +
            '<div class="product-footer">' +
                '<span class="product-price">$' + price.toLocaleString() + '</span>' +
                '<span class="price-trend" data-trend-id="' + invItem.name + '"></span>' +
            '</div>' +
        '</div>');
        
        card.on('click', function() {
            addToCart(invItem.name, itemConfig.name, price, invItem.amount);
        });
        
        grid.append(card);
    });
}

// Adicionar item ao carrinho de venda
function addToCart(itemId, itemName, price, maxAmount) {
    console.log('[JEWELRY-SHOP NUI] Adicionando ao carrinho:', itemName);
    
    const existing = cart.find(function(i) { return i.id === itemId; });
    
    if (existing) {
        if (existing.quantity < maxAmount) {
            existing.quantity++;
            console.log('[JEWELRY-SHOP NUI] Item já existe, nova quantidade:', existing.quantity);
        } else {
            console.log('[JEWELRY-SHOP NUI] Quantidade máxima atingida:', maxAmount);
        }
    } else {
        cart.push({
            id: itemId,
            name: itemName,
            price: price,
            quantity: 1,
            maxAmount: maxAmount
        });
        console.log('[JEWELRY-SHOP NUI] Novo item adicionado ao carrinho');
    }
    
    renderCart();
}

// Remover item do carrinho
function removeFromCart(itemId) {
    console.log('[JEWELRY-SHOP NUI] Removendo do carrinho:', itemId);
    cart = cart.filter(function(i) { return i.id !== itemId; });
    renderCart();
}

// Atualizar quantidade
function updateQuantity(itemId, delta) {
    console.log('[JEWELRY-SHOP NUI] Atualizando quantidade:', itemId, 'delta:', delta);
    
    const item = cart.find(function(i) { return i.id === itemId; });
    if (item) {
        const newQty = item.quantity + delta;
        if (newQty >= 1 && newQty <= item.maxAmount) {
            item.quantity = newQty;
            renderCart();
        } else {
            console.log('[JEWELRY-SHOP NUI] Quantidade fora do limite:', newQty, 'Max:', item.maxAmount);
        }
    }
}

// Renderizar carrinho
function renderCart() {
    const container = $('#cartItems');
    const footer = $('#cartFooter');
    
    $('#cartCount').text(cart.length);
    
    if (cart.length === 0) {
        container.html('<p class="empty-cart">Selecione itens para vender</p>');
        footer.hide();
        console.log('[JEWELRY-SHOP NUI] Carrinho vazio');
        return;
    }
    
    container.empty();
    let total = 0;
    
    cart.forEach(function(item) {
        const itemTotal = item.price * item.quantity;
        total += itemTotal;
        
        const cartItem = $('<div class="cart-item">' +
            '<div class="cart-item-header">' +
                '<div class="cart-item-info">' +
                    '<div class="cart-item-name">' + item.name + '</div>' +
                    '<div class="cart-item-price">$' + item.price.toLocaleString() + ' cada</div>' +
                '</div>' +
                '<button class="remove-btn">✕</button>' +
            '</div>' +
            '<div class="cart-item-controls">' +
                '<button class="qty-btn qty-minus">-</button>' +
                '<span class="qty-display">' + item.quantity + '/' + item.maxAmount + '</span>' +
                '<button class="qty-btn qty-plus">+</button>' +
                '<span class="cart-item-total">$' + itemTotal.toLocaleString() + '</span>' +
            '</div>' +
        '</div>');
        
        cartItem.find('.remove-btn').on('click', function() { 
            removeFromCart(item.id); 
        });
        cartItem.find('.qty-minus').on('click', function() { 
            updateQuantity(item.id, -1); 
        });
        cartItem.find('.qty-plus').on('click', function() { 
            updateQuantity(item.id, 1); 
        });
        
        container.append(cartItem);
    });
    
    $('#cartTotal').text('$' + total.toLocaleString());
    footer.show();
    
    console.log('[JEWELRY-SHOP NUI] Carrinho renderizado. Total a receber: $' + total);
}

// Vender itens
function sellItems() {
    if (cart.length === 0) {
        console.log('[JEWELRY-SHOP NUI] Tentativa de venda com carrinho vazio');
        return;
    }
    
    const total = cart.reduce(function(sum, item) { 
        return sum + (item.price * item.quantity); 
    }, 0);
    
    console.log('[JEWELRY-SHOP NUI] ========================================');
    console.log('[JEWELRY-SHOP NUI] Vendendo itens');
    console.log('[JEWELRY-SHOP NUI] Total a receber: $' + total);
    console.log('[JEWELRY-SHOP NUI] Itens:', cart);
    console.log('[JEWELRY-SHOP NUI] ========================================');
    
    $.post('https://jewelry-shop/sellItems', JSON.stringify({
        cart: cart,
        total: total
    })).done(function(response) {
        console.log('[JEWELRY-SHOP NUI] Resposta do servidor:', response);
        
        if (response && response.success) {
            console.log('[JEWELRY-SHOP NUI] ✓ Venda aprovada pelo servidor');
            cart = [];
            
            // Atualizar inventário local
            response.soldItems.forEach(function(soldItem) {
                const invItem = playerInventory.find(function(i) { return i.name === soldItem.id; });
                if (invItem) {
                    invItem.amount -= soldItem.quantity;
                    if (invItem.amount <= 0) {
                        playerInventory = playerInventory.filter(function(i) { return i.name !== soldItem.id; });
                    }
                }
            });
            
            renderProducts();
            renderCart();
        } else {
            console.log('[JEWELRY-SHOP NUI] ✗ Venda recusada:', response ? response.message : 'Sem resposta');
        }
    }).fail(function(xhr, status, error) {
        console.error('[JEWELRY-SHOP NUI] ✗ ERRO na requisição:', status, error);
        console.error('[JEWELRY-SHOP NUI] XHR:', xhr);
    });
}

// Fechar loja
function closeShop() {
    console.log('[JEWELRY-SHOP NUI] Fechando loja...');
    
    // Fechar a interface primeiro
    $('#app').fadeOut(300);
    cart = [];
    console.log('[JEWELRY-SHOP NUI] ✓ Interface fechada');
    
    // Tentar notificar o cliente (pode falhar se já estiver fechado, é normal)
    $.post('https://jewelry-shop/closeShop', JSON.stringify({}))
        .done(function() {
            console.log('[JEWELRY-SHOP NUI] ✓ Callback closeShop executado');
        })
        .fail(function() {
            // Silencioso - é normal falhar quando ESC é pressionado
        });
}

// Event listeners
$(document).ready(function() {
    console.log('[JEWELRY-SHOP NUI] ========================================');
    console.log('[JEWELRY-SHOP NUI] Script NUI carregado e pronto!');
    console.log('[JEWELRY-SHOP NUI] jQuery versão:', $.fn.jquery);
    console.log('[JEWELRY-SHOP NUI] ========================================');
    
    // Filtros
    $('.filter-btn').on('click', function() {
        $('.filter-btn').removeClass('active');
        $(this).addClass('active');
        currentFilter = $(this).data('filter');
        
        console.log('[JEWELRY-SHOP NUI] Filtro alterado para:', currentFilter);
        renderProducts();
    });
    
    // Tabs
    $('.tab-btn').on('click', function() {
        const tab = $(this).data('tab');
        
        $('.tab-btn').removeClass('active');
        $(this).addClass('active');
        
        $('.tab-content').removeClass('active');
        if (tab === 'sell') {
            $('#sellTab').addClass('active');
        } else if (tab === 'prices') {
            $('#pricesTab').addClass('active');
        }
        
        console.log('[JEWELRY-SHOP NUI] Aba alterada para:', tab);
    });
    
    // Filtros de preço
    $('.price-filter-btn').on('click', function() {
        $('.price-filter-btn').removeClass('active');
        $(this).addClass('active');
        currentPriceFilter = $(this).data('filter');
        
        console.log('[JEWELRY-SHOP NUI] Filtro de preços alterado para:', currentPriceFilter);
        renderPricesTable();
    });
    
    // ESC para fechar
    $(document).on('keyup', function(e) {
        if (e.key === 'Escape') {
            console.log('[JEWELRY-SHOP NUI] ESC pressionado, fechando loja');
            closeShop();
        }
    });
    
    // Teste de funcionamento
    console.log('[JEWELRY-SHOP NUI] Event listeners registrados');
});

// Prevenir arrastar e soltar
document.addEventListener('dragstart', function(e) { e.preventDefault(); });
document.addEventListener('drop', function(e) { e.preventDefault(); });