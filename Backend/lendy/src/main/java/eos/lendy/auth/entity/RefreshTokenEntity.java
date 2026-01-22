package eos.lendy.auth.entity;

import eos.lendy.user.entity.UserEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_tokens", indexes = {
        @Index(name = "idx_refresh_user", columnList = "user_id"),
        @Index(name = "idx_refresh_expires", columnList = "expiresAt"),
        @Index(name = "idx_refresh_revoked", columnList = "revokedAt"),
        @Index(name = "uk_refresh_token_hash", columnList = "tokenHash", unique = true)
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RefreshTokenEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(nullable = false, length = 64)
    private String tokenHash;

    @Column(nullable = false)
    private LocalDateTime expiresAt;

    @Column
    private LocalDateTime revokedAt;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column
    private LocalDateTime lastUsedAt;

    @Builder
    public RefreshTokenEntity(UserEntity user, String tokenHash, LocalDateTime expiresAt, LocalDateTime createdAt){
        this.user = user;
        this.tokenHash = tokenHash;
        this.expiresAt = expiresAt;
        this.createdAt = createdAt;
    }

    public boolean isActive(LocalDateTime now){
        return revokedAt == null && expiresAt.isAfter(now);
    }

    public boolean isExpired(LocalDateTime now){
        return !expiresAt.isAfter(now);
    }

    public void revoke(LocalDateTime now){
        this.revokedAt = now;
    }

    public void touch(LocalDateTime now){
        this.lastUsedAt = now;
    }
}
