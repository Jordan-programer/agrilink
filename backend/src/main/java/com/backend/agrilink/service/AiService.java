package com.backend.agrilink.service;

import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;

@Service
public class AiService {

    // ----------------------------------------------------
    // RIA02 - Recomendação de Preços ao Agricultor
    // ----------------------------------------------------
    public Map<String, Object> recommendPrice(String productName, String province) {
        // Base baseada em heurísticas simulando um modelo treinado
        double basePrice = getBasePriceForProduct(productName);
        double provinceMultiplier = getProvinceMultiplier(province);
        double seasonMultiplier = getSeasonMultiplier(LocalDate.now().getMonthValue());

        double recommendedPrice = basePrice * provinceMultiplier * seasonMultiplier;

        Map<String, Object> result = new HashMap<>();
        result.put("product", productName);
        result.put("province", province);
        result.put("recommendedPrice", Math.round(recommendedPrice));
        result.put("confidence", "85%");
        result.put("reason", "Ajustado pela sazonalidade atual e procura alta em " + province);
        return result;
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
        } else if (msg.contains("ola") || msg.contains("olá") || msg.contains("bom dia")) {
            reply = "Olá! Sou o Assistente IA da AgriLink. Como posso ajudar a otimizar o seu negócio agrícola hoje?";
        } else if (msg.contains("transporte") || msg.contains("frete")) {
            reply = "Para poupar no frete, recomendo ir à aba de Transportes e usar a nossa função 'Otimizar Rota com IA', que agrupa os seus produtos com os de outros agricultores da sua região.";
        } else if (msg.contains("chuva") || msg.contains("clima")) {
            reply = "A previsão climática indica chuva forte nas próximas duas semanas nas províncias do Centro (Huambo, Bié). Recomendamos proteger as colheitas mais sensíveis.";
        } else {
            reply = "Interessante! Como sou uma IA em fase de treino na AgriLink, ainda estou a aprender sobre esse tema. Pode perguntar-me sobre preços de tomate, dicas de transporte ou previsões climáticas.";
        }

        Map<String, Object> response = new HashMap<>();
        response.put("reply", reply);
        return response;
    }
}
