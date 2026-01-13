package eos.lendy.community.service;

import eos.lendy.community.dto.*;
import eos.lendy.community.entity.CommunityEntity;

import java.util.List;

public interface CommunityService {

    CommunityDetailResponse create(CommunityRequest request);
    CommunityDetailResponse read(Long id);
    List<CommunityListResponse> readAllLatest();
    void fix(Long id, CommunityFixRequest request);
    void delete(Long id);
    CommentResponse addComment(Long boardId, CommentCreateRequest request);
    List<CommentResponse> listCommentsLatest(Long boardId);
    LikeToggleResponse toggleLike(Long boardId, String username);

    /*
    default CommunityEntity requestToEntity(CommunityRequest request) {
        return CommunityEntity.builder()
                .title(request.title())
                .content(request.content())
                .username(request.username())
                .build();
    }

    default CommunityResponse entityToResponse(CommunityEntity communityEntity){
        return CommunityResponse.builder()
                .id(communityEntity.getId())
                .title(communityEntity.getTitle())
                .content(communityEntity.getContent())
                .name(communityEntity.getUsername())
                .build();
    }

     */
}