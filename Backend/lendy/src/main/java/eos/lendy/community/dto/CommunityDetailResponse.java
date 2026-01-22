package eos.lendy.community.dto;

import java.time.LocalDateTime;
import java.util.List;

public record CommunityDetailResponse(
        Long id,
        String title,
        String content,
        String username,
        String profileImageUrl,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        long likeCount,
        long commentCount,
        boolean liked,
        List<CommentResponse> comments,
        List<String> imageUrls
) {
}
