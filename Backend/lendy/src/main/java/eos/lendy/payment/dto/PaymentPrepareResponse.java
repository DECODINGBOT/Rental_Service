package eos.lendy.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class PaymentPrepareResponse {
    private String orderId;
    private Long amount;
}
