package eos.lendy.community.dto;

import java.time.LocalDateTime;

public record CommunityListResponse(
        Long id,
        String title,
        String preview,
        String username,
        String profileImageUrl,
        LocalDateTime createdAt,
        long likeCount,
        long commentCount
) {
}
