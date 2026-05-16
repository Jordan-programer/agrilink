package com.backend.agrilink.service;

import org.springframework.stereotype.Service;

import com.backend.agrilink.dto.OrderItemDTO;
import com.backend.agrilink.dto.OrderRequest;
import com.backend.agrilink.model.Order;
import com.backend.agrilink.model.OrderItem;
import com.backend.agrilink.model.StatusPedido;
import com.backend.agrilink.repository.OrderItemRepository;
import com.backend.agrilink.repository.OrderRepository;
import com.backend.agrilink.repository.ListingRepository;

import lombok.RequiredArgsConstructor;
import com.backend.agrilink.repository.ProductRepository;
import com.backend.agrilink.repository.UserRepository;
import com.backend.agrilink.dto.BuyerOrderResponseDTO;
import com.backend.agrilink.model.Product;
import com.backend.agrilink.model.User;
import com.backend.agrilink.model.PaymentStatus;
import com.backend.agrilink.model.Listing;
import com.backend.agrilink.dto.OrderItemResponseDTO;
import java.util.List;
import java.util.UUID;
import java.util.ArrayList;
import java.time.LocalDateTime;
import com.backend.agrilink.dto.TransportOrderResponseDTO;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository itemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final ListingRepository listingRepository;

    public Order createOrder(OrderRequest request) {

        Order order = new Order();
        order.setCompradorId(request.getCompradorId());
        order.setStatus(StatusPedido.PENDENTE);
        order.setTotal(0.0);

        Order savedOrder = orderRepository.save(order);

        double total = 0;

        for (OrderItemDTO itemDto : request.getItems()) {
            OrderItem item = new OrderItem();
            
            item.setPedidoId(savedOrder.getId());
            item.setProdutoId(itemDto.getProdutoId());
            item.setQuantidade(itemDto.getQuantidade());
            item.setPreco(itemDto.getPreco());

            itemRepository.save(item);

            total += itemDto.getPreco() * itemDto.getQuantidade();
        }

        savedOrder.setTotal(total);
        savedOrder.setComissaoPlataforma(total * 0.05); // 5% commission
        return orderRepository.save(savedOrder);

    }

    public Order findById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido não encontrado com o ID: " + id));
    }

    public List<BuyerOrderResponseDTO> getOrdersByComprador(UUID compradorId) {
        List<Order> orders = orderRepository.findByCompradorId(compradorId);
        List<BuyerOrderResponseDTO> response = new ArrayList<>();

        for (Order order : orders) {
            List<OrderItem> items = itemRepository.findByPedidoId(order.getId());
            if (items.isEmpty()) continue;
            
            OrderItem firstItem = items.get(0);
            Product product = productRepository.findById(firstItem.getProdutoId()).orElse(null);
            User seller = order.getAgricultorId() != null ? userRepository.findById(order.getAgricultorId()).orElse(null) : null;
            
            BuyerOrderResponseDTO dto = new BuyerOrderResponseDTO();
            dto.setId("PED-" + order.getId());
            dto.setProductName(product != null ? product.getNome() : "Desconhecido");
            dto.setCategory(product != null && product.getCategoriaId() != null ? product.getCategoriaId().name() : "Geral");
            dto.setSellerName(seller != null ? seller.getNome() : "Desconhecido");
            dto.setSellerProvince(seller != null && seller.getProvincia() != null ? seller.getProvincia().name() : "Desconhecido");
            dto.setTotalAoa(order.getTotal());
            dto.setQuantity(firstItem.getQuantidade());
            dto.setUnit("kg");
            dto.setStatus(order.getStatus().name().toLowerCase());
            dto.setDeliveryDate(order.getDeliveryDate() != null ? order.getDeliveryDate().toString() : LocalDateTime.now().plusDays(3).toString());
            dto.setPlacedAt(order.getCreatedAt() != null ? order.getCreatedAt().toString() : LocalDateTime.now().toString());
            dto.setComprovativoBase64(order.getComprovativoBase64());

            List<OrderItemResponseDTO> itemDtos = new ArrayList<>();
            for (OrderItem item : items) {
                Product p = productRepository.findById(item.getProdutoId()).orElse(null);
                itemDtos.add(OrderItemResponseDTO.builder()
                        .productName(p != null ? p.getNome() : "Desconhecido")
                        .quantity(item.getQuantidade())
                        .price(item.getPreco())
                        .build());
            }
            dto.setItems(itemDtos);

            response.add(dto);
        }

        return response;
    }

    public List<BuyerOrderResponseDTO> findAllOrders() {
        List<Order> orders = orderRepository.findAll();
        List<BuyerOrderResponseDTO> response = new ArrayList<>();

        for (Order order : orders) {
            List<OrderItem> items = itemRepository.findByPedidoId(order.getId());
            if (items.isEmpty()) continue;
            
            OrderItem firstItem = items.get(0);
            Product product = productRepository.findById(firstItem.getProdutoId()).orElse(null);
            User seller = order.getAgricultorId() != null ? userRepository.findById(order.getAgricultorId()).orElse(null) : null;
            
            BuyerOrderResponseDTO dto = new BuyerOrderResponseDTO();
            dto.setId("PED-" + order.getId());
            dto.setProductName(product != null ? product.getNome() : "Desconhecido");
            dto.setCategory(product != null && product.getCategoriaId() != null ? product.getCategoriaId().name() : "Geral");
            dto.setSellerName(seller != null ? seller.getNome() : "Desconhecido");
            dto.setSellerProvince(seller != null && seller.getProvincia() != null ? seller.getProvincia().name() : "Desconhecido");
            dto.setTotalAoa(order.getTotal());
            dto.setQuantity(firstItem.getQuantidade());
            dto.setUnit("kg");
            dto.setStatus(order.getStatus().name().toLowerCase());
            dto.setDeliveryDate(order.getDeliveryDate() != null ? order.getDeliveryDate().toString() : LocalDateTime.now().plusDays(3).toString());
            dto.setPlacedAt(order.getCreatedAt() != null ? order.getCreatedAt().toString() : LocalDateTime.now().toString());
            dto.setComprovativoBase64(order.getComprovativoBase64());

            List<OrderItemResponseDTO> itemDtos = new ArrayList<>();
            for (OrderItem item : items) {
                Product p = productRepository.findById(item.getProdutoId()).orElse(null);
                itemDtos.add(OrderItemResponseDTO.builder()
                        .productName(p != null ? p.getNome() : "Desconhecido")
                        .quantity(item.getQuantidade())
                        .price(item.getPreco())
                        .build());
            }
            dto.setItems(itemDtos);

            response.add(dto);
        }

        return response;
    }

    public List<BuyerOrderResponseDTO> getOrdersByFarmer(UUID farmerId) {
        // 1. Find all listings of the farmer
        List<Listing> listings = listingRepository.findByAgricultorId(farmerId);
        List<Long> productIds = listings.stream().map(Listing::getProductId).toList();

        // 2. Find all orders
        List<Order> orders = orderRepository.findAll();
        List<BuyerOrderResponseDTO> response = new ArrayList<>();

        for (Order order : orders) {
            List<OrderItem> items = itemRepository.findByPedidoId(order.getId());
            if (items.isEmpty()) continue;

            // Filter items belonging to this farmer
            List<OrderItem> farmerItems = items.stream()
                    .filter(item -> productIds.contains(item.getProdutoId()))
                    .toList();

            if (farmerItems.isEmpty()) continue; // This order doesn't have products from this farmer

            // Calculate total for this farmer
            Double totalFarmer = farmerItems.stream()
                    .mapToDouble(item -> item.getPreco() * item.getQuantidade())
                    .sum();

            OrderItem firstItem = farmerItems.get(0);
            Product product = productRepository.findById(firstItem.getProdutoId()).orElse(null);
            User seller = userRepository.findById(farmerId).orElse(null);

            BuyerOrderResponseDTO dto = new BuyerOrderResponseDTO();
            dto.setId("PED-" + order.getId());
            dto.setProductName(product != null ? product.getNome() : "Desconhecido");
            dto.setCategory(product != null && product.getCategoriaId() != null ? product.getCategoriaId().name() : "Geral");
            dto.setSellerName(seller != null ? seller.getNome() : "Desconhecido");
            dto.setSellerProvince(seller != null && seller.getProvincia() != null ? seller.getProvincia().name() : "Desconhecido");
            dto.setTotalAoa(totalFarmer); // Total just for this farmer!
            dto.setQuantity(firstItem.getQuantidade());
            dto.setUnit("kg");
            dto.setStatus(order.getStatus().name().toLowerCase());
            dto.setDeliveryDate(order.getDeliveryDate() != null ? order.getDeliveryDate().toString() : LocalDateTime.now().plusDays(3).toString());
            dto.setPlacedAt(order.getCreatedAt() != null ? order.getCreatedAt().toString() : LocalDateTime.now().toString());
            dto.setComprovativoBase64(order.getComprovativoBase64());

            List<OrderItemResponseDTO> itemDtos = new ArrayList<>();
            for (OrderItem item : farmerItems) {
                Product p = productRepository.findById(item.getProdutoId()).orElse(null);
                itemDtos.add(OrderItemResponseDTO.builder()
                        .productName(p != null ? p.getNome() : "Desconhecido")
                        .quantity(item.getQuantidade())
                        .price(item.getPreco())
                        .build());
            }
            dto.setItems(itemDtos);

            response.add(dto);
        }

        return response;
    }

    public Order cancelOrder(Long id) {
        Order order = findById(id);
        order.setStatus(StatusPedido.CANCELADO);
        return orderRepository.save(order);
    }

    private TransportOrderResponseDTO mapToTransportDTO(Order order) {
        List<OrderItem> items = itemRepository.findByPedidoId(order.getId());
        OrderItem firstItem = items.isEmpty() ? null : items.get(0);
        Product product = firstItem != null ? productRepository.findById(firstItem.getProdutoId()).orElse(null) : null;
        User seller = order.getAgricultorId() != null ? userRepository.findById(order.getAgricultorId()).orElse(null) : null;
        User buyer = order.getCompradorId() != null ? userRepository.findById(order.getCompradorId()).orElse(null) : null;

        int totalWeight = items.stream().mapToInt(OrderItem::getQuantidade).sum();
        double payout = totalWeight * 50.0; // 50 AOA per kg as an example payout

        return TransportOrderResponseDTO.builder()
                .id("FRETE-" + order.getId())
                .numericId(order.getId())
                .productName(product != null ? product.getNome() : "Carga Mista")
                .farmerName(seller != null ? seller.getNome() : "Desconhecido")
                .pickupProvince(seller != null && seller.getProvincia() != null ? seller.getProvincia().name() : "Desconhecido")
                .buyerName(buyer != null ? buyer.getNome() : "Desconhecido")
                .dropoffProvince(buyer != null && buyer.getProvincia() != null ? buyer.getProvincia().name() : "Desconhecido")
                .totalWeight(totalWeight)
                .transportPayout(payout)
                .statusTransporte(order.getStatusTransporte() != null ? order.getStatusTransporte().name() : "DISPONIVEL")
                .placedAt(order.getCreatedAt() != null ? order.getCreatedAt().toString() : LocalDateTime.now().toString())
                .build();
    }

    public List<TransportOrderResponseDTO> getAvailableTransports() {
        List<Order> orders = orderRepository.findByStatusTransporte(com.backend.agrilink.model.StatusTransporte.DISPONIVEL);
        List<TransportOrderResponseDTO> response = new ArrayList<>();
        for (Order order : orders) {
            response.add(mapToTransportDTO(order));
        }
        return response;
    }

    public List<TransportOrderResponseDTO> getAllTransports() {
        List<Order> orders = orderRepository.findAll();
        List<TransportOrderResponseDTO> response = new ArrayList<>();
        for (Order order : orders) {
            if (order.getStatusTransporte() != null) {
                response.add(mapToTransportDTO(order));
            }
        }
        return response;
    }

    public List<TransportOrderResponseDTO> getTransporterOrders(UUID transportadorId) {
        List<Order> orders = orderRepository.findByTransportadorId(transportadorId);
        List<TransportOrderResponseDTO> response = new ArrayList<>();
        for (Order order : orders) {
            response.add(mapToTransportDTO(order));
        }
        return response;
    }

    public Order acceptTransport(Long id, UUID transportadorId) {
        Order order = findById(id);
        if (order.getStatusTransporte() != com.backend.agrilink.model.StatusTransporte.DISPONIVEL) {
            throw new RuntimeException("Este frete já não está disponível");
        }
        order.setTransportadorId(transportadorId);
        order.setStatusTransporte(com.backend.agrilink.model.StatusTransporte.EM_TRANSITO);
        return orderRepository.save(order);
    }

    public Order uploadComprovativo(Long id, String base64) {
        Order order = findById(id);
        order.setComprovativoBase64(base64);
        return orderRepository.save(order);
    }

    public Order approvePayment(Long id) {
        Order order = findById(id);
        order.setPaymentStatus(PaymentStatus.PAGO);
        order.setStatus(StatusPedido.APROVADO);
        return orderRepository.save(order);
    }
}