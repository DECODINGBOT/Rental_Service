package eos.lendy.community.entity;

import eos.lendy.user.entity.UserEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "board_likes",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_board_user_like",
                columnNames = {"board_id", "user_id"}
        )
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BoardLikeEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "board_id", nullable = false)
    private CommunityEntity board;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Builder
    public BoardLikeEntity(CommunityEntity board, UserEntity user){
        this.board = board;
        this.user = user;
    }
}
