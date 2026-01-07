package eos.lendy.community.entity;

import jakarta.persistence.*;

@Entity
public class BoardEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String title;

    @Column
    private String content;

    @Column
    private String name;
}
