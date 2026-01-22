package eos.lendy.transaction.service;

import eos.lendy.transaction.dto.*;

import java.time.LocalDateTime;

public interface TransactionService {

    TransactionResponse create(TransactionCreateRequest request);

    TransactionResponse accept(Long transactionId, TransactionAcceptRequest request);

    TransactionResponse markPaid(Long transactionId);

    TransactionResponse startRental(Long transactionId, LocalDateTime startAt, LocalDateTime endAt);

    TransactionResponse returnProduct(Long transactionId);

    TransactionResponse cancel(Long transactionId);

    TransactionResponse cancelAfterRefund(Long transactionId);
}
