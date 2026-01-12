package eos.lendy.user.repository;

import eos.lendy.user.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {
    boolean existsByUsername(String username);
    //Optional<UserEntity> findById(Long id);
    Optional<UserEntity> findByUsername(String username);
}
