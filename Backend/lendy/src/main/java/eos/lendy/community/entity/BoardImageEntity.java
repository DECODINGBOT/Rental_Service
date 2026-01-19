package eos.lendy.community.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "board_images")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BoardImageEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "board_id", nullable = false)
    private CommunityEntity board;

    @Column(nullable = false)
    private String imageUrl;

    @Builder
    public BoardImageEntity(CommunityEntity board, String imageUrl){
        this.board = board;
        this.imageUrl = imageUrl;
    }
}
