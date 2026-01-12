package eos.lendy.user.dto;

import java.time.LocalDateTime;

public record UserResponse (
        Long id,
        String username,
        LocalDateTime createdAt
){}
