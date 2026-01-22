package eos.lendy.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class PaymentConfirmResponse {
    private String orderId;
    private String paymentKey;
    private Long amount;
    private String status; // CONFIRMED 등
}
