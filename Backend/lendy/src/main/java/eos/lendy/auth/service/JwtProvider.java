package eos.lendy.auth.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtProvider {

    private final SecretKey key;
    private final long accessMinutes;

    public JwtProvider(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.accessMinutes}") long accessMinutes
    ){
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessMinutes = accessMinutes;
    }

    public String createAccessToken(Long userId){
        Instant now = Instant.now();
        Instant exp = now.plus(accessMinutes, ChronoUnit.MINUTES);

        return Jwts.builder()
                .subject(String.valueOf(userId))
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .claim("type", "access")
                .signWith(key)
                .compact();
    }

    public String createRefreshToken(){
        return UUID.randomUUID().toString() + UUID.randomUUID();
    }

    public Long parseUserId(String token) throws JwtException{
        Claims claims = Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        String type = claims.get("type", String.class);
        if(!"access".equals(type)){
            throw new JwtException("not an access token");
        }

        String sub = claims.getSubject();
        if(sub == null || sub.isBlank()){
            throw new JwtException("missing subject");
        }

        try{
            return Long.parseLong(sub);
        } catch (NumberFormatException e){
            throw new JwtException("invalid subject", e);
        }

    }
}
