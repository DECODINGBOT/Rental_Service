package eos.lendy.payment.dto;

import lombok.Getter;

@Getter
public class PaymentPrepareRequest {
    private Long transactionId;
    private Integer rentalDays; // NEW: 대여일수(일 단위)
}
