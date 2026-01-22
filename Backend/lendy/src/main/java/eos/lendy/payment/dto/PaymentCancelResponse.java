package eos.lendy.payment.dto;

public record PaymentCancelResponse(
        String orderId,
        String paymentKey,
        Long amount,
        String status
) {}
