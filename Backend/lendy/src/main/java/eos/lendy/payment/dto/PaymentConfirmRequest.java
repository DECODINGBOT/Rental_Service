package eos.lendy.payment.dto;

import lombok.Getter;

@Getter
public class PaymentConfirmRequest {
    private String paymentKey;
    private String orderId;
    private Long amount;
}
