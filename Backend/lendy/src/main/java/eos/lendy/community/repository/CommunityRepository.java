package eos.lendy.community.repository;

import eos.lendy.community.entity.CommunityEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CommunityRepository extends JpaRepository<CommunityEntity, Long> {
}
