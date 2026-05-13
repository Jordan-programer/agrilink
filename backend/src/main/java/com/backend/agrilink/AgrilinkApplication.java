package com.backend.agrilink;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class AgrilinkApplication {

	public static void main(String[] args) {
		SpringApplication.run(AgrilinkApplication.class, args);
	}

	@Bean
    public org.springframework.web.client.RestTemplate restTemplate() {
        return new org.springframework.web.client.RestTemplate();
    }

}
