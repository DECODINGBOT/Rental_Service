package eos.lendy.payment.controller;

import eos.lendy.payment.dto.*;
import eos.lendy.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/prepare")
    public PaymentPrepareResponse prepare(@RequestBody PaymentPrepareRequest req) {
        return paymentService.prepare(req.getTransactionId());
    }

    @PostMapping("/confirm")
    public PaymentConfirmResponse confirm(@RequestBody PaymentConfirmRequest req) {
        return paymentService.confirm(req);
    }

    @PostMapping("/cancel")
    public PaymentCancelResponse cancel(@RequestBody PaymentCancelRequest req) {
        return paymentService.cancel(req);
    }
}
