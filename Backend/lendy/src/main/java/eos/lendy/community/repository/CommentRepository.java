package eos.lendy.community.repository;

import eos.lendy.community.entity.CommentEntity;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface CommentRepository extends JpaRepository<CommentEntity, Long> {
    long countByBoard_Id(Long boardId);
    List<CommentEntity> findByBoard_Id(Long boardId, Sort sort);

    @Query("""
            select c.board.id as boardId, count(c) as cnt
            from CommentEntity c
            where c.board.id in :ids
            group by c.board.id
    """)
    List<BoardCountProjection> countByBoardIds(@Param("ids") List<Long> ids);
}
