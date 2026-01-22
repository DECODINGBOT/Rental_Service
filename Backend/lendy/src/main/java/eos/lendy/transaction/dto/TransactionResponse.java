package eos.lendy.transaction.dto;

import eos.lendy.transaction.entity.TransactionStatus;

import java.time.LocalDateTime;

/**
 * Response model for transaction information.
 */
public record TransactionResponse(
        Long id,
        Long productId,
        Long renterUserId,
        Long ownerUserId,
        TransactionStatus status,
        LocalDateTime startAt,
        LocalDateTime endAt,
        LocalDateTime createdAt
) {}
