package eos.lendy.community.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "board_likes",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_board_user_like",
                columnNames = {"board_id", "username"}
        )
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class BoardLikeEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "board_id", nullable = false)
    private CommunityEntity board;

    @Column(nullable = false)
    private String username;
}
