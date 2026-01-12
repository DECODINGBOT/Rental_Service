package eos.lendy.user.dto;

public record UserProfileUpdateRequest(
        String profileImageUrl,
        String address,
        String detailAddress,
        String phone,
        String bio
) {
}
