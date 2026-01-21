package eos.lendy.transaction.controller;

import eos.lendy.transaction.dto.*;
import eos.lendy.transaction.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * REST controller for rental transaction APIs.
 */
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
    public TransactionResponse accept(
            @PathVariable Long id,
            @RequestBody TransactionAcceptRequest request
    ) {
        return transactionService.accept(id, request);
    }

    @PostMapping("/{id}/pay")
    public TransactionResponse pay(@PathVariable Long id) {
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
}
