package eos.lendy.user.service;

import eos.lendy.user.dto.*;
import eos.lendy.user.entity.UserEntity;
import eos.lendy.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService{

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public UserResponse signUp(SignUpRequest request) {
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
        UserEntity saved = userRepository.save(new UserEntity(username, hash, LocalDateTime.now()));

        return new UserResponse(saved.getId(), saved.getUsername(), saved.getCreatedAt());
    }

    @Override
    public UserResponse login(LoginRequest request) {
        String username = normalize(request.username());
        String rawPassword = request.password();

        UserEntity user = userRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("invalid username or password"));

        if(!passwordEncoder.matches(rawPassword, user.getPasswordHash())){
            throw new IllegalArgumentException("invalid username or password");
        }

        return new UserResponse(user.getId(), user.getUsername(), user.getCreatedAt());
    }

    @Override
    public UserProfileResponse getProfile(Long id) {
        UserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));
        return toProfileResponse(user);
    }

    @Transactional
    @Override
    public UserProfileResponse updateProfile(Long id, UserProfileUpdateRequest request) {
        UserEntity user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));
        user.updateProfile(
                request.profileImageUrl(),
                request.address(),
                request.detailAddress(),
                request.phone(),
                request.bio()
        );
        return toProfileResponse(user);
    }

    private UserProfileResponse toProfileResponse(UserEntity user) {
        return new UserProfileResponse(
                user.getId(),
                user.getUsername(),
                user.getCreatedAt(),
                user.getProfileImageUrl(),
                user.getAddress(),
                user.getDetailAddress(),
                user.getPhone(),
                user.getBio()
        );
    }

    private String normalize(String s){
        return s == null ? null : s.trim();
    }
}
