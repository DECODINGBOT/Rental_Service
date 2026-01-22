package eos.lendy.payment.service;

import eos.lendy.payment.client.TossPaymentsClient;
import eos.lendy.payment.dto.*;
import eos.lendy.payment.entity.PaymentEntity;
import eos.lendy.payment.entity.PaymentStatus;
import eos.lendy.payment.repository.PaymentRepository;
import eos.lendy.transaction.entity.TransactionEntity;
import eos.lendy.transaction.entity.TransactionStatus;
import eos.lendy.transaction.repository.TransactionRepository;
import eos.lendy.transaction.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final TossPaymentsClient tossPaymentsClient;

    // Needed to validate transaction state during prepare/cancel
    private final TransactionRepository transactionRepository;

    // Needed to propagate payment outcomes to transaction state transitions
    private final TransactionService transactionService;

    /**
     * Prepare a payment (issue orderId, lock amount, persist READY payment)
     */
    @Transactional
    public PaymentPrepareResponse prepare(Long transactionId) {

        TransactionEntity tx = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("transactionId does not exist."));

        if (tx.getStatus() != TransactionStatus.ACCEPTED) {
            throw new IllegalStateException("Payment can be prepared only when transaction is ACCEPTED. Current=" + tx.getStatus());
        }

        // TODO: Replace with real pricing logic (duration-based rent fee, deposit policy, etc.)
        long rentFee = 10000L;
        long deposit = 5000L;
        long totalAmount = rentFee + deposit;

        String orderId = UUID.randomUUID().toString();

        PaymentEntity payment = PaymentEntity.builder()
                .orderId(orderId)
                .amount(totalAmount)
                .status(PaymentStatus.READY)
                .transactionId(transactionId)
                .build();

        paymentRepository.save(payment);

        return new PaymentPrepareResponse(orderId, totalAmount);
    }

    /**
     * Confirm payment
     * - Toss confirm succeeds
     * - Payment -> CONFIRMED
     * - Transaction -> PAID (propagated)
     */
    @Transactional
    public PaymentConfirmResponse confirm(PaymentConfirmRequest req) {

        PaymentEntity payment = paymentRepository.findByOrderId(req.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("orderId does not exist."));

        // Anti-tampering: FE amount must match server-stored amount
        if (!payment.getAmount().equals(req.getAmount())) {
            throw new IllegalArgumentException("amount mismatch.");
        }

        // Idempotency: if already confirmed, return as-is
        if (payment.getStatus() == PaymentStatus.CONFIRMED) {
            return new PaymentConfirmResponse(
                    payment.getOrderId(),
                    payment.getPaymentKey(),
                    payment.getAmount(),
                    payment.getStatus().name()
            );
        }

        if (payment.getStatus() != PaymentStatus.READY) {
            throw new IllegalStateException("Only READY payments can be confirmed. Current=" + payment.getStatus());
        }

        // Toss confirm must succeed before we mutate DB state
        tossPaymentsClient.confirm(req.getPaymentKey(), req.getOrderId(), req.getAmount());

        payment.confirm(req.getPaymentKey());

        // Propagate to transaction state
        transactionService.markPaid(payment.getTransactionId());

        return new PaymentConfirmResponse(
                payment.getOrderId(),
                payment.getPaymentKey(),
                payment.getAmount(),
                payment.getStatus().name()
        );
    }

    /**
     * Cancel payment (refund)
     * - Payment must be CONFIRMED
     * - Transaction must be PAID (full refund allowed only before rental starts)
     * - Toss cancel succeeds
     * - Payment -> CANCELED
     * - Transaction -> CANCELED (propagated)
     */
    @Transactional
    public PaymentCancelResponse cancel(PaymentCancelRequest req) {

        PaymentEntity payment = paymentRepository.findByOrderId(req.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("orderId does not exist."));

        if (payment.getStatus() == PaymentStatus.CANCELED) {
            return new PaymentCancelResponse(
                    payment.getOrderId(),
                    payment.getPaymentKey(),
                    payment.getAmount(),
                    payment.getStatus().name()
            );
        }

        if (payment.getStatus() != PaymentStatus.CONFIRMED) {
            throw new IllegalStateException("Only CONFIRMED payments can be canceled. Current=" + payment.getStatus());
        }

        TransactionEntity tx = transactionRepository.findById(payment.getTransactionId())
                .orElseThrow(() -> new IllegalArgumentException("transaction not found."));

        // Policy: allow full refund only before rental starts (PAID)
        if (tx.getStatus() != TransactionStatus.PAID) {
            throw new IllegalStateException("Refund allowed only when transaction is PAID. Current=" + tx.getStatus());
        }

        // Toss cancel must succeed before we mutate DB state
        tossPaymentsClient.cancel(payment.getPaymentKey(), req.getCancelReason(), payment.getAmount());

        payment.cancel();

        // Propagate to transaction state
        transactionService.cancelAfterRefund(payment.getTransactionId());

        return new PaymentCancelResponse(
                payment.getOrderId(),
                payment.getPaymentKey(),
                payment.getAmount(),
                payment.getStatus().name()
        );
    }
}
