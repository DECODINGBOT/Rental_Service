package eos.lendy.transaction.controller;

import eos.lendy.transaction.dto.*;
import eos.lendy.transaction.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/transactions")
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping
    public TransactionResponse create(@RequestBody TransactionCreateRequest request) {
        return transactionService.create(request);
    }

    @PostMapping("/{id}/accept")
    public TransactionResponse accept(@PathVariable Long id, @RequestBody TransactionAcceptRequest request) {
        return transactionService.accept(id, request);
    }

    @PostMapping("/{id}/pay")
    public TransactionResponse markPaid(@PathVariable Long id) {
        return transactionService.markPaid(id);
    }

    @PostMapping("/{id}/start")
    public TransactionResponse startRental(
            @PathVariable Long id,
            @RequestParam LocalDateTime startAt,
            @RequestParam LocalDateTime endAt
    ) {
        return transactionService.startRental(id, startAt, endAt);
    }

    @PostMapping("/{id}/return")
    public TransactionResponse returnProduct(@PathVariable Long id) {
        return transactionService.returnProduct(id);
    }

    /**
     * Cancel before payment (REQUESTED/ACCEPTED).
     * For post-payment refund, use /api/payments/cancel and the server will propagate cancelAfterRefund.
     */
    @PostMapping("/{id}/cancel")
    public TransactionResponse cancel(@PathVariable Long id, @RequestBody(required = false) TransactionCancelRequest req) {
        return transactionService.cancel(id);
    }

    /*
    // TransactionController.java 에 추가
    @GetMapping("/renter/{renterUserId}")
    public java.util.List<TransactionResponse> listByRenter(@PathVariable Long renterUserId) {
        return transactionService.listByRenter(renterUserId);
    }

    @GetMapping("/owner/{ownerUserId}")
    public java.util.List<TransactionResponse> listByOwner(@PathVariable Long ownerUserId) {
        return transactionService.listByOwner(ownerUserId);
    }
    
     */
}
