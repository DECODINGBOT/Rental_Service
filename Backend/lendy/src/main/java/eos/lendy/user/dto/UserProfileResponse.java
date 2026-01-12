package eos.lendy.user.dto;

import java.time.LocalDateTime;

public record UserProfileResponse(
        Long id,
        String username,
        LocalDateTime createdAt,
        String profileImageUrl,
        String address,
        String detailAddress,
        String phone,
        String bio
) {
}
