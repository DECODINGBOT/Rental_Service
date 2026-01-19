package eos.lendy.community.repository;

import eos.lendy.community.entity.BoardImageEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BoardImageRepository extends JpaRepository<BoardImageEntity, Long> {
    List<BoardImageEntity> findByBoard_Id(Long boardId);
}
