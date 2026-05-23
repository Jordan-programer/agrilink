package com.backend.agrilink.service;

import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
public class AiService {

    // ----------------------------------------------------
    // RIA02 - Recomendação de Preços ao Agricultor
    // ----------------------------------------------------
    public Map<String, Object> recommendPrice(String productName, String province, String unit) {
        double basePrice = getBasePriceForProduct(productName);
        double provinceMultiplier = getProvinceMultiplier(province);
        double seasonMultiplier = getSeasonMultiplier(LocalDate.now().getMonthValue());
        double unitMultiplier = getUnitMultiplier(unit);

        double recommendedPrice = basePrice * provinceMultiplier * seasonMultiplier * unitMultiplier;

        Map<String, Object> result = new HashMap<>();
        result.put("product", productName);
        result.put("province", province);
        result.put("unit", unit);
        result.put("recommendedPrice", Math.round(recommendedPrice));
        result.put("confidence", "92%");
        result.put("reason", "Ajustado para a unidade " + unit + ", sazonalidade atual e procura em " + province);
        return result;
    }

    private double getUnitMultiplier(String unit) {
        if (unit == null) return 1.0;
        switch (unit.toUpperCase()) {
            case "TONELADA": return 1000.0;
            case "SACO": return 50.0;     // Saco de 50kg
            case "CAIXA": return 20.0;    // Caixa de 20kg
            case "UNIDADE": return 0.2;   // Fração aproximada
            case "LITRO": return 1.0;
            case "KG":
            default: return 1.0;
        }
    }

    private double getBasePriceForProduct(String product) {
        if (product == null) return 500.0;
        String p = product.toLowerCase();
        if (p.contains("tomate")) return 350.0;
        if (p.contains("mandioca")) return 200.0;
        if (p.contains("milho")) return 150.0;
        if (p.contains("feijao")) return 800.0;
        return 500.0;
    }

    private double getProvinceMultiplier(String province) {
        if (province == null) return 1.0;
        if (province.equalsIgnoreCase("Luanda")) return 1.3; // Alta procura
        if (province.equalsIgnoreCase("Huambo")) return 0.8; // Alta produção
        if (province.equalsIgnoreCase("Benguela")) return 1.1; 
        return 1.0;
    }

    private double getSeasonMultiplier(int month) {
        // Simula sazonalidade. Ex: no inverno há menos produção, preço sobe.
        if (month >= 5 && month <= 8) return 1.15; // Cacimbo
        return 1.0; // Normal
    }

    // ----------------------------------------------------
    // RIA04 - Otimização de Rotas de Transporte
    // ----------------------------------------------------
    public Map<String, Object> optimizeRoutes(String province) {
        Map<String, Object> response = new HashMap<>();
        
        List<Map<String, Object>> clusters = new ArrayList<>();
        
        // Simulação de agrupamento de cargas por IA (Clustering K-Means simulado)
        Map<String, Object> cluster1 = new HashMap<>();
        cluster1.put("routeId", "RT-001");
        cluster1.put("pickupZone", province + " - Zona Norte");
        cluster1.put("deliveryZone", "Luanda - Mercado 30");
        cluster1.put("totalWeightKg", 2500);
        cluster1.put("fuelSavedPercentage", 18);
        cluster1.put("bundledOrders", Arrays.asList(101, 102, 105));

        Map<String, Object> cluster2 = new HashMap<>();
        cluster2.put("routeId", "RT-002");
        cluster2.put("pickupZone", province + " - Zona Sul");
        cluster2.put("deliveryZone", "Luanda - Kilamba");
        cluster2.put("totalWeightKg", 1800);
        cluster2.put("fuelSavedPercentage", 12);
        cluster2.put("bundledOrders", Arrays.asList(108, 109));

        clusters.add(cluster1);
        clusters.add(cluster2);

        response.put("province", province);
        response.put("optimizedRoutes", clusters);
        response.put("aiMessage", "Rotas agrupadas com sucesso. Economia estimada de combustível: 15%.");
        return response;
    }

    // ----------------------------------------------------
    // RIA06 - Assistente Virtual (Chatbot)
    // ----------------------------------------------------
    public Map<String, Object> chat(String message) {
        String msg = message.toLowerCase();
        String reply;

        if (msg.contains("preço") && msg.contains("tomate")) {
            reply = "De acordo com os nossos dados preditivos, o Tomate em Luanda está a ser vendido em média a 450 AOA/kg. Se estiver no Huambo, recomendo vender a 300 AOA/kg devido à alta oferta.";
        } else if (msg.contains("ola") || msg.contains("olá") || msg.contains("bom dia") || msg.contains("boa tarde")) {
            reply = "Olá! Sou o Assistente Virtual Inteligente da AgriLink. Como posso ajudar a otimizar as suas operações ou o seu negócio agrícola hoje?";
        } else if (msg.contains("transporte") || msg.contains("frete") || msg.contains("logistica") || msg.contains("logística") || msg.contains("rastrear") || msg.contains("rastreamento")) {
            reply = "Os transportadores cadastrados visualizam ofertas de frete na aba 'Logística'. A nossa IA de Otimização de Rotas agrupa mercadorias da mesma região para economizar até 18% de combustível. Além disso, compradores e agricultores podem acompanhar o status e o percurso do envio em tempo real diretamente na aba 'Rastreamento'!";
        } else if (msg.contains("chuva") || msg.contains("clima") || msg.contains("tempo") || msg.contains("previsão")) {
            reply = "A previsão climática indica chuvas fortes nas próximas duas semanas nas províncias do Centro (Huambo, Bié, Benguela). Recomendamos proteger as colheitas mais sensíveis e programar os fretes com antecedência para evitar atrasos nas vias.";
        } else if (msg.contains("sobre") || msg.contains("o que é") || msg.contains("funcionamento") || msg.contains("agrilink") || msg.contains("plataforma")) {
            reply = "A AgriLink é uma plataforma inovadora criada em Angola para ligar diretamente Agricultores, Compradores (Grossistas, Retalhistas e Consumidores) e Transportadores. O nosso objetivo é reduzir custos de intermediários, garantir preços justos usando Inteligência Artificial de recomendação e otimizar toda a logística de distribuição nacional.";
        } else if (msg.contains("publicar") || msg.contains("vender") || msg.contains("anunciar") || msg.contains("cadastrar produto") || msg.contains("postar")) {
            reply = "Para publicar um produto, faça login como Agricultor, aceda à aba 'Mercado' e clique no botão 'Publicar'. Selecione o produto desejado, insira a quantidade e a província de origem. Pode também clicar no botão 'Inteligência Artificial' com o ícone de estrelas para receber automaticamente uma sugestão de preço ideal calculada em Kwanzas (AOA) com base na unidade de venda e na procura real!";
        } else if (msg.contains("pagamento") || msg.contains("pagar") || msg.contains("comprovativo") || msg.contains("multicaixa") || msg.contains("express")) {
            reply = "O AgriLink suporta pagamentos seguros e práticos. Os compradores podem efetuar pagamentos via Multicaixa Express ou por Transferência Bancária direta (fazendo o upload do comprovativo para validação do Administrador). Os fundos são mantidos de forma segura e libertados para o agricultor assim que o transportador confirmar a recolha e entrega da carga.";
        } else if (msg.contains("plano") || msg.contains("subscrição") || msg.contains("premium") || msg.contains("ouro") || msg.contains("prata")) {
            reply = "Os agricultores podem aderir a planos de subscrição na aba de Perfil (Básico, Prata, Ouro e Premium). O plano Premium oferece o destaque automático de todos os seus produtos no topo das buscas dos compradores, acesso ilimitado a previsões climáticas detalhadas e sugestões de preços avançadas via IA!";
        } else if (msg.contains("pedido") || msg.contains("comprar") || msg.contains("encomenda") || msg.contains("carrinho")) {
            reply = "Para efetuar compras, faça login como Comprador, adicione os produtos desejados ao Carrinho, selecione a quantidade, escolha um dos transportadores disponíveis para fazer o frete e finalize a encomenda com o método de pagamento preferido. O progresso do envio poderá ser acompanhado na aba 'Rastreamento'.";
        } else if (msg.contains("segurança") || msg.contains("confiável") || msg.contains("garantia") || msg.contains("fraude")) {
            reply = "Garantimos total segurança em cada transação! Todos os perfis de agricultores e transportadores passam por uma verificação rigorosa antes de operar. Os pagamentos por transferência bancária passam por validação administrativa humana antes de qualquer mercadoria ser liberada para recolha, eliminando riscos de fraudes.";
        } else {
            reply = "Interessante! Como sou o assistente IA da AgriLink, ainda estou a aprender mais tópicos. Pode perguntar-me sobre: 'Como funciona o AgriLink?', 'Como publicar produtos?', 'Preço de tomates', 'Métodos de pagamento', 'Planos Premium', 'Dicas de transporte e frete' ou 'Previsão do tempo'.";
        }

        Map<String, Object> response = new HashMap<>();
        response.put("reply", reply);
        return response;
    }
}
