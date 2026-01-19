package eos.lendy.community.dto;

import java.time.LocalDateTime;

public record CommentResponse(
        Long id,
        Long userId,
        String username,
        String profileImageUrl,
        String content,
        LocalDateTime createdAt
) {
}
