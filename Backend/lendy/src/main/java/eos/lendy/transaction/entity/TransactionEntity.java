package eos.lendy.transaction.entity;

import eos.lendy.product.entity.ProductEntity;
import eos.lendy.user.entity.UserEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

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

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private ProductEntity product;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "renter_user_id", nullable = false)
    private UserEntity renter;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private UserEntity owner;

    private LocalDateTime startAt;
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

    public void accept() {
        if (this.status != TransactionStatus.REQUESTED) {
            throw new IllegalStateException("Only REQUESTED transactions can be accepted.");
        }
        this.status = TransactionStatus.ACCEPTED;
    }

    public void markPaid() {
        if (this.status != TransactionStatus.ACCEPTED) {
            throw new IllegalStateException("Payment is allowed only after acceptance (ACCEPTED).");
        }
        this.status = TransactionStatus.PAID;
    }

    public void cancelBeforePayment() {
        if (this.status != TransactionStatus.REQUESTED && this.status != TransactionStatus.ACCEPTED) {
            throw new IllegalStateException("Only REQUESTED/ACCEPTED transactions can be canceled before payment.");
        }
        this.status = TransactionStatus.CANCELED;
    }

    public void cancelAfterRefund() {
        if (this.status != TransactionStatus.PAID) {
            throw new IllegalStateException("Only PAID transactions can be canceled after refund.");
        }
        this.status = TransactionStatus.CANCELED;
    }

    public void startRental(LocalDateTime startAt, LocalDateTime endAt) {
        if (this.status != TransactionStatus.PAID) {
            throw new IllegalStateException("Rental can start only after payment (PAID).");
        }
        this.startAt = startAt;
        this.endAt = endAt;
        this.status = TransactionStatus.RENTED;
    }

    public void returnProduct() {
        if (this.status != TransactionStatus.RENTED) {
            throw new IllegalStateException("Only RENTED transactions can be returned.");
        }
        this.status = TransactionStatus.RETURNED;
    }
}
