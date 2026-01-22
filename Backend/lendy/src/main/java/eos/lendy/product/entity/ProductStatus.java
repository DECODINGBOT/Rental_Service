package eos.lendy.product.entity;

/**
 * Represents the current rental status of a product.
 */
public enum ProductStatus {
    AVAILABLE, // Product can be rented
    RENTED,    // Product is currently rented
    HIDDEN     // Product is hidden from public listing
}
