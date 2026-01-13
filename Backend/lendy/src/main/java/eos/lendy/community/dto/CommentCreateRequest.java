package eos.lendy.community.dto;

public record CommentCreateRequest(
        String username,
        String content
) {
}
