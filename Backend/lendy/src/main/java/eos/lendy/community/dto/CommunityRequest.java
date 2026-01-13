package eos.lendy.community.dto;

public record CommunityRequest(
        String title,
        String content,
        Long userId
) {
}
