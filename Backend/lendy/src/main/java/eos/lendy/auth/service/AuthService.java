package eos.lendy.auth.service;

import eos.lendy.auth.dto.*;
import eos.lendy.auth.entity.RefreshTokenEntity;
import eos.lendy.auth.repository.RefreshTokenRepository;
import eos.lendy.user.dto.UserResponse;
import eos.lendy.user.entity.UserEntity;
import eos.lendy.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;
    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public UserResponse signUp(SignUpRequest request){
        String username = normalize(request.username());
        String rawPassword = request.password();

        if(username == null || username.isBlank()){
            throw new IllegalArgumentException("username is required");
        }
        if(rawPassword == null || rawPassword.isBlank()){
            throw new IllegalArgumentException("password is required");
        }
        if(userRepository.existsByUsername(username)){
            throw new IllegalArgumentException("username already exists");
        }

        String hash = passwordEncoder.encode(rawPassword);
        UserEntity saved = userRepository.save(
                UserEntity.builder()
                        .username(username)
                        .passwordHash(hash)
                        .createdAt(LocalDateTime.now())
                        .build()
        );

        return new UserResponse(saved.getId(), saved.getUsername(), saved.getCreatedAt());
    }

    @Transactional
    public LoginResponse login(LoginRequest request){
        String username = normalize(request.username());
        String rawPassword = request.password();
        UserEntity user = userRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("invalid username or password"));

        if(!passwordEncoder.matches(rawPassword, user.getPasswordHash())){
            throw new IllegalArgumentException("invalid username or password");
        }

        String access = jwtProvider.createAccessToken(user.getId());
        String refresh = jwtProvider.createRefreshToken();
        RefreshTokenEntity tokenEntity = RefreshTokenEntity.builder()
                .user(user)
                .tokenHash(sha256(refresh))
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusDays(14))
                .build();
        refreshTokenRepository.save(tokenEntity);

        return new LoginResponse(
                access,
                refresh,
                new UserResponse(user.getId(), user.getUsername(), user.getCreatedAt())
        );
    }

    @Transactional
    public RefreshResponse refresh(RefreshRequest request){
        String token = request == null ? null : request.refreshToken();
        if(token == null || token.isBlank()){
            throw new IllegalArgumentException("refreshToken is required");
        }

        String tokenHash = sha256(token);
        RefreshTokenEntity saved = refreshTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new IllegalArgumentException("invalid refreshToken"));

        if(!saved.isActive(LocalDateTime.now())){
            refreshTokenRepository.delete(saved);
            throw new IllegalArgumentException("refreshToken expired");
        }
        saved.touch(LocalDateTime.now());
        Long userId = saved.getUser().getId();
        String newAccess = jwtProvider.createAccessToken(userId);
        return new RefreshResponse(newAccess);
    }

    @Transactional
    public void logout(LogoutRequest request){
        String token = request == null ? null : request.refreshToken();
        if(token == null || token.isBlank()){
            return;
        }
        String tokenHash = sha256(token);
        refreshTokenRepository.findByTokenHash(tokenHash)
                .ifPresent(refreshTokenRepository::delete);
    }

    private String normalize(String s){
        return s== null ? null : s.trim();
    }

    private static String sha256(String raw){
        try{
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for(byte b : digest){
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e){
            throw new IllegalStateException("hashing failed", e);
        }
    }
}
