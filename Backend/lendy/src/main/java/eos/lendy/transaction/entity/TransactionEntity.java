package eos.lendy.transaction.entity;

import eos.lendy.product.entity.ProductEntity;
import eos.lendy.user.entity.UserEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * JPA entity representing a rental transaction.
 */
@Entity
@Table(name = "transactions")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class TransactionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Product being rented
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private ProductEntity product;

    // User who rents the product
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "renter_user_id", nullable = false)
    private UserEntity renter;

    // Product owner
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private UserEntity owner;

    // Rental start date
    private LocalDateTime startAt;

    // Rental end date
    private LocalDateTime endAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionStatus status;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
        if (this.status == null) {
            this.status = TransactionStatus.REQUESTED;
        }
    }

    @PreUpdate
    void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * Accepts the rental request.
     */
    public void accept() {
        if (this.status != TransactionStatus.REQUESTED) {
            throw new IllegalStateException("Only requested transaction can be accepted");
        }
        this.status = TransactionStatus.ACCEPTED;
    }

    /**
     * Marks the transaction as paid.
     */
    public void markPaid() {
        if (this.status != TransactionStatus.ACCEPTED) {
            throw new IllegalStateException("Payment allowed only after acceptance");
        }
        this.status = TransactionStatus.PAID;
    }

    /**
     * Starts the rental.
     */
    public void startRental(LocalDateTime startAt, LocalDateTime endAt) {
        if (this.status != TransactionStatus.PAID) {
            throw new IllegalStateException("Rental can start only after payment");
        }
        this.startAt = startAt;
        this.endAt = endAt;
        this.status = TransactionStatus.RENTED;
    }

    /**
     * Completes the rental and marks the product as returned.
     */
    public void returnProduct() {
        if (this.status != TransactionStatus.RENTED) {
            throw new IllegalStateException("Only rented transaction can be returned");
        }
        this.status = TransactionStatus.RETURNED;
    }
}
