package eos.lendy.payment.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentEntity {

    @Id @GeneratedValue
    private Long id;

    @Column(unique = true, nullable = false)
    private String orderId;       // 우리 시스템 주문 ID

    private String paymentKey;    // 토스 결제 키

    private Long amount;          // 총 결제 금액 (대여비 + 보증금)

    @Enumerated(EnumType.STRING)
    private PaymentStatus status; // READY, CONFIRMED, CANCELED

    private Long rentalId;        // 어떤 대여에 대한 결제인지

    public void confirm(String paymentKey) {
        if (this.status != PaymentStatus.READY) {
            throw new IllegalStateException("READY 상태만 승인할 수 있습니다.");
        }
        this.paymentKey = paymentKey;
        this.status = PaymentStatus.CONFIRMED;
    }
}

