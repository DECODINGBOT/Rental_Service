package eos.lendy.user.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "users", uniqueConstraints = {
        @UniqueConstraint(name = "uk_users_username", columnNames = "username")
})
@Getter
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String username;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column
    private String profileImageUrl;

    @Column
    private String address;

    @Column
    private String detailAddress;

    @Column
    private String phone;

    @Column
    private String bio;

    @Builder
    public UserEntity(String username, String passwordHash, LocalDateTime createdAt){
        this.username = username;
        this.passwordHash = passwordHash;
        this.createdAt = createdAt;
    }

    public void updateProfile(String profileImageUrl, String address, String detailAddress, String phone, String bio){
        if(profileImageUrl != null) {
            this.profileImageUrl = profileImageUrl;
        }
        if(address != null) this.address = address;
        if(detailAddress != null) this.detailAddress = detailAddress;
        if(phone != null) this.phone = phone;
        if(bio != null) this.bio = bio;
    }

    public void updateProfileImageUrl(String profileImageUrl){
        this.profileImageUrl = profileImageUrl;
    }
}
