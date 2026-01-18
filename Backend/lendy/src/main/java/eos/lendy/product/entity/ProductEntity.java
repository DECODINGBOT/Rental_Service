package eos.lendy.product.entity;

import eos.lendy.user.entity.UserEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * JPA entity representing a rentable product.
 */
@Entity
@Table(name = "products")
@Builder
@Getter
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProductEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Product title shown in list and detail view
    @Column(nullable = false)
    private String title;

    // Detailed description of the product
    @Lob
    @Column(nullable = false)
    private String description;

    // Category name (e.g. bicycle, camera)
    @Column(nullable = false)
    private String category;

    // Rental price per day
    @Column(nullable = false)
    private Integer pricePerDay;

    // Deposit required for rental
    @Column(nullable = false)
    private Integer deposit;

    // Location where the product can be rented
    @Column(nullable = false)
    private String location;

    // Thumbnail image URL
    private String thumbnailUrl;

    // Current rental status
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProductStatus status;

    // Owner (seller) of the product
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private UserEntity owner;

    // Timestamp when the product was created
    @Column(nullable = false)
    private LocalDateTime createdAt;

    // Timestamp when the product was last updated
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    /**
     * Initializes timestamps and default status when the entity is created.
     */
    @PrePersist
    void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
        if (this.status == null) {
            this.status = ProductStatus.AVAILABLE;
        }
    }

    /**
     * Updates the last modified timestamp.
     */
    @PreUpdate
    void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * Updates mutable fields of the product.
     * Null values are ignored to allow partial updates.
     */
    public void update(
            String title,
            String description,
            String category,
            Integer pricePerDay,
            Integer deposit,
            String location,
            String thumbnailUrl,
            ProductStatus status
    ) {
        if (title != null) this.title = title;
        if (description != null) this.description = description;
        if (category != null) this.category = category;
        if (pricePerDay != null) this.pricePerDay = pricePerDay;
        if (deposit != null) this.deposit = deposit;
        if (location != null) this.location = location;
        if (thumbnailUrl != null) this.thumbnailUrl = thumbnailUrl;
        if (status != null) this.status = status;
    }
}
