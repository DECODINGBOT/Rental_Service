package eos.lendy.message.websocket;

import eos.lendy.auth.service.JwtProvider;
import eos.lendy.global.common.AuthUserPrincipal;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.List;

@Component
@RequiredArgsConstructor
public class StompAuthChannelInterceptor implements ChannelInterceptor {

    private final JwtProvider jwtProvider;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if (accessor == null) return message;

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            String bearer = resolveBearer(accessor);
            if (!StringUtils.hasText(bearer)) {
                throw new JwtException("Missing Authorization header for STOMP CONNECT");
            }

            String token = bearer.substring(7).trim();
            Long userId = jwtProvider.parseUserId(token);

            AuthUserPrincipal principal = new AuthUserPrincipal(userId);
            var auth = new UsernamePasswordAuthenticationToken(
                    principal,
                    null,
                    List.of(new SimpleGrantedAuthority("ROLE_USER"))
            );

            accessor.setUser(auth);
        }

        return message;
    }

    private String resolveBearer(StompHeaderAccessor accessor) {
        List<String> headers = accessor.getNativeHeader("Authorization");
        if (headers == null || headers.isEmpty()) return null;

        String raw = headers.get(0);
        if (!StringUtils.hasText(raw)) return null;
        if (!raw.startsWith("Bearer ")) return null;

        return raw;
    }
}
