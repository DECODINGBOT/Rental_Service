package eos.lendy.community.dto;

import lombok.Builder;

@Builder
public record CommunityResponse(
        Long id,
        String title,
        String content,
        String name
) {
}
