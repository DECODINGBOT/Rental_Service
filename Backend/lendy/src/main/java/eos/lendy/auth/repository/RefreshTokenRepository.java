package eos.lendy.auth.repository;

import eos.lendy.auth.entity.RefreshTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.Optional;

public interface RefreshTokenRepository extends JpaRepository<RefreshTokenEntity, Long> {
    Optional<RefreshTokenEntity> findByTokenHash(String tokenHash);
    long deleteByUser_Id(Long userId);
    long deleteByExpiresAtBefore(LocalDateTime now);
}
