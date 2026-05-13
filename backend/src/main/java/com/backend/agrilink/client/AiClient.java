package com.backend.agrilink.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;


@Service
public class AiClient {

    @Value("${ai.service.url}")
    private String aiUrl;

    private final RestTemplate restTemplate;

    public AiClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public Object preverPreco(Object req) {
        return restTemplate.postForObject(
            aiUrl + "api/preco/prever",
            req,
            Object.class
        );
    }
}
