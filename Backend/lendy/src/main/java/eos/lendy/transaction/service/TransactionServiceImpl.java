package eos.lendy.transaction.service;

import eos.lendy.product.entity.ProductEntity;
import eos.lendy.product.entity.ProductStatus;
import eos.lendy.product.repository.ProductRepository;
import eos.lendy.transaction.dto.*;
import eos.lendy.transaction.entity.TransactionEntity;
import eos.lendy.transaction.repository.TransactionRepository;
import eos.lendy.user.entity.UserEntity;
import eos.lendy.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * Implementation of rental transaction business logic.
 */
@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements TransactionService {

    private final TransactionRepository transactionRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    @Transactional
    @Override
    public TransactionResponse create(TransactionCreateRequest request) {
        ProductEntity product = productRepository.findById(request.productId())
                .orElseThrow(() -> new IllegalArgumentException("product not found"));

        UserEntity renter = userRepository.findById(request.renterUserId())
                .orElseThrow(() -> new IllegalArgumentException("renter not found"));

        UserEntity owner = product.getOwner();

        if (product.getStatus() != ProductStatus.AVAILABLE) {
            throw new IllegalStateException("product is not available");
        }

        TransactionEntity tx = transactionRepository.save(
                TransactionEntity.builder()
                        .product(product)
                        .renter(renter)
                        .owner(owner)
                        .build()
        );

        return toResponse(tx);
    }

    @Transactional
    @Override
    public TransactionResponse accept(Long transactionId, TransactionAcceptRequest request) {
        TransactionEntity tx = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("transaction not found"));

        if (!tx.getOwner().getId().equals(request.ownerUserId())) {
            throw new IllegalStateException("only owner can accept the request");
        }

        tx.accept();
        return toResponse(tx);
    }

    @Transactional
    @Override
    public TransactionResponse markPaid(Long transactionId) {
        TransactionEntity tx = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("transaction not found"));

        tx.markPaid();
        return toResponse(tx);
    }

    @Transactional
    @Override
    public TransactionResponse startRental(Long transactionId, LocalDateTime startAt, LocalDateTime endAt) {
        TransactionEntity tx = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("transaction not found"));

        tx.startRental(startAt, endAt);
        tx.getProduct().update(null, null, null, null, null, null, null, ProductStatus.RENTED);

        return toResponse(tx);
    }

    @Transactional
    @Override
    public TransactionResponse returnProduct(Long transactionId) {
        TransactionEntity tx = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("transaction not found"));

        tx.returnProduct();
        tx.getProduct().update(null, null, null, null, null, null, null, ProductStatus.AVAILABLE);

        return toResponse(tx);
    }

    private TransactionResponse toResponse(TransactionEntity tx) {
        return new TransactionResponse(
                tx.getId(),
                tx.getProduct().getId(),
                tx.getRenter().getId(),
                tx.getOwner().getId(),
                tx.getStatus(),
                tx.getStartAt(),
                tx.getEndAt(),
                tx.getCreatedAt()
        );
    }
}
