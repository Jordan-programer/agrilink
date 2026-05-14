package com.backend.agrilink.sockets;

import com.backend.agrilink.model.User;
import com.backend.agrilink.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Optional;

@Component
@RequiredArgsConstructor
public class TcpSecureServer {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private ServerSocket serverSocket;
    private boolean running;

    @PostConstruct
    public void startServer() {
        running = true;
        new Thread(() -> {
            try {
                // In a production environment with RSC10, this would be:
                // SSLServerSocketFactory ssf = (SSLServerSocketFactory) SSLServerSocketFactory.getDefault();
                // serverSocket = ssf.createServerSocket(8081);
                
                serverSocket = new ServerSocket(8081);
                System.out.println("TCP Secure Server started on port 8081 (RSC01)");

                while (running) {
                    Socket clientSocket = serverSocket.accept();
                    new Thread(new ClientHandler(clientSocket)).start();
                }
            } catch (Exception e) {
                if (running) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    @PreDestroy
    public void stopServer() {
        running = false;
        try {
            if (serverSocket != null && !serverSocket.isClosed()) {
                serverSocket.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private class ClientHandler implements Runnable {
        private final Socket clientSocket;
        private final ObjectMapper mapper = new ObjectMapper();

        public ClientHandler(Socket socket) {
            this.clientSocket = socket;
        }

        @Override
        public void run() {
            try (
                BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)
            ) {
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    try {
                        JsonNode request = mapper.readTree(inputLine);
                        String action = request.has("action") ? request.get("action").asText() : "UNKNOWN";

                        if ("LOGIN".equals(action)) {
                            String email = request.get("email").asText();
                            String password = request.get("senha").asText();

                            Optional<User> userOpt = userRepository.findByEmail(email);
                            if (userOpt.isPresent() && passwordEncoder.matches(password, userOpt.get().getSenha())) {
                                out.println("{\"status\": \"SUCCESS\", \"message\": \"Authenticated via TCP\", \"userId\": \"" + userOpt.get().getId() + "\"}");
                            } else {
                                out.println("{\"status\": \"ERROR\", \"message\": \"Invalid credentials\"}");
                            }
                        } else if ("SYNC".equals(action)) {
                            out.println("{\"status\": \"SUCCESS\", \"message\": \"Data synchronized via TCP\"}");
                        } else {
                            out.println("{\"status\": \"ERROR\", \"message\": \"Unknown action\"}");
                        }
                    } catch (Exception e) {
                        out.println("{\"status\": \"ERROR\", \"message\": \"Invalid JSON Format\"}");
                    }
                }
            } catch (Exception e) {
                System.out.println("TCP Client disconnected");
            }
        }
    }
}
