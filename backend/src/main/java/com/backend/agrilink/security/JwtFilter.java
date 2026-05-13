package com.backend.agrilink.security;

import java.io.IOException;
import java.util.List;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor; // Usaremos isso para as Roles (Perfis) depois

@Component
@RequiredArgsConstructor
public class JwtFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getServletPath();
        return path.startsWith("/auth/");
}


    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        // 1. Verifica se o cabeçalho existe e começa com "Bearer "
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        // 2. Valida o token
        if (jwtService.validateToken(token)) {
            // 3. Extrai a identificação do usuário (no seu caso, o telefone)
            String telefone = jwtService.extractTelefone(token);

            // 4. Verifica se já não existe uma autenticação no contexto atual
            if (telefone != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                
                // 5. Cria o objeto de autenticação do Spring (Ainda sem as roles específicas)
                String tipo = jwtService.extractTipo(token);

                UsernamePasswordAuthenticationToken authToken =
                    new UsernamePasswordAuthenticationToken(
                        telefone,
                        null,
                        List.of(new SimpleGrantedAuthority("TIPO_" + tipo.toUpperCase()))
                    );
                
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                
                // 6. Finalmente, avisa ao Spring: "Este usuário está autenticado!"
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return; // Bloqueia a requisição se o token for inválido
        }

        filterChain.doFilter(request, response);
    }
}