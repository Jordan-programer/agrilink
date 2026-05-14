package com.backend.agrilink.sockets;

import com.backend.agrilink.model.Listing;
import com.backend.agrilink.repository.ListingRepository;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.List;

@Component
@RequiredArgsConstructor
public class UdpPriceServer {

    private final ListingRepository listingRepository;
    private DatagramSocket socket;
    private boolean running;

    @PostConstruct
    public void startServer() {
        running = true;
        new Thread(() -> {
            try {
                socket = new DatagramSocket(9090);
                System.out.println("UDP Server started on port 9090 (RSC06)");

                byte[] receiveData = new byte[1024];

                while (running) {
                    DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
                    socket.receive(receivePacket);
                    
                    String message = new String(receivePacket.getData(), 0, receivePacket.getLength());
                    
                    if (message.trim().equals("GET_PRICES")) {
                        // Resposta com cotações
                        String jsonResponse = getMarketPricesJson();
                        byte[] sendData = jsonResponse.getBytes();
                        
                        InetAddress IPAddress = receivePacket.getAddress();
                        int port = receivePacket.getPort();
                        
                        DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, IPAddress, port);
                        socket.send(sendPacket);
                    }
                }
            } catch (Exception e) {
                if (running) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private String getMarketPricesJson() {
        // Para simplificar, buscamos todas as listagens ou uma estatística rápida.
        // Em produção com IA, a IA analisaria estes preços e geraria a média.
        List<Listing> listings = listingRepository.findAll();
        
        if(listings.isEmpty()) {
            return "{\"avgPrice\": 0, \"trend\": \"N/A\"}";
        }

        double total = 0;
        for (Listing l : listings) {
            total += l.getPreco();
        }
        double avg = total / listings.size();

        // O UDP é desenhado para enviar JSON muito leve e rápido (RSC12)
        return String.format("{\"avgPrice\": %.2f, \"trend\": \"up\", \"totalListings\": %d}", avg, listings.size());
    }

    @PreDestroy
    public void stopServer() {
        running = false;
        if (socket != null && !socket.isClosed()) {
            socket.close();
        }
    }
}
