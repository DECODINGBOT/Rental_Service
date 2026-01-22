package eos.lendy.product.dto;

/**
 * Request payload for creating a new product.
 */
public record ProductCreateRequest(
        String title,
        String description,
        String category,
        Integer pricePerDay,
        Integer deposit,
        String location,
        String thumbnailUrl,
        Long ownerUserId
) {}
