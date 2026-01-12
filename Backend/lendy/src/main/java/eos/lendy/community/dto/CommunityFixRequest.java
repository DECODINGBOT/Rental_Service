package eos.lendy.community.dto;

public record CommunityFixRequest(
        Long id,
        String title,
        String content,
        String name
) {
}
