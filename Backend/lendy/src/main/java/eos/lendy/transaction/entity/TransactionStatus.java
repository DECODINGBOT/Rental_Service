package eos.lendy.transaction.entity;

/**
 * Represents the lifecycle status of a rental transaction.
 */
public enum TransactionStatus {
    REQUESTED,   // Rental request created by renter
    ACCEPTED,    // Accepted by product owner
    PAID,        // Payment completed
    RENTED,      // Product is currently rented
    RETURNED,    // Product returned by renter
    CANCELED     // Request canceled or rejected
}
