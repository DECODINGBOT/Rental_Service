package eos.lendy.transaction.dto;

/**
 * Request payload for accepting a rental request.
 */
public record TransactionAcceptRequest(
        Long ownerUserId
) {}
