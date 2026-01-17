# 💎 Jewelry Shop - Sistema de Joalheria Premium

Um sistema completo de joalheria para servidores FiveM com QBCore, desenvolvido com interface moderna e sistema de preços dinâmicos.

## 🚀 Características Principais

### ⚡ Sistema de Preços Dinâmicos
- **Flutuação automática de preços** a cada 5 minutos
- **Variação de até 15%** nos valores base dos itens
- **Sistema anti-exploit** com verificação de preços no servidor
- **Atualização em tempo real** para todos os jogadores conectados

### 🎨 Interface Moderna (NUI)
- **Design responsivo** com gradientes e animações suaves
- **Sistema de abas** para venda e consulta de preços
- **Filtros por categoria** (Minérios, Joias, Metais)
- **Carrinho de compras** interativo com controle de quantidade
- **Imagens personalizadas** para cada item
- **Indicadores visuais** para itens mais caros e baratos

### 🛡️ Sistema de Segurança
- **Verificação de inventário** em tempo real
- **Validação de preços** no servidor
- **Proteção contra exploits** de duplicação
- **Sistema de rollback** em caso de falha na transação

### 🎯 Funcionalidades Avançadas
- **NPC inteligente** com spawn automático e configuração robusta
- **Sistema de debug** completo para desenvolvimento
- **Comandos administrativos** para gerenciamento
- **Integração completa** com ox_inventory e ox_target
- **Suporte a múltiplas categorias** de itens

## 📦 Dependências

- **qb-core** - Framework base
- **ox_inventory** - Sistema de inventário
- **ox_target** - Sistema de interação

## 🔧 Instalação

1. **Baixe e extraia** o recurso na pasta `resources`
2. **Configure** as coordenadas no `config.lua` se necessário
3. **Adicione** ao `server.cfg`:
   ```
   ensure jewelry-shop
   ```
4. **Reinicie** o servidor

## ⚙️ Configuração

### 📍 Localização da Loja
```lua
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
```

### 💰 Sistema de Preços
```lua
Config.PriceFluctuationTime = 300000  -- 5 minutos
Config.MaxPriceVariation = 0.15       -- 15% de variação
```

### 🤖 Configuração do NPC
```lua
Config.NPCModel = "a_m_y_business_01"  -- Modelo confiável
Config.NPCCoords = vector4(1731.07, 6395.71, 34.78, 352.47)
```

## 💎 Itens Suportados

### 🔮 Pedras Preciosas
- **Diamantes** - Valor mais alto (até $22.000)
- **Safiras** - Premium (até $24.000)
- **Esmeraldas** - Valor médio-alto (até $17.000)
- **Rubis** - Valor médio-alto (até $18.500)

### 💍 Joias Elaboradas
- **Anéis, Brincos e Colares** em ouro e prata
- **Variações por metal** (ouro mais valioso que prata)
- **Diferentes designs** para cada pedra preciosa

### 🥇 Metais Preciosos
- **Ouro** - Lingotes, correntes, anéis e brincos
- **Prata** - Lingotes, correntes, anéis e brincos
- **Valores diferenciados** por tipo de item

## 🎮 Como Usar

### Para Jogadores
1. **Vá até a Vangelico Jewelry** (marcada no mapa)
2. **Interaja com o NPC** usando ox_target
3. **Selecione os itens** que deseja vender
4. **Ajuste as quantidades** no carrinho
5. **Confirme a venda** e receba o dinheiro

### Para Administradores
```
/resetprices  - Resetar preços para valores base
/checkprices  - Ver preços atuais no console
```

### Comandos de Debug (se Config.Debug = true)
```
/spawnjewelrynpc  - Recriar o NPC
/checkjewelrynpc  - Verificar status do NPC
/testjewelryui    - Testar interface diretamente
/tpjewelry        - Teleportar para a joalheria
```

## 🔍 Sistema de Debug

O script inclui um sistema de debug completo que registra:
- **Spawn e configuração do NPC**
- **Carregamento de modelos**
- **Interações dos jogadores**
- **Transações de venda**
- **Atualizações de preços**
- **Erros e falhas**

## 🎨 Interface Visual

### Características da UI
- **Design moderno** com tema escuro e dourado
- **Animações suaves** e transições fluidas
- **Responsividade** para diferentes resoluções
- **Feedback visual** para todas as ações
- **Sistema de badges** para destacar itens especiais

### Funcionalidades da Interface
- **Filtros inteligentes** por categoria
- **Busca visual** com imagens dos itens
- **Carrinho interativo** com controle total
- **Tabela de preços** em tempo real
- **Indicadores de tendência** de preços

## 🛠️ Estrutura Técnica

### Arquivos Principais
- `fxmanifest.lua` - Manifesto do recurso
- `config.lua` - Configurações centralizadas
- `client/main.lua` - Lógica do cliente
- `server/main.lua` - Lógica do servidor
- `html/` - Interface NUI completa

### Tecnologias Utilizadas
- **Lua** - Lógica do servidor e cliente
- **HTML5/CSS3** - Interface moderna
- **JavaScript/jQuery** - Interatividade
- **NUI** - Integração com FiveM

## 📈 Performance

- **Otimizado** para múltiplos jogadores simultâneos
- **Baixo uso de recursos** do servidor
- **Cache inteligente** de preços e inventário
- **Threads eficientes** para atualizações automáticas

## 🔒 Segurança

- **Validação dupla** de transações
- **Proteção contra exploits** de preços
- **Verificação de inventário** em tempo real
- **Sistema de rollback** automático

## 📝 Changelog

### Versão 1.0.0
- ✅ Sistema completo de venda de joias
- ✅ Interface NUI moderna e responsiva
- ✅ Preços dinâmicos com flutuação automática
- ✅ Integração completa com QBCore e ox_inventory
- ✅ Sistema de debug avançado
- ✅ NPC inteligente com spawn robusto
- ✅ Suporte a 40+ itens diferentes
- ✅ Sistema de categorização avançado

## 🤝 Suporte

Para suporte técnico ou dúvidas sobre implementação, consulte:
- Logs de debug no console F8
- Arquivo de configuração `config.lua`
- Comandos de debug disponíveis

---

**Desenvolvido com ❤️ para a comunidade FiveM**

*Sistema profissional de joalheria com foco em performance, segurança e experiência do usuário.*