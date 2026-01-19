package eos.lendy.community.dto;

public record CommentCreateRequest(
        Long userId,
        String content
) {
}
