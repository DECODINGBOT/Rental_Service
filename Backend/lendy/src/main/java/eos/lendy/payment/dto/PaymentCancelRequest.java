package eos.lendy.payment.dto;

import lombok.Getter;

@Getter
public class PaymentCancelRequest {
    private String orderId;
    private String cancelReason;
}
