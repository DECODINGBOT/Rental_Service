package eos.lendy.community.repository;

import eos.lendy.community.entity.BoardLikeEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface BoardLikeRepository extends JpaRepository<BoardLikeEntity, Long> {
    long countByBoard_Id(Long boardId);
    Optional<BoardLikeEntity> findByBoard_IdAndUser_Id(Long boardId, Long userId);
    boolean existsByBoard_IdAndUser_Id(Long boardId, Long userId);
    void deleteByBoard_IdAndUser_Id(Long boardId, Long userId);

    @Query("""
            select bl.board.id as boardId, count(bl) as cnt
            from BoardLikeEntity bl
            where bl.board.id in :ids
            group by bl.board.id
    """)
    List<BoardCountProjection> countByBoardIds(@Param("ids") List<Long> ids);
}
