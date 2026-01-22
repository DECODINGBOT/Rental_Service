package eos.lendy.payment.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentEntity {

    @Id
    @GeneratedValue
    private Long id;

    @Column(unique = true, nullable = false)
    private String orderId;       // Internal order ID

    private String paymentKey;    // Toss payment key

    private Long amount;          // Total amount (rent fee + deposit)

    @Enumerated(EnumType.STRING)
    private PaymentStatus status; // READY, CONFIRMED, CANCELED

    /**
     * The transaction this payment belongs to.
     * In this project, Transaction is the single source of truth for the rental lifecycle,
     * so Payment references transactionId.
     */
    @Column(nullable = false)
    private Long transactionId;

    public void confirm(String paymentKey) {
        if (this.status != PaymentStatus.READY) {
            throw new IllegalStateException("Only READY payments can be confirmed.");
        }
        this.paymentKey = paymentKey;
        this.status = PaymentStatus.CONFIRMED;
    }

    public void cancel() {
        if (this.status != PaymentStatus.CONFIRMED) {
            throw new IllegalStateException("Only CONFIRMED payments can be canceled.");
        }
        this.status = PaymentStatus.CANCELED;
    }
}
