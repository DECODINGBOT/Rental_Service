package eos.lendy.community.dto;

public record LikeToggleResponse(
        boolean liked,
        long likeCount
) {
}
