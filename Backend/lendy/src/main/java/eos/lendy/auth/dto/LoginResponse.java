package eos.lendy.auth.dto;

import eos.lendy.user.dto.UserResponse;

public record LoginResponse(
        String accessToken,
        String refreshToken,
        UserResponse user
) {}
