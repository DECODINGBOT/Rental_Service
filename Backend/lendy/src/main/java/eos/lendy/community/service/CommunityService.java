package eos.lendy.community.service;

import eos.lendy.community.dto.CommunityFixRequest;
import eos.lendy.community.dto.CommunityRequest;
import eos.lendy.community.dto.CommunityResponse;
import eos.lendy.community.entity.CommunityEntity;

import java.util.List;

public interface CommunityService {

    void create(CommunityRequest communityRequest);

    CommunityResponse read(Long id);

    List<CommunityResponse> readAll();

    void fix(CommunityFixRequest communityFixRequest);

    void delete(Long id);

    default CommunityEntity requestToEntity(CommunityRequest communityRequest) {
        return CommunityEntity.builder()
                .title(communityRequest.title())
                .content(communityRequest.content())
                .name(communityRequest.name())
                .build();
    }

    default CommunityResponse entityToResponse(CommunityEntity communityEntity){
        return CommunityResponse.builder()
                .id(communityEntity.getId())
                .title(communityEntity.getTitle())
                .content(communityEntity.getContent())
                .name(communityEntity.getName())
                .build();
    }
}