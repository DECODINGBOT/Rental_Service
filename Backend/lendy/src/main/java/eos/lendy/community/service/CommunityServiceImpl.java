package eos.lendy.community.service;

import eos.lendy.community.dto.CommunityFixRequest;
import eos.lendy.community.dto.CommunityRequest;
import eos.lendy.community.dto.CommunityResponse;
import eos.lendy.community.entity.CommunityEntity;
import eos.lendy.community.repository.CommunityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommunityServiceImpl implements CommunityService {

    private final CommunityRepository communityRepository;

    @Override
    public void create(CommunityRequest communityRequest) {
        communityRepository.save(requestToEntity(communityRequest));
    }

    @Override
    public CommunityResponse read(Long id) {
        CommunityEntity communityEntity = communityRepository.findById(id).get();
        return entityToResponse(communityEntity);
    }

    @Override
    public List<CommunityResponse> readAll() {
        List<CommunityEntity> communityEntityList = (List<CommunityEntity>) communityRepository.findAll();
        return communityEntityList.stream()
                .map(this::entityToResponse)
                .toList();
    }

    @Override
    public void fix(CommunityFixRequest communityFixRequest) {
        CommunityEntity communityEntity = communityRepository.findById(communityFixRequest.id()).get();
        communityEntity.fix(communityFixRequest);
        communityRepository.save(communityEntity);
    }

    @Override
    public void delete(Long id) {
        communityRepository.deleteById(id);
    }
}
