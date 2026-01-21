package eos.lendy.transaction.dto;

/**
 * Request payload for creating a rental request.
 */
public record TransactionCreateRequest(
        Long productId,
        Long renterUserId
) {}
