package eos.lendy.community.entity;

import eos.lendy.community.dto.CommunityFixRequest;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Builder
@Getter
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommunityEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String title;

    @Column
    private String content;

    @Column
    private String name;

    public void fix(CommunityFixRequest communityFixRequest){
        this.title = communityFixRequest.title();
        this.content = communityFixRequest.content();
        this.name = communityFixRequest.name();
    }
}
