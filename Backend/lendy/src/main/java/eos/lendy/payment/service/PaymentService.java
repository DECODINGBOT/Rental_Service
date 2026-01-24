package eos.lendy.payment.service;

import eos.lendy.payment.client.TossPaymentsClient;
import eos.lendy.payment.dto.*;
import eos.lendy.payment.entity.PaymentEntity;
import eos.lendy.payment.entity.PaymentStatus;
import eos.lendy.payment.repository.PaymentRepository;
import eos.lendy.product.entity.ProductEntity;
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

    private final TransactionRepository transactionRepository;
    private final TransactionService transactionService;

    /**
     * Prepare a payment (issue orderId, lock amount, persist READY payment)
     *
     * actualAmount = (rentalDays * product.pricePerDay) + product.deposit
     */
    @Transactional
    public PaymentPrepareResponse prepare(Long transactionId, Integer rentalDays) {

        if (transactionId == null) {
            throw new IllegalArgumentException("transactionId is required.");
        }
        if (rentalDays == null) {
            throw new IllegalArgumentException("rentalDays is required.");
        }
        if (rentalDays <= 0) {
            throw new IllegalArgumentException("rentalDays must be >= 1.");
        }

        TransactionEntity tx = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("transactionId does not exist."));

        /*
        if (tx.getStatus() != TransactionStatus.ACCEPTED) {
            throw new IllegalStateException(
                    "Payment can be prepared only when transaction is ACCEPTED. Current=" + tx.getStatus()
            );
        }*/

        ProductEntity product = tx.getProduct();
        if (product == null) {
            throw new IllegalStateException("transaction.product is missing.");
        }

        Integer pricePerDay = product.getPricePerDay();
        Integer deposit = product.getDeposit();

        if (pricePerDay == null || pricePerDay < 0) {
            throw new IllegalStateException("product.pricePerDay is invalid.");
        }
        if (deposit == null || deposit < 0) {
            throw new IllegalStateException("product.deposit is invalid.");
        }

        long rentFee = (long) rentalDays * (long) pricePerDay;
        long totalAmount = rentFee + (long) deposit;

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

    @Transactional
    public PaymentConfirmResponse confirm(PaymentConfirmRequest req) {
        PaymentEntity payment = paymentRepository.findByOrderId(req.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("orderId does not exist."));

        if (!payment.getAmount().equals(req.getAmount())) {
            throw new IllegalArgumentException("amount mismatch.");
        }

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

        tossPaymentsClient.confirm(req.getPaymentKey(), req.getOrderId(), req.getAmount());

        payment.confirm(req.getPaymentKey());
        transactionService.markPaid(payment.getTransactionId());

        return new PaymentConfirmResponse(
                payment.getOrderId(),
                payment.getPaymentKey(),
                payment.getAmount(),
                payment.getStatus().name()
        );
    }

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

        if (tx.getStatus() != TransactionStatus.PAID) {
            throw new IllegalStateException("Refund allowed only when transaction is PAID. Current=" + tx.getStatus());
        }

        tossPaymentsClient.cancel(payment.getPaymentKey(), req.getCancelReason(), payment.getAmount());

        payment.cancel();
        transactionService.cancelAfterRefund(payment.getTransactionId());

        return new PaymentCancelResponse(
                payment.getOrderId(),
                payment.getPaymentKey(),
                payment.getAmount(),
                payment.getStatus().name()
        );
    }
}
